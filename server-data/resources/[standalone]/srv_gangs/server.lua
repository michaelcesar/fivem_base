-- Servidor: server side of the gang radial actions. Both handlers are authoritative (CLAUDE.md
-- rule 2): the radial is a menu, not a permission, and the client is never asked to prove
-- anything. See ADR-126.

--- Registers one `ox_inventory` stash per gang, at boot.
---
--- `groups` is what makes the stash gang-only inside ox_inventory itself, on top of this
--- resource's own check below - the same mechanism `policelocker`/`emslocker` already use for
--- jobs in `ox_inventory/data/stashes.lua`. Two independent gates rather than one, because a
--- stash id is guessable and `OpenInventory` is not the only way into one.
CreateThread(function()
    for gang, stash in pairs(Config.stashes) do
        exports.ox_inventory:RegisterStash(
            ('gang_%s'):format(gang),
            stash.label,
            Config.stashSlots,
            Config.stashWeight,
            nil,                      -- not owner-scoped: one shared stash for the whole gang
            { [gang] = 0 }            -- any grade of that gang, boss included
        )

        -- Servidor: the vault, registered for every gang alongside its stash. Same group gate, same
        -- shared (not owner-scoped) shape - it differs only in what it accepts, which is enforced
        -- by the hook below rather than by anything RegisterStash can express. See ADR-141.
        exports.ox_inventory:RegisterStash(
            ('cofre_%s'):format(gang),
            -- Reuses the stash's own label so the two containers name the same gang identically -
            -- "Baú dos Ballas" becomes "Cofre dos Ballas". Parenthesised because `gsub` returns a
            -- count as its second value, which `format` would otherwise be handed.
            ('Cofre%s'):format((stash.label:gsub('^Baú', ''))),
            Config.vaultSlots,
            Config.vaultWeight,
            nil,
            { [gang] = 0 }
        )
    end
end)

-- Servidor: the vault takes money and nothing else.
--
-- `RegisterStash` has no way to whitelist items, so this is a `swapItems` hook - the same mechanism
-- `srv_shootingrange` uses to stop its loaner weapons leaving. It fires for every move on the
-- server, so it returns `true` immediately for anything that is not going INTO a vault; only the
-- last case actually refuses.
--
-- Taking money OUT is never blocked: the hook only inspects the destination.
CreateThread(function()
    exports.ox_inventory:registerHook('swapItems', function(payload)
        local toInventory = payload.toInventory

        if type(toInventory) ~= 'string' or not toInventory:find('^cofre_') then return true end

        -- `fromSlot` is the slot DATA table on a real move; guard the shape rather than the value,
        -- since a non-table here means the payload is not what this hook is for.
        local item = type(payload.fromSlot) == 'table' and payload.fromSlot.name

        if item and Config.vaultItems[item] then return true end

        TriggerClientEvent('ox_lib:notify', payload.source,
            { title = 'O cofre só guarda dinheiro.', type = 'error' })

        return false
    end)
end)

---@param source number
---@return string? gang, table? stash
local function gangStashFor(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local gang = player.PlayerData.gang.name
    local stash = Config.stashes[gang]
    if not stash then return end

    return gang, stash
end

--- Shared by the stash and the vault: both live in the same places and answer to the same gang.
---
--- Returns the gang name when the caller may open a container right now, or `nil` after having
--- already told them why not.
--- Servidor: `key` was missing and the bug it caused is worth naming - this function took only the
--- WORD for the refusal message and then checked `base.stash` for both containers. The vault sits
--- ~15m from the stash, so standing at the vault failed the base test and the only way to open it
--- was from inside the territory. Reported as "não consigo abrir o cofre". A parameter used for a
--- message is not a parameter that selects behaviour, and this needed both.
---@param source number
---@param what string 'baú' or 'cofre', for the refusal message
---@param key string the `GangBase` field this container sits at - 'stash' or 'vault'
---@return string? gang
local function gangContainerAccess(source, what, key)
    local gang, stash = gangStashFor(source)

    if not gang or not stash then
        TriggerClientEvent('ox_lib:notify', source,
            { title = 'Você não faz parte de nenhuma gangue.', type = 'error' })
        return
    end

    -- Position is read from the server's own copy of the ped, never sent by the client.
    local coords = GetEntityCoords(GetPlayerPed(source))

    -- Servidor: two valid places, not one. The territory anchor (ADR-126) stays, and the gang's BASE
    -- is added once that coordinate exists (ADR-136). Keeping both matters: four gangs have no base
    -- at all, so requiring one would have taken the stash away from them entirely rather than
    -- moving it.
    local base = Config.bases[gang]
    local atTerritory = #(coords - stash.coords) <= Config.stashRadius
    local point = base and base[key]
    local atBase = point and #(coords - point) <= Config.baseInteractionDistance + 1.0

    if not atTerritory and not atBase then
        TriggerClientEvent('ox_lib:notify', source,
            { title = ('O %s da sua gangue fica no território ou na base dela.'):format(what), type = 'error' })
        return
    end

    return gang
end

--- Whether the caller is standing at a named point of their OWN gang's base.
---
--- The generic form of the check `openStash`/`openVault` do for containers, for the base points
--- that are not containers. Any future base point routes through this rather than trusting the
--- client to have only shown its prompt in the right place - the prompt is UI, this is the rule
--- (CLAUDE.md rule 2). See ADR-147.
---
--- The 1.0 slack matches the container checks: the client shows its prompt at exactly
--- `baseInteractionDistance`, and a player can drift a little between pressing the key and the
--- event arriving. Tight enough that it cannot be used from anywhere else.
---@param source number
---@param key string the `GangBase` field, e.g. 'wardrobe'
---@return string? gang
local function gangBasePoint(source, key)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local gang = player.PlayerData.gang.name
    local base = gang ~= 'none' and Config.bases[gang]
    local point = base and base[key]

    if not point then
        TriggerClientEvent('ox_lib:notify', source,
            { title = 'Isso é da base da sua gangue.', type = 'error' })
        return
    end

    -- Position from the server's own copy of the ped, never sent by the client.
    if #(GetEntityCoords(GetPlayerPed(source)) - point) > Config.baseInteractionDistance + 1.0 then
        TriggerClientEvent('ox_lib:notify', source,
            { title = 'Você não está na base da sua gangue.', type = 'error' })
        return
    end

    return gang
end

--- Servidor: the wardrobe used to be opened by a purely LOCAL `TriggerEvent` on the client - the
--- server never heard about it, so anyone could fire `srv_wardrobe:client:open` from anywhere,
--- with no gang and nowhere near a base. It was the one base point out of five not going through
--- the server, and it was inconsistent rather than dangerous (changing clothes moves no item, money
--- or permission) - but it did not match the rule the other four follow. See ADR-147.
RegisterNetEvent('srv_gangs:server:openWardrobe', function()
    local source = source
    if not gangBasePoint(source, 'wardrobe') then return end

    TriggerClientEvent('srv_wardrobe:client:open', source)
end)

RegisterNetEvent('srv_gangs:server:openStash', function()
    local source = source
    local gang = gangContainerAccess(source, 'baú', 'stash')
    if not gang then return end

    exports.ox_inventory:forceOpenInventory(source, 'stash', ('gang_%s'):format(gang))
end)

RegisterNetEvent('srv_gangs:server:openVault', function()
    local source = source
    local gang = gangContainerAccess(source, 'cofre', 'vault')
    if not gang then return end

    exports.ox_inventory:forceOpenInventory(source, 'stash', ('cofre_%s'):format(gang))
end)

RegisterNetEvent('srv_gangs:server:checkAccount', function()
    local source = source
    local gang = gangStashFor(source)

    if not gang then
        TriggerClientEvent('ox_lib:notify', source,
            { title = 'Você não faz parte de nenhuma gangue.', type = 'error' })
        return
    end

    -- `Renewed-Banking` registers this under the `qb-management` export name it replaced - not a
    -- typo, and not a dependency on `qb-management` itself, which this server does not run.
    local balance = exports['qb-management']:GetGangAccount(gang) or 0

    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Caixa da Gangue',
        description = ('Saldo: $%s'):format(lib.math.groupdigits(balance)),
        type = 'inform',
    })
end)

-- ============================================================================
-- Rota de Cobrança (ADR-145)
--
-- A member takes the route from the base ped and is sent to a handful of street corners to collect
-- what the sellers there owe the gang. Repeatable with no cooldown, capped at a number of STOPS per
-- real calendar day.
--
-- Authoritative throughout: the client is told where to go, and is never believed about having
-- arrived. Every payout re-reads the player's position from the server's own copy of the ped, and
-- re-reads the daily count from the database - a client that lies gets refused, not paid.
-- ============================================================================

local COLLECTION_TABLE <const> = 'srv_gangs_collection'

MySQL.ready(function()
    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS %s (
            citizenid VARCHAR(50) NOT NULL,
            collect_date DATE NOT NULL,
            stop_count INT NOT NULL DEFAULT 0,
            PRIMARY KEY (citizenid, collect_date)
        )
    ]]):format(COLLECTION_TABLE))
end)

--- Active routes, by player source. Server-side only - the client is sent the stop list to draw,
--- but this is the copy that decides whether a collection is valid.
---@type table<number, {gang: string, stops: vector3[], index: number}>
local activeRoutes = {}

--- How many stops `cid` has collected today, from the DATABASE's own CURDATE() rather than this
--- server's clock. Same source the counter writes to, so the check and the write can never disagree
--- about which day it is.
---@param cid string
---@return integer
local function collectedToday(cid)
    local row = MySQL.single.await(
        ('SELECT stop_count FROM %s WHERE citizenid = ? AND collect_date = CURDATE()'):format(COLLECTION_TABLE),
        { cid }
    )

    return row and row.stop_count or 0
end

--- Picks `count` distinct stops at random from the shared pool.
---
--- A partial Fisher-Yates over a COPY: shuffling in place would mutate `srv_jobs`' own table
--- through the export's reference and quietly reorder the street-dealing job's stops too.
---@param count integer
---@return vector3[]
local function pickStops(count)
    local pool = exports.srv_jobs:GetSharedStops()
    local copy = {}

    for i = 1, #pool do copy[i] = pool[i] end

    local picked = {}
    local available = #copy

    for i = 1, math.min(count, available) do
        local roll = math.random(i, available)
        copy[i], copy[roll] = copy[roll], copy[i]
        picked[i] = copy[i]
    end

    return picked
end

lib.callback.register('srv_gangs:server:startCollection', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return { ok = false } end

    local gang = player.PlayerData.gang.name
    if gang == 'none' then return { ok = false, reason = 'nogang' } end

    local base = Config.bases[gang]
    if not base or not base.collectionRoute then return { ok = false, reason = 'nobase' } end

    -- Position from the server's own ped, never sent by the client.
    local coords = GetEntityCoords(GetPlayerPed(source))
    if #(coords - base.collectionRoute) > Config.baseInteractionDistance + 1.0 then
        return { ok = false, reason = 'far' }
    end

    -- Servidor: one route at a time. Pressing [E] at the ped with a route already running used to
    -- silently replace it with a fresh one - a free reroll of five random stops, and any progress
    -- toward the ones already walked to simply vanished. Reported as "peguei a rota, aperto E, pego
    -- de novo". Cancelling is now a deliberate act at the same ped, not a side effect of talking to
    -- it. See ADR-148.
    if activeRoutes[source] then
        return { ok = false, reason = 'active' }
    end

    local cid = player.PlayerData.citizenid
    local done = collectedToday(cid)
    local remaining = Config.collection.dailyStopLimit - done

    if remaining <= 0 then
        return { ok = false, reason = 'dailylimit' }
    end

    -- A run never hands out more stops than the player can still be paid for, so the ceiling is
    -- reached exactly rather than mid-route with stops left pointing nowhere.
    local stops = pickStops(math.min(Config.collection.stops, remaining))

    activeRoutes[source] = { gang = gang, stops = stops, index = 1 }

    return { ok = true, stops = stops, remaining = remaining }
end)

lib.callback.register('srv_gangs:server:collectStop', function(source)
    local route = activeRoutes[source]
    if not route then return { ok = false } end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return { ok = false } end

    -- The gang is re-checked every stop: a member kicked out mid-route stops being paid by it.
    if player.PlayerData.gang.name ~= route.gang then
        activeRoutes[source] = nil
        return { ok = false, reason = 'nogang' }
    end

    local target = route.stops[route.index]
    if not target then
        activeRoutes[source] = nil
        return { ok = false }
    end

    local coords = GetEntityCoords(GetPlayerPed(source))
    if #(coords - target) > Config.collection.stopDistance + 1.0 then
        return { ok = false, reason = 'far' }
    end

    local cid = player.PlayerData.citizenid

    -- Re-read rather than trusting the figure from `startCollection`: a route can outlive midnight,
    -- and a player can hold two sessions. The ceiling is enforced here, at the moment money moves.
    local before = collectedToday(cid)

    if before >= Config.collection.dailyStopLimit then
        activeRoutes[source] = nil
        return { ok = false, reason = 'dailylimit' }
    end

    local pay = Config.collection.payPerStop

    if not exports.ox_inventory:AddItem(source, 'black_money', pay) then
        return { ok = false, reason = 'noroom' }
    end

    MySQL.query((
        'INSERT INTO %s (citizenid, collect_date, stop_count) VALUES (?, CURDATE(), 1) ' ..
        'ON DUPLICATE KEY UPDATE stop_count = stop_count + 1'
    ):format(COLLECTION_TABLE), { cid })

    route.index += 1

    -- Derived from the count read BEFORE the insert, not re-read after it: `MySQL.query` above is
    -- fire-and-forget, so a second read here could easily land before the write and report a stale
    -- figure - which would tell the player they had a stop left when they did not.
    local remaining = Config.collection.dailyStopLimit - (before + 1)
    local finished = route.index > #route.stops

    if finished or remaining <= 0 then
        activeRoutes[source] = nil
    end

    return {
        ok = true,
        paid = pay,
        finished = finished,
        remaining = math.max(0, remaining),
        -- Distinguishes "route over" from "you have hit the daily ceiling", so the client can say
        -- which one happened instead of one message covering both.
        limitReached = remaining <= 0,
    }
end)

AddEventHandler('playerDropped', function()
    activeRoutes[source] = nil
end)

--- Cancels the caller's active route, at the ped that handed it out.
---
--- Deliberately requires standing at the ped rather than being a menu option from anywhere: the
--- route is taken face to face, and it is given back the same way. Nothing is paid back and nothing
--- is lost beyond the stops not yet walked - the daily counter only ever moved on collections that
--- actually happened.
lib.callback.register('srv_gangs:server:cancelCollection', function(source)
    if not activeRoutes[source] then return { ok = false } end
    if not gangBasePoint(source, 'collectionRoute') then return { ok = false } end

    activeRoutes[source] = nil

    return { ok = true }
end)
