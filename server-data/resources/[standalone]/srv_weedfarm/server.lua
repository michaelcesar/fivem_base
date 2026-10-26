-- Servidor: persistent weed growing. Unlike srv_jobs, state has to survive a restart and keep
-- growing while nobody is online, so it lives in the database, not in an in-memory table keyed
-- by `source`. `plants` here is a server-side read cache of that table, kept in sync on every
-- write - the database itself stays the source of truth, this just avoids a query on every
-- status check.

local TABLE_NAME = 'srv_weedfarm_plants'
local STOCK_TABLE = 'srv_weedfarm_stock'
-- Servidor: bricks converted per player per day, the ledger the selling cap is checked against.
local SALES_TABLE = 'srv_weedfarm_brick_sales'
-- Servidor: units bought per player per day, the ledger the BUYING cap is checked against. This
-- is the table ADR-089 retired when the cap briefly moved entirely to selling; it holds exactly
-- the fact needed again, so it is reused rather than replaced. See ADR-090.
local PURCHASES_TABLE = 'srv_weedfarm_bag_purchases'

---@type table<string, {citizenid: string, strain: string, plantedAt: number, boosts: number}>
local plants = {}

-- Servidor: the dealer's retail bag stock - shared across every player, not per-citizenid, since
-- anyone can buy from it once a brick has restocked it (same open-access shape as ADR-057's
-- harvest). A single-row table rather than a bare in-memory counter for the same reason plants
-- live in the database: it has to survive a restart, not reset to zero every boot.
-- Servidor: the dealer holds ONE stock per retail form, not one pool split two ways. A brick
-- sold is converted into whichever form the seller chose, and that is the only thing that
-- restocks it - so what a buyer sees on each card is the real, separate supply of that item.
-- Shared across every player rather than per-citizenid, same open-access rule as ADR-057.
-- See ADR-089.
local bagStock = 0
local consumerStock = 0

-- Servidor: plot keys are validated against this map on every callback below, since the key
-- comes from the client and has to resolve to one of the farm's 9 real spots, not an arbitrary
-- string. Also gives plant/harvest each plot's own real coords, so a player has to be at that
-- specific spot, not just somewhere in the farm.
local plotByKey = {}
for i = 1, #Config.plots do
    plotByKey[Config.plots[i].key] = Config.plots[i]
end

CreateThread(function()
    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS %s (
            plot VARCHAR(1) NOT NULL PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL,
            strain VARCHAR(50) NOT NULL,
            planted_at BIGINT NOT NULL
        )
    ]]):format(TABLE_NAME))

    -- Servidor: `boosts` was added after this table already existed on a live database, so it has
    -- to be an ALTER rather than part of the CREATE above - a CREATE TABLE IF NOT EXISTS is a
    -- no-op against an existing table and would silently never add the column. `IF NOT EXISTS` on
    -- ADD COLUMN is MariaDB-specific and makes the migration idempotent across restarts. See
    -- ADR-082.
    MySQL.query.await(('ALTER TABLE %s ADD COLUMN IF NOT EXISTS boosts INT NOT NULL DEFAULT 0'):format(TABLE_NAME))

    local rows = MySQL.query.await('SELECT * FROM ' .. TABLE_NAME)
    for i = 1, #rows do
        plants[rows[i].plot] = { citizenid = rows[i].citizenid, strain = rows[i].strain,
            plantedAt = rows[i].planted_at, boosts = rows[i].boosts or 0 }
    end

    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS %s (
            id TINYINT NOT NULL PRIMARY KEY DEFAULT 1,
            count INT NOT NULL DEFAULT 0
        )
    ]]):format(STOCK_TABLE))
    MySQL.query.await(('INSERT IGNORE INTO %s (id, count) VALUES (1, 0)'):format(STOCK_TABLE))

    -- Servidor: `count` is the plain bag and predates the split; `consumer_count` is the second
    -- form. Added by ALTER for the same reason `boosts` was (ADR-082) - a CREATE TABLE IF NOT
    -- EXISTS is a no-op against a table that already exists on the live database.
    MySQL.query.await(('ALTER TABLE %s ADD COLUMN IF NOT EXISTS consumer_count INT NOT NULL DEFAULT 0')
        :format(STOCK_TABLE))

    local stockRow = MySQL.single.await(('SELECT count, consumer_count FROM %s WHERE id = 1'):format(STOCK_TABLE))
    bagStock = stockRow and stockRow.count or 0
    consumerStock = stockRow and stockRow.consumer_count or 0

    -- Servidor: the daily cap moved from buying to SELLING (ADR-089), so what has to be counted
    -- per player per day is bricks converted into each form - not units bought. That is a
    -- different fact from what the old `_bag_purchases` table held, so it gets its own table
    -- rather than reusing those columns with a changed meaning. The old table is deliberately
    -- left in place, untouched: dropping a table with real rows is destructive, and it is a
    -- record of purchases that actually happened.
    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS %s (
            citizenid VARCHAR(50) NOT NULL,
            sale_date DATE NOT NULL,
            bag_count INT NOT NULL DEFAULT 0,
            consumer_count INT NOT NULL DEFAULT 0,
            PRIMARY KEY (citizenid, sale_date)
        )
    ]]):format(SALES_TABLE))

    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS %s (
            citizenid VARCHAR(50) NOT NULL,
            purchase_date DATE NOT NULL,
            count INT NOT NULL DEFAULT 0,
            PRIMARY KEY (citizenid, purchase_date)
        )
    ]]):format(PURCHASES_TABLE))

    -- Servidor: `count` is the plain bag and predates the split; `consumer_count` is the second
    -- form. ALTER rather than part of the CREATE above, same reason as everywhere else here - a
    -- CREATE TABLE IF NOT EXISTS is a no-op against a table that already exists.
    MySQL.query.await(('ALTER TABLE %s ADD COLUMN IF NOT EXISTS consumer_count INT NOT NULL DEFAULT 0')
        :format(PURCHASES_TABLE))
end)

--- Adds `amount` units to ONE form's stock, in memory and in the database - called once per
--- successful brick sale, with the form the seller chose. `form` is never client-supplied: it is
--- resolved from a validated item name before this is reached. See ADR-089.
---@param form 'bag'|'consumer'
---@param amount number
local function restock(form, amount)
    if form == 'consumer' then
        consumerStock += amount
        MySQL.query(('UPDATE %s SET consumer_count = consumer_count + ? WHERE id = 1'):format(STOCK_TABLE),
            { amount })
    else
        bagStock += amount
        MySQL.query(('UPDATE %s SET count = count + ? WHERE id = 1'):format(STOCK_TABLE), { amount })
    end
end

-- Servidor: a generous sanity ceiling, not a real business limit - just rules out a client
-- reporting something absurd (fractional, negative, zero, or a huge number) before any of the
-- real limits below (owned count, stock, daily cap, seedPurchaseCeiling) are even checked.
local SANE_AMOUNT_CEILING = 9999

--- True if `amount` is a real positive integer within `SANE_AMOUNT_CEILING` - the one shape check
--- every quantity-based callback below starts with. Each callback then checks its own real limit
--- separately, so a rejection tells the player *why* (not enough owned, not enough stock, past
--- the daily cap, past the seed ceiling) instead of one generic failure covering all of them.
local function isValidAmount(amount)
    return type(amount) == 'number' and amount == math.floor(amount) and amount >= 1 and amount <= SANE_AMOUNT_CEILING
end

local function getCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

--- True if `source`'s real, server-read ped position is within `maxDist` of `coords` - same
--- shape as srv_jobs' own `isPlayerWithin`, kept here rather than shared since resources can't
--- share a local across FXServer's per-resource script environments.
local function isPlayerWithin(source, coords, maxDist)
    return #(GetEntityCoords(GetPlayerPed(source)) - coords) <= maxDist
end

---@param seedItem string
local function findStrainBySeed(seedItem)
    for i = 1, #Config.strains do
        if Config.strains[i].seed == seedItem then return Config.strains[i] end
    end
end

-- Servidor: `os` doesn't exist client-side in FiveM (`os.time` there is a nil-index crash, caught
-- live - "attempt to index a nil value (global 'os')") - every elapsed-growth number the client
-- displays (the plot prompt's countdown, the growth-stage prop fraction) is computed here, with
-- the server's own real `os.time()`, and handed over pre-computed. The client never calls
-- `os.time()` itself again.
---@param plant {citizenid: string, strain: string, plantedAt: number, boosts: number}
local function withGrowthState(plant)
    local elapsed = os.time() - plant.plantedAt
    local total = Config.growthMinutes * 60

    return {
        citizenid = plant.citizenid,
        strain = plant.strain,
        plantedAt = plant.plantedAt,
        ready = elapsed >= total,
        secondsLeft = math.max(0, total - elapsed),
        fraction = elapsed / total,
        -- Servidor: sent so the plot prompt can say how many applications are left without the
        -- client having to track any of it - the cap itself is enforced server-side in `boost`.
        boosts = plant.boosts,
        boostsLeft = math.max(0, Config.maxBoosts - plant.boosts),
    }
end

--- The client never gets pushed updates - it asks for the current state once on start and again
--- after its own plant/harvest, and periodically while idle (see client.lua). A stale read here
--- only ever shows the wrong prompt or growth-stage prop for a few seconds; every action below
--- re-validates for real, so staleness is a display quirk, never a security gap.
lib.callback.register('srv_weedfarm:server:getPlants', function(source)
    local withState = {}
    for plot, plant in pairs(plants) do
        withState[plot] = withGrowthState(plant)
    end
    return withState
end)

lib.callback.register('srv_weedfarm:server:plant', function(source, plot, seedItem)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    local plotConfig = plotByKey[plot]
    if not plotConfig then return { ok = false } end
    if plants[plot] then return { ok = false, reason = 'occupied' } end
    if not isPlayerWithin(source, plotConfig.coords.xyz, Config.plotDistance) then
        return { ok = false, reason = 'far' }
    end

    -- Servidor: the seed item name comes from the client, so it has to be one of this farm's real
    -- strains, not an arbitrary item name - otherwise a client could claim any item is a "seed"
    -- and get it silently swallowed here for nothing.
    local strain = findStrainBySeed(seedItem)
    if not strain then return { ok = false } end

    if not exports.ox_inventory:RemoveItem(source, seedItem, 1) then
        return { ok = false, reason = 'noseed' }
    end

    local plantedAt = os.time()
    plants[plot] = { citizenid = cid, strain = strain.plant, plantedAt = plantedAt, boosts = 0 }
    MySQL.insert(('INSERT INTO %s (plot, citizenid, strain, planted_at, boosts) VALUES (?, ?, ?, ?, 0)'):format(TABLE_NAME),
        { plot, cid, strain.plant, plantedAt })

    return { ok = true }
end)

-- Servidor: applying fertilizer. The whole mechanic is one subtraction on `planted_at` - moving the
-- timestamp backwards makes the plant *older*, and every piece of arithmetic in this file already
-- derives everything (ready, secondsLeft, fraction, the growth-stage props) from that one number,
-- so nothing else needs to know fertilizer exists.
--
-- That is also exactly why the separate `boosts` counter is needed rather than being inferred: once
-- the timestamp has moved, "planted 2h ago" and "planted 1h ago, fertilized twice" are the same
-- value, and the cap could not be enforced. The counter is the only record that an application
-- happened.
--
-- Open to anyone at the plot, not gated to whoever planted it - same open-access rule as harvest
-- (ADR-057), for the same reason: a shared farm.
lib.callback.register('srv_weedfarm:server:boost', function(source, plot)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    local plotConfig = plotByKey[plot]
    if not plotConfig then return { ok = false } end

    local plant = plants[plot]
    if not plant then return { ok = false, reason = 'empty' } end
    if not isPlayerWithin(source, plotConfig.coords.xyz, Config.plotDistance) then
        return { ok = false, reason = 'far' }
    end

    if plant.boosts >= Config.maxBoosts then return { ok = false, reason = 'maxed' } end

    -- Servidor: refuse on an already-ready plant rather than silently eating the item for no
    -- effect - the client hides the option in that case, but the client is never the authority.
    if os.time() - plant.plantedAt >= Config.growthMinutes * 60 then
        return { ok = false, reason = 'ready' }
    end

    if not exports.ox_inventory:RemoveItem(source, Config.boostItem, 1) then
        return { ok = false, reason = 'noitem' }
    end

    plant.plantedAt -= Config.boostMinutes * 60
    plant.boosts += 1
    MySQL.query(('UPDATE %s SET planted_at = ?, boosts = ? WHERE plot = ?'):format(TABLE_NAME),
        { plant.plantedAt, plant.boosts, plot })

    local state = withGrowthState(plant)

    return { ok = true, secondsLeft = state.secondsLeft, ready = state.ready, boostsLeft = state.boostsLeft }
end)

lib.callback.register('srv_weedfarm:server:harvest', function(source, plot)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    local plotConfig = plotByKey[plot]
    if not plotConfig then return { ok = false } end

    local plant = plants[plot]
    if not plant then return { ok = false, reason = 'empty' } end
    -- Servidor: harvest is open to anyone at the farm, not gated to the citizenid that planted it
    -- - by request, superseding ADR-056's original ownership check. See ADR-057.
    if not isPlayerWithin(source, plotConfig.coords.xyz, Config.plotDistance) then
        return { ok = false, reason = 'far' }
    end

    -- Servidor: elapsed time is computed from the server's own os.time() against the timestamp
    -- stored at planting - never trusted from the client. The entire point of persistent,
    -- real-time growth (chosen over a session-based job) is that it cannot be rushed by claiming
    -- to have waited longer than you did.
    local elapsed = os.time() - plant.plantedAt
    if elapsed < Config.growthMinutes * 60 then
        return { ok = false, reason = 'notready' }
    end

    if not exports.ox_inventory:AddItem(source, plant.strain, Config.yieldPerHarvest) then
        return { ok = false }
    end

    plants[plot] = nil
    MySQL.query(('DELETE FROM %s WHERE plot = ?'):format(TABLE_NAME), { plot })

    return { ok = true, strain = plant.strain, amount = Config.yieldPerHarvest }
end)

-- Servidor: pressing used to be a custom callback here - now handled entirely by ox_inventory's
-- own crafting bench (`srv_weedfarm_press` in its `data/crafting.lua`, ADR-069), which owns its
-- own ingredient validation, weight checks and item creation server-side. Nothing here needs to
-- know about pressing anymore.

-- Servidor: selling a brick is also the choice of what it becomes. The seller picks the retail
-- form, that form's stock is what gets restocked, and the daily cap is `dailyBrickLimit` bricks
-- of EACH form per player per day - so someone sitting on three bricks can turn all three into
-- the consumable without spending any of that day's resale allowance. See ADR-089.
lib.callback.register('srv_weedfarm:server:sell', function(source, amount, form)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    -- Servidor: the form is client-reported, so it has to be one of exactly two literals before
    -- anything moves - the same rule every item-taking callback here already applies.
    if form ~= 'bag' and form ~= 'consumer' then return { ok = false } end

    if not Config.dealer then return { ok = false } end
    if not isPlayerWithin(source, Config.dealer.xyz, Config.dealerDistance) then
        return { ok = false, reason = 'far' }
    end

    local owned = exports.ox_inventory:GetItemCount(source, Config.brickItem) or 0
    if owned <= 0 then return { ok = false, reason = 'nobricks' } end

    if not isValidAmount(amount) then return { ok = false } end
    if amount > owned then return { ok = false, reason = 'notenough' } end

    local bagSold, consumerSold = todayBrickSales(cid)
    local soldToday = form == 'consumer' and consumerSold or bagSold

    if soldToday + amount > Config.dailyBrickLimit then
        return { ok = false, reason = 'dailylimit' }
    end

    -- Servidor: docs/security.md's paid-action ordering - take the product, then pay. If the payout
    -- fails the bricks go back rather than the player losing product for nothing.
    if not exports.ox_inventory:RemoveItem(source, Config.brickItem, amount) then
        return { ok = false }
    end

    local pay = amount * Config.brickPrice

    -- Servidor: illegal income is DIRTY money, by request - every payout from the illegal economy
    -- now lands as the `black_money` item rather than clean cash, and has to be run through a
    -- launderer (`srv_robbery`) to become spendable. Refunds below stay cash on purpose: they
    -- return money the player actually spent. See ADR-142.
    if not exports.ox_inventory:AddItem(source, 'black_money', pay) then
        exports.ox_inventory:AddItem(source, Config.brickItem, amount)
        return { ok = false }
    end

    restock(form, amount * Config.bagsPerBrick)

    -- Servidor: the column name is one of two literals chosen from the validated `form` above, so
    -- interpolating it cannot carry anything a player controls. The values stay parameterised.
    local column = form == 'consumer' and 'consumer_count' or 'bag_count'
    MySQL.query((
        'INSERT INTO %s (citizenid, sale_date, %s) VALUES (?, CURDATE(), ?) ' ..
        'ON DUPLICATE KEY UPDATE %s = %s + ?'
    ):format(SALES_TABLE, column, column, column), { cid, amount, amount })

    return {
        ok = true,
        count = amount,
        paid = pay,
        units = amount * Config.bagsPerBrick,
        bricksLeft = Config.dailyBrickLimit - soldToday - amount,
    }
end)

-- Servidor: everything the dealer menu shows, in one round trip - the shared stock, and this
-- player's own consumption of the daily cap. The menu draws both as cards rather than folding
-- them into a sublabel, so it needs the daily figures too, and asking for them separately would
-- mean two awaits every time the menu opens. Display only: `buyRetail` re-reads both for real
-- before anything is charged, so a stale read here can never oversell. See ADR-084.
--- How many bricks `cid` has already converted into each form today, read from the database's
--- own CURDATE() rather than this server's clock - the same source `sell` writes to, so the menu
--- and the sale can never disagree about what "today" means.
---@param cid string?
---@return integer bagBricks, integer consumerBricks
local function todayBrickSales(cid)
    if not cid then return 0, 0 end

    local row = MySQL.single.await(
        ('SELECT bag_count, consumer_count FROM %s WHERE citizenid = ? AND sale_date = CURDATE()')
            :format(SALES_TABLE), { cid })

    if not row then return 0, 0 end

    return row.bag_count or 0, row.consumer_count or 0
end


--- How many units of each form `cid` has already bought today. Same CURDATE() source as the sale
--- ledger above, for the same reason: the database decides what "today" means, not this server.
---@param cid string?
---@return integer bagUnits, integer consumerUnits
local function todayPurchases(cid)
    if not cid then return 0, 0 end

    local row = MySQL.single.await(
        ('SELECT count, consumer_count FROM %s WHERE citizenid = ? AND purchase_date = CURDATE()')
            :format(PURCHASES_TABLE), { cid })

    if not row then return 0, 0 end

    return row.count or 0, row.consumer_count or 0
end
lib.callback.register('srv_weedfarm:server:getDealerState', function(source)
    local cid = getCitizenId(source)
    local bagSold, consumerSold = todayBrickSales(cid)
    local bagBought, consumerBought = todayPurchases(cid)

    return {
        bagStock = bagStock,
        consumerStock = consumerStock,
        brickLimit = Config.dailyBrickLimit,
        bagBricksSold = bagSold,
        consumerBricksSold = consumerSold,
        bagBricksLeft = math.max(0, Config.dailyBrickLimit - bagSold),
        consumerBricksLeft = math.max(0, Config.dailyBrickLimit - consumerSold),
        buyLimit = Config.dailyBuyLimit,
        bagBought = bagBought,
        consumerBought = consumerBought,
        bagBuyLeft = math.max(0, Config.dailyBuyLimit - bagBought),
        consumerBuyLeft = math.max(0, Config.dailyBuyLimit - consumerBought),
    }
end)

--- Tries cash then bank - same fallback order `srv_jobs`' own `chargeFine` uses.
local function chargeBag(source, amount)
    return exports.qbx_core:RemoveMoney(source, 'cash', amount, 'srv_weedfarm:buyRetail')
        or exports.qbx_core:RemoveMoney(source, 'bank', amount, 'srv_weedfarm:buyRetail')
end

-- Servidor: the dealer sells two forms of the same retail unit from ONE stock pool - the plain
-- `bagItem` (no effect, what `srv_jobs`' `dealing` job resells) and `consumerItem` (a real
-- consumable). `item` says which; everything else - the stock decrement, the shared daily cap,
-- the proximity check - is identical for both, which is the point: a brick still restocks
-- `bagsPerBrick` units and the buyer chooses their form, so supply never doubles. See ADR-084.
-- Servidor: buying draws from the chosen form's OWN stock. There is no per-player daily cap here
-- any more - the cap moved to selling (ADR-089), and what limits a buyer now is simply how much
-- of that form anyone has produced. First come, first served, same as ADR-057.
lib.callback.register('srv_weedfarm:server:buyRetail', function(source, item, amount)
    -- Servidor: the item name is client-reported, so it has to resolve to one of exactly two
    -- allowed values before any money moves. The price comes from the config, never the client.
    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    local price, form, column
    if item == Config.bagItem then
        price, form, column = Config.bagPrice, 'bag', 'count'
    elseif item == Config.consumerItem then
        price, form, column = Config.consumerPrice, 'consumer', 'consumer_count'
    else
        return { ok = false }
    end

    if not Config.dealer then return { ok = false } end
    if not isPlayerWithin(source, Config.dealer.xyz, Config.dealerDistance) then
        return { ok = false, reason = 'far' }
    end

    local available = form == 'consumer' and consumerStock or bagStock
    if available <= 0 then return { ok = false, reason = 'nostock' } end

    if not isValidAmount(amount) then return { ok = false } end
    if amount > available then return { ok = false, reason = 'nostock' } end

    -- Servidor: only the form being bought counts against its own allowance - a player who has
    -- spent all 20 bags today can still buy all 20 of the consumer form.
    local bagBought, consumerBought = todayPurchases(cid)
    local boughtToday = form == 'consumer' and consumerBought or bagBought

    if boughtToday + amount > Config.dailyBuyLimit then
        return { ok = false, reason = 'dailylimit' }
    end

    local pay = amount * price

    if not chargeBag(source, pay) then
        return { ok = false, reason = 'nomoney' }
    end

    if not exports.ox_inventory:AddItem(source, item, amount) then
        exports.qbx_core:AddMoney(source, 'cash', pay, 'srv_weedfarm:buyRetail:refund')
        return { ok = false }
    end

    if form == 'consumer' then
        consumerStock -= amount
        MySQL.query(('UPDATE %s SET consumer_count = consumer_count - ? WHERE id = 1'):format(STOCK_TABLE),
            { amount })
    else
        bagStock -= amount
        MySQL.query(('UPDATE %s SET count = count - ? WHERE id = 1'):format(STOCK_TABLE), { amount })
    end

    -- Servidor: the column name is one of two literals chosen from the validated item above, so
    -- interpolating it cannot carry anything a player controls. The values stay parameterised.
    MySQL.query((
        'INSERT INTO %s (citizenid, purchase_date, %s) VALUES (?, CURDATE(), ?) ' ..
        'ON DUPLICATE KEY UPDATE %s = %s + ?'
    ):format(PURCHASES_TABLE, column, column, column), { cid, amount, amount })

    return {
        ok = true,
        count = amount,
        paid = pay,
        stockLeft = available - amount,
        dailyLeft = Config.dailyBuyLimit - boughtToday - amount,
    }
end)

--- Tries cash then bank - same fallback order `srv_jobs`' own `chargeFine` uses for a paid
--- action, so a player isn't blocked just because their cash on hand is short.
local function chargeSeed(source, amount)
    return exports.qbx_core:RemoveMoney(source, 'cash', amount, 'srv_weedfarm:buySeed')
        or exports.qbx_core:RemoveMoney(source, 'bank', amount, 'srv_weedfarm:buySeed')
end

lib.callback.register('srv_weedfarm:server:buySeed', function(source, seedItem, amount)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    if not Config.seedVendor then return { ok = false } end
    if not isPlayerWithin(source, Config.seedVendor.xyz, Config.seedVendorDistance) then
        return { ok = false, reason = 'far' }
    end

    -- Servidor: same reasoning as `plant`/`process` - the item name is client-reported, so it has
    -- to resolve to one of this farm's own real seeds before any money moves.
    if not findStrainBySeed(seedItem) then return { ok = false } end

    -- Servidor: same quantity-dialog shape as `sell`/`buyRetail` (ADR-065) - no real stock to cap
    -- against here, so `seedPurchaseCeiling` is a plain sanity bound, not a resource limit, but
    -- still its own check with its own reason rather than folded into `isValidAmount`.
    if not isValidAmount(amount) then return { ok = false } end
    if amount > Config.seedPurchaseCeiling then return { ok = false, reason = 'toomany' } end

    local pay = amount * Config.seedPrice

    if not chargeSeed(source, pay) then
        return { ok = false, reason = 'nomoney' }
    end

    if not exports.ox_inventory:AddItem(source, seedItem, amount) then
        exports.qbx_core:AddMoney(source, 'cash', pay, 'srv_weedfarm:buySeed:refund')
        return { ok = false }
    end

    return { ok = true, count = amount, paid = pay }
end)
