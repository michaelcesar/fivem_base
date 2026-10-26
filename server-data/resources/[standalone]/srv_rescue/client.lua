local config = require 'config'

--- Servidor: the client half of the paid NPC rescue. It owns the SCENE only - every rule about
--- money, debt, wanted status and whether a rescue is owed lives on the server (CLAUDE.md rule 2).
--- This file can be lied to and the worst a liar achieves is a free animation.

local sceneRunning = false

--- The ambulance currently on its way, so the panel can report how far off it is.
local sceneVehicle = nil

--- Set the moment the fade begins, so the panel survives the whole approach and disappears only
--- when the player is actually being taken away.
local sceneEnding = false

--- Which attempt is in the air, so the downed panel can show the player that a second and third
--- ambulance really were sent rather than leaving them staring at an unchanging line.
local sceneAttempt = 0

--- When the current attempt runs out, so the panel can count it down. Watching a number fall is
--- how the player knows the ambulance is still being given a chance rather than forgotten.
local sceneAttemptEnds = 0

lib.callback.register('srv_rescue:client:isDown', function()
    return exports.qbx_medical:IsDead() or exports.qbx_medical:IsLaststand()
end)

--- Finds a road node for the ambulance to appear on.
---
--- Spawning it on the nearest road rather than at a fixed offset is what keeps the drive short and
--- on tarmac - the one stretch GTA's NPC driving handles reliably. If no node is reachable (a roof,
--- a mountain, deep interior), the server is told so and delivers the rescue without the scene
--- rather than sending an ambulance that can never arrive.
RegisterNetEvent('srv_rescue:client:findSpawn', function(target)
    local from = vec3(target.x + 0.0, target.y + 0.0, target.z + 0.0)

    for _, distance in ipairs({ config.ambulance.spawnDistance, 90.0, 60.0, 40.0 }) do
        local found, node, heading = GetClosestVehicleNodeWithHeading(
            from.x + math.random(-distance, distance),
            from.y + math.random(-distance, distance),
            from.z,
            1, 3.0, 0
        )

        if found then
            return TriggerServerEvent('srv_rescue:server:spawnAt', {
                x = node.x, y = node.y, z = node.z, w = heading,
            })
        end
    end

    lib.print.warn('no road node near the player; asking for delivery without the scene')
    TriggerServerEvent('srv_rescue:server:sceneFinished')
end)

--- Drives the ambulance in, plays the pickup, loads the player, pulls away, then fades him out.
RegisterNetEvent('srv_rescue:client:runScene', function(data)
    if sceneRunning then return end
    sceneRunning = true

    CreateThread(function()
        local ped = cache.ped
        local vehicle, driver

        --- Creates the ambulance and its driver. Runs ONCE: a failed attempt does not throw the
        --- vehicle away and start over from somewhere far off - it keeps going from wherever it
        --- got stuck, which is both more likely to succeed and what an ambulance that is still on
        --- its way actually looks like.
        ---@return boolean
        local function spawnAmbulance()
            lib.requestModel(config.ambulance.model, 5000)
            lib.requestModel(config.ambulance.driver, 5000)

            local spawn = data.spawn
            vehicle = CreateVehicle(config.ambulance.model, spawn.x, spawn.y, spawn.z, spawn.w, true, false)

            if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end

            -- Servidor: this vehicle is networked (isNetwork = true at CreateVehicle), so the
            -- mission-entity claim must say so too, or DeleteEntity silently does nothing.
            SetEntityAsMissionEntity(vehicle, true, true)
            SetVehicleEngineOn(vehicle, true, true, false)
            SetVehicleSiren(vehicle, true)
            sceneVehicle = vehicle

            driver = CreatePedInsideVehicle(vehicle, 26, config.ambulance.driver, -1, true, false)

            SetModelAsNoLongerNeeded(config.ambulance.model)
            SetModelAsNoLongerNeeded(config.ambulance.driver)

            if not driver or driver == 0 or not DoesEntityExist(driver) then
                driver = nil
                return false
            end

            -- Servidor: this ped is networked (isNetwork = true at CreatePedInsideVehicle), so
            -- the mission-entity claim must say so too, or DeleteEntity silently does nothing.
            SetEntityAsMissionEntity(driver, true, true)
            SetBlockingOfNonTemporaryEvents(driver, true)
            SetEntityInvincible(driver, true)
            SetDriverAbility(driver, 1.0)
            SetDriverAggressiveness(driver, 1.0)
            SetPedKeepTask(driver, true)

            return true
        end

        --- Points the ambulance at the player from wherever it currently is. Re-issued each
        --- attempt, because a driving task that has given up leaves the ped idling in traffic with
        --- no error - the only cure is asking again.
        local function driveToPlayer()
            if not driver or not DoesEntityExist(driver) or not DoesEntityExist(vehicle) then return end

            local target = GetEntityCoords(ped)

            ClearPedTasks(driver)
            TaskVehicleDriveToCoord(driver, vehicle, target.x, target.y, target.z,
                config.ambulance.driveSpeed, 0, GetEntityModel(vehicle),
                config.ambulance.drivingStyle, 8.0, true)
        end

        ---@return boolean arrived
        local function waitForArrival()
            local deadline = GetGameTimer() + config.ambulance.attemptSeconds * 1000
            sceneAttemptEnds = deadline

            while GetGameTimer() < deadline do
                if not DoesEntityExist(vehicle) then return false end
                -- 40m, not 15. An ambulance cannot leave the road: when the player is down on a
                -- pavement or a verge it parks at the nearest point the tarmac allows and stops,
                -- which was being read as a failed attempt at 36m with the engine idling. The
                -- paramedic walks the rest, which is what a paramedic does.
                if #(GetEntityCoords(vehicle) - GetEntityCoords(ped)) <= 40.0 then return true end

                Wait(500)
            end

            return false
        end

        local function scrap()
            for _, entity in ipairs({ driver, vehicle }) do
                if entity and DoesEntityExist(entity) then
                    SetEntityAsMissionEntity(entity, false, true)
                    DeleteEntity(entity)
                end
            end

            vehicle, driver, sceneVehicle = nil, nil, nil
        end

        local arrived = false

        if spawnAmbulance() then
            for try = 1, config.ambulance.attempts do
                sceneAttempt = try

                driveToPlayer()

                if waitForArrival() then
                    arrived = true

                    -- The attempt is over the moment it succeeds. Leaving the counter running
                    -- left the panel counting down attempt 1 of 3 while the paramedic was
                    -- already loading the player into the back of the ambulance.
                    sceneAttempt = 0
                    sceneAttemptEnds = 0
                    break
                end

                local stuck = DoesEntityExist(vehicle) and GetEntitySpeed(vehicle) < 2.0

                if stuck and try < config.ambulance.attempts then
                    scrap()

                    -- A node picked around the player rather than the original faraway point:
                    -- whatever the first spawn chose led somewhere a vehicle could not finish,
                    -- and trying it again would fail the same way.
                    local from = GetEntityCoords(ped)
                    local angle = math.random() * math.pi * 2
                    local found, node, heading = GetClosestVehicleNodeWithHeading(
                        from.x + math.cos(angle) * 130.0,
                        from.y + math.sin(angle) * 130.0,
                        from.z, 1, 3.0, 0)

                    if found then
                        data.spawn = { x = node.x, y = node.y, z = node.z, w = heading }
                        spawnAmbulance()
                    end
                end

                TriggerServerEvent('srv_rescue:server:log', 'attempt', {
                    try = try,
                    away = DoesEntityExist(vehicle)
                        and math.floor(#(GetEntityCoords(vehicle) - GetEntityCoords(ped))) or -1,
                    speed = DoesEntityExist(vehicle) and math.floor(GetEntitySpeed(vehicle)) or -1,
                    respawned = stuck,
                })

                if try < config.ambulance.attempts then
                    lib.notify({
                        title = 'Ambulância',
                        description = ('A ambulância está presa no trânsito. Tentando de novo (%s de %s).'):format(
                            try + 1, config.ambulance.attempts),
                        type = 'inform',
                    })
                end
            end
        end
        if not arrived then
            scrap()
            sceneRunning = false
            sceneEnding = false
            sceneAttempt = 0
            sceneAttemptEnds = 0

            -- Genuinely failed. The server refunds and clears the call, because charging for a
            -- rescue that never happened is the one outcome this feature must never produce.
            return TriggerServerEvent('srv_rescue:server:failed')
        end
        -- Bought time. Topped up the moment the ambulance is close enough for the pickup to
        -- start, and again as the scene proceeds, so the clock cannot expire between the medic
        -- kneeling and the player waking in hospital.
        local function buyTime(seconds)
            if exports.qbx_medical.IncrementDeathTime then
                exports.qbx_medical:IncrementDeathTime(seconds)
            end

            if exports.qbx_medical.IncrementLaststandTime then
                exports.qbx_medical:IncrementLaststandTime(seconds)
            end
        end

        buyTime(180)

        -- The pickup. Written as a sequence of separate steps, each optional, because every one of
        -- them can fail on its own and none of them is worth losing the rescue over: a player who
        -- paid must end up in hospital even if the paramedic never plays a single frame.
        -- Whether the carry made it to the ambulance. When it did not, the player is NOT put
        -- down: being dropped in the road by the medic who came for you is a worse ending than
        -- a cut, so the screen fades while he is still being carried and he wakes in hospital.
        local reachedVehicle = false

        local function tryAnim(dict, timeout)
            return lib.requestAnimDict(dict, timeout or 2000) and true or false
        end

        if arrived and driver and DoesEntityExist(driver) then
            -- Out of the ambulance and over to the player on foot. TaskGoToEntity rather than a
            -- fixed coordinate, so he walks to where the body actually is.
            ClearPedTasks(driver)
            TaskLeaveVehicle(driver, vehicle, 0)
            Wait(2200)

            TaskGoToEntity(driver, ped, 20000, 1.2, 2.0, 1073741824, 0)

            -- Every position he passes through on the way out, recorded.
            --
            -- The way back is this list, backwards. Three attempts at asking the pathfinder to
            -- work out a route to the ambulance all circled, and all of them were solving a
            -- problem that does not need solving: the route is already known, because the man
            -- just ran it. A breadcrumb trail cannot path into a wall or a fence, because
            -- nothing on it is anywhere he has not physically stood.
            local trail = { GetEntityCoords(driver) }

            local reachBy = GetGameTimer() + 21000

            -- TEMPORARY, paired with the [carry] report below. The first report showed the return
            -- leg finishing in 0.4s and one hop, which means the walk that still looks wrong is
            -- not the one that was rewritten three times. This measures the other one.
            local walkOut = GetGameTimer()
            local startedAt = GetEntityCoords(driver)
            local outReached = false
            local pathLength = 0.0

            while GetGameTimer() < reachBy do
                local here = GetEntityCoords(driver)

                -- Roughly every metre. Denser than that buys nothing and turns the return into a
                -- stutter of tiny hops; sparser starts cutting corners the outbound run took.
                if #(here - trail[#trail]) >= 1.0 then
                    pathLength = pathLength + #(here - trail[#trail])
                    trail[#trail + 1] = here
                end

                if #(here - GetEntityCoords(ped)) <= 2.0 then
                    outReached = true
                    break
                end

                Wait(200)
            end

            -- pathLength against straightLine is the whole question. Equal means he ran straight
            -- at the body; a path much longer than the line he had to cover is a detour, and a
            -- detour that ends where it started is the circling.
            TriggerServerEvent('srv_rescue:server:log', 'approach', {
                trail = #trail,
                reached = outReached,
                seconds = math.floor((GetGameTimer() - walkOut) / 100) / 10,
                pathLength = math.floor(pathLength * 10) / 10,
                straightLine = math.floor(#(startedAt - GetEntityCoords(ped)) * 10) / 10,
                startedFromVehicle = math.floor(#(startedAt - GetEntityCoords(vehicle)) * 10) / 10,
                endedFromVehicle = math.floor(#(GetEntityCoords(driver) - GetEntityCoords(vehicle)) * 10) / 10,
            })

            -- Kneels to treat.
            if tryAnim('amb@medic@standing@kneel@base') then
                TaskPlayAnim(driver, 'amb@medic@standing@kneel@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
            end

            Wait(3500)
            ClearPedTasks(driver)

            -- Carried. The player is attached to the medic and both play the carry pair; if the
            -- dictionary will not load, the attach still happens and the pose is generic rather
            -- than the whole step being skipped.
            local carrierPose = tryAnim('missfinale_c2mcs_1', 3000)

            -- Collision OFF before attaching. A carried body that still collides shoves the ped
            -- carrying it, the ped corrects its heading, and the correction repeats - which is
            -- exactly the circling. Every carry system turns this off; leaving it on is the bug.
            SetEntityCollision(ped, false, false)

            -- The offset that matters is the Z: -0.02 left the body at ground level, being
            -- dragged by the feet. 0.63 lifts it into the carrier's arms, which is what the
            -- animation pair below is posed for.
            AttachEntityToEntity(ped, driver, 0, 0.27, 0.15, 0.63,
                0.5, 0.5, 0.0, false, false, false, false, 2, true)

            if carrierPose then
                -- Flag 49 (loop + upper body) is what allows the carrier to walk while holding
                -- the pose. A full-body looping animation fights the movement task instead.
                TaskPlayAnim(driver, 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, -8.0, -1, 49, 0, false, false, false)
            end

            -- The CARRIED player gets a limp pose, not the carry animation. Both peds were playing
            -- 'fin_c2_mcs_1_camman', which is the animation of someone DOING the carrying - so the
            -- player performed the same gesture as the medic while hanging off him.
            --
            -- 'dead'/'dead_a' is the same pair qbx_medical uses for a downed body, so it is known to
            -- exist and it matches how the player already looked lying on the ground.
            if tryAnim('dead', 2000) then
                TaskPlayAnim(ped, 'dead', 'dead_a', 8.0, -8.0, -1, 1, 0, false, false, false)
            end

            -- The outbound trail, walked backwards.
            --
            -- TaskGoStraightToCoord, not TaskGoToEntity or any of the navmesh tasks: it walks a
            -- DIRECT line and consults no pathfinder at all. On its own that would be reckless,
            -- because a straight line runs into whatever is between here and there. It is safe
            -- here for one reason only - each hop is a metre of ground the paramedic covered on
            -- foot moments ago, so there is nothing in the way by construction.
            --
            -- This is also why the circling stops. The pathfinder was never failing to find a
            -- route; it was re-deciding one every frame against a six-metre vehicle whose nearest
            -- point kept sliding along its own bodywork. Now there is nothing left to decide.
            reachedVehicle = false

            local loadBy = GetGameTimer() + 15000

            -- TEMPORARY instrumentation. The carry runs entirely client-side, so the server log
            -- cannot see any of it - which is why "it still circles" had to be diagnosed by
            -- watching rather than by reading. Remove once the walk is settled.
            local walkStarted = GetGameTimer()
            local hops, abandoned = 0, 0

            for i = #trail - 1, 1, -1 do
                if GetGameTimer() >= loadBy then break end

                local point = trail[i]

                TaskGoStraightToCoord(driver, point.x, point.y, point.z, 2.0, 4000,
                    GetEntityHeading(driver), 0.0)

                -- Per-hop, and generous: a metre at running speed is well under a second, so this
                -- only ever runs out when something really has gone wrong.
                local hopBy = GetGameTimer() + 2500
                local lastPos = GetEntityCoords(driver)
                local stuckSince = GetGameTimer()

                while GetGameTimer() < hopBy and GetGameTimer() < loadBy do
                    local here = GetEntityCoords(driver)

                    if #(here - point) <= 1.2 then break end

                    -- Stopped moving. Abandoning the hop rather than the whole trail: one bad
                    -- breadcrumb - a kerb he mounted, a body that has since rolled into the way -
                    -- should cost a step, not the rescue.
                    if #(here - lastPos) > 0.3 then
                        lastPos = here
                        stuckSince = GetGameTimer()
                    elseif GetGameTimer() - stuckSince > 1200 then
                        abandoned += 1
                        break
                    end

                    Wait(100)
                end

                hops += 1

                if #(GetEntityCoords(driver) - GetEntityCoords(vehicle)) <= 4.0 then
                    reachedVehicle = true
                    break
                end
            end

            -- The trail ends where he got out, which is beside the ambulance rather than at it.
            local closeEnough = reachedVehicle

            if not reachedVehicle then
                reachedVehicle = #(GetEntityCoords(driver) - GetEntityCoords(vehicle)) <= 6.0
            end

            TriggerServerEvent('srv_rescue:server:log', 'carry', {
                trail = #trail,
                hops = hops,
                abandoned = abandoned,
                reachedByDistance = closeEnough,
                usedFallback = reachedVehicle and not closeEnough,
                finalDistance = math.floor(#(GetEntityCoords(driver) - GetEntityCoords(vehicle)) * 10) / 10,
                seconds = math.floor((GetGameTimer() - walkStarted) / 100) / 10,
                timedOut = GetGameTimer() >= loadBy,
                reached = reachedVehicle,
            })

            if reachedVehicle then
                DetachEntity(ped, true, true)
                SetEntityCollision(ped, true, true)
                ClearPedTasks(driver)
            end
        end

        -- Into the ambulance. This is the shot the whole feature exists for, and it happens even
        -- when every step above was skipped.
        if not reachedVehicle then
            -- Cut. No drop, no seat, no ride - the rescue is honoured the short way.
            sceneEnding = true

            DoScreenFadeOut(1200)
            while not IsScreenFadedOut() do Wait(50) end

            DetachEntity(ped, true, true)
            SetEntityCollision(ped, true, true)
            SetEntityInvincible(ped, false)

            -- The ambulance and its driver go with the scene. Behind a faded screen, so nothing
            -- is seen to pop.
            scrap()

            sceneRunning = false
            sceneAttempt = 0
            sceneAttemptEnds = 0

            return TriggerServerEvent('srv_rescue:server:sceneFinished', data.key)
        end

        if DoesEntityExist(vehicle) then
            SetEntityInvincible(ped, true)

            -- Tried across several seats: the rear ones are the right ones for a stretcher, but
            -- a seat can be occupied or refused, and any seat inside the ambulance beats being
            -- left on the tarmac.
            local seated = false

            for _, seat in ipairs({ 1, 2, 0 }) do
                SetPedIntoVehicle(ped, vehicle, seat)
                Wait(250)

                if GetVehiclePedIsIn(ped, false) == vehicle then
                    seated = true
                    break
                end
            end

            if not seated then
                TriggerServerEvent('srv_rescue:server:log', 'scene', { note = 'player never entered the ambulance' })
            end

            buyTime(120)
        end

        if driver and DoesEntityExist(driver) then
            ClearPedTasks(driver)
            TaskEnterVehicle(driver, vehicle, 10000, -1, 2.0, 1, 0)
            Wait(4000)

            TaskVehicleDriveToCoord(driver, vehicle, config.wakeCoords.x, config.wakeCoords.y,
                config.wakeCoords.z, config.ambulance.driveSpeed, 0, GetEntityModel(vehicle), config.ambulance.drivingStyle, 20.0, true)
        end
        -- The ride, watched rather than waited out.
        --
        -- A flat Wait assumes the trip goes well. It does not always: the ambulance rolls, gets
        -- rammed, catches fire, or the player is thrown clear. Sitting through the remaining
        -- seconds inside a burning wreck before a fade is worse than cutting there and then, and
        -- the rescue was paid for either way.
        local rideUntil = GetGameTimer() + data.rideSeconds * 1000

        while GetGameTimer() < rideUntil do
            if not DoesEntityExist(vehicle)
                or IsEntityDead(vehicle)
                or not IsVehicleDriveable(vehicle, false)
                or IsEntityUpsidedown(vehicle)
                or GetVehiclePedIsIn(ped, false) ~= vehicle then

                TriggerServerEvent('srv_rescue:server:log', 'scene', { note = 'ride cut short' })
                break
            end

            Wait(500)
        end

        sceneEnding = true

        DoScreenFadeOut(1200)
        while not IsScreenFadedOut() do Wait(50) end

        if IsPedInAnyVehicle(ped, false) then
            SetEntityCoords(ped, config.wakeCoords.x, config.wakeCoords.y, config.wakeCoords.z, false, false, false, false)
        end

        SetEntityInvincible(ped, false)

        -- Removed HERE, and this is the only place it can be done.
        --
        -- The ambulance is created by this client, so only this client can delete it. The server
        -- has a despawn sweep for exactly this - but it sweeps activeVehicles, which its own
        -- spawnAmbulance fills and which nothing calls any more since the vehicle moved
        -- client-side. The sweep has been walking an empty table, so every rescue left a
        -- paramedic and an ambulance parked outside the hospital for the rest of the session.
        --
        -- The player is teleported out of the vehicle on the line above before this runs, so it
        -- never deletes a car with someone still inside it.
        scrap()

        sceneRunning = false
        sceneEnding = false

        TriggerServerEvent('srv_rescue:server:sceneFinished', data.key)
    end)
end)

--- Places the revived player in the hospital. Separate from the scene because it also runs for
--- someone who paid, disconnected, and came back after the ambulance could no longer reach him.
--- The operation. A fade, time on a bed, and waking up whole.
---
--- There is no native surgery cutscene to call: the medical scenes in story mode are mission
--- cutscenes and a script cannot invoke them. This is time passing in the dark, which reads as an
--- operation without claiming to be something GTA does not have.
RegisterNetEvent('srv_rescue:client:surgery', function(organ)
    CreateThread(function()
        sceneEnding = true

        lib.notify({
            title = 'Hospital',
            description = ('Você perdeu %s. A cirurgia começou.'):format(organ),
            type = 'inform',
            duration = 7000,
        })

        DoScreenFadeOut(1500)
        while not IsScreenFadedOut() do Wait(50) end

        Wait(config.transplant.surgerySeconds * 1000)

        TriggerServerEvent('srv_rescue:server:transplantDone')

        -- Placed on the bed by the same path the ambulance rescue uses, so both end identically.
        TriggerEvent('srv_rescue:client:wakeUp', config.wakeCoords)

        sceneEnding = false
    end)
end)

RegisterNetEvent('srv_rescue:client:wakeUp', function(coords)
    local ped = cache.ped

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(50) end

    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, coords.w)

    -- Both waits, not just collision: the recovery point is inside an MLO, and an interior can
    -- report ready while its floor is still not there. This is the trap that dropped a player into
    -- the metro tunnel under Pillbox - see docs/conventions.md.
    local interior = GetInteriorAtCoords(coords.x, coords.y, coords.z)
    if interior ~= 0 then LoadInterior(interior) end

    local deadline = GetGameTimer() + 8000

    while GetGameTimer() < deadline do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)

        if HasCollisionLoadedAroundEntity(ped) and (interior == 0 or IsInteriorReady(interior)) then
            break
        end

        Wait(0)
    end

    SetEntityHealth(ped, GetEntityMaxHealth(ped))

    -- Laid on the bed rather than stood next to it. The same dictionary qbx_ambulancejob uses
    -- for its own hospital beds, so the pose matches the ones a medic puts people in and the
    -- animation is known to exist.
    if lib.requestAnimDict('anim@gangops@morgue@table@', 3000) then
        TaskPlayAnim(ped, 'anim@gangops@morgue@table@', 'body_search', 8.0, 1.0, -1, 1, 0, false, false, false)
    end

    FreezeEntityPosition(ped, false)

    DoScreenFadeIn(1500)

    lib.notify({
        title = 'Hospital',
        description = 'Você foi trazido de ambulância e está recuperado.',
        type = 'success',
    })
end)

--- The downed panel.
---
--- Activated by a KEY, never by a typed command: a command nobody is told about is a feature
--- nobody uses, and typing one while bleeding out reads nothing like being hurt.
---
--- Control 44 (Q) was picked by elimination against the keys this server already binds - E, Z, H,
--- X/F6, F5, K, Y, R, left Alt, Caps Lock, 1-5, M, F10, F11, and G which qbx_ambulancejob already
--- uses here to call the medics. Q is checked per frame only while down, so it registers no
--- global mapping and cannot collide with anything outside this state.
local CALL_CONTROL = 44

--- K. E is already qbx_medical's respawn (hold to give up and lose a life), G is the medic call
--- and Q is ours, so this is the free one left in this state.
local TRANSPLANT_CONTROL = 311

--- G. qbx_ambulancejob binds this too, but with IsControlJustPressed - which never fires while
--- the ped is dead, because the game disables controls then. Its medic call has therefore never
--- worked from the downed state at all. This panel offers the row, so it performs the action.
local MEDIC_CONTROL = 47

--- When a medic may be called again. One call per knockdown assumed somebody was on duty at
--- that exact moment; a cooldown lets the player try again when someone comes on shift, while
--- still stopping the key being held down to spam every medic online.
local medicNextAt = 0

---@param seconds number
---@return string
local function clock(seconds)
    if seconds <= 0 then return '00:00' end

    return ('%02d:%02d'):format(math.floor(seconds / 60), math.floor(seconds % 60))
end

local function send(payload)
    SendNUIMessage({ action = 'update', show = payload ~= nil, ems = payload and payload.ems, npc = payload and payload.npc,
        transplant = payload and payload.transplant,
        timer = payload and payload.timer, lives = payload and payload.lives, livesDanger = payload and payload.livesDanger })
end

--- Shuts the phone while the player is down, and stops it being reopened.
---
--- The same treatment a vehicle already gives it: closed on the way in, refused while you are
--- there, handed back on the way out. A man bleeding out in the road answering messages is the
--- one thing that makes the whole bleed-out clock look like a menu screen.
---
--- setPhoneVisible closes what is open; setPhoneDisabled is what makes the key do nothing. Both
--- are needed - disabling alone leaves an already-open phone sitting on screen.
---@param locked boolean
local function lockPhone(locked)
    if locked then
        if exports.npwd:isPhoneVisible() then exports.npwd:setPhoneVisible(false) end
        exports.npwd:setPhoneDisabled(true)
        return
    end

    -- Restored to whether he actually HAS a phone, not to enabled. Blindly enabling would hand a
    -- working phone to someone who was robbed of his while unconscious, and qbx_npwd is the thing
    -- that owns that question.
    exports.npwd:setPhoneDisabled(not exports.qbx_npwd:HasPhone())
end

CreateThread(function()
    local status, lastFetch, lastSend = nil, 0, 0
    local phoneLocked = false

    while true do
        local down = exports.qbx_medical:IsDead() or exports.qbx_medical:IsLaststand()

        -- Driven by the state, not by an event, so it is also correct for a player who was
        -- already down when he reconnected.
        if down ~= phoneLocked then
            phoneLocked = down
            lockPhone(down)
        end

        -- Deliberately NOT hidden while the scene runs. Hiding on sceneRunning removed the panel
        -- at the exact moment the ambulance was dispatched, which is the only moment its distance
        -- readout is worth anything. It goes when the fade starts instead.
        if not down or sceneEnding then
            if status then
                status = nil
                medicNextAt = 0
                send(nil)
            end

            Wait(700)
            goto continue
        end

        -- Refreshed every few seconds rather than every frame: debt and wanted state change
        -- rarely, and a callback per frame would be a round trip per frame.
        if not status or GetGameTimer() - lastFetch > 4000 then
            status = lib.callback.await('srv_rescue:server:status', false)
            lastFetch = GetGameTimer()
        end

        if status then
            -- Laststand and death each keep their own clock; reading only one shows 00:00 for
            -- half the states this panel is visible in.
            local remaining = exports.qbx_medical:IsLaststand()
                and (exports.qbx_medical:GetLaststandTime() or 0)
                or (exports.qbx_medical:GetDeathTime() or 0)
            local npc

            if remaining <= 0 and not sceneRunning then
                npc = { enabled = false, state = 'Tarde demais', tone = 'bad',
                    sub = 'Nenhuma ambulância chegaria a tempo.' }
            elseif status.pending then
                -- Real distance, not an ETA. An ETA would have to guess at traffic and routing,
                -- and a number the player can watch being wrong is worse than no number.
                local away = sceneVehicle and DoesEntityExist(sceneVehicle)
                    and math.floor(#(GetEntityCoords(sceneVehicle) - GetEntityCoords(cache.ped)))
                    or nil

                npc = { enabled = false, tone = sceneAttempt > 1 and 'warn' or 'ok',
                    -- Once the attempts are done the ambulance is not approaching any more - it
                    -- has him. Reporting 0m to someone lying in the back reads as broken.
                    state = sceneAttempt == 0 and 'Resgatado'
                        or (away and ('A %sm'):format(away) or 'A caminho'),
                    sub = sceneAttempt > 0
                        and ('Tentativa %s de %s, %s restantes.'):format(
                            sceneAttempt, config.ambulance.attempts,
                            clock(math.max(0, (sceneAttemptEnds - GetGameTimer()) / 1000)))
                        or 'A caminho do hospital.' }
            elseif status.wanted then
                npc = { enabled = false, state = 'Indisponível', tone = 'bad', sub = 'Nenhuma ambulância atende procurados.' }
            elseif status.debt > 0 then
                npc = { enabled = false, state = ('Dívida $%s'):format(status.debt), tone = 'bad',
                    sub = 'Quite a dívida no hospital para chamar de novo.' }
            else
                npc = { enabled = true, state = ('$%s ao chegar'):format(status.price), tone = 'warn',
                    sub = 'Buscam você e levam ao hospital.' }
            end

            local payload = {
                timer = clock(remaining),
                -- The G row is qbx_ambulancejob's key, not ours, so it cannot be blocked from
                -- here without patching that resource. What this panel CAN do is stop offering
                -- it once an ambulance is already coming: the key still works, it just no longer
                -- reads as something worth pressing.
                -- Only once the clock is out. Before that the transplant is not on the table -
                -- there is still a rescue to be had, and offering the expensive way out early
                -- would push players into paying when waiting would have worked.
                transplant = remaining <= 0
                    and { enabled = true, state = ('$%s'):format(config.transplant.price), tone = 'bad',
                        sub = 'Última chance. Não custa uma vida.' }
                    or { enabled = false, state = '', tone = '',
                        sub = 'Disponível quando o tempo acabar.' },

                -- Calling a medic AND paying for an ambulance at once is the player's decision:
                -- the free option might not answer, and hedging is reasonable. An earlier version
                -- greyed this out once the ambulance was dispatched, which was a rule nobody asked
                -- for.
                --
                -- What does end it is the clock. Once he has bled out there is nobody left to come
                -- for him, and only the transplant is on the table.
                -- Once the clock is out this row stops being the medic call and becomes the way
                -- out. The KEY changes with it: giving up is qbx_medical's hold-E respawn, not G,
                -- and a row naming the wrong key is worse than a row showing nothing.
                ems = (remaining <= 0 and not sceneRunning)
                    and { enabled = true, key = 'E', tone = 'bad',
                        label = 'Desistir', state = 'Custa 1 vida',
                        sub = 'Segure para renascer no hospital.' }
                    or (GetGameTimer() < medicNextAt
                        and { enabled = false, key = 'G', tone = 'ok',
                            label = 'Pedir socorro médico', state = 'Chamado enviado',
                            sub = ('Novo chamado em %s.'):format(
                                clock((medicNextAt - GetGameTimer()) / 1000)) }
                        or { enabled = true, key = 'G', tone = '',
                            label = 'Pedir socorro médico', state = '',
                            sub = 'Avisa os médicos de plantão.' }),
                npc = npc,
                lives = ('%s vidas restantes.'):format(status.lives),
                livesDanger = status.lives <= 3,
            }

            -- Throttled: the key check below needs every frame, the panel does not. Pushing a NUI
            -- message per frame is work nobody sees.
            if GetGameTimer() - lastSend > 200 then
                send(payload)
                lastSend = GetGameTimer()
            end

            if remaining > 0 and GetGameTimer() >= medicNextAt
                and IsDisabledControlJustPressed(0, MEDIC_CONTROL) then

                medicNextAt = GetGameTimer() + config.medicCooldownSeconds * 1000
                TriggerServerEvent('hospital:server:ambulanceAlert', 'Civil caído')

                lib.notify({
                    title = 'Socorro',
                    description = 'Os médicos de plantão foram avisados da sua posição.',
                    type = 'success',
                })
            end

            if remaining <= 0 and IsDisabledControlJustPressed(0, TRANSPLANT_CONTROL) then
                local ok, answer = lib.callback.await('srv_rescue:server:transplant', false)

                if ok then
                    TriggerEvent('srv_rescue:client:surgery', answer)
                else
                    lib.notify({ title = 'Transplante', description = answer, type = 'error' })
                end

                status = nil
            end

            if npc.enabled and IsDisabledControlJustPressed(0, CALL_CONTROL) then
                local ok, message = lib.callback.await('srv_rescue:server:request', false)

                lib.notify({ title = 'Ambulância', description = message, type = ok and 'success' or 'error' })
                status = nil -- force a refresh so the panel reflects the new state at once
            end
        end

        Wait(0)
        ::continue::
    end
end)