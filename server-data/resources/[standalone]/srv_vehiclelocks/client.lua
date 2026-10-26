-- Servidor: this project's own `[E]` prompts for getting into and starting a car you don't have the
-- key to, replacing `qbx_vehiclekeys`' own hidden keybinds end to end. That resource has no
-- `[E]`/target system anywhere - locking is `L`, and finding keys once seated was `H` - and this
-- reaches the exact same underlying mechanics (the door lockpick, the hotwire, the key search) via
-- a proximity prompt instead of a keybind a player has to already know exists.
--
-- Two entirely separate prompts, never both live at once:
--   AT THE DOOR (not seated) - "Destrancar" if the player has the key, "Arrombar" (lockpick) if not.
--   SEATED, no key - "Procurar chaves" first; only once that has failed once for THIS vehicle does
--   the same `[E]` become "Ligação direta" (hotwire) instead. The lockpick tool is what both the
--   door and the hotwire consume - qbx_vehiclekeys' own `Hotwire` already rolls the same break
--   chance on the same item, this project just gates reaching it on actually holding one.
--
-- See ADR-111 (the door), ADR-115 (the seated half and retiring the native `H` prompt).

local INTERACT_CONTROL = 38 -- Servidor: this project's own [E] convention (see srv_robbery, srv_jobs)

-- Servidor: TWO radii, not one, and this is the whole reason the first version of this file showed
-- no prompt at all on a box truck. `lib.getClosestVehicle` measures to the vehicle's ENTITY ORIGIN
-- (its centre), which on a long vehicle sits several metres behind the driver's door - a single
-- small radius measured from there can never reach a player standing at the cab. `qbx_vehiclekeys`
-- already solves this the same way and its own numbers are copied here rather than re-invented:
-- `config.client.vehicleMaximumLockingDistance = 9.0` for the centre-based search, and
-- `LockpickDoor`'s own `maxDistance = 2` for the real, door-bone-based proximity that decides
-- whether the player is actually AT a door.
local SEARCH_RADIUS = 9.0
local DOOR_RADIUS = 2.0

-- Servidor: how long the seated "Procurar chaves" progress circle runs. Deliberately NOT
-- `qbx_vehiclekeys`' own `minKeysSearchTime`/`maxKeysSearchTime` (20-40 SECONDS) - reduced by
-- request, and it is a fixed value rather than a random range because this whole action is now
-- built here rather than reused from that resource's own `findKeys()` (see below). Every other
-- "quick action" progress circle in this project runs 2-10s; 20-40s was an outlier even before
-- being asked to shrink it.
local SEARCH_KEYS_DURATION_MS = 8000

-- Servidor: mirrored from `qbx_vehiclekeys/client/functions.lua` - `getBoneCoords`,
-- `getIsCloseToAnyBone` and `doorBones` are all `local` there, so they cannot be reused across the
-- resource boundary the way the exported `HasKeys` can. Copied verbatim in behaviour (including the
-- fall back to entity coords when a model has no such bone) rather than approximated.
local DOOR_BONES = { 'door_dside_f', 'door_dside_r', 'door_pside_f', 'door_pside_r' }

local function getBoneCoords(entity, boneName)
    local boneIndex = GetEntityBoneIndexByName(entity, boneName)

    return boneIndex ~= -1
        and GetWorldPositionOfEntityBone(entity, boneIndex)
        or GetEntityCoords(entity)
end

local function isCloseToAnyDoor(coords, vehicle)
    for i = 1, #DOOR_BONES do
        if #(coords - getBoneCoords(vehicle, DOOR_BONES[i])) < DOOR_RADIUS then
            return true
        end
    end

    return false
end

---@return number? vehicle, string? state 'unlock'|'lockpick'
local function findPromptableVehicle()
    if cache.vehicle then return end -- already inside a vehicle, nothing to prompt at a door for

    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords, SEARCH_RADIUS, false)
    if not vehicle or vehicle == 0 then return end

    if not isCloseToAnyDoor(coords, vehicle) then return end

    -- Servidor: exactly 2 ("locked"), not merely ">= 2". Everything this server actually locks ends
    -- up at 1 or 2 - `qbx_vehiclekeys`' own `toggleLock` toggles between exactly those two, and its
    -- `onVehicleAttemptToEnter` sets one of them on every ambient vehicle. The higher GTA lock
    -- states mean something else entirely, and one of them is load-bearing here: `qbx_vehicleshop`
    -- sets its showroom cars to **10** ("cannot even be tried"), which a `>= 2` test read as a
    -- locked car and happily offered up for lockpicking. Reported exactly that way - dealership
    -- cars could be broken into, and succeeding set their lock state to 1 permanently.
    if GetVehicleDoorLockStatus(vehicle) ~= 2 then return end

    -- Servidor: `qbx_vehiclekeys`' own `GetIsVehicleAccessible` (personal key OR job-shared access)
    -- is a plain global inside that resource, not reachable from here - only `HasKeys` is exported.
    -- Job-shared vehicles (a job's whole fleet, not a personal key) fall through to the lockpick
    -- prompt below instead of the unlock one - a known, narrow gap, not a security issue: at worst
    -- an on-duty officer sees "Arrombar" on their own squad car instead of "Destrancar".
    --
    -- pcall'd because this runs in a loop: `HasKeys` yields (`lib.callback.await`) on the branch
    -- where the player owns the vehicle, and a yield inside a cross-resource export call is exactly
    -- the kind of thing that raises rather than returns. An error here must not silently kill the
    -- whole prompt thread - it would look identical to "the feature does nothing".
    local ok, hasKeys = pcall(function()
        return exports.qbx_vehiclekeys:HasKeys(vehicle)
    end)

    if ok and hasKeys then
        return vehicle, 'unlock'
    end

    if IsVehicleSeatFree(vehicle, -1) then
        return vehicle, 'lockpick'
    end
end

--- Servidor: the same toggle `qbx_vehiclekeys`' own `L` keybind runs (`client/main.lua`'s
--- `toggleLock`) - that function is local to that resource and not reachable from here, so this
--- mirrors it rather than reimplementing the lock logic itself: same fob anim, same server event,
--- same light-blink feedback, same notify. Only reachable here when `HasKeys` already agreed the
--- player has the key, the same gate `L` uses.
local function unlockWithKey(vehicle)
    lib.playAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49)

    local newLockState = (GetVehicleDoorLockStatus(vehicle) % 2) + 1
    TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), newLockState)

    lib.notify({ description = newLockState == 2 and 'Carro trancado.' or 'Carro destrancado.', type = 'success' })

    SetVehicleLights(vehicle, 2)
    Wait(250)
    SetVehicleLights(vehicle, 1)
    Wait(200)
    SetVehicleLights(vehicle, 0)
    Wait(300)
    ClearPedTasks(cache.ped)
end

--- Servidor: reuses `qbx_vehiclekeys`' own `lockpicks:UseLockpick` event end to end - not just for
--- the door. That event already branches on `cache.vehicle` itself: fired from OUTSIDE a vehicle
--- it runs `LockpickDoor` (opens a locked door); fired from INSIDE one it runs `Hotwire` (bypasses
--- the ignition regardless of lock state). One trigger, two different native mechanics, entirely by
--- where the player is standing when it fires - so this single function serves both the door
--- lockpick prompt and the seated hotwire prompt below, unchanged.
---
--- The only thing added on top is the server-side lockpick-possession check, standing in for the
--- inventory gate that normally reaches this same event through "using" the item - see the note in
--- server.lua.
local function useLockpickItem()
    local hasLockpick = lib.callback.await('srv_vehiclelocks:server:hasLockpick', false)
    if not hasLockpick then
        lib.notify({ description = 'Você precisa de uma chave mestra.', type = 'error' })
        return
    end

    TriggerEvent('lockpicks:UseLockpick', false)
end

-- Servidor: keyed by network id (survives a re-entry, not just an in-memory entity handle), tracks
-- which vehicles have already had a failed key search - once one has, the seated `[E]` becomes
-- "Ligação direta" instead of "Procurar chaves" for that specific vehicle, by request: the search
-- is offered once as the free, no-tool option, and only falls back to hotwiring (which needs the
-- same chave mestra the door lockpick does) after it has actually failed.
local searchFailedVehicles = {}

--- Servidor: this project's own trigger for a mechanic `qbx_vehiclekeys` otherwise only offers
--- through its own hidden `H` keybind (`searchkeys.lua`'s `findKeys`) - that function is `local` to
--- that resource and reads its own per-model animation table, neither of which is reachable from
--- here. Rather than guess an animation, this reuses the same verified `random@shop_robbery`/
--- `robbery_action_b` clip every other quick "grab/search" action in this project already does, and
--- calls the exact same server callback (`qbx_vehiclekeys:server:findKeys`) that resource's own
--- keybind calls - so the odds, and what a success actually grants (`GiveKeys`, server-side,
--- untouched), are identical. Only the trigger and the duration are new.
---@param vehicle number
local function trySearchKeys(vehicle)
    if not lib.progressCircle({
        duration = SEARCH_KEYS_DURATION_MS,
        position = 'bottom',
        label = 'Procurando chaves...',
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'random@shop_robbery', clip = 'robbery_action_b' },
    }) then
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local success = lib.callback.await('qbx_vehiclekeys:server:findKeys', false, netId)

    if success then
        lib.notify({ description = 'Você achou a chave.', type = 'success' })
    else
        searchFailedVehicles[netId] = true
        lib.notify({ description = 'Não achou nada.', type = 'error' })
    end
end

---@return number? vehicle, string? state 'search'|'hotwire'
local function findSeatedPrompt()
    local vehicle = cache.vehicle
    if not vehicle or cache.seat ~= -1 then return end -- only the driver's seat has an ignition

    -- Servidor: same pcall reasoning as `findPromptableVehicle` above - `HasKeys` can yield, and an
    -- error here must not silently kill this thread.
    local ok, hasKeys = pcall(function() return exports.qbx_vehiclekeys:HasKeys(vehicle) end)
    if ok and hasKeys then return end -- accessible - nothing to prompt for

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    return vehicle, searchFailedVehicles[netId] and 'hotwire' or 'search'
end

-- Servidor: two speeds on purpose. `IsControlJustPressed` is only ever true on the single frame the
-- key went down, so it has to be polled every frame - the first version of this loop checked it on
-- a 200ms tick and would have silently swallowed almost every press. Scanning for a nearby vehicle
-- every frame, on the other hand, is wasteful (`lib.getClosestVehicle` walks the vehicle pool), so
-- the search stays on a 200ms tick and only the keypress runs per-frame, inside the window where a
-- prompt is actually up. Same shape ox_lib zones give `srv_robbery`'s own points for free; there
-- is no zone to hang this off, because the thing being interacted with moves.
local RESCAN_INTERVAL_MS = 200

CreateThread(function()
    while true do
        local vehicle, state = findPromptableVehicle()

        if not vehicle then
            Wait(RESCAN_INTERVAL_MS)
        else
            lib.showTextUI(state == 'unlock' and '[E] Destrancar o carro.' or '[E] Arrombar o carro.')

            local nextScan = GetGameTimer() + RESCAN_INTERVAL_MS

            while true do
                Wait(0)

                if IsControlJustPressed(0, INTERACT_CONTROL) then
                    lib.hideTextUI()

                    if state == 'unlock' then
                        unlockWithKey(vehicle)
                    else
                        useLockpickItem()
                    end

                    break
                end

                -- Servidor: the prompt has to drop when the player walks away or the state changes
                -- (someone else unlocks it, the player gets keys), so the same check that raised it
                -- is re-run on the original tick rate rather than every frame.
                if GetGameTimer() >= nextScan then
                    local stillVehicle, stillState = findPromptableVehicle()

                    if stillVehicle ~= vehicle or stillState ~= state then
                        lib.hideTextUI()
                        break
                    end

                    nextScan = GetGameTimer() + RESCAN_INTERVAL_MS
                end
            end
        end
    end
end)

-- Servidor: the seated half - same two-speed shape as the door loop above, and the same reasons for
-- it (`IsControlJustPressed` needs a per-frame poll; re-scanning the vehicle/seat/keys state does
-- not). Entirely separate from the door loop because `findPromptableVehicle` explicitly bails the
-- instant `cache.vehicle` is set - a door prompt and a seated prompt are never candidates for the
-- same moment, so there is no priority question between the two the way there is with a place's
-- text UI elsewhere in this project.
CreateThread(function()
    while true do
        local vehicle, state = findSeatedPrompt()

        if not vehicle then
            Wait(RESCAN_INTERVAL_MS)
        else
            lib.showTextUI(state == 'search' and '[E] Procurar chaves.' or '[E] Ligação direta.')

            local nextScan = GetGameTimer() + RESCAN_INTERVAL_MS

            while true do
                Wait(0)

                if IsControlJustPressed(0, INTERACT_CONTROL) then
                    lib.hideTextUI()

                    if state == 'search' then
                        trySearchKeys(vehicle)
                    else
                        useLockpickItem()
                    end

                    break
                end

                if GetGameTimer() >= nextScan then
                    local stillVehicle, stillState = findSeatedPrompt()

                    if stillVehicle ~= vehicle or stillState ~= state then
                        lib.hideTextUI()
                        break
                    end

                    nextScan = GetGameTimer() + RESCAN_INTERVAL_MS
                end
            end
        end
    end
end)
