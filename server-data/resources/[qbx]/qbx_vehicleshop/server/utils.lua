local config = require 'config.server'
local allowedVehicles = require 'server.vehicles'

---@param vehicle string Vehicle model name to check if allowed for purchase/testdrive/etc.
---@param shop string? Shop name to check if vehicle is allowed in that shop
---@return boolean
function CheckVehicleList(vehicle, shop)
    for i = 1, allowedVehicles.count do
        local allowedVeh = allowedVehicles.vehicles[i]
        if allowedVeh.model == vehicle and (not shop or allowedVeh.shopType == shop) then
            return true
        end
    end

    return false
end

local shops = require 'config.shared'.shops
local shopZones = {}

---@param source number
---@return string?
function GetShopZone(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
    for i = 1, #shopZones do
        local zone = shopZones[i]
        if zone:contains(coords) then
            return zone.name
        end
    end
end

-- Create shop zones for point checking
CreateThread(function()
    for shopName, shop in pairs(shops) do
        shopZones[#shopZones + 1] = lib.zones.poly({
            name = shopName,
            points = shop.zone.shape,
            -- Servidor: honours the same per-shop `zone.thickness` the client's own `createShop`
            -- does. These are two SEPARATE zone sets built from one config - the client's decides
            -- whether the `[E]` prompt appears, this one decides whether the server believes the
            -- player is at a shop at all - and only the client's was made configurable at first.
            --
            -- The result was a dealership that looked completely functional and silently refused
            -- every action: at `vip`, whose showroom spans three levels 10.69m apart, a player on
            -- the upper two floors got the prompt and the menu from the client zone, then
            -- `GetShopZone` returned nil here and every handler hit `if not shop then return end`.
            -- No error, no notification, nothing in the log. Reported as "I can't buy or test drive
            -- at vip".
            thickness = shop.zone.thickness or 5,
        })

        for i = 1, #shop.showroomVehicles do
            local vehicle = shop.showroomVehicles[i]

            if not CheckVehicleList(vehicle.vehicle, shopName) then
                lib.print.warn(('Vehicle "%s" is a showroom vehicle for shop "%s" but is not allowed to be bought there'):format(vehicle.vehicle, shopName))
            end
        end
    end
end)

---@param price number
---@param cash number
---@param bank number
---@return 'cash'|'bank'|nil
function FindChargeableCurrencyType(price, cash, bank)
    if cash >= price then
        return 'cash'
    elseif bank >= price then
        return 'bank'
    else
        return
    end
end

---@param src number
---@param amount number
---@param reason string?
---@return boolean success if money was removed
function RemoveMoney(src, amount, reason)
    local player = exports.qbx_core:GetPlayer(src)
    local cash = player.PlayerData.money.cash
    local bank = player.PlayerData.money.bank
    local currencyType = FindChargeableCurrencyType(amount, cash, bank)

    if not currencyType then
        exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
        return false
    end

    return config.removePlayerFunds(player, currencyType, amount, reason)
end

---@param spawns vector4[]
---@return vector4 | nil
function GetClearSpawnArea(spawns)
    for i = 1, #spawns do
        local spawn = spawns[i]

        if #lib.getNearbyVehicles(spawn.xyz) == 0 then
            return spawn
        end
    end
end

---@param src number
---@param data {coords: vector4, vehicleId?: number, modelName: string, plate?: string, props?: {plate: string}}
---@return number|nil
function SpawnVehicle(src, data)
    local coords, vehicleId = data.coords, data.vehicleId
    local newVehicle = vehicleId and exports.qbx_vehicles:GetPlayerVehicle(vehicleId) or data
    if not newVehicle then return end

    -- Servidor: a dealership inside an interior spawns onto street `vehicleSpawns` the buyer is
    -- nowhere near, so the `warp` below cannot resolve and stays pending - the car sits at the kerb
    -- empty and the player only drops into it later, when they happen to walk out. Reported for
    -- both buying and test driving, which both reach this function.
    --
    -- `srv_dealerdoors` teleports them out first if they are standing in one of its showrooms, and
    -- this AWAITS that so the vehicle is not created mid-teleport. Guarded on the resource actually
    -- running: without the check a server without it would block here until the callback timed out.
    --
    -- The SPAWN POINT is what gets sent, not the shop's door. A dealership's street door and its
    -- delivery kerb are not required to be near each other - `vip`'s are about 300m apart - so
    -- sending the buyer to the door would leave them walking to their own new car. Sending them to
    -- the spot the vehicle is about to appear at works for every shop regardless of that distance.
    if GetResourceState('srv_dealerdoors') == 'started' then
        lib.callback.await('srv_dealerdoors:client:leaveForPurchase', src, {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            w = coords.w,
        })
    end

    local plate = newVehicle.plate or newVehicle.props.plate

    local netId, vehicle = qbx.spawnVehicle({
        model = newVehicle.modelName,
        spawnSource = coords,
        warp = GetPlayerPed(src),
        props = {
            plate = plate
        }
    })

    if not netId or netId == 0 or not vehicle or vehicle == 0 then return end

    if vehicleId then
        Entity(vehicle).state:set('vehicleid', vehicleId, false)
    end

    config.giveKeys(src, plate, vehicle)

    return netId
end