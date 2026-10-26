if Config.UseTarget then return end

local currentZone = nil

local Zones = {
    Store = {},
    ClothingRoom = {},
    PlayerOutfitRoom = {}
}

local function RemoveZones()
    for i = 1, #Zones.Store do
        if Zones.Store[i]["remove"] then
            Zones.Store[i]:remove()
        end
    end
    for i = 1, #Zones.ClothingRoom do
        Zones.ClothingRoom[i]:remove()
    end
    for i = 1, #Zones.PlayerOutfitRoom do
        Zones.PlayerOutfitRoom[i]:remove()
    end
end

local function lookupZoneIndexFromID(zones, id)
    for i = 1, #zones do
        if zones[i].id == id then
            return i
        end
    end
end

local function onStoreEnter(data)
    local index = lookupZoneIndexFromID(Zones.Store, data.id)
    local store = Config.Stores[index]

    local jobName = (store.job and client.job.name) or (store.gang and client.gang.name)
    if jobName == (store.job or store.gang) then
        currentZone = {
            name = store.type,
            index = index,
            coords = store.coords
        }
        local prefix = Config.UseRadialMenu and "" or "[E] "
        if currentZone.name == "clothing" then
            lib.showTextUI(prefix .. string.format(_L("textUI.clothing"), Config.ClothingCost), Config.TextUIOptions)
        elseif currentZone.name == "barber" then
            lib.showTextUI(prefix .. string.format(_L("textUI.barber"), Config.BarberCost), Config.TextUIOptions)
        elseif currentZone.name == "tattoo" then
            lib.showTextUI(prefix .. string.format(_L("textUI.tattoo"), Config.TattooCost), Config.TextUIOptions)
        elseif currentZone.name == "surgeon" then
            lib.showTextUI(prefix .. string.format(_L("textUI.surgeon"), Config.SurgeonCost), Config.TextUIOptions)
        end
        Radial.AddOption(currentZone)
    end
end

local function onClothingRoomEnter(data)
    local index = lookupZoneIndexFromID(Zones.ClothingRoom, data.id)
    local clothingRoom = Config.ClothingRooms[index]

    local jobName = clothingRoom.job and client.job.name or client.gang.name
    if jobName == (clothingRoom.job or clothingRoom.gang) then
        if CheckDuty() or clothingRoom.gang then
            currentZone = {
                name = "clothingRoom",
                index = index,
                coords = clothingRoom.coords
            }
            local prefix = Config.UseRadialMenu and "" or "[E] "
            lib.showTextUI(prefix .. _L("textUI.clothingRoom"), Config.TextUIOptions)
            Radial.AddOption(currentZone)
        end
    end
end

local function onPlayerOutfitRoomEnter(data)
    local index = lookupZoneIndexFromID(Zones.PlayerOutfitRoom, data.id)
    local playerOutfitRoom = Config.PlayerOutfitRooms[index]

    local isAllowed = IsPlayerAllowedForOutfitRoom(playerOutfitRoom)
    if isAllowed then
        currentZone = {
            name = "playerOutfitRoom",
            index = index,
            coords = playerOutfitRoom.coords
        }
        local prefix = Config.UseRadialMenu and "" or "[E] "
        lib.showTextUI(prefix .. _L("textUI.playerOutfitRoom"), Config.TextUIOptions)
        Radial.AddOption(currentZone)
    end
end

local function onZoneExit()
    currentZone = nil
    Radial.RemoveOption()
    lib.hideTextUI()
end

local function SetupZone(store, onEnter, onExit)
    if Config.RCoreTattoosCompatibility and store.type == "tattoo" then
        return {}
    end

    if Config.UseRadialMenu or store.usePoly then
        return lib.zones.poly({
            points = store.points,
            debug = Config.Debug,
            onEnter = onEnter,
            onExit = onExit
        })
    end

    return lib.zones.box({
        coords = store.coords,
        size = store.size,
        rotation = store.rotation,
        debug = Config.Debug,
        onEnter = onEnter,
        onExit = onExit
    })
end

local function SetupStoreZones()
    for _, v in pairs(Config.Stores) do
        Zones.Store[#Zones.Store + 1] = SetupZone(v, onStoreEnter, onZoneExit)
    end
end

local function SetupClothingRoomZones()
    for _, v in pairs(Config.ClothingRooms) do
        Zones.ClothingRoom[#Zones.ClothingRoom + 1] = SetupZone(v, onClothingRoomEnter, onZoneExit)
    end
end

local function SetupPlayerOutfitRoomZones()
    for _, v in pairs(Config.PlayerOutfitRooms) do
        Zones.PlayerOutfitRoom[#Zones.PlayerOutfitRoom + 1] = SetupZone(v, onPlayerOutfitRoomEnter, onZoneExit)
    end
end

local function SetupZones()
    SetupStoreZones()
    SetupClothingRoomZones()
    SetupPlayerOutfitRoomZones()
end

local function ZonesLoop()
    Wait(1000)
    while true do
        local sleep = 1000
        if currentZone then
            -- Servidor: DrawMarker only persists for the frame it's called on - every other
            -- marker in this project runs inside ox_lib's `inside` zone callback, which ticks
            -- every frame (see docs/conventions.md). This loop isn't an ox_lib zone, so it has
            -- to match that cadence by hand: Wait(5) let frames slip through undrawn, which is
            -- exactly what read as flickering.
            sleep = 0

            -- Servidor: same ground marker convention as qbx_cityhall/qbx_garages/srv_jobs -
            -- this file only ever showed the [E] text, with nothing drawn on the ground.
            if currentZone.coords then
                local coords = currentZone.coords
                DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 20, 246, 12, 200, false, false, 0, false, nil, nil, false)
            end

            if IsControlJustReleased(0, 38) then
                if currentZone.name == "clothingRoom" then
                    local clothingRoom = Config.ClothingRooms[currentZone.index]
                    local outfits = GetPlayerJobOutfits(clothingRoom.job)
                    TriggerEvent("illenium-appearance:client:openJobOutfitsMenu", outfits)
                elseif currentZone.name == "playerOutfitRoom" then
                    local outfitRoom = Config.PlayerOutfitRooms[currentZone.index]
                    OpenOutfitRoom(outfitRoom)
                elseif currentZone.name == "clothing" then
                    -- Servidor: gated on `srv_wanted` - a marked player is refused here, the same
                    -- way `srv_robbery`'s own convenience-store counters already are, and the
                    -- attempt is reported to the police. This point had no server round trip at
                    -- all before (a client `TriggerEvent` straight into the appearance editor), so
                    -- this is the only check standing between a modified client and the shop.
                    local access = lib.callback.await('srv_wanted:server:checkShopAccess', false)
                    if access and access.ok then
                        TriggerEvent("illenium-appearance:client:openClothingShopMenu")
                    else
                        lib.notify({ title = 'Procurado', description = 'Você está procurado - o lojista não te atende.', type = 'error' })
                    end
                elseif currentZone.name == "barber" then
                    OpenBarberShop()
                elseif currentZone.name == "tattoo" then
                    OpenTattooShop()
                elseif currentZone.name == "surgeon" then
                    OpenSurgeonShop()
                end
            end
        end
        Wait(sleep)
    end
end


CreateThread(function()
    SetupZones()
    if not Config.UseRadialMenu then
        ZonesLoop()
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        RemoveZones()
    end
end)

RegisterNetEvent("illenium-appearance:client:OpenClothingRoom", function()
    local clothingRoom = Config.ClothingRooms[currentZone.index]
    local outfits = GetPlayerJobOutfits(clothingRoom.job)
    TriggerEvent("illenium-appearance:client:openJobOutfitsMenu", outfits)
end)

RegisterNetEvent("illenium-appearance:client:OpenPlayerOutfitRoom", function()
    local outfitRoom = Config.PlayerOutfitRooms[currentZone.index]
    OpenOutfitRoom(outfitRoom)
end)
