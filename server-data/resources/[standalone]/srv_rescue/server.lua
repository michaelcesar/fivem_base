local config = require 'config'

--- Servidor: the paid NPC ambulance rescue.
---
--- The design decision that shapes everything here: the player is NOT coupled to the vehicle. The
--- ambulance driving to the hospital is theatre for whoever is watching; the passenger is faded out
--- and placed in the hospital on a timer of his own. That means a stuck or lost ambulance is a
--- cosmetic oddity rather than a player trapped in a car that will never arrive - and GTA's
--- long-range NPC pathfinding makes that outcome common enough to design around.
---
--- Paying creates a DEBT of service. Once the money leaves, the rescue is owed: a disconnection, a
--- crash or a restart does not consume it. That closes the worst failure this feature can have,
--- which is a player paying 10k and receiving nothing with no way to prove it.

local activeVehicles = {}

--- Servidor: oxmysql hands TINYINT(1) back as a BOOLEAN, not as 1. Comparing it with == 1 is
--- false for a column that is set, and the guard built on it silently never fires - which is how
--- a paid rescue was charged twice and how a blocked character would have kept logging in.
--- Accepting both shapes is the only comparison that survives the driver deciding either way.
---@param value any
---@return boolean
local function toBool(value)
    return value == true or value == 1
end
---@param citizenid string
---@return { debt: integer, pending: boolean }
local function getRecord(citizenid)
    local row = MySQL.single.await('SELECT debt, pending FROM srv_rescue WHERE citizenid = ?', { citizenid })

    if not row then
        MySQL.insert.await('INSERT IGNORE INTO srv_rescue (citizenid) VALUES (?)', { citizenid })
        return { debt = 0, pending = false }
    end

    return { debt = row.debt, pending = toBool(row.pending) }
end

exports('GetRecord', getRecord)

---@param citizenid string
local function clearPending(citizenid)
    MySQL.update.await('UPDATE srv_rescue SET pending = 0, pending_at = NULL WHERE citizenid = ?', { citizenid })
end

--- Settles an outstanding debt. Exposed so the hospital counter (or any other payment point) can
--- clear it without duplicating the arithmetic.
---@param source number
---@return boolean paid, string message
local function payDebt(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false, 'Personagem não encontrado.' end

    local record = getRecord(player.PlayerData.citizenid)

    if record.debt <= 0 then
        return false, 'Você não deve nada ao hospital.'
    end

    if not player.Functions.RemoveMoney('cash', record.debt, 'srv_rescue:debt') then
        return false, ('Você precisa de $%s em dinheiro para quitar a dívida.'):format(record.debt)
    end

    MySQL.update.await('UPDATE srv_rescue SET debt = 0 WHERE citizenid = ?', { player.PlayerData.citizenid })

    return true, ('Dívida de $%s quitada.'):format(record.debt)
end

exports('PayDebt', payDebt)

--- Removes an ambulance and its driver. Idempotent: a vehicle already gone is not an error, because
--- entities disappear for reasons this resource does not control.
---@param key string
local function despawn(key)
    local entry = activeVehicles[key]
    if not entry then return end

    for _, entity in ipairs({ entry.vehicle, entry.driver }) do
        if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
    end

    activeVehicles[key] = nil
end

--- Creates the ambulance and its driver SERVER-side, deliberately.
---
--- A client-created vehicle belongs to the client that made it, and this one is made by the player
--- who is about to be faded out and teleported across the map. When he goes, the entity goes or
--- migrates - and the bystanders this whole scene exists for would watch an ambulance evaporate.
--- Server-created entities outlive him.
---@param coords vector4
---@return number? vehicle, number? driver, string? key
local function spawnAmbulance(coords)
    local vehicle = CreateVehicle(config.ambulance.model, coords.x, coords.y, coords.z, coords.w, true, true)

    -- A server-created entity is not valid on the same tick it is returned. Asking for its network
    -- id immediately throws "Tried to access invalid entity", which is what this did until the
    -- error appeared in the log. Waiting for DoesEntityExist is the whole fix.
    local ready = false
    local deadline = GetGameTimer() + 3000

    while GetGameTimer() < deadline do
        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
            ready = true
            break
        end

        Wait(0)
    end

    if not ready then
        lib.print.error('the ambulance never became a valid entity')
        if vehicle and vehicle ~= 0 then DeleteEntity(vehicle) end
        return nil, nil, nil
    end

    local driver = CreatePed(0, config.ambulance.driver, coords.x, coords.y, coords.z, coords.w, true, true)

    lib.print.info(('[ped] created=%s type=%s model=%s'):format(tostring(driver), type(driver), config.ambulance.driver))

    -- Same wait for the ped, and the driver is optional: an ambulance that arrives driverless is a
    -- worse scene than one with a medic, but it is still a rescue. Nothing below depends on it.
    deadline = GetGameTimer() + 3000

    while driver and driver ~= 0 and not DoesEntityExist(driver) and GetGameTimer() < deadline do
        Wait(0)
    end

    if driver and driver ~= 0 and DoesEntityExist(driver) then
        SetPedIntoVehicle(driver, vehicle, -1)
    else
        lib.print.error('the paramedic never became a valid entity - the ambulance will have no driver')
        driver = nil
    end

    local key = ('%s_%s'):format(vehicle, GetGameTimer())

    activeVehicles[key] = {
        vehicle = vehicle,
        driver = driver,
        deadline = os.time() + config.ambulance.maxLifetime,
    }

    return vehicle, driver, key
end

--- Sends the ambulance. The requesting client drives the scene because tasking an entity requires
--- ownership, and it is the client nearest to it.
---@param source number
local function dispatch(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return end

    local coords = GetEntityCoords(ped)

    TriggerClientEvent('srv_rescue:client:findSpawn', source, {
        x = coords[1], y = coords[2], z = coords[3],
    })
end

--- The client found a road node; create the entities there and hand back the network ids.
--- The client found a road node. The server only confirms a rescue is actually owed and hands the
--- coordinate back - it creates nothing. Entity creation moved to the client after the
--- server-created version proved unable to keep a driving task on a networked ped.
RegisterNetEvent('srv_rescue:server:spawnAt', function(node)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    -- The client proposes a location and nothing else. It never says whether a rescue was paid
    -- for; that answer only ever comes from here.
    local record = getRecord(player.PlayerData.citizenid)
    if not record.pending then return end

    TriggerClientEvent('srv_rescue:client:runScene', src, {
        spawn = node,
        rideSeconds = config.ambulance.rideSeconds,
        driveSpeed = config.ambulance.driveSpeed,
    })
end)
--- Puts the player in the hospital, healed, and consumes the pending rescue. Called at the end of
--- the scene, and also on load for anyone who paid and then vanished before it could play.
---@param source number
local function deliver(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    -- The SOURCE, not the player table. qbx_medical annotates this export as ---@param
    -- player table|number, but its body passes the argument straight to TriggerClientEvent as the
    -- recipient, and that only accepts a numeric id. Handing it the table fails the native with
    -- 'Native invocation failed' and no hint as to why. The annotation is wrong.
    -- Charged HERE, on arrival. Cash first, then bank, and a debt only when neither covers it -
    -- the player is already in the hospital bed by this point, so refusing the service now
    -- would mean reviving him and then taking it back.
    local citizenid = player.PlayerData.citizenid

    local paid = player.Functions.RemoveMoney('cash', config.price, 'srv_rescue:call')
        or player.Functions.RemoveMoney('bank', config.price, 'srv_rescue:call')

    if not paid then
        MySQL.update.await('UPDATE srv_rescue SET debt = ? WHERE citizenid = ?', { config.price, citizenid })

        exports.qbx_core:Notify(source,
            ('Você ficou devendo $%s ao hospital.'):format(config.price), 'error', 7000)
    end

    exports.qbx_medical:Revive(source)

    -- Revive puts him back on his feet; Heal is what makes him arrive at 100% with no injuries
    -- or bleeding, which is what the rescue was paid for.
    exports.qbx_medical:Heal(source)

    -- Placed in one of the hospital's OWN beds rather than at a coordinate of ours.
    --
    -- qbx_ambulancejob already knows how to do this: it finds the bed prop, lays the ped on it,
    -- sets the camera and registers the interaction to get up again. Re-implementing that here
    -- would be a second bed system that drifts from the first the moment either changes.
    --
    -- The bed is picked at random from the eight surveyed ones so two people rescued minutes apart
    -- do not wake in the same place.
    local beds = 8
    TriggerClientEvent('qbx_ambulancejob:client:putPlayerInBed', source, 'pillbox', math.random(beds))
    clearPending(player.PlayerData.citizenid)
end

RegisterNetEvent('srv_rescue:server:sceneFinished', function(key)
    local src = source

    deliver(src)

    -- The vehicle keeps driving and is cleaned up by the sweep below, not here: the point of
    -- decoupling is that it outlives the passenger.
    if key and activeVehicles[key] then
        activeVehicles[key].orphanAt = os.time()
    end
end)

--- The request. Every rule that matters is checked here and nowhere else (CLAUDE.md rule 2).
lib.callback.register('srv_rescue:server:request', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false, 'Personagem não encontrado.' end

    local citizenid = player.PlayerData.citizenid

    -- Wanted players are refused AND reported, which is the pattern srv_wanted already uses for
    -- shops: the attempt tells the police where he is. A criminal down in a firefight choosing
    -- between bleeding out and revealing his position is better than a wall.
    if exports.srv_wanted:IsWanted(source) then
        -- The SAME event srv_wanted fires from its shop gate, handled by qbx_police. An event
        -- name invented here would have been a line that did nothing, which is what this was
        -- until it was checked.
        TriggerEvent('police:server:policeAlert', config.alert, nil, source)
        return false, 'Nenhuma ambulância aceita a chamada. A polícia foi avisada.'
    end

    local record = getRecord(citizenid)

    if record.pending then
        return false, 'A ambulância já está a caminho.'
    end

    if record.debt > 0 then
        return false, ('Você deve $%s ao hospital. Quite a dívida para chamar de novo.'):format(record.debt)
    end

    -- Checked at the CALL, taken on arrival.
    --
    -- Charging up front was tried and reversed, because it made a failed rescue - or simply
    -- bleeding out - cost money, and needed a refund path to undo. Charging only on arrival left
    -- the opposite hole: someone with nothing could call, be rescued, and walk out owing.
    --
    -- Verifying here closes that without reopening the other: the money stays in his pocket while
    -- the ambulance drives, and it has to be there for the ambulance to be sent at all. The debt
    -- below remains for the narrow case of him spending it during the trip.
    local money = player.PlayerData.money
    local available = (money.cash or 0) + (money.bank or 0)

    if available < config.price then
        return false, ('Você precisa de $%s entre dinheiro e banco para chamar.'):format(config.price)
    end


    MySQL.update.await(
        'UPDATE srv_rescue SET pending = 1, pending_at = CURRENT_TIMESTAMP WHERE citizenid = ?',
        { citizenid }
    )

    -- Tell the on-duty medics the call was answered. Without this a medic drives across the map
    -- to an empty street, and two wasted trips is all it takes for him to stop answering blips -
    -- which is the exact problem this whole feature exists to solve.
    local players = exports.qbx_core:GetQBPlayers()

    for _, medic in pairs(players) do
        if medic.PlayerData.job.type == 'ems' and medic.PlayerData.job.onduty then
            exports.qbx_core:Notify(medic.PlayerData.source, 'Um chamado foi atendido por ambulância particular.', 'inform')
        end
    end

    dispatch(source)

    -- Nothing is charged here. The money moves when the player actually wakes up in hospital,
    -- which removes the whole class of "paid and got nothing" outcomes: a rescue that fails, a
    -- disconnection, a server restart, or the bleed-out clock simply running out all cost the
    -- player nothing. Bleeding out with an ambulance still on its way is a real ending, and it
    -- should not also be an expensive one.
    return true, ('Ambulância a caminho. $%s ao chegar no hospital.'):format(config.price)
end)

--- A paid rescue survives the player leaving. On load, anyone still owed one gets it: the ambulance
--- is sent again if he is still down and within the window, and otherwise the outcome he paid for
--- is simply handed over.
AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    local record = getRecord(player.PlayerData.citizenid)
    if not record.pending then return end

    CreateThread(function()
        Wait(5000) -- let the client finish spawning before anything is done to it

        local src = player.PlayerData.source
        if not GetPlayerName(src) then return end

        local elapsed = MySQL.scalar.await(
            'SELECT TIMESTAMPDIFF(SECOND, pending_at, CURRENT_TIMESTAMP) FROM srv_rescue WHERE citizenid = ?',
            { player.PlayerData.citizenid }
        ) or 0

        if elapsed < config.dispatchWindow and lib.callback.await('srv_rescue:client:isDown', src) then
            exports.qbx_core:Notify(src, 'A ambulância que você chamou está chegando.', 'inform')
            return dispatch(src)
        end

        exports.qbx_core:Notify(src, 'Você foi resgatado enquanto estava fora.', 'inform')
        deliver(src)
    end)
end)

--- Sweep. Removes an ambulance once nobody can see it, or once it has simply been around too long.
CreateThread(function()
    while true do
        Wait(10000)

        local now = os.time()

        for key, entry in pairs(activeVehicles) do
            if not entry.vehicle or not DoesEntityExist(entry.vehicle) then
                activeVehicles[key] = nil
                goto continue
            end

            if now >= entry.deadline then
                despawn(key)
                goto continue
            end

            -- Only orphaned vehicles are eligible: one still carrying a passenger is mid-scene.
            if entry.orphanAt then
                local coords = GetEntityCoords(entry.vehicle)
                local watched = false

                for _, playerId in ipairs(GetPlayers()) do
                    local ped = GetPlayerPed(playerId)

                    if ped and ped ~= 0 and #(GetEntityCoords(ped) - coords) <= config.ambulance.keepAliveRadius then
                        watched = true
                        break
                    end
                end

                if not watched then despawn(key) end
            end

            ::continue::
        end
    end
end)

--- Nothing this resource created may outlive it (CLAUDE.md rule 3).
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for key in pairs(activeVehicles) do despawn(key) end
end)

--- Everything the downed panel needs, in one round trip. The client renders it and decides
--- nothing: a client that lies about its debt still gets refused by the request callback.
lib.callback.register('srv_rescue:server:status', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return nil end

    local citizenid = player.PlayerData.citizenid
    local record = getRecord(citizenid)
    local lives = exports.srv_lives:GetRecord(citizenid)

    return {
        price = config.price,
        debt = record.debt,
        pending = record.pending,
        wanted = exports.srv_wanted:IsWanted(source),
        lives = lives.lives,
    }
end)
--- Scene diagnostics from the client. Temporary: remove once the NPC drives reliably.
RegisterNetEvent('srv_rescue:server:log', function(tag, data)
    lib.print.info(('[%s] %s'):format(tag, json.encode(data)))
end)
--- No ambulance made it. Refunds and clears the call.
---
--- Charging for a rescue that never happened is the single outcome this feature must never
--- produce: the player has no way to prove it and nothing to show for the money. Failure being
--- a legitimate result of the design makes the refund more important, not less.
RegisterNetEvent('srv_rescue:server:failed', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    local record = getRecord(citizenid)

    if not record.pending then return end

    -- Nothing to refund: the money is only taken on arrival, so a failed call has cost nothing.
    clearPending(citizenid)

    exports.qbx_core:Notify(src, 'Nenhuma ambulância conseguiu chegar até você.', 'error', 8000)
end)
--- The transplant: the way out once the clock has run out.
---
--- Charged at a different price and NOT recorded as a pending rescue - there is no ambulance to
--- send and nothing to owe. It simply revives, which is what keeps the life: a life is only lost
--- through qbx_medical's respawn path, and this never takes it.
lib.callback.register('srv_rescue:server:transplant', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false, 'Personagem não encontrado.' end

    local price = config.transplant.price

    if not player.Functions.RemoveMoney('cash', price, 'srv_rescue:transplant')
        and not player.Functions.RemoveMoney('bank', price, 'srv_rescue:transplant') then
        return false, ('Você precisa de $%s para o transplante.'):format(price)
    end

    local organ = config.transplant.organs[math.random(#config.transplant.organs)]

    return true, organ
end)

--- Called by the client once the operation has played out.
RegisterNetEvent('srv_rescue:server:transplantDone', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    exports.qbx_medical:Revive(src)
    exports.qbx_medical:Heal(src)
end)