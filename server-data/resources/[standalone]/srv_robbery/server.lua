-- Servidor: the authority for store robberies. Everything that decides whether a robbery may happen,
-- and what it is worth, is here - the client only draws prompts and runs the minigame.
--
-- One honest limitation, stated plainly rather than papered over: the minigame runs client-side and
-- the client reports whether it won. There is no way around that with a client-rendered puzzle, so
-- a modified client can claim a success it did not earn. What this file can and does control is how
-- often that is worth anything: police presence, both cooldowns, real proximity at both ends of the
-- attempt, a one-shot token, and a floor on elapsed time. A cheating client gets the same payout as
-- an honest one, at the same rate, no more often. See ADR-097.

local STORE_TABLE = 'srv_robbery_stores'
local PLAYER_TABLE = 'srv_robbery_players'
-- Servidor: keyed by (house, point_index) rather than by item - two points in the same house could
-- give the same item in principle, and the cooldown is about the SPOT, not the loot sitting on it.
local HOUSE_LOOT_TABLE = 'srv_robbery_house_loot'
-- Servidor: how much dirty money each player has put through each contact today. Nothing enforces a
-- limit against it any more - both ceilings were removed by request - but it is still written and
-- still shown in the menu, because the number is what any future cap would be based on and because
-- throwing away the history to save one INSERT would be the expensive kind of tidy.
local LAUNDER_TABLE = 'srv_robbery_laundering'

-- Servidor: in-flight attempts, keyed by store. Deliberately NOT persisted - an attempt that a
-- restart interrupts should simply vanish, not survive as a token someone can redeem later.
---@type table<string, {citizenid: string, source: number, startedAt: number, token: string}>
local attempts = {}

-- Servidor: store keys arrive from the client and have to resolve to one of the real 16, never an
-- arbitrary string. Also gives each callback that store's own coords for the proximity check.
local storeByKey = {}
for i = 1, #Config.stores do
    storeByKey[Config.stores[i].key] = Config.stores[i]
end

-- Servidor: same reasoning as `storeByKey` - house keys arrive from the client and have to resolve
-- to one of the real 8, never an arbitrary string.
local houseByKey = {}
for i = 1, #Config.houses do
    houseByKey[Config.houses[i].key] = Config.houses[i]
end

-- Servidor: same reasoning again - story house keys arrive from the client the same way, resolved
-- against the real 4 rather than trusted as an arbitrary string.
local storyHouseByKey = {}
for i = 1, #Config.storyHouses do
    storyHouseByKey[Config.storyHouses[i].key] = Config.storyHouses[i]
end

-- Servidor: launderer keys arrive from the client the same way store keys do, and are validated the
-- same way - against the real list, never trusted as an arbitrary string.
local laundererByKey = {}
for i = 1, #Config.launderers do
    laundererByKey[Config.launderers[i].key] = Config.launderers[i]
end

CreateThread(function()
    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS %s (
            store VARCHAR(32) NOT NULL PRIMARY KEY,
            robbed_at BIGINT NOT NULL
        )
    ]]):format(STORE_TABLE))

    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS %s (
            citizenid VARCHAR(50) NOT NULL PRIMARY KEY,
            robbed_at BIGINT NOT NULL
        )
    ]]):format(PLAYER_TABLE))

    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS %s (
            citizenid VARCHAR(50) NOT NULL,
            launder_date DATE NOT NULL,
            launderer VARCHAR(32) NOT NULL,
            amount INT NOT NULL DEFAULT 0,
            -- Servidor: keyed by contact as well as by day, so each launderer has its own daily
            -- allowance. A single shared cap would make the better rate pointless the moment the
            -- worse one had been used, and a per-contact cap is what lets the good one run dry
            -- while the bad one is still open - which is the whole reason there are two.
            PRIMARY KEY (citizenid, launder_date, launderer)
        )
    ]]):format(LAUNDER_TABLE))

    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS %s (
            house VARCHAR(32) NOT NULL,
            point_index INT NOT NULL,
            looted_at BIGINT NOT NULL,
            PRIMARY KEY (house, point_index)
        )
    ]]):format(HOUSE_LOOT_TABLE))
end)

local function getCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

--- Same shape as every farm's own - duplicated rather than shared, since resources can't share a
--- local across FXServer's per-resource script environments.
local function isPlayerWithin(source, coords, maxDist)
    return #(GetEntityCoords(GetPlayerPed(source)) - coords) <= maxDist
end

-- Servidor: a development override for the police requirement, and the ONLY way to exercise this
-- resource without two real officers logged in and on duty. A ped standing at the plaza cannot help:
-- the count below reads connected players from qbx_core, and a world entity has no PlayerData, no
-- job, and no presence in that list. Faking a player would mean patching qbx_core itself.
--
-- Unset by default, so a server that never sets it behaves exactly as before. Any value >= 0
-- replaces the real count outright.
--
-- A convar rather than a config field, on purpose: config is committed, so a leftover
-- `policeRequired = 0` would ship silently. A convar lives in server.cfg and announces itself at
-- every boot, which is the same shape CLAUDE.md hard rule 6 already requires of `srv_tools` - the
-- boot log is the check that it is off.
local POLICE_OVERRIDE = GetConvarInt('srv_robbery:policeOverride', -1)

if POLICE_OVERRIDE >= 0 then
    print(('^1[srv_robbery] OVERRIDE DE POLICIA ATIVO^7 - a contagem real esta ignorada e vale %s. Remova srv_robbery:policeOverride do server.cfg antes de abrir para jogadores.')
        :format(POLICE_OVERRIDE))
end

--- How many LEOs are on duty right now.
---
--- Counted here rather than asked of `qbx_police`, and that is not an oversight: its own
--- `isPoliceForcePresent` is a file-local function, and the `lib.callback` it is registered under is
--- a client-to-server callback, so neither is reachable from another resource's server. The three
--- lines below mirror that resource's own `IsLeoAndOnDuty` exactly - if its definition of "on duty"
--- ever changes, this has to follow.
---@return integer
local function onDutyPolice()
    if POLICE_OVERRIDE >= 0 then return POLICE_OVERRIDE end

    local count = 0
    for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
        local job = player.PlayerData.job
        if job and job.type == 'leo' and job.onduty then count += 1 end
    end
    return count
end

--- Seconds since `key` was last robbed, or nil if never.
---@param table_ string
---@param key string
---@return integer?
local function secondsSince(table_, key)
    local at = MySQL.scalar.await(
        ('SELECT robbed_at FROM %s WHERE %s = ?'):format(table_, table_ == STORE_TABLE and 'store' or 'citizenid'),
        { key })
    if not at then return nil end
    return os.time() - at
end

---@param table_ string
---@param key string
local function markRobbed(table_, key)
    local column = table_ == STORE_TABLE and 'store' or 'citizenid'
    MySQL.query((
        'INSERT INTO %s (%s, robbed_at) VALUES (?, ?) ON DUPLICATE KEY UPDATE robbed_at = ?'
    ):format(table_, column), { key, os.time(), os.time() })
end

--- Every reason a robbery may not start, in one place so the prompt and the attempt can never
--- disagree about why. Returns nil when it may.
---@param source number
---@param cid string
---@param store {key: string, coords: vector3}
---@return string? reason
local function blockedBecause(source, cid, store)
    -- Servidor: checked first, and for the same reason the counter menu below shows it on
    -- "Assaltar" as well as "Abrir loja" - a marked player is refused by every shop, robbery or
    -- purchase, not specifically locked out of the crime.
    if exports.srv_wanted:IsWanted(source) then return 'wanted' end
    if attempts[store.key] then return 'busy' end
    if onDutyPolice() < Config.policeRequired then return 'nopolice' end

    local sinceStore = secondsSince(STORE_TABLE, store.key)
    if sinceStore and sinceStore < Config.storeCooldownMinutes * 60 then return 'storecooldown' end

    local sincePlayer = secondsSince(PLAYER_TABLE, cid)
    if sincePlayer and sincePlayer < Config.playerCooldownMinutes * 60 then return 'playercooldown' end

    return nil
end

-- Servidor: "Abrir loja" had no server round trip at all before this - the client called
-- `exports.ox_inventory:openInventory` straight away, which was fine when nothing needed refusing.
-- Now something does: a marked player is turned away from `ox_inventory`'s own shop, and the
-- attempt is reported to the police the same way a real robbery already is.
lib.callback.register('srv_robbery:server:canOpenStore', function(source, storeKey)
    local store = storeByKey[storeKey]
    if not store then return { ok = false } end

    if exports.srv_wanted:IsWanted(source) then
        TriggerEvent('police:server:policeAlert', ('%s - Tentativa procurado'):format(Config.alert), nil, source)
        return { ok = false, reason = 'wanted' }
    end

    return { ok = true }
end)

--- Display only - drives what the counter menu shows before the player commits. Every value it
--- reports is checked again for real in `start`, so a stale read here can never authorise anything.
lib.callback.register('srv_robbery:server:getStoreState', function(source, storeKey)
    local store = storeByKey[storeKey]
    if not store then return nil end

    local cid = getCitizenId(source)
    if not cid then return nil end

    local sinceStore = secondsSince(STORE_TABLE, storeKey)
    local sincePlayer = secondsSince(PLAYER_TABLE, cid)

    return {
        reason = blockedBecause(source, cid, store),
        police = onDutyPolice(),
        policeRequired = Config.policeRequired,
        storeSecondsLeft = sinceStore and math.max(0, Config.storeCooldownMinutes * 60 - sinceStore) or 0,
        playerSecondsLeft = sincePlayer and math.max(0, Config.playerCooldownMinutes * 60 - sincePlayer) or 0,
    }
end)

lib.callback.register('srv_robbery:server:start', function(source, storeKey)
    local store = storeByKey[storeKey]
    if not store then return { ok = false } end

    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    if not isPlayerWithin(source, store.coords, Config.interactDistance) then
        return { ok = false, reason = 'far' }
    end

    local reason = blockedBecause(source, cid, store)
    if reason then
        -- Servidor: a marked player attempting a robbery anyway is exactly the case
        -- `srv_wanted`'s whole feature exists to catch - reported the same way a real robbery
        -- already is, not silently refused.
        if reason == 'wanted' then
            TriggerEvent('police:server:policeAlert', ('%s - Tentativa procurado'):format(Config.alert), nil, source)
        end
        return { ok = false, reason = reason }
    end

    -- Servidor: the store is claimed the moment the attempt starts, not when it succeeds. Two players
    -- hitting the same till at once would otherwise both be allowed through, and the second would be
    -- robbing a register the first already emptied.
    local token = ('%s:%s:%s'):format(cid, os.time(), math.random(100000, 999999))
    attempts[storeKey] = { citizenid = cid, source = source, startedAt = os.time(), token = token }

    -- Servidor: the police are told at the START, not at the end. A robbery they only hear about once
    -- it is over is a notification, not a response - the whole point of gating on police presence is
    -- that there is time to arrive.
    TriggerEvent('police:server:policeAlert', ('%s - %s'):format(Config.alert, store.label), nil, source)

    return { ok = true, token = token }
end)

lib.callback.register('srv_robbery:server:finish', function(source, storeKey, token, won)
    local store = storeByKey[storeKey]
    if not store then return { ok = false } end

    local attempt = attempts[storeKey]
    if not attempt then return { ok = false } end

    -- Servidor: the token is one-shot and bound to both the player and the store, so a replayed or
    -- borrowed one is worth nothing. Cleared before anything is paid, so even an error below cannot
    -- leave it redeemable.
    if attempt.token ~= token or attempt.source ~= source then return { ok = false } end
    attempts[storeKey] = nil

    local cid = getCitizenId(source)
    if not cid or cid ~= attempt.citizenid then return { ok = false } end

    if not won then return { ok = true, won = false } end

    -- Servidor: a success that arrives faster than any honest attempt could finish is refused. The
    -- player still burns the attempt and the store's cooldown, so this costs a cheat rather than
    -- merely denying it.
    if os.time() - attempt.startedAt < Config.minimumSeconds then
        markRobbed(STORE_TABLE, storeKey)
        markRobbed(PLAYER_TABLE, cid)
        return { ok = false, reason = 'toofast' }
    end

    if not isPlayerWithin(source, store.coords, Config.interactDistance) then
        markRobbed(STORE_TABLE, storeKey)
        markRobbed(PLAYER_TABLE, cid)
        return { ok = false, reason = 'far' }
    end

    local payout = math.random(Config.payout.min, Config.payout.max)

    markRobbed(STORE_TABLE, storeKey)
    markRobbed(PLAYER_TABLE, cid)

    -- Servidor: an ox_inventory item, not a money account - `black_money` is carried and can be
    -- taken off a body, which is the point of paying in it. A full inventory is the real failure
    -- here, and the cooldowns above are already spent by then: the attempt is burned either way,
    -- which is deliberate. Robbing a till with no room to carry the takings is the player's
    -- problem, not a reason to hand them a free retry.
    if not exports.ox_inventory:AddItem(source, Config.payoutItem, payout) then
        return { ok = false, reason = 'noroom' }
    end

    -- Servidor: marked on a successful robbery only, after the payout is confirmed - a robbery that
    -- failed for lack of inventory space never happened as far as `srv_wanted` is concerned.
    exports.srv_wanted:MarkWanted(source)

    return { ok = true, won = true, payout = payout }
end)

-- Servidor: the lockpick gate every house requires. `passed` is the client's own skill-check
-- result, which cannot be otherwise for a client-rendered minigame - the same bounded exception
-- `mhacking`'s result already is (ADR-097). What this bounds instead: whether the player is
-- actually there, and whether they actually have a lockpick to spend. A cheating client can claim
-- it won the check; it cannot claim to have an item it does not have, or to be somewhere it is not.
--
-- No cooldown here on purpose - entering costs a lockpick and its break chance, which is the real
-- gate at this step. A per-house cooldown belongs to taking the loot inside, which does not exist
-- yet (no house has loot points mapped) - adding one now would cap a reward that isn't there.
lib.callback.register('srv_robbery:server:enterHouse', function(source, houseKey, passed)
    local house = houseByKey[houseKey]
    if not house or not house.entrance then return { ok = false } end

    if (exports.ox_inventory:GetItemCount(source, Config.houseLockpick.item) or 0) <= 0 then
        return { ok = false, reason = 'nolockpick' }
    end

    if not isPlayerWithin(source, house.entrance.outside.xyz, house.entrance.distance + 1.0) then
        return { ok = false, reason = 'far' }
    end

    local broke = math.random() <= Config.houseLockpick.breakChance
    if broke then
        exports.ox_inventory:RemoveItem(source, Config.houseLockpick.item, 1)
    end

    return { ok = true, entered = passed == true, broke = broke }
end)

-- Servidor: taking a piece of loot from a house - independent of the entrance/lockpick above, since
-- a point is only reachable at all once a player is already inside (the entrance callback already
-- gated getting in). `pointIndex` is the position in `house.lootPoints`, arriving as a plain number
-- from the client; validated against the real list length below rather than trusted, the same
-- "resolve against the real thing, never trust an arbitrary value" rule `houseByKey` already is.
lib.callback.register('srv_robbery:server:lootHousePoint', function(source, houseKey, pointIndex)
    local house = houseByKey[houseKey]
    if not house or not house.lootPoints then return { ok = false } end

    local point = house.lootPoints[pointIndex]
    if not point then return { ok = false } end

    if not isPlayerWithin(source, point.coords.xyz, 2.0) then
        return { ok = false, reason = 'far' }
    end

    local row = MySQL.single.await(
        ('SELECT looted_at FROM %s WHERE house = ? AND point_index = ?'):format(HOUSE_LOOT_TABLE),
        { houseKey, pointIndex }
    )

    -- Servidor: minutes, not seconds - same unit `storeCooldownMinutes` already uses, converted once
    -- here rather than carrying two different units through the rest of this file.
    if row and os.time() - row.looted_at < Config.houseLootCooldownMinutes * 60 then
        return { ok = false, reason = 'empty' }
    end

    if not exports.ox_inventory:CanCarryItem(source, point.item, 1) then
        return { ok = false, reason = 'noroom' }
    end

    if not exports.ox_inventory:AddItem(source, point.item, 1) then
        return { ok = false, reason = 'noroom' }
    end

    MySQL.query(
        ('INSERT INTO %s (house, point_index, looted_at) VALUES (?, ?, ?) ' ..
            'ON DUPLICATE KEY UPDATE looted_at = ?'):format(HOUSE_LOOT_TABLE),
        { houseKey, pointIndex, os.time(), os.time() }
    )

    -- Servidor: same reasoning as the store payout above - marked once the item is actually in
    -- hand, which for a house is the moment loot changes hands rather than the moment the lock does.
    exports.srv_wanted:MarkWanted(source)

    return { ok = true, item = point.item }
end)

--- Whether `source` may use `launderer` at all.
---
--- `allowedGangs` nil means open to everyone; a list means only those gangs, and an EMPTY list
--- means nobody - which is the state a closed contact ships in until a group is chosen. Read from
--- the server's own copy of the player, never from anything the client sends.
---@param source number
---@param launderer {allowedGangs: string[]?}
---@return boolean
local function mayUseLaunderer(source, launderer)
    if not launderer.allowedGangs then return true end

    local player = exports.qbx_core:GetPlayer(source)
    local gang = player and player.PlayerData.gang
    if not gang then return false end

    for i = 1, #launderer.allowedGangs do
        if launderer.allowedGangs[i] == gang.name then return true end
    end

    return false
end

--- How much dirty money `cid` has already put through ONE launderer today, from the database's own
--- CURDATE() rather than this server's clock - the same source the write below uses.
---@param cid string?
---@param launderer string
---@return integer
local function launderedToday(cid, launderer)
    if not cid then return 0 end
    return MySQL.scalar.await(
        ('SELECT amount FROM %s WHERE citizenid = ? AND launder_date = CURDATE() AND launderer = ?')
            :format(LAUNDER_TABLE), { cid, launderer }) or 0
end

--- Display only - drives the launderer menu. `launder` re-reads everything before moving anything.
lib.callback.register('srv_robbery:server:getLaunderState', function(source, laundererKey)
    local launderer = laundererByKey[laundererKey]
    if not launderer then return nil end

    local cid = getCitizenId(source)
    if not cid then return nil end

    if not mayUseLaunderer(source, launderer) then return nil end

    return {
        held = exports.ox_inventory:GetItemCount(source, Config.payoutItem) or 0,
        label = launderer.label,
        rate = launderer.rate,
        -- Servidor: reported for display only - there is no ceiling to compare it against.
        dailyUsed = launderedToday(cid, laundererKey),
    }
end)

lib.callback.register('srv_robbery:server:launder', function(source, laundererKey, amount)
    local launderer = laundererByKey[laundererKey]
    if not launderer then return { ok = false } end

    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    if not mayUseLaunderer(source, launderer) then return { ok = false, reason = 'notallowed' } end

    if not launderer.vendor then return { ok = false } end
    if not isPlayerWithin(source, launderer.vendor.xyz, launderer.vendorDistance) then
        return { ok = false, reason = 'far' }
    end

    -- Servidor: same shape check every quantity callback in this project starts with.
    if type(amount) ~= 'number' or amount ~= math.floor(amount) or amount < 1 or amount > 1000000 then
        return { ok = false }
    end

    local held = exports.ox_inventory:GetItemCount(source, Config.payoutItem) or 0
    if held <= 0 then return { ok = false, reason = 'nomoney' } end
    if amount > held then return { ok = false, reason = 'notenough' } end

    -- Servidor: docs/security.md's paid-action ordering - take the dirty money first, then pay out.
    -- If the payout somehow fails the dirty money goes back, so the player never loses both.
    if not exports.ox_inventory:RemoveItem(source, Config.payoutItem, amount) then
        return { ok = false }
    end

    local clean = math.floor(amount * launderer.rate)

    if not exports.qbx_core:AddMoney(source, 'cash', clean, 'srv_robbery:launder') then
        exports.ox_inventory:AddItem(source, Config.payoutItem, amount)
        return { ok = false }
    end

    MySQL.query((
        'INSERT INTO %s (citizenid, launder_date, launderer, amount) VALUES (?, CURDATE(), ?, ?) ' ..
        'ON DUPLICATE KEY UPDATE amount = amount + ?'
    ):format(LAUNDER_TABLE), { cid, laundererKey, amount, amount })

    return { ok = true, dirty = amount, clean = clean }
end)

-- Servidor: the story-house tier's only server-side involvement, by design - there is no lockpick to
-- consume and no loot to hand out yet (no loot points are mapped for these 4 houses), so the one
-- thing that has to be server-authoritative is the police alert. A modified client can already set
-- its own guards hostile locally (it is client-side combat AI, the same trust boundary every ped in
-- this project already has), but it cannot make the SERVER tell the police - that only happens if
-- this event says the player is genuinely at one of the 4 houses.
--
-- Not gated on `Config.policeRequired` the way starting a store robbery is - there is no "abort if
-- police are away" here, since the fight already started the moment the player pressed [E] and the
-- point of this event is to report it, not to permit it.
RegisterNetEvent('srv_robbery:server:storyRobberyAlert', function(houseKey)
    local source = source
    local house = storyHouseByKey[houseKey]
    if not house then return end

    if not isPlayerWithin(source, house.coords, house.guardRadius + 15.0) then return end

    TriggerEvent('police:server:policeAlert', ('%s - Casa vigiada'):format(Config.alert), nil, source)

    -- Servidor: marked the moment the fight starts, matching the alert above - there is no loot
    -- system for these 4 houses yet (same gap the lockpick tier had before its own loot points were
    -- mapped), so this is the earliest point that reliably means "actually robbing", not just
    -- walking near a guarded property.
    exports.srv_wanted:MarkWanted(source)
end)

-- Servidor: an attempt whose player disconnects mid-minigame would otherwise hold the store shut
-- until a restart, since nothing else clears `attempts`.
AddEventHandler('playerDropped', function()
    local src = source
    for key, attempt in pairs(attempts) do
        if attempt.source == src then attempts[key] = nil end
    end
end)
