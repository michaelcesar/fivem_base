-- Servidor: persistent cocaine processing - srv_weedfarm's sibling, same reasoning (state has to
-- survive a restart and keep progressing while nobody is online, so it lives in the database, not
-- an in-memory table keyed by `source`). `batches` here is a server-side read cache of that table,
-- kept in sync on every write - the database itself stays the source of truth.

local TABLE_NAME = 'srv_cocainelab_batches'
local STOCK_TABLE = 'srv_cocainelab_stock'
-- Servidor: bricks converted per player per day, the ledger the selling cap is checked against.
local SALES_TABLE = 'srv_cocainelab_brick_sales'
-- Servidor: units bought per player per day, the ledger the BUYING cap is checked against. This
-- is the table ADR-089 retired when the cap briefly moved entirely to selling; it holds exactly
-- the fact needed again, so it is reused rather than replaced. See ADR-090.
local PURCHASES_TABLE = 'srv_cocainelab_bag_purchases'

---@type table<string, {citizenid: string, startedAt: number, boosts: number}>
local batches = {}

-- Servidor: the dealer's retail stock - shared across every player, not per-citizenid, mirroring
-- srv_weedfarm's own `stock` exactly (ADR-057's open-access reasoning).
-- Servidor: the dealer holds ONE stock per retail form, not one pool split two ways. A brick
-- sold is converted into whichever form the seller chose, and that is the only thing that
-- restocks it - so what a buyer sees on each card is the real, separate supply of that item.
-- Shared across every player rather than per-citizenid, same open-access rule as ADR-057.
-- See ADR-089.
local bagStock = 0
local consumerStock = 0

-- Servidor: station keys are validated against this map on every callback below, since the key
-- comes from the client and has to resolve to one of the lab's 9 real spots, not an arbitrary
-- string. Also gives process/collect each station's own real coords.
local stationByKey = {}
for i = 1, #Config.stations do
    stationByKey[Config.stations[i].key] = Config.stations[i]
end

CreateThread(function()
    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS %s (
            station VARCHAR(10) NOT NULL PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL,
            started_at BIGINT NOT NULL
        )
    ]]):format(TABLE_NAME))

    -- Servidor: same post-hoc migration as srv_weedfarm's own `boosts` column - a
    -- CREATE TABLE IF NOT EXISTS is a no-op against an existing table, so the column has to
    -- be added by an ALTER. `IF NOT EXISTS` on ADD COLUMN is MariaDB-specific and makes it
    -- idempotent across restarts. See ADR-082.
    MySQL.query.await(('ALTER TABLE %s ADD COLUMN IF NOT EXISTS boosts INT NOT NULL DEFAULT 0'):format(TABLE_NAME))

    local rows = MySQL.query.await('SELECT * FROM ' .. TABLE_NAME)
    for i = 1, #rows do
        batches[rows[i].station] = { citizenid = rows[i].citizenid, startedAt = rows[i].started_at,
            boosts = rows[i].boosts or 0 }
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

-- Servidor: same sanity ceiling as srv_weedfarm's own - rules out a client reporting something
-- absurd before any real limit (owned count, stock, daily cap, leafPurchaseCeiling) is checked.
local SANE_AMOUNT_CEILING = 9999

local function isValidAmount(amount)
    return type(amount) == 'number' and amount == math.floor(amount) and amount >= 1 and amount <= SANE_AMOUNT_CEILING
end

local function getCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

--- Same shape as srv_weedfarm's own `isPlayerWithin` - kept here rather than shared since
--- resources can't share a local across FXServer's per-resource script environments.
local function isPlayerWithin(source, coords, maxDist)
    return #(GetEntityCoords(GetPlayerPed(source)) - coords) <= maxDist
end

-- Servidor: `os` doesn't exist client-side in FiveM (see srv_weedfarm's ADR-068) - every elapsed
-- number the client displays is computed here, with the server's own real `os.time()`, and
-- handed over pre-computed. The client never calls `os.time()` itself.
---@param batch {citizenid: string, startedAt: number, boosts: number}
local function withBatchState(batch)
    local elapsed = os.time() - batch.startedAt
    local total = Config.processingMinutes * 60

    return {
        citizenid = batch.citizenid,
        startedAt = batch.startedAt,
        ready = elapsed >= total,
        secondsLeft = math.max(0, total - elapsed),
        fraction = elapsed / total,
        -- Servidor: sent so the station prompt can say how many applications are left without
        -- the client tracking any of it - the cap itself is enforced server-side in `boost`.
        boosts = batch.boosts,
        boostsLeft = math.max(0, Config.maxBoosts - batch.boosts),
    }
end

--- Same "asked once on start, refreshed after this client's own action, and periodically while
--- idle" shape as srv_weedfarm's `getPlants` - staleness here only ever shows the wrong prompt
--- for a few seconds; every action below re-validates for real.
lib.callback.register('srv_cocainelab:server:getBatches', function(source)
    local withState = {}
    for station, batch in pairs(batches) do
        withState[station] = withBatchState(batch)
    end
    return withState
end)

lib.callback.register('srv_cocainelab:server:process', function(source, station)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    local stationConfig = stationByKey[station]
    if not stationConfig then return { ok = false } end
    if batches[station] then return { ok = false, reason = 'occupied' } end
    if not isPlayerWithin(source, stationConfig.coords.xyz, Config.stationDistance) then
        return { ok = false, reason = 'far' }
    end

    if not exports.ox_inventory:RemoveItem(source, Config.leafItem, 1) then
        return { ok = false, reason = 'noleaf' }
    end

    local startedAt = os.time()
    batches[station] = { citizenid = cid, startedAt = startedAt, boosts = 0 }
    MySQL.insert(('INSERT INTO %s (station, citizenid, started_at, boosts) VALUES (?, ?, ?, 0)'):format(TABLE_NAME),
        { station, cid, startedAt })

    return { ok = true }
end)

-- Servidor: applying the accelerator. Mirrors srv_weedfarm's own `boost` exactly - the whole
-- mechanic is one subtraction on `started_at`, making the batch *older*, since every piece of
-- arithmetic in this file already derives ready/secondsLeft/fraction from that one number.
--
-- The separate `boosts` counter is what makes the cap enforceable: once the timestamp has moved,
-- "started 2h ago" and "started 1h ago, accelerated twice" are the same value, so the counter is
-- the only record that an application happened.
--
-- Open to anyone at the station, not gated to whoever started the batch - same open-access rule
-- as collect (ADR-057).
lib.callback.register('srv_cocainelab:server:boost', function(source, station)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    local stationConfig = stationByKey[station]
    if not stationConfig then return { ok = false } end

    local batch = batches[station]
    if not batch then return { ok = false, reason = 'empty' } end
    if not isPlayerWithin(source, stationConfig.coords.xyz, Config.stationDistance) then
        return { ok = false, reason = 'far' }
    end

    if batch.boosts >= Config.maxBoosts then return { ok = false, reason = 'maxed' } end

    -- Servidor: refuse on an already-finished batch rather than silently eating the item for no
    -- effect - the client hides the option in that case, but the client is never the authority.
    if os.time() - batch.startedAt >= Config.processingMinutes * 60 then
        return { ok = false, reason = 'ready' }
    end

    if not exports.ox_inventory:RemoveItem(source, Config.boostItem, 1) then
        return { ok = false, reason = 'noitem' }
    end

    batch.startedAt -= Config.boostMinutes * 60
    batch.boosts += 1
    MySQL.query(('UPDATE %s SET started_at = ?, boosts = ? WHERE station = ?'):format(TABLE_NAME),
        { batch.startedAt, batch.boosts, station })

    local state = withBatchState(batch)

    return { ok = true, secondsLeft = state.secondsLeft, ready = state.ready, boostsLeft = state.boostsLeft }
end)

lib.callback.register('srv_cocainelab:server:collect', function(source, station)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    local stationConfig = stationByKey[station]
    if not stationConfig then return { ok = false } end

    local batch = batches[station]
    if not batch then return { ok = false, reason = 'empty' } end
    -- Servidor: open to anyone at the station, not gated to whoever started it - same open-access
    -- rule srv_weedfarm's harvest uses (ADR-057), for the same reason: a shared lab.
    if not isPlayerWithin(source, stationConfig.coords.xyz, Config.stationDistance) then
        return { ok = false, reason = 'far' }
    end

    -- Servidor: elapsed time is computed from the server's own os.time() against the timestamp
    -- stored at the start of processing - never trusted from the client. Same reasoning as
    -- srv_weedfarm's harvest: this cannot be rushed by claiming to have waited longer than you did.
    local elapsed = os.time() - batch.startedAt
    if elapsed < Config.processingMinutes * 60 then
        return { ok = false, reason = 'notready' }
    end

    if not exports.ox_inventory:AddItem(source, Config.pasteItem, Config.yieldPerBatch) then
        return { ok = false }
    end

    batches[station] = nil
    MySQL.query(('DELETE FROM %s WHERE station = ?'):format(TABLE_NAME), { station })

    return { ok = true, amount = Config.yieldPerBatch }
end)

-- Servidor: pressing is ox_inventory's own crafting bench (`srv_cocainelab_press` in its
-- `data/crafting.lua`, mirroring srv_weedfarm's ADR-069) - nothing here needs to know about it.

-- Servidor: selling a brick is also the choice of what it becomes. The seller picks the retail
-- form, that form's stock is what gets restocked, and the daily cap is `dailyBrickLimit` bricks
-- of EACH form per player per day - so someone sitting on three bricks can turn all three into
-- the consumable without spending any of that day's resale allowance. See ADR-089.
lib.callback.register('srv_cocainelab:server:sell', function(source, amount, form)
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
lib.callback.register('srv_cocainelab:server:getDealerState', function(source)
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

--- Tries cash then bank - same fallback order srv_weedfarm's own `chargeBag` uses.
local function chargeBag(source, amount)
    return exports.qbx_core:RemoveMoney(source, 'cash', amount, 'srv_cocainelab:buyRetail')
        or exports.qbx_core:RemoveMoney(source, 'bank', amount, 'srv_cocainelab:buyRetail')
end

-- Servidor: the dealer sells two forms of the same retail unit from ONE stock pool - the plain
-- `bagItem` (no effect, what `srv_jobs`' `dealing` job resells) and `consumerItem` (a real
-- consumable). `item` says which; everything else - the stock decrement, the shared daily cap,
-- the proximity check - is identical for both, which is the point: a brick still restocks
-- `bagsPerBrick` units and the buyer chooses their form, so supply never doubles. See ADR-084.
-- Servidor: buying draws from the chosen form's OWN stock. There is no per-player daily cap here
-- any more - the cap moved to selling (ADR-089), and what limits a buyer now is simply how much
-- of that form anyone has produced. First come, first served, same as ADR-057.
lib.callback.register('srv_cocainelab:server:buyRetail', function(source, item, amount)
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
        exports.qbx_core:AddMoney(source, 'cash', pay, 'srv_cocainelab:buyRetail:refund')
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

--- Tries cash then bank - same fallback order srv_weedfarm's own `chargeSeed` uses.
local function chargeLeaf(source, amount)
    return exports.qbx_core:RemoveMoney(source, 'cash', amount, 'srv_cocainelab:buyLeaf')
        or exports.qbx_core:RemoveMoney(source, 'bank', amount, 'srv_cocainelab:buyLeaf')
end

lib.callback.register('srv_cocainelab:server:buyLeaf', function(source, amount)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    if not Config.leafVendor then return { ok = false } end
    if not isPlayerWithin(source, Config.leafVendor.xyz, Config.leafVendorDistance) then
        return { ok = false, reason = 'far' }
    end

    -- Servidor: same quantity-dialog shape as srv_weedfarm's `buySeed` (ADR-065) - no real stock
    -- to cap against here, so `leafPurchaseCeiling` is a plain sanity bound, not a resource limit.
    if not isValidAmount(amount) then return { ok = false } end
    if amount > Config.leafPurchaseCeiling then return { ok = false, reason = 'toomany' } end

    local pay = amount * Config.leafPrice

    if not chargeLeaf(source, pay) then
        return { ok = false, reason = 'nomoney' }
    end

    if not exports.ox_inventory:AddItem(source, Config.leafItem, amount) then
        exports.qbx_core:AddMoney(source, 'cash', pay, 'srv_cocainelab:buyLeaf:refund')
        return { ok = false }
    end

    return { ok = true, count = amount, paid = pay }
end)
