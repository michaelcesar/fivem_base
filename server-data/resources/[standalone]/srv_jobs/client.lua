-- Servidor: shared engine for every city-hall job that only had a passive paycheck before.
-- Nobody holds one of these full-time - anyone can walk up to a job's depot and start a
-- shift regardless of their actual qbx_core job. A shift loops forever, one generated stop
-- at a time, until the player drives the work vehicle back to the job's return point
-- (like a garage - possibly the same spot as the depot, possibly not, see config.lua) and
-- parks it there.

-- Servidor: the type below is deliberately not `?` even though the value starts (and often
-- returns to) `nil` - every function here checks `activeJob` once at its own entry, then reads
-- it freely through nested closures the type checker can't trace back to that check. Marking it
-- optional turned 2 warnings (at the two `activeJob = nil` reassignments) into 32, almost all in
-- code that is already guarded, just not in a way the checker can see across closures.
local activeJob = nil ---@type {name: string, config: table, vehicle: number?, vehicleBlip: number?, vehicleWatch: number?, currentStop: vector3?, count: number, zone: table?, textShown: boolean?, watchdog: number?, stopBlip: number?, stopIndex: number?, haul: number?, haulBlip: number?, haulNonce: number?, delivering: boolean?, tookVehicle: boolean?, vehicleSettled: boolean?}

-- Servidor: FiveM control ID for the "E" key (INPUT_CONTEXT) - every [E]-to-interact prompt in
-- this file checks the same control, so it exists once rather than as the literal `38` repeated
-- at each call site.
local INTERACT_CONTROL = 38

-- Servidor: reverted back to the original marker (type 29, tried as a match for ox_inventory's
-- shop marker, actually rendered as a dollar-sign icon in-game - wrong guess, corrected per
-- the user's own in-game report rather than guessed again).
local function drawGroundMarker(coords, xyScale, zScale)
    DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, xyScale, xyScale, zScale,
        20, 246, 12, 200, false, false, 0, false, nil, nil, false)
end

local function notify(description, notifyType)
    lib.notify({ title = 'Trabalho', description = description, type = notifyType or 'inform' })
end

--- Advances `job.count` and, if anything was actually paid, notifies with the job's own step
--- label ("Reboque 3 concluído. Você recebeu $375.") - identical between `watchCurrentStop`'s and
--- `watchDelivery`'s success handlers, so it exists once. `stepFeminine == false` is the one job
--- (`tow`, "Reboque") whose step label takes the masculine past participle; every other job's is
--- feminine by default.
local function reportStopPaid(job, result)
    job.count += 1

    if result.paid > 0 then
        local doneWord = job.config.stepFeminine == false and 'concluído' or 'concluída'
        notify(('%s %s %s. Você recebeu $%s.'):format(job.config.stepLabel, job.count, doneWord, result.paid), 'success')
    end
end

-- Servidor: a wrong model *name* (typo, renamed prop) fails loudly here instead of silently -
-- CreateVehicle would just never spawn anything and the job would look broken with no clue why.
-- This does not confirm the model is a *good* choice (CLAUDE.md rule 4) - only that it is real.
-- Each one still needs a live look with `/testprop` before shipping. Lives here, not server.lua,
-- because `IsModelInCdimage` is a client-only native - it crashed the whole resource server-side
-- (`attempt to call a nil value`) until caught live and moved here.
CreateThread(function()
    for jobName, jobConfig in pairs(Config.jobs) do
        if jobConfig.brokenVehicles then
            for _, model in ipairs(jobConfig.brokenVehicles) do
                if not IsModelInCdimage(model) then
                    print(('^1[srv_jobs] %s: brokenVehicles has an invalid model hash (%s) - never spawns.^7')
                        :format(jobName, model))
                end
            end
        end
    end
end)

---@param origin vector3
---@param minDist number
---@param maxDist number
---@return vector3?
local function randomRoadPoint(origin, minDist, maxDist)
    for _ = 1, 15 do
        local angle = math.random() * 2 * math.pi
        local dist = minDist + math.random() * (maxDist - minDist)
        local x = origin.x + math.cos(angle) * dist
        local y = origin.y + math.sin(angle) * dist

        local found, nodePos = GetClosestVehicleNode(x, y, origin.z, 1, 3.0, 0)

        if found then return nodePos end
    end

    return nil
end

local function deleteVehicle(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end

    -- Servidor: unlike srv_lib's DeleteLocalEntity, this vehicle is networked
    -- (isNetwork = true at CreateVehicle) so the mission-entity claim must say so too,
    -- or DeleteEntity silently does nothing - the same trap, the opposite value.
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteEntity(vehicle)
end

--- Removes the blip stored at `activeJob[field]` (`stopBlip`, `vehicleBlip` or `haulBlip`) if it
--- still exists - the one blip-teardown shape every blip this resource creates shares.
local function clearBlip(field)
    if not activeJob then return end

    -- Servidor: cast, not a real type - `field` is a dynamic key, so the type checker can only
    -- see the union of every field `activeJob` has, not specifically the number this one is.
    local blip = activeJob[field] --[[@as integer?]]
    if blip and DoesBlipExist(blip) then RemoveBlip(blip) end
end

--- Local-only teardown shared by every way a shift can end (properly, abandoned, or given up
--- for a fine) - clears the stop zone/blip, the vehicle watchdogs, the text UI, and the local
--- vehicle entity. Does not touch the server; callers decide what (if anything) to tell it.
local function cleanupActiveJob()
    if not activeJob then return end

    if activeJob.zone then activeJob.zone:remove() end
    if activeJob.watchdog then ClearInterval(activeJob.watchdog) end
    if activeJob.vehicleWatch then ClearInterval(activeJob.vehicleWatch) end

    lib.hideTextUI()
    clearBlip('stopBlip')
    clearBlip('vehicleBlip')
    clearBlip('haulBlip')
    deleteVehicle(activeJob.vehicle)
    -- Servidor: a tow-style shift (ADR-052) can end mid-haul - the server already despawns the
    -- hauled vehicle by its own network ID (see `endRoute`/`endShift`), this only needs to drop
    -- the local handle so nothing here keeps trying to reference an entity that's about to go.
    deleteVehicle(activeJob.haul)
end

--- Ends the shift without paying the completion bonus - the player abandoned it instead of
--- driving back to the return point or giving up properly at the depot. Used by the
--- away-from-vehicle watchdog, running out of road to generate a stop on, and a resource
--- restart - leaves a fine on the player's citizenid (see server.lua's `endRoute`).
local function abandonJob()
    if not activeJob then return end
    cleanupActiveJob()
    TriggerServerEvent('srv_jobs:server:cancelJob')
    activeJob = nil
end

--- Picks the next stop from a job's fixed, user-mapped point list (see config.lua's `stops`)
--- instead of generating one. Two orderings:
--- - Default: walked in the exact order the points were mapped in (not shuffled - they were read
---   out driving the route in sequence, so consecutive points are already close together;
---   shuffling would send the player jumping across the map instead of following the real
---   route), wrapping back to the first point once the last one is done.
--- - `jobConfig.randomStops = true`: a real `math.random` pick each time, by request for
---   `methdealing` (reusing `dealing`'s own 30 mapped points, but without the "walk them in
---   mapped order" reasoning that shape was chosen for in the first place - meth's own delivery
---   spread is meant to look scattered, not routed).
local function nextFixedStop(job)
    local stops = job.config.stops

    if job.config.randomStops then
        job.stopIndex = math.random(#stops)
        return stops[job.stopIndex]
    end

    job.stopIndex = (job.stopIndex or 0) % #stops + 1

    return stops[job.stopIndex]
end

local watchCurrentStop
local watchPickup
local watchDelivery

--- Spawns this pickup's broken-down vehicle, undriveable and with a dead engine so it visibly
--- needs a hook rather than just being parked there, and reports its network ID - the only
--- vehicle the server will later accept a delivery against (see server.lua's `setHaul`, which
--- also checks it's genuinely near this same pickup, the same anti-cheat shape as the job's own
--- vehicle in `setVehicle`). One at a time: called only once per pickup, from `watchPickup`.
---
--- Servidor: `nonce`, from `setPickup`, is embedded in the entity's own state bag rather than
--- just matched by model/position (ADR-055) - state alone let a player's own matching, broken-
--- down vehicle pass as the haul (ADR-054's finding). A number the server generated for this
--- specific pickup and the client never saw beforehand proves this is the vehicle the server
--- actually authorised, not merely one that looks the part.
local function spawnHaulVehicle(jobConfig, stopCoords, nonce)
    local model = jobConfig.brokenVehicles[math.random(#jobConfig.brokenVehicles)]
    local heading = math.random(0, 359) + 0.0

    lib.requestModel(model, 10000)
    local haul = CreateVehicle(model, stopCoords.x, stopCoords.y, stopCoords.z, heading, true, false)
    SetModelAsNoLongerNeeded(model)
    SetVehicleOnGroundProperly(haul)
    SetVehicleEngineHealth(haul, 0.0)
    SetVehicleUndriveable(haul, true)
    Entity(haul).state:set('haulTag', nonce, true)
    TriggerServerEvent('srv_jobs:server:setHaul', NetworkGetNetworkIdFromEntity(haul))

    return haul
end

--- Picks the next stop - from the job's fixed point list if it has one, generated near the
--- last one otherwise - tells the server (the only coordinate it will later accept a
--- completion against), and starts watching it.
---
--- Servidor: a tow-style job (ADR-052, `jobConfig.dropoffPoint` set) branches here into its own
--- pickup/delivery pair instead of the generic single-point loop below - a stop for tow isn't
--- "arrive somewhere", it's "hook a specific vehicle, then actually deliver it". Uses `setPickup`
--- (a callback, ADR-055), not `setStop` - it needs the per-pickup secret back, not just to report
--- the point.
local function advanceToNextStop(fromCoords)
    if activeJob.config.dropoffPoint then
        local point = nextFixedStop(activeJob)
        local result = lib.callback.await('srv_jobs:server:setPickup', false, point)

        if not result or not result.ok then
            notify('Não foi possível confirmar a próxima coleta. Serviço cancelado.', 'error')
            abandonJob()
            return
        end

        activeJob.currentStop = point
        activeJob.haulNonce = result.nonce
        watchPickup()
        return
    end

    local point

    if activeJob.config.stops then
        point = nextFixedStop(activeJob)
    else
        point = randomRoadPoint(fromCoords, Config.minStopDistance, Config.maxStopDistance)

        if not point then
            notify('Não achei rota de estrada por perto. Tentando de novo perto de você...', 'error')
            point = randomRoadPoint(GetEntityCoords(cache.ped), Config.minStopDistance, Config.maxStopDistance)
        end

        if not point then
            notify('Sem rotas de estrada por perto pra continuar. Serviço cancelado.', 'error')
            abandonJob()
            return
        end
    end

    activeJob.currentStop = point
    TriggerServerEvent('srv_jobs:server:setStop', point)
    watchCurrentStop()
end

--- Shared shape behind `watchCurrentStop`/`watchPickup`/`watchDelivery`: draws the route blip and
--- ground marker at `coords`, shows `opts.prompt` once `opts.canInteract()` is true, and on [E]
--- tears down the zone/blip/text UI before calling `opts.onInteract()` - every caller's own
--- action starts from that same clean state. `opts.onTick`, if given, runs every frame the player
--- is inside the outer marker, before the interact check - only `watchPickup` needs it, to spawn
--- the haul vehicle the moment it's visible rather than only once the player is close enough to
--- interact.
local function watchStop(coords, opts)
    local job = activeJob

    SetNewWaypoint(coords.x, coords.y)

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    job[opts.blipField] = blip
    SetBlipSprite(blip, opts.sprite or 1)
    SetBlipColour(blip, opts.colour or 5)
    SetBlipRoute(blip, true)

    job.zone = lib.zones.sphere({
        coords = coords,
        radius = Config.markerRadius,
        debug = false,
        onExit = function()
            if job.textShown then
                lib.hideTextUI()
                job.textShown = false
            end
        end,
        inside = function()
            drawGroundMarker(coords, 3.0, 1.0)

            if opts.onTick then opts.onTick() end

            if opts.canInteract() then
                if not job.textShown then
                    job.textShown = true
                    lib.showTextUI(opts.prompt)
                end

                if IsControlJustPressed(0, INTERACT_CONTROL) then
                    job.textShown = false
                    lib.hideTextUI()
                    job.zone:remove()
                    job.zone = nil
                    clearBlip(opts.blipField)

                    opts.onInteract()
                end
            elseif job.textShown then
                job.textShown = false
                lib.hideTextUI()
            end
        end,
    })
end

watchCurrentStop = function()
    local job = activeJob
    local coords = job.currentStop

    watchStop(coords, {
        blipField = 'stopBlip',
        sprite = 1,
        colour = 5,
        prompt = ('[E] Concluir %s.'):format(job.config.stepLabel:lower()),
        canInteract = function()
            return #(GetEntityCoords(cache.ped) - coords) < Config.promptRadius
        end,
        onInteract = function()
            lib.callback('srv_jobs:server:completeStop', false, function(result)
                if not activeJob then return end

                if not result or not result.ok then
                    local reasons = {
                        novehiclenearby = 'O veículo de trabalho precisa estar estacionado aqui perto pra confirmar essa parada.',
                        noitem = 'Você ficou sem estoque pra vender. Compre mais e volte.',
                    }
                    notify((result and reasons[result.reason]) or 'Não foi possível confirmar essa parada.', 'error')

                    -- Servidor: an item-gated job has nothing left to try again for once the item
                    -- runs out mid-shift - re-watching the same stop would just fail the same way
                    -- forever. Ends the shift locally instead of looping `watchCurrentStop`.
                    if result and result.reason == 'noitem' then
                        abandonJob()
                        return
                    end

                    watchCurrentStop()
                    return
                end

                reportStopPaid(job, result)
                advanceToNextStop(coords)
            end)
        end,
    })
end

--- Tow-style pickup (ADR-052): spawns this stop's broken vehicle as soon as the player is close
--- enough to see it, then waits for them to actually hook it to their own work vehicle - the
--- native GTA tow-truck attach, not a proximity check standing in for one. Requires the tow
--- truck itself to be nearby, not just the ped, since the hook belongs to the vehicle.
watchPickup = function()
    local job = activeJob
    local coords = job.currentStop

    watchStop(coords, {
        blipField = 'stopBlip',
        sprite = 1,
        colour = 5,
        prompt = '[E] Prender veículo no guincho.',
        onTick = function()
            if not job.haul then
                job.haul = spawnHaulVehicle(job.config, coords, job.haulNonce)
            end
        end,
        canInteract = function()
            local pedCoords = GetEntityCoords(cache.ped)
            local towNearby = job.vehicle and DoesEntityExist(job.vehicle)
                and #(pedCoords - GetEntityCoords(job.vehicle)) < Config.markerRadius

            return towNearby and #(pedCoords - coords) < Config.promptRadius
        end,
        onInteract = function()
            AttachVehicleToTowTruck(job.vehicle, job.haul, true, 0.0, 0.0, 0.0)
            SetVehicleTowTruckArmPosition(job.vehicle, 1.0)
            notify('Veículo preso. Leve até o ponto de entrega marcado no GPS.')
            watchDelivery()
        end,
    })
end

--- Tow-style delivery (ADR-052): the drop-off is one fixed point shared by every pickup, unlike
--- the pickups themselves which rotate through `stops`. Confirming here calls `completeStop` the
--- same as every other job's stop - the server is the one that actually checks the hauled
--- vehicle got here, not just the player (see server.lua's `dropoffPoint` branch).
watchDelivery = function()
    local job = activeJob
    local coords = job.config.dropoffPoint.xyz

    watchStop(coords, {
        blipField = 'haulBlip',
        sprite = job.config.icon or 1,
        -- Servidor: colour 3 (blue), same convention as the return point's blip (ADR-030) - this
        -- pin is the cargo's place, not the job's, so it reads as a different kind of stop than
        -- the pickup's green one.
        colour = 3,
        prompt = '[E] Entregar veículo.',
        canInteract = function()
            local haulHere = job.haul and DoesEntityExist(job.haul)
                and #(GetEntityCoords(job.haul) - coords) < Config.promptRadius

            return haulHere and #(GetEntityCoords(cache.ped) - coords) < Config.promptRadius
        end,
        onInteract = function()
            if job.vehicle and DoesEntityExist(job.vehicle) then
                DetachVehicleFromTowTruck(job.vehicle, job.haul)
            end

            lib.callback('srv_jobs:server:completeStop', false, function(result)
                if not activeJob then return end

                if not result or not result.ok then
                    local reasons = {
                        nohaul = 'Você precisa prender um veículo antes de entregar.',
                        haullost = 'O veículo preso sumiu. Pegue outro na próxima parada.',
                        haulfar = 'O veículo preso precisa estar aqui pra confirmar a entrega.',
                        notruck = 'O guincho também precisa estar aqui pra confirmar a entrega.',
                    }
                    notify((result and reasons[result.reason]) or 'Não foi possível confirmar a entrega.', 'error')
                    watchDelivery()
                    return
                end

                job.haul = nil
                reportStopPaid(job, result)
                advanceToNextStop(coords)
            end)
        end,
    })
end

--- Local bookkeeping shared by both ways of settling the job's own vehicle at the return point
--- (storing it free, paying it off) - the vehicle is gone either way, so its watchdog and blip go
--- with it, but the shift itself continues, unlike every other path that destroys the vehicle.
local function settleVehicleLocally()
    clearBlip('vehicleBlip')
    if not activeJob then return end

    if activeJob.watchdog then ClearInterval(activeJob.watchdog) end
    activeJob.watchdog = nil
    activeJob.vehicle = nil
    activeJob.vehicleSettled = true
end

--- Waits for the player to actually get into the freshly spawned work vehicle before the
--- delivery loop starts - the vehicle can spawn somewhere other than the depot the player
--- is standing at (see config.lua's `vehicleSpawn`), so there is a real gap to walk.
local function watchForVehicleEntry(vehicleSpawnCoords)
    activeJob.vehicleWatch = SetInterval(function()
        if not activeJob or not activeJob.vehicle then return end

        if not DoesEntityExist(activeJob.vehicle) then
            notify('O veículo de trabalho sumiu. Serviço cancelado.', 'error')
            abandonJob()
            return
        end

        if GetVehiclePedIsIn(cache.ped, false) == activeJob.vehicle then
            ClearInterval(activeJob.vehicleWatch)
            activeJob.vehicleWatch = nil
            clearBlip('vehicleBlip')
            advanceToNextStop(vehicleSpawnCoords)
        end
    end, 1000)
end

--- Spawns the shift's work vehicle into a server-reserved slot, marks it as this shift's, and
--- arms the abandonment watchdog. Shared by starting a shift and withdrawing the vehicle again
--- at the NPC afterwards (ADR-051), so both paths land in exactly the same state.
local function spawnJobVehicle(jobConfig, slot, atCoords)
    local spawn = jobConfig.vehicleSpawn or jobConfig.depot or vec4(atCoords.x, atCoords.y, atCoords.z, GetEntityHeading(cache.ped))
    local offset = Config.vehicleSlotOffsets[slot] or vector3(0.0, 0.0, 0.0)
    local spawnCoords = spawn.xyz + offset

    lib.requestModel(jobConfig.vehicle, 10000)
    -- Set once and never cleared: the return point uses it to know this shift owes a vehicle
    -- at all, even after the vehicle itself is gone (stored, paid off, lost). See ADR-050.
    activeJob.tookVehicle = true
    activeJob.vehicleSettled = false
    activeJob.vehicle = CreateVehicle(jobConfig.vehicle, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawn.w, true, false)
    SetModelAsNoLongerNeeded(jobConfig.vehicle)
    SetVehicleOnGroundProperly(activeJob.vehicle)
    TriggerServerEvent('srv_jobs:server:setVehicle', NetworkGetNetworkIdFromEntity(activeJob.vehicle))

    activeJob.vehicleBlip = AddBlipForCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
    SetBlipSprite(activeJob.vehicleBlip, jobConfig.icon or 1)
    SetBlipColour(activeJob.vehicleBlip, 5)
    SetBlipRoute(activeJob.vehicleBlip, true)
    lib.showTextUI('Vá até o veículo marcado no GPS.')

    activeJob.watchdog = SetInterval(function()
        if not activeJob then return end

        local pedCoords = GetEntityCoords(cache.ped)

        -- Servidor: standing at this job's own depot or return point never counts as
        -- abandoning the vehicle. Since ADR-050 split the two - vehicle stored at the return
        -- point, shift ended at the depot NPC - a player legitimately walks between them
        -- with the vehicle left behind, and on `garbage` those two points are 47m apart
        -- against a 60m `abandonDistance`. Without this the watchdog would cancel the shift
        -- (and fine them) precisely while they were on their way to settle it properly.
        if #(pedCoords - jobConfig.depot.xyz) <= Config.abandonDistance then return end
        if jobConfig.returnPoint and #(pedCoords - jobConfig.returnPoint.xyz) <= Config.abandonDistance then
            return
        end

        local vehicleCoords = DoesEntityExist(activeJob.vehicle) and GetEntityCoords(activeJob.vehicle) or nil

        if not vehicleCoords or #(pedCoords - vehicleCoords) > Config.abandonDistance then
            notify('Serviço cancelado - você se afastou demais do veículo.', 'error')
            abandonJob()
        end
    end, 5000)

    watchForVehicleEntry(spawnCoords)
end

--- Asks which of a job's `itemOptions` the player is selling this shift - only for item-gated
--- jobs that have more than one real choice (`dealing`, ADR-070). A job with exactly one option
--- skips the dialog and picks it automatically - nothing to choose, so nothing to ask. No job
--- currently has exactly one; the branch is kept because auto-picking is the right behaviour if
--- one ever does, but note it makes a misconfigured job fail *silently* rather than loudly -
--- that is how ADR-074's duplicate-depot bug hid (the wrong job answered the prompt and never
--- asked anything). Returns `item, proceed`: `proceed` is false only when the player cancels the
--- dialog, so `startJob` can tell "chose nothing" apart from "job has no choice to make at all"
--- (nil item, proceed still true).
---@param jobConfig table
---@return string?, boolean
local function askItemChoice(jobConfig)
    if not jobConfig.itemOptions then return nil, true end
    if #jobConfig.itemOptions == 1 then return jobConfig.itemOptions[1].item, true end

    local options = {}
    for i = 1, #jobConfig.itemOptions do
        local opt = jobConfig.itemOptions[i]
        options[i] = { value = opt.item, label = opt.label }
    end

    local input = lib.inputDialog('Selecionar mercadoria', {
        -- Servidor: `placeholder` so the closed select is not a blank box. `ox_lib`'s select shows
        -- the placeholder until a value is picked; without one it renders the icon and nothing
        -- else, which reads as a field that failed to load rather than one waiting on you.
        { type = 'select', label = 'Droga', description = 'O que você vai vender neste turno?',
            icon = 'sack-dollar', options = options, required = true,
            placeholder = 'Selecione o tipo' },
    })
    if not input then return nil, false end

    return input[1], true
end

--- Asks whether the player wants their own work vehicle for this shift - only for jobs that
--- have one. Declining skips the slot reservation and spawn entirely; stops still require some
--- job vehicle nearby to confirm (ADR-023), so this is meant for riding along in a colleague's.
local function askWantsVehicle(jobConfig)
    if not jobConfig.vehicle then return true end

    local confirmed = lib.alertDialog({
        header = 'Retirar veículo de trabalho?',
        content = 'Você pode retirar seu próprio veículo, ou fazer o turno de carona no veículo de um colega já em serviço.',
        centered = true,
        cancel = true,
        labels = { confirm = 'Retirar veículo', cancel = 'Vou de carona' },
    })

    return confirmed == 'confirm'
end

local function startJob(jobName, jobConfig, atCoords)
    if activeJob then
        notify('Você já está em serviço.', 'error')
        return
    end

    local itemChoice, proceed = askItemChoice(jobConfig)
    if not proceed then return end

    local wantsVehicle = askWantsVehicle(jobConfig)
    local result = lib.callback.await('srv_jobs:server:startJob', false, jobName, wantsVehicle, itemChoice)

    if not result or not result.ok then
        if result and result.reason == 'debt' then
            local confirmed = lib.alertDialog({
                header = 'Veículo de trabalho pendente',
                content = ('Você não devolveu um veículo de trabalho da última vez. Pagar a multa de $%s agora pra liberar?'):format(result.fine),
                centered = true,
                cancel = true,
            })

            if confirmed == 'confirm' then
                local paidResult = lib.callback.await('srv_jobs:server:payDebt', false)

                if paidResult and paidResult.ok then
                    notify(('Multa de $%s paga. Pendência liberada.'):format(paidResult.paid), 'success')
                    startJob(jobName, jobConfig, atCoords)
                else
                    notify('Dinheiro insuficiente pra pagar a multa.', 'error')
                end
            end

            return
        end

        if result and result.reason == 'full' then
            notify('Todas as vagas de veículo desse trabalho estão em uso. Tente de novo em instantes.', 'error')
            return
        end

        -- Servidor: the interaction zone already keeps the player at the depot when this fires
        -- in normal play, so this reason isn't expected to show up here - it's the server-side
        -- half of the same distance check, in case this callback is ever reached another way.
        if result and result.reason == 'fardepot' then
            notify('Você precisa estar no posto pra iniciar o turno.', 'error')
            return
        end

        if result and result.reason == 'noitem' then
            notify('Você não tem mercadoria pra vender. Consiga alguma antes de iniciar o turno.', 'error')
            return
        end

        notify('Não foi possível iniciar o serviço.', 'error')
        return
    end

    activeJob = { name = jobName, config = jobConfig, count = 0 }

    if jobConfig.vehicle and result.slot then
        spawnJobVehicle(jobConfig, result.slot, atCoords)
        notify(jobConfig.startMessage or 'Serviço iniciado.')
    else
        if jobConfig.vehicle then
            notify('Turno iniciado sem veículo próprio - fique perto do veículo de um colega em serviço pra confirmar as paradas.', 'warning')
        end

        notify(jobConfig.startMessage or 'Serviço iniciado.')
        advanceToNextStop(atCoords)
    end
end

local storeVehicleFailureMessages = {
    novehicle = 'O veículo de trabalho não foi encontrado - já deve ter sido perdido.',
    farvehicle = 'Estacione o veículo aqui pra guardá-lo.',
    fardepot = 'Você precisa estar no local de guardar o veículo.',
    alreadysettled = 'Esse veículo já foi resolvido.',
    novehicleroute = 'Esse turno não retirou veículo nenhum.',
}

-- Servidor: the return point stores the vehicle and nothing else - it never ends a shift
-- (ADR-050). Free, and the only place a job vehicle can be stored at all.
local function storeVehicle(jobName)
    lib.callback('srv_jobs:server:storeVehicle', false, function(result)
        if not result or not result.ok then
            local reason = result and storeVehicleFailureMessages[result.reason]
            notify(reason or 'Não foi possível guardar o veículo aqui.', 'error')
            return
        end

        settleVehicleLocally()
        notify('Veículo guardado. Encerre o turno com o responsável no posto.', 'success')
    end, jobName)
end

-- The paid way out of the same obligation, also only at the return point - for a vehicle that is
-- lost, stuck, or simply not worth going back for.
local function payVehicleFineHere(jobName)
    local confirmed = lib.alertDialog({
        header = 'Pagar multa do veículo?',
        content = ('O veículo não está guardado aqui. Pagar $%s resolve a pendência dele agora e ele some de onde estiver. Guardar o veículo aqui é gratuito.')
            :format(Config.pendingVehicleFine),
        centered = true,
        cancel = true,
        labels = { confirm = 'Pagar multa', cancel = 'Vou buscar o veículo' },
    })

    if confirmed ~= 'confirm' then return end

    lib.callback('srv_jobs:server:payVehicleFine', false, function(result)
        if not result or not result.ok then
            if result and result.reason == 'cantafford' then
                notify(('Dinheiro insuficiente pra pagar a multa de $%s.'):format(result.fine), 'error')
                return
            end

            local reason = result and storeVehicleFailureMessages[result.reason]
            notify(reason or 'Não foi possível pagar a multa aqui.', 'error')
            return
        end

        settleVehicleLocally()
        notify(('Multa de $%s paga. Pendência do veículo resolvida.'):format(result.fine), 'inform')
    end, jobName)
end

local withdrawFailureMessages = {
    fardepot = 'Você precisa estar no posto pra retirar o veículo.',
    stillhasvehicle = 'Você já está com um veículo de trabalho.',
    noslot = 'Não há vaga livre no posto agora. Tente de novo em instantes.',
    novehiclejob = 'Esse trabalho não usa veículo.',
}

-- Servidor: takes the work vehicle back out mid-shift, at the depot NPC (ADR-051). Free, and it
-- undoes nothing that was paid for - the shift simply owes a vehicle again, so the fine at the
-- end comes back with it. Mainly there for storing the vehicle by accident with 15 stops to go.
local function withdrawVehicle(jobName)
    lib.callback('srv_jobs:server:withdrawVehicle', false, function(result)
        if not result or not result.ok then
            local reason = result and withdrawFailureMessages[result.reason]
            notify(reason or 'Não foi possível retirar o veículo.', 'error')
            return
        end

        if not activeJob then return end

        spawnJobVehicle(activeJob.config, result.slot, GetEntityCoords(cache.ped))
        notify('Veículo liberado. Guarde-o de novo antes de encerrar pra não pagar multa.', 'success')
    end, jobName)
end

-- Servidor: a shift is ended at the depot NPC, where it was started (ADR-050) - the return point
-- only ever handles the vehicle. Ending always succeeds once the player is at the depot; what
-- can happen is a fine, never a hard block, so each one is confirmed explicitly before being
-- charged, the same two-step pattern used throughout this file:
--   - too few stops done: confirm paying `Config.earlyEndFine`, no bonus either way;
--   - vehicle never settled at the return point: confirm paying `Config.pendingVehicleFine`.
-- Both can apply to the same shift and stack; neither pays the bonus.
local function finishShift(jobName, payEarlyFine, payVehicleFine)
    lib.callback('srv_jobs:server:endShift', false, function(result)
        if not result or not result.ok then
            if result and result.reason == 'notenough' then
                local plural = (Config.jobs[jobName] or {}).stepLabelPlural or 'paradas'
                local confirmed = lib.alertDialog({
                    header = 'Turno incompleto',
                    content = ('Você fez %s/%s %s. Terminar agora custa uma multa de $%s e você não recebe o bônus. Quer pagar e encerrar mesmo assim?')
                        :format(result.have, result.need, plural, Config.earlyEndFine),
                    centered = true,
                    cancel = true,
                    labels = { confirm = 'Pagar e encerrar', cancel = 'Continuar turno' },
                })

                if confirmed == 'confirm' then finishShift(jobName, true, payVehicleFine) end

                return
            end

            if result and result.reason == 'vehiclenotsettled' then
                local confirmed = lib.alertDialog({
                    header = 'Veículo não guardado',
                    content = ('Você não guardou o veículo de trabalho. Encerrar assim custa uma multa de $%s. Guardá-lo no local marcado no mapa é gratuito.')
                        :format(result.fine),
                    centered = true,
                    cancel = true,
                    labels = { confirm = 'Pagar e encerrar', cancel = 'Vou guardar o veículo' },
                })

                if confirmed == 'confirm' then finishShift(jobName, payEarlyFine, true) end

                return
            end

            if result and result.reason == 'cantaffordearly' then
                notify(('Dinheiro insuficiente pra pagar a multa de $%s.'):format(result.fine), 'error')
                return
            end

            if result and result.reason == 'fardepot' then
                notify('Você precisa estar no posto pra encerrar o turno.', 'error')
                return
            end

            notify('Não foi possível encerrar o turno aqui.', 'error')
            return
        end

        cleanupActiveJob()
        activeJob = nil

        local fine = (result.earlyFine or 0) + (result.vehicleFine or 0)

        if fine > 0 then
            notify(('Turno encerrado pagando multa de $%s. Sem bônus.'):format(fine), 'inform')
        else
            notify(('Turno encerrado. Bônus de $%s recebido.'):format(result.paid), 'success')
        end
    end, jobName, payEarlyFine, payVehicleFine)
end

--- Generic two-tier marker+[E] zone (same convention as qbx_cityhall/qbx_garages/shops):
--- an outer sphere draws the ground marker, an inner sphere handles the prompt and the
--- action - but only while `getPrompt()` returns text. Returning nil hides both, so the
--- same helper covers "nothing to do here right now" without a separate code path.
local function setupInteractionZone(coords, getPrompt, onInteract)
    local innerZone

    lib.zones.sphere({
        coords = coords,
        radius = Config.markerRadius,
        debug = false,
        onEnter = function()
            innerZone = lib.zones.sphere({
                coords = coords,
                radius = Config.promptRadius,
                debug = false,
                onEnter = function()
                    local prompt = getPrompt()
                    if prompt then lib.showTextUI(prompt) end
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = function()
                    if not IsControlJustPressed(0, INTERACT_CONTROL) then return end
                    if not getPrompt() then return end

                    lib.hideTextUI()
                    onInteract()
                end,
            })
        end,
        onExit = function()
            if innerZone then
                innerZone:remove()
                innerZone = nil
            end
        end,
        inside = function()
            if getPrompt() then
                drawGroundMarker(coords, 2.0, 1.0)
            end
        end,
    })
end

local depotPeds = {}

--- The depot NPC is flavor, not an interaction target - the marker/prompt is what
--- actually starts the job, same as the ped's job is just to make it look like you're
--- talking to someone instead of a jobsite floating in a field.
local function spawnDepotPed(jobConfig)
    local coords = jobConfig.depot
    lib.requestModel(jobConfig.ped, 10000)

    local ped = CreatePed(0, jobConfig.ped, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
    SetModelAsNoLongerNeeded(jobConfig.ped)
    SetEntityHeading(ped, coords.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)

    depotPeds[#depotPeds + 1] = ped
end

--- Purely decorative armed peds standing around a depot - `dealing`'s only user so far (ADR-064).
--- Cleaned up the same way as the depot ped itself (`depotPeds`), since they're just as much
--- flavor and share the same lifetime.
local function spawnSecurityPeds(jobConfig)
    if not jobConfig.securityPeds then return end

    for i = 1, #jobConfig.securityPeds do
        local guard = jobConfig.securityPeds[i]
        local coords = guard.coords

        lib.requestModel(guard.ped, 10000)
        local ped = CreatePed(0, guard.ped, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
        SetModelAsNoLongerNeeded(guard.ped)
        SetEntityHeading(ped, coords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        if guard.weapon then
            lib.requestWeaponAsset(guard.weapon, 10000)
            GiveWeaponToPed(ped, guard.weapon, 0, false, true)
        end

        TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_GUARD_STAND', 0, true)

        depotPeds[#depotPeds + 1] = ped
    end
end

-- Servidor: `jobConfig.blipName` (`dealing` only, so far) overrides the label shown - "Desconhecido"
-- rather than the real job name, by request: every illegal point of interest across this project
-- shows the same unidentifying label (same treatment as srv_weedfarm's farm/dealer/seed-vendor
-- blips).
local function addJobBlip(coords, jobConfig, colour, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, jobConfig.icon or 1)
    SetBlipColour(blip, colour or 2)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(label or jobConfig.blipName or jobConfig.label)
    EndTextCommandSetBlipName(blip)
end

-- Only jobs with a real, user-supplied `depot` coordinate (see config.lua) get one of these; a
-- job without one is simply not playable (ADR-044).
--
-- Servidor: the depot NPC both starts and ends a shift (ADR-050) - it is the one place the job
-- itself is handled. The vehicle is handled somewhere else entirely, at the return point, and
-- ending here simply bills whatever is still outstanding.
local function setupDepot(jobName, jobConfig)
    local coords = jobConfig.depot.xyz
    local lowerLabel = jobConfig.label:lower()

    spawnDepotPed(jobConfig)
    spawnSecurityPeds(jobConfig)
    -- Servidor: `blipColour` is a per-job override - every existing job stays the default green
    -- (`addJobBlip`'s own `colour or 2`), `dealing` is the first to set it (grey, matching the
    -- dealer/seed-vendor NPC blips in srv_weedfarm - same "standard NPC" marker by request).
    addJobBlip(coords, jobConfig, jobConfig.blipColour)

    --- True when the NPC can hand this shift a work vehicle right now (ADR-051): the job has one,
    --- and this shift doesn't currently owe it - either it was stored/paid off, or the shift went
    --- ride-along and never took one. The server re-checks the same condition before spawning
    --- anything; this only decides whether the option is worth showing.
    local function canWithdrawVehicle()
        if not jobConfig.vehicle or not activeJob or activeJob.name ~= jobName then return false end

        return not activeJob.tookVehicle or activeJob.vehicleSettled == true
    end

    setupInteractionZone(coords,
        function()
            if activeJob then
                if activeJob.name ~= jobName then return nil end
                -- One [E] can't do two things, so as soon as there is a second action here the
                -- prompt opens a menu instead of ending the shift outright.
                if canWithdrawVehicle() then return '[E] Falar com o responsável.' end
                return '[E] Encerrar turno.'
            end
            return ('[E] Iniciar trabalho como %s.'):format(lowerLabel)
        end,
        function()
            if activeJob and activeJob.name == jobName then
                if not canWithdrawVehicle() then
                    finishShift(jobName)
                    return
                end

                lib.registerContext({
                    id = 'srv_jobs_depot',
                    title = jobConfig.label,
                    options = {
                        {
                            title = 'Retirar veículo',
                            description = 'Pega um veículo. Você fica responsável.',
                            icon = 'truck',
                            onSelect = function() withdrawVehicle(jobName) end,
                        },
                        {
                            title = 'Encerrar turno',
                            description = 'Finaliza o serviço e acerta as contas.',
                            icon = 'right-from-bracket',
                            onSelect = function() finishShift(jobName) end,
                        },
                    },
                })
                lib.showContext('srv_jobs_depot')
            elseif activeJob then
                notify('Você já está em outro serviço. Encerre ele no posto correspondente.', 'error')
            else
                startJob(jobName, jobConfig, coords)
            end
        end
    )
end

-- The vehicle's place, and only the vehicle's - it never ends a shift (ADR-050). Two actions
-- live here, and which one the prompt offers depends on whether the vehicle is actually parked
-- close enough to be stored: park it (free) or pay it off. Nothing else.
--
-- Servidor: this used to have no blip at all - the depot's was the only marked spot on the map,
-- so a player looking for the return point had nothing to walk towards. A distinct colour (3,
-- blue) and its own label keep this pin from being confused with the depot's green one for the
-- same job. See ADR-030.
local function setupReturnPoint(jobName, jobConfig)
    local coords = jobConfig.returnPoint.xyz

    addJobBlip(coords, jobConfig, 3, ('%s (Guardar veículo)'):format(jobConfig.label))

    --- True when this shift's own vehicle is parked close enough here for the server to accept
    --- it as stored. Purely to decide which prompt to show - the server re-checks the real
    --- distance itself before storing anything (see `storeVehicle`), this never decides that.
    local function vehicleIsHere()
        if not activeJob or not activeJob.vehicle then return false end
        if not DoesEntityExist(activeJob.vehicle) then return false end

        return #(GetEntityCoords(activeJob.vehicle) - coords) <= Config.returnVehicleDistance
    end

    setupInteractionZone(coords,
        function()
            if not activeJob or activeJob.name ~= jobName then return nil end
            -- A shift that never took a vehicle (ADR-024's ride-along), or has already settled
            -- one, has nothing to do here. `tookVehicle` is set at spawn and never cleared, so a
            -- vehicle that was lost or destroyed still offers the pay-off route rather than
            -- silently leaving the player with an unsettleable shift.
            if not activeJob.tookVehicle or activeJob.vehicleSettled then return nil end

            if vehicleIsHere() then return '[E] Guardar veículo.' end
            return ('[E] Pagar multa do veículo ($%s).'):format(Config.pendingVehicleFine)
        end,
        function()
            if not activeJob or activeJob.name ~= jobName then return end

            if vehicleIsHere() then
                storeVehicle(jobName)
            else
                payVehicleFineHere(jobName)
            end
        end
    )
end

CreateThread(function()
    for jobName, jobConfig in pairs(Config.jobs) do
        if jobConfig.depot then
            setupDepot(jobName, jobConfig)

            if jobConfig.returnPoint then
                setupReturnPoint(jobName, jobConfig)
            end
        end
    end
end)

-- Servidor: there is deliberately no command-based way to start any job, not even as a temporary
-- measure for the ones not yet mapped. Every job is picked up by walking to its physical depot
-- (`setupDepot`, above) and given up the same way - by request, after `/trabalho <name>` briefly
-- existed as a stand-in for jobs without a depot yet. A job with no `depot` in config.lua is
-- simply not playable until the user supplies its coordinates; nothing here starts it any other
-- way. See ADR-044.

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    if activeJob then abandonJob() end

    -- Servidor: depot peds are local (isNetwork = false at CreatePed), so srv_lib's
    -- DeleteLocalEntity is the correct cleanup - same trap as the job vehicle, opposite value.
    exports.srv_lib:DeleteLocalEntities(depotPeds)
end)
