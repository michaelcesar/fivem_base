local coreVehicles = exports.qbx_core:GetVehiclesByName()

-- Servidor: `qbx_core`'s own `category` field on every vehicle (`shared/vehicles.lua`) is English
-- and lowercase - `qbx.string.capitalize` only fixed the casing, never the language. Same 23-entry
-- translation this project's own `srv_tools`/`dev.lua` debug overlays already use, kept in sync
-- by hand since neither is generated from the other.
local CATEGORY_LABELS = {
    boats = 'Barcos',
    commercial = 'Comerciais',
    compacts = 'Compactos',
    coupes = 'Cupês',
    cycles = 'Bicicletas',
    emergency = 'Emergência',
    helicopters = 'Helicópteros',
    industrial = 'Industriais',
    military = 'Militares',
    motorcycles = 'Motocicletas',
    muscle = 'Muscle',
    offroad = 'Off-road',
    openwheel = 'Rodas Abertas',
    planes = 'Aviões',
    sedans = 'Sedãs',
    service = 'Serviço',
    sports = 'Esportivos',
    sportsclassics = 'Esportivos Clássicos',
    super = 'Super',
    suvs = 'SUVs',
    trains = 'Trens',
    utility = 'Utilitários',
    vans = 'Vans',
}

---@param category string
---@return string
local function categoryLabel(category)
    return CATEGORY_LABELS[category] or qbx.string.capitalize(category)
end

-- Servidor: the same real preview image `qbx_garages` already shows in its own context menu -
-- `VehicleImages` comes from `srv_vehicleimages/data.lua` (declared in this resource's own
-- `fxmanifest.lua`), a global set covering every model `qbx_core` knows about. A model the set
-- doesn't cover gets no icon rather than a broken image path. See ADR-075.
---@param modelName string
---@return string?
local function getVehicleImage(modelName)
    if not modelName or not VehicleImages or not VehicleImages[modelName] then return nil end
    return ('nui://srv_vehicleimages/images/%s.png'):format(modelName)
end

function GenerateVehiclesSpawnMenu()
    local canUseMenu = lib.callback.await('qbx_admin:server:canUseMenu', false)
    if not canUseMenu then
        ShowVehiclesMenu()
        return
    end

    local categories = {}
    for _, v in pairs(coreVehicles) do
        categories[v.category] = true
    end

    local categoryList = {}
    for k in pairs(categories) do
        categoryList[#categoryList + 1] = k
    end

    table.sort(categoryList, function(a, b) return a < b end)

    local categoryOptions = {}
    for i = 1, #categoryList do
        local category = categoryList[i]

        categoryOptions[i] = {
            title = categoryLabel(category),
            icon = 'fas fa-car',
            arrow = true,
            onSelect = function()
                local vehsInCategory = {}
                for model, v in pairs(coreVehicles) do
                    if v.category == category then
                        vehsInCategory[#vehsInCategory + 1] = { model = model, name = v.name }
                    end
                end

                table.sort(vehsInCategory, function(a, b) return a.name < b.name end)

                local vehOptions = {}
                for j = 1, #vehsInCategory do
                    local entry = vehsInCategory[j]
                    local icon = getVehicleImage(entry.model)

                    vehOptions[j] = {
                        title = entry.name,
                        description = entry.model,
                        icon = icon,
                        image = icon,
                        onSelect = function()
                            local vehNetId = lib.callback.await('qbx_admin:server:spawnVehicle', false, entry.model)
                            if not vehNetId then return end

                            local veh
                            repeat
                                veh = NetToVeh(vehNetId)
                                Wait(100)
                            until DoesEntityExist(veh)

                            TriggerEvent('qb-vehiclekeys:client:AddKeys', qbx.getVehiclePlate(veh))
                            SetVehicleNeedsToBeHotwired(veh, false)
                            SetVehicleHasBeenOwnedByPlayer(veh, true)
                            SetEntityAsMissionEntity(veh, true, false)
                            SetVehicleIsStolen(veh, false)
                            SetVehicleIsWanted(veh, false)
                            SetVehicleEngineOn(veh, true, true, true)
                            SetPedIntoVehicle(cache.ped, veh, -1)
                            SetVehicleOnGroundProperly(veh)
                            SetVehicleRadioEnabled(veh, true)
                            SetVehRadioStation(veh, 'OFF')
                        end,
                    }
                end

                lib.registerContext({
                    id = ('qbx_adminmenu_spawn_vehicles_menu_%s'):format(category),
                    title = categoryLabel(category),
                    menu = 'qbx_adminmenu_spawn_vehicles_menu',
                    options = vehOptions,
                })
                lib.showContext(('qbx_adminmenu_spawn_vehicles_menu_%s'):format(category))
            end,
        }
    end

    lib.registerContext({
        id = 'qbx_adminmenu_spawn_vehicles_menu',
        title = 'Spawnar Veículo',
        menu = 'qbx_adminmenu_vehicles_menu',
        options = categoryOptions,
    })
    lib.showContext('qbx_adminmenu_spawn_vehicles_menu')
end

ShowVehiclesMenu = function()
    lib.registerContext({
        id = 'qbx_adminmenu_vehicles_menu',
        title = 'Veículos',
        menu = 'qbx_adminmenu_main_menu',
        options = {
            { title = 'Spawnar Veículo', icon = 'fas fa-car', arrow = true, onSelect = GenerateVehiclesSpawnMenu },
            { title = 'Consertar Veículo', icon = 'fas fa-wrench', onSelect = function() ExecuteCommand('fix'); ShowVehiclesMenu() end },
            { title = 'Comprar Veículo', icon = 'fas fa-hand-holding-dollar', onSelect = function() ExecuteCommand('admincar'); ShowVehiclesMenu() end },
            { title = 'Remover Veículo', icon = 'fas fa-trash', onSelect = function() ExecuteCommand('dv'); ShowVehiclesMenu() end },
            { title = 'Tunar Veículo', icon = 'fas fa-gears', onSelect = function()
                if not cache.vehicle then
                    exports.qbx_core:Notify('Você precisa estar em um veículo para usar isso.', 'error')
                    ShowVehiclesMenu()
                    return
                end
                exports.qbx_core:Notify('Ainda sem suporte para o novo customs.', 'error')
                ShowVehiclesMenu()
            end },
            { title = 'Trocar Placa', icon = 'fas fa-id-card', onSelect = function()
                if not cache.vehicle then
                    exports.qbx_core:Notify('Você precisa estar em um veículo para usar isso.', 'error')
                    ShowVehiclesMenu()
                    return
                end

                local dialog = lib.inputDialog('Placa Personalizada (Máx. 8 caracteres)', { 'Placa' })

                if not dialog or not dialog[1] or dialog[1] == '' then
                    ShowVehiclesMenu()
                    return
                end

                if #dialog[1] > 8 then
                    exports.qbx_core:Notify('Você pode usar no máximo 8 caracteres.', 'error')
                    ShowVehiclesMenu()
                    return
                end

                SetVehicleNumberPlateText(cache.vehicle, dialog[1])
                TriggerEvent('qb-vehiclekeys:client:AddKeys', dialog[1])
                ShowVehiclesMenu()
            end },
        },
    })
    lib.showContext('qbx_adminmenu_vehicles_menu')
end
