local config = require 'config.client'
if not config.enableClient then return end
local VEHICLES = exports.qbx_core:GetVehiclesByName()

-- Servidor: vehicle preview images, served by our own `srv_vehicleimages` resource (one copy,
-- shared with the phone garage app). ox_lib's context menu renders `image` inside the hover
-- card, not inline in the row - deliberate: the hover card gives a bigger picture exactly when
-- you're choosing, the list stays scannable, and it needs no change to our ox_lib fork.
--
-- The image set currently covers every model qbx_core knows about, but that is a fact about
-- today's data, not a guarantee - a future DLC adds models before the image set catches up. So
-- the generated `VehicleImages` set is checked first: a model it doesn't cover gets no `image`
-- field at all, rather than a URL that 404s into a broken-image placeholder. That global comes
-- from `@srv_vehicleimages/data.lua`, included in this resource's own fxmanifest. See ADR-075.
---@param modelName string?
---@return string?
local function vehicleImage(modelName)
    if not modelName or not VehicleImages or not VehicleImages[modelName] then return nil end

    return ('nui://srv_vehicleimages/images/%s.png'):format(modelName)
end

---@enum ProgressColor
local ProgressColor = {
    GREEN = 'green.5',
    YELLOW = 'yellow.5',
    RED = 'red.5'
}

---@param percent number
---@return string
local function getProgressColor(percent)
    if percent >= 75 then
        return ProgressColor.GREEN
    elseif percent > 25 then
        return ProgressColor.YELLOW
    else
        return ProgressColor.RED
    end
end

local VehicleCategory = {
    all = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22},
    car = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 17, 18, 19, 20, 22},
    air = {15, 16},
    sea = {14},
}

---@param category VehicleType
---@param vehicle number
---@return boolean
local function isOfType(category, vehicle)
    local classSet = {}

    for _, class in pairs(VehicleCategory[category]) do
        classSet[class] = true
    end

    return classSet[GetVehicleClass(vehicle)] == true
end

---@param vehicle number
local function kickOutPeds(vehicle)
    for i = -1, 5, 1 do
        local seat = GetPedInVehicleSeat(vehicle, i)
        if seat then
            TaskLeaveVehicle(seat, vehicle, 0)
        end
    end
end

local spawnLock = false

---@param vehicleId number
---@param garageName string
---@param accessPoint integer
local function takeOutOfGarage(vehicleId, garageName, accessPoint)
    if spawnLock then
        exports.qbx_core:Notify(locale('error.spawn_in_progress'))
    end
    spawnLock = true
    local success, result = pcall(function()
        if cache.vehicle then
            exports.qbx_core:Notify(locale('error.in_vehicle'))
            return
        end

        local netId = lib.callback.await('qbx_garages:server:spawnVehicle', false, vehicleId, garageName, accessPoint)
        if not netId then return end

        local veh = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(netId) then
                return NetToVeh(netId)
            end
        end)

        if veh == 0 then
            exports.qbx_core:Notify('Algo deu errado ao retirar o veículo.', 'error')
            return
        end

        if config.engineOn then
            SetVehicleEngineOn(veh, true, true, false)
        end
    end)
    spawnLock = false
    assert(success, result)
end

---@param data {vehicle: PlayerVehicle, garageName: string, accessPoint: integer}
local function takeOutDepot(data)
    if data.vehicle.depotPrice ~= 0 then
        local success = lib.callback.await('qbx_garages:server:payDepotPrice', false, data.vehicle.id)
        if not success then
            exports.qbx_core:Notify(locale('error.not_enough'), 'error')
            return
        end
    end

    takeOutOfGarage(data.vehicle.id, data.garageName, data.accessPoint)
end

---@param vehicle PlayerVehicle
---@param garageName string
---@param garageInfo GarageConfig
---@param accessPoint integer
local function displayVehicleInfo(vehicle, garageName, garageInfo, accessPoint)
    local engine = qbx.math.round(vehicle.props.engineHealth / 10)
    local body = qbx.math.round(vehicle.props.bodyHealth / 10)
    local engineColor = getProgressColor(engine)
    local bodyColor = getProgressColor(body)
    local fuelColor = getProgressColor(vehicle.props.fuelLevel)
    local vehicleLabel = ('%s %s'):format(VEHICLES[vehicle.modelName].brand, VEHICLES[vehicle.modelName].name)

    local options = {
        {
            title = locale('menu.information'),
            icon = 'circle-info',
            description = locale('menu.description', vehicleLabel, vehicle.props.plate, lib.math.groupdigits(vehicle.depotPrice)),
            -- Servidor: deliberately NO `image` here. ox_lib disables an option's hover card when
            -- the option is `readOnly` (`ContextButton.tsx`: `disabled={button.disabled ||
            -- button.readOnly || ...}`), so an image on this row would never render - it would
            -- just be a path built for nothing. The picture lives on the vehicle-list rows one
            -- screen back, which are not readOnly. See ADR-075.
            readOnly = true,
        },
        {
            title = locale('menu.body'),
            icon = 'car-side',
            readOnly = true,
            progress = body,
            colorScheme = bodyColor,
        },
        {
            title = locale('menu.engine'),
            icon = 'oil-can',
            readOnly = true,
            progress = engine,
            colorScheme = engineColor,
        },
        {
            title = locale('menu.fuel'),
            icon = 'gas-pump',
            readOnly = true,
            progress = vehicle.props.fuelLevel,
            colorScheme = fuelColor,
        }
    }

    if vehicle.state == VehicleState.OUT then
        if garageInfo.type == GarageType.DEPOT then
            options[#options + 1] = {
                title = locale('menu.take_out'),
                icon = 'fa-truck-ramp-box',
                description = ('$%s'):format(lib.math.groupdigits(vehicle.depotPrice)),
                arrow = true,
                onSelect = function()
                    takeOutDepot({
                        vehicle = vehicle,
                        garageName = garageName,
                        accessPoint = accessPoint,
                    })
                end,
            }
        else
            options[#options + 1] = {
                title = locale('menu.already_out'),
                icon = VehicleType.CAR,
                readOnly = true,
            }
        end
    elseif vehicle.state == VehicleState.GARAGED then
        options[#options + 1] = {
            title = locale('menu.take_out'),
            icon = 'car-rear',
            arrow = true,
            onSelect = function()
                takeOutOfGarage(vehicle.id, garageName, accessPoint)
            end,
        }
    elseif vehicle.state == VehicleState.IMPOUNDED then
        options[#options + 1] = {
            title = locale('menu.veh_impounded'),
            icon = 'building-shield',
            readOnly = true,
        }
    end

    lib.registerContext({
        id = 'vehicleList',
        title = garageInfo.label,
        menu = 'garageMenu',
        options = options,
    })

    lib.showContext('vehicleList')
end

---@param garageName string
---@param garageInfo GarageConfig
---@param accessPoint integer
local function openGarageMenu(garageName, garageInfo, accessPoint)
    ---@type PlayerVehicle[]?
    local vehicleEntities = lib.callback.await('qbx_garages:server:getGarageVehicles', false, garageName)

    local options = {}

    if not vehicleEntities then
        options[#options + 1] = {
            title = locale('error.no_vehicles'),
            icon = 'car-side',
            readOnly = true,
        }
    else
        table.sort(vehicleEntities, function(a, b)
            return a.modelName < b.modelName
        end)

        for i = 1, #vehicleEntities do
            local vehicleEntity = vehicleEntities[i]
            local vehicleLabel = ('%s %s'):format(VEHICLES[vehicleEntity.modelName].brand, VEHICLES[vehicleEntity.modelName].name)

            options[#options + 1] = {
                title = vehicleLabel,
                description = vehicleEntity.props.plate,
                image = vehicleImage(vehicleEntity.modelName),
                arrow = true,
                onSelect = function()
                    displayVehicleInfo(vehicleEntity, garageName, garageInfo, accessPoint)
                end,
            }
        end
    end

    lib.registerContext({
        id = 'garageMenu',
        title = garageInfo.label,
        description = locale('menu.garage_description'),
        options = options,
    })

    lib.showContext('garageMenu')
end

---@param vehicle number
---@param garageName string
local function parkVehicle(vehicle, garageName)
    if GetVehicleNumberOfPassengers(vehicle) ~= 1 then
        local isParkable = lib.callback.await('qbx_garages:server:isParkable', false, garageName, NetworkGetNetworkIdFromEntity(vehicle))

        if not isParkable then
            exports.qbx_core:Notify(locale('error.not_owned'), 'error', 5000)
            return
        end

        kickOutPeds(vehicle)
        SetVehicleDoorsLocked(vehicle, 2)
        Wait(1500)
        lib.callback.await('qbx_garages:server:parkVehicle', false, NetworkGetNetworkIdFromEntity(vehicle), lib.getVehicleProperties(vehicle), garageName)
        exports.qbx_core:Notify(locale('success.vehicle_parked'), 'primary', 4500)
    else
        exports.qbx_core:Notify(locale('error.vehicle_occupied'), 'error', 3500)
    end
end

---@param garage GarageConfig
---@return boolean
local function checkCanAccess(garage)
    if garage.groups and not exports.qbx_core:HasPrimaryGroup(garage.groups, QBX.PlayerData) then
        exports.qbx_core:Notify(locale('error.no_access'), 'error')
        return false
    end
    if cache.vehicle and not isOfType(garage.vehicleType, cache.vehicle) then
        exports.qbx_core:Notify(locale('error.not_correct_type'), 'error')
        return false
    end
    return true
end

---@param garageName string
---@param garage GarageConfig
---@param accessPoint AccessPoint
---@param accessPointIndex integer
local function createZones(garageName, garage, accessPoint, accessPointIndex)
    CreateThread(function()
        accessPoint.dropPoint = accessPoint.dropPoint or accessPoint.spawn
        local dropZone, coordsZone

        -- Servidor: this outer sphere is what CREATES the drop zone on entry, so a `dropPoint`
        -- further from `coords` than the sphere's own radius can never be reached - you leave the
        -- sphere before you arrive, and the inner zone is torn down (or never built). Upstream's
        -- flat 15 assumed the two are always close together.
        --
        -- Reported on the Lost MC garage, whose counter and parking bay are 18.06m apart: the red
        -- circle was on the map, but standing in it showed no [E] at all. Radius now derives from
        -- the real distance, so a garage can be laid out however the building actually is.
        local dropDistance = accessPoint.dropPoint
            and #(accessPoint.coords.xyz - accessPoint.dropPoint.xyz)
            or 0

        lib.zones.sphere({
            coords = accessPoint.coords,
            radius = math.max(15, dropDistance + 5),
            onEnter = function()
                if accessPoint.dropPoint and garage.type ~= GarageType.DEPOT then
                    dropZone = lib.zones.sphere({
                        coords = accessPoint.dropPoint,
                        radius = 1.5,
                        onEnter = function()
                            if not cache.vehicle then return end
                            lib.showTextUI(locale('info.park_e'))
                        end,
                        onExit = function()
                            lib.hideTextUI()
                        end,
                        inside = function()
                            if not cache.vehicle then return end
                            if IsControlJustReleased(0, 38) then
                                if not checkCanAccess(garage) then return end
                                parkVehicle(cache.vehicle, garageName)
                            end
                        end,
                        debug = config.debugPoly
                    })
                end
                coordsZone = lib.zones.sphere({
                    coords = accessPoint.coords,
                    radius = 1,
                    onEnter = function()
                        if accessPoint.dropPoint and cache.vehicle then return end
                        lib.showTextUI((garage.type == GarageType.DEPOT and locale('info.impound_e')) or (cache.vehicle and locale('info.park_e')) or locale('info.car_e'))
                    end,
                    onExit = function()
                        lib.hideTextUI()
                    end,
                    inside = function()
                        if accessPoint.dropPoint and cache.vehicle then return end
                        if IsControlJustReleased(0, 38) then
                            if not checkCanAccess(garage) then return end
                            if cache.vehicle and garage.type ~= GarageType.DEPOT then
                                parkVehicle(cache.vehicle, garageName)
                            else
                                openGarageMenu(garageName, garage, accessPointIndex)
                            end
                        end
                    end,
                    debug = config.debugPoly
                })
            end,
            onExit = function()
                if dropZone then
                    dropZone:remove()
                end
                if coordsZone then
                    coordsZone:remove()
                end
            end,
            inside = function()
                if accessPoint.dropPoint then
                    config.drawDropOffMarker(accessPoint.dropPoint)
                end
                config.drawGarageMarker(accessPoint.coords.xyz)
            end,
            debug = config.debugPoly,
        })
    end)
end

---@param garageInfo GarageConfig
---@param accessPoint AccessPoint
local function createBlips(garageInfo, accessPoint)
    local blip = AddBlipForCoord(accessPoint.coords.x, accessPoint.coords.y, accessPoint.coords.z)
    SetBlipSprite(blip, accessPoint.blip.sprite or 357)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.60)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, accessPoint.blip.color or 3)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(accessPoint.blip.name or garageInfo.label)
    EndTextCommandSetBlipName(blip)

    return blip
end

-- Servidor: the pickup point (config.drawGarageMarker, green) and the return/park spot
-- (config.drawDropOffMarker, red - createZones' `dropPoint`, defaulting to `spawn`) both already
-- had a ground marker, but those only draw within 15m - nothing showed either on the map itself.
-- Requested: mark both on the map too, subtly. Sprite 1 is a plain circle (not the parking-sign
-- icon `createBlips` uses for the garage's own blip), scaled down, short range and
-- semi-transparent so it reads as a secondary detail next to that blip rather than a second
-- destination. Deliberately only called where `accessPoint.blip` is already set: job/gang
-- garages never define one - their locations aren't meant to be on the map at all - and this must
-- not become the first thing that puts them there.
---@param coords vector3
---@param color number
---@param label string
local function createCircleBlip(coords, color, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.4)
    SetBlipColour(blip, color)
    SetBlipAlpha(blip, 140)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(blip)

    return blip
end

-- Servidor: reported after the first restart - at some garages `dropPoint` (defaulting to
-- `spawn`) sits only a couple of metres from `accessPoint.coords`, so the green and red circles
-- landed close enough on the map to read as one blob. This only pushes the RED blip's *map
-- position* further out along the real line between the two points - it does not touch
-- `dropPoint`/`spawn` themselves, so the actual ground marker, the drop zone, and where the
-- vehicle spawns are all untouched. Purely a map-legibility nudge, not a gameplay coordinate.
---@param fromCoords vector4|vector3
---@param towardCoords vector4|vector3
---@param extraDistance number
---@return vector3
local function pushBlipAway(fromCoords, towardCoords, extraDistance)
    local dx, dy = towardCoords.x - fromCoords.x, towardCoords.y - fromCoords.y
    local dist = math.sqrt(dx * dx + dy * dy)
    -- Points essentially on top of each other have no real direction to extend along - push
    -- east as an arbitrary, harmless default so the two blips still separate on the map.
    local nx, ny = dist > 0.1 and (dx / dist) or 1.0, dist > 0.1 and (dy / dist) or 0.0
    return vector3(towardCoords.x + nx * extraDistance, towardCoords.y + ny * extraDistance, towardCoords.z)
end

-- Servidor: every blip belonging to a job/gang garage, so they can be removed and redrawn when the
-- player's group changes. Public garages are never in here - they are drawn once and never move.
---@type number[]
local groupBlips = {}

--- Draws one access point's three blips (the garage icon, the green pickup circle, the red park
--- circle) and returns their handles.
---@param garage GarageConfig
---@param accessPoint AccessPoint
---@return number[]
local function createAccessPointBlips(garage, accessPoint)
    local blips = { createBlips(garage, accessPoint) }

    -- Green at the pickup point, for every garage type - even a DEPOT's `coords` is
    -- where you retrieve a vehicle from, matching drawGarageMarker's own unconditional
    -- green ground marker below.
    blips[#blips + 1] = createCircleBlip(accessPoint.coords.xyz, 2, locale('info.pickup_spot'))

    if garage.type ~= GarageType.DEPOT then
        local dropCoords = accessPoint.dropPoint or accessPoint.spawn or accessPoint.coords
        blips[#blips + 1] = createCircleBlip(pushBlipAway(accessPoint.coords, dropCoords, 2.0), 1, locale('info.park_spot'))
    end

    return blips
end

--- Servidor: whether this client should see a garage's blips at all.
---
--- A garage with `groups` is a job or gang garage, and its blips are drawn ONLY for a member -
--- requested, so a gang's parking is on the map for the gang and invisible to everyone else. Using
--- `HasPrimaryGroup`, the same check `createZones` and the server already gate *use* on, so what is
--- shown and what is allowed can never disagree.
---@param garage GarageConfig
---@return boolean
local function maySeeGarageBlips(garage)
    if not garage.groups then return true end

    return exports.qbx_core:HasPrimaryGroup(garage.groups, QBX.PlayerData)
end

local function createGarage(name, garage)
    local accessPoints = garage.accessPoints
    for i = 1, #accessPoints do
        local accessPoint = accessPoints[i]

        if accessPoint.blip and maySeeGarageBlips(garage) then
            local blips = createAccessPointBlips(garage, accessPoint)

            -- Only group garages are tracked: their blips are the ones that have to disappear when
            -- the player leaves the gang.
            if garage.groups then
                for j = 1, #blips do
                    groupBlips[#groupBlips + 1] = blips[j]
                end
            end
        end

        createZones(name, garage, accessPoint, i)
    end
end

-- Servidor: kept so the group blips can be redrawn without re-running `createGarage`, which would
-- register a second set of zones on top of the existing ones.
local cachedGarages

local function createGarages()
    cachedGarages = lib.callback.await('qbx_garages:server:getGarages')
    for name, garage in pairs(cachedGarages) do
        createGarage(name, garage)
    end
end

--- Servidor: redraws only the job/gang garage blips, for when the player's group changes.
---
--- Without this the blips would be a snapshot taken at login: join a gang and its garage stays
--- invisible until relog, leave one and its garage stays on your map forever. That is the exact
--- stale-snapshot bug ADR-139 was written about, and it is avoided here rather than repeated.
--- Zones are untouched - they do their own `HasPrimaryGroup` check every time they are used.
local function refreshGroupBlips()
    for i = 1, #groupBlips do
        RemoveBlip(groupBlips[i])
    end

    groupBlips = {}

    if not cachedGarages then return end

    for _, garage in pairs(cachedGarages) do
        if garage.groups and maySeeGarageBlips(garage) then
            local accessPoints = garage.accessPoints

            for i = 1, #accessPoints do
                if accessPoints[i].blip then
                    local blips = createAccessPointBlips(garage, accessPoints[i])

                    for j = 1, #blips do
                        groupBlips[#groupBlips + 1] = blips[j]
                    end
                end
            end
        end
    end
end

RegisterNetEvent('QBCore:Client:OnGangUpdate', refreshGroupBlips)
RegisterNetEvent('QBCore:Client:OnJobUpdate', refreshGroupBlips)

RegisterNetEvent('qbx_garages:client:garageRegistered', function(name, garage)
    createGarage(name, garage)
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    createGarages()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end
    createGarages()
end)
