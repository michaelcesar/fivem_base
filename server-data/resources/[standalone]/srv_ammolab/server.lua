-- Servidor: persistent station state - same reasoning as srv_gunlab's own (state has to survive a
-- restart), identical 2-minute batch. No booster/accelerator table here either.

local TABLE_NAME = 'srv_ammolab_batches'

---@type table<string, {citizenid: string, startedAt: number}>
local batches = {}

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

    local rows = MySQL.query.await('SELECT * FROM ' .. TABLE_NAME)
    for i = 1, #rows do
        batches[rows[i].station] = { citizenid = rows[i].citizenid, startedAt = rows[i].started_at }
    end
end)

local SANE_AMOUNT_CEILING = 9999

local function isValidAmount(amount)
    return type(amount) == 'number' and amount == math.floor(amount) and amount >= 1 and amount <= SANE_AMOUNT_CEILING
end

local function getCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function isPlayerWithin(source, coords, maxDist)
    return #(GetEntityCoords(GetPlayerPed(source)) - coords) <= maxDist
end

---@param batch {citizenid: string, startedAt: number}
local function withBatchState(batch)
    local elapsed = os.time() - batch.startedAt
    local total = Config.processingMinutes * 60

    return {
        citizenid = batch.citizenid,
        startedAt = batch.startedAt,
        ready = elapsed >= total,
        secondsLeft = math.max(0, total - elapsed),
        fraction = elapsed / total,
    }
end

lib.callback.register('srv_ammolab:server:getBatches', function(source)
    local withState = {}
    for station, batch in pairs(batches) do
        withState[station] = withBatchState(batch)
    end
    return withState
end)

lib.callback.register('srv_ammolab:server:process', function(source, station)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    local stationConfig = stationByKey[station]
    if not stationConfig then return { ok = false } end
    if batches[station] then return { ok = false, reason = 'occupied' } end
    if not isPlayerWithin(source, stationConfig.coords.xyz, Config.stationDistance) then
        return { ok = false, reason = 'far' }
    end

    if not exports.ox_inventory:RemoveItem(source, Config.materialItem, 4) then
        return { ok = false, reason = 'nomaterial' }
    end

    local startedAt = os.time()
    batches[station] = { citizenid = cid, startedAt = startedAt }
    MySQL.insert(('INSERT INTO %s (station, citizenid, started_at) VALUES (?, ?, ?)'):format(TABLE_NAME),
        { station, cid, startedAt })

    return { ok = true }
end)

lib.callback.register('srv_ammolab:server:collect', function(source, station)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    local stationConfig = stationByKey[station]
    if not stationConfig then return { ok = false } end

    local batch = batches[station]
    if not batch then return { ok = false, reason = 'empty' } end
    -- Servidor: open to anyone at the station, not gated to whoever started it - same open-access
    -- rule the drug farms' own harvest/collect use (ADR-057).
    if not isPlayerWithin(source, stationConfig.coords.xyz, Config.stationDistance) then
        return { ok = false, reason = 'far' }
    end

    local elapsed = os.time() - batch.startedAt
    if elapsed < Config.processingMinutes * 60 then
        return { ok = false, reason = 'notready' }
    end

    if not exports.ox_inventory:AddItem(source, Config.partItem, Config.yieldPerBatch) then
        return { ok = false }
    end

    batches[station] = nil
    MySQL.query(('DELETE FROM %s WHERE station = ?'):format(TABLE_NAME), { station })

    return { ok = true, amount = Config.yieldPerBatch }
end)

-- Servidor: loading is ox_inventory's own crafting bench (`srv_ammolab_press` in its own
-- `data/crafting.lua`, same ADR-069 shape the drug presses and `srv_gunlab_press` use) - nothing
-- here needs to know about it. Six recipes, one per real ammo type, all `ammo_part = 4`, all
-- 120000ms. No NPC buyer and no sell callback - what comes off the press stays in the builder's
-- inventory; a sale to another player, if it happens, goes through `srv_trade`. See ADR-117.

--- Tries cash then bank - same fallback order the drug farms' own vendor purchases use.
local function chargeMaterial(source, amount)
    return exports.qbx_core:RemoveMoney(source, 'cash', amount, 'srv_ammolab:buyMaterial')
        or exports.qbx_core:RemoveMoney(source, 'bank', amount, 'srv_ammolab:buyMaterial')
end

lib.callback.register('srv_ammolab:server:buyMaterial', function(source, amount)
    if not exports.srv_lib:IsInGang(source, Config.ownerGang) then return { ok = false, reason = 'notgang' } end
    if not Config.vendor then return { ok = false } end
    if not isPlayerWithin(source, Config.vendor.xyz, Config.vendorDistance) then
        return { ok = false, reason = 'far' }
    end

    if not isValidAmount(amount) then return { ok = false } end
    if amount > Config.materialPurchaseCeiling then return { ok = false, reason = 'toomany' } end

    local pay = amount * Config.materialPrice

    if not chargeMaterial(source, pay) then
        return { ok = false, reason = 'nomoney' }
    end

    if not exports.ox_inventory:AddItem(source, Config.materialItem, amount) then
        exports.qbx_core:AddMoney(source, 'cash', pay, 'srv_ammolab:buyMaterial:refund')
        return { ok = false }
    end

    return { ok = true, count = amount, paid = pay }
end)
