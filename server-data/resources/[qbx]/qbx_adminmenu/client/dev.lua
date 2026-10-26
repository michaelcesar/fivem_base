local showCoords = false
local vehicleDev = false
local vehicleTypes = {'Compactos', 'Sedãs', 'SUVs', 'Cupês', 'Muscle', 'Esportivos Clássicos', 'Esportivos', 'Super', 'Motocicletas', 'Off-road', 'Industriais', 'Utilitários', 'Vans', 'Bicicletas', 'Barcos', 'Helicópteros', 'Aviões', 'Serviço', 'Emergência', 'Militares', 'Comerciais', 'Trens', 'Rodas Abertas'}

-- Servidor: every row reopens this same menu after running (`ShowDevMenu()` at the end of each
-- `onSelect`) - the four copy actions already did this under `lib.registerMenu` (`close = false`
-- plus an explicit reopen), and the two on-screen overlays (coords/vehicle info) are meant to keep
-- running with the menu conceptually still "at" this screen, same as before.
ShowDevMenu = function()
    lib.registerContext({
        id = 'qbx_adminmenu_dev_menu',
        title = locale('title.dev_menu'),
        menu = 'qbx_adminmenu_main_menu',
        options = {
            { title = locale('dev_options.label1'), description = locale('dev_options.desc1'), icon = 'fas fa-compass', onSelect = function() CopyToClipboard('coords2'); ShowDevMenu() end },
            { title = locale('dev_options.label2'), description = locale('dev_options.desc2'), icon = 'fas fa-compass', onSelect = function() CopyToClipboard('coords3'); ShowDevMenu() end },
            { title = locale('dev_options.label3'), description = locale('dev_options.desc3'), icon = 'fas fa-compass', onSelect = function() CopyToClipboard('coords4'); ShowDevMenu() end },
            { title = locale('dev_options.label4'), description = locale('dev_options.desc4'), icon = 'fas fa-compass', onSelect = function() CopyToClipboard('heading'); ShowDevMenu() end },
            { title = locale('dev_options.label5'), description = locale('dev_options.desc5'), icon = 'fas fa-compass-drafting', onSelect = function()
                showCoords = not showCoords
                if showCoords then
                    CreateThread(function()
                        while showCoords do
                            local coords, heading = GetEntityCoords(cache.ped), GetEntityHeading(cache.ped)

                            qbx.drawText2d({
                                text = ('~o~vector4~w~(%s, %s, %s, %s)'):format(qbx.math.round(coords.x, 2), qbx.math.round(coords.y, 2), qbx.math.round(coords.z, 2), qbx.math.round(heading, 2)),
                                coords = vec2(1.0, 0.5),
                                scale = 0.5,
                                font = 6
                            })

                            Wait(0)
                        end
                    end)
                end
                ShowDevMenu()
            end },
            { title = locale('dev_options.label6'), description = locale('dev_options.desc6'), icon = 'fas fa-car-side', onSelect = function()
                vehicleDev = not vehicleDev
                if vehicleDev then
                    CreateThread(function()
                        while vehicleDev do
                            if cache.vehicle then
                                local clutch, gear, rpm, temperature = GetVehicleClutch(cache.vehicle), GetVehicleCurrentGear(cache.vehicle), GetVehicleCurrentRpm(cache.vehicle), GetVehicleEngineTemperature(cache.vehicle)
                                local oil, angle, body, class = GetVehicleOilLevel(cache.vehicle), GetVehicleSteeringAngle(cache.vehicle), GetVehicleBodyHealth(cache.vehicle), vehicleTypes[GetVehicleClass(cache.vehicle)]
                                local dirt, maxSpeed, netId, hash = GetVehicleDirtLevel(cache.vehicle), GetVehicleEstimatedMaxSpeed(cache.vehicle), VehToNet(cache.vehicle), GetEntityModel(cache.vehicle)
                                local name = GetLabelText(GetDisplayNameFromVehicleModel(hash))
                                qbx.drawText2d({
                                    text = ('~o~Embreagem: ~w~ %s | ~o~Marcha: ~w~ %s | ~o~Rpm: ~w~ %s | ~o~Temperatura: ~w~ %s'):format(qbx.math.round(clutch, 4), gear, qbx.math.round(rpm, 4), temperature),
                                    coords = vec2(1.0, 0.575),
                                    scale = 0.45,
                                    font = 6
                                })
                                qbx.drawText2d({
                                    text = ('~o~Óleo: ~w~ %s | ~o~Ângulo da Direção: ~w~ %s | ~o~Carroceria: ~w~ %s | ~o~Classe: ~w~ %s'):format(qbx.math.round(oil, 4), qbx.math.round(angle, 4), qbx.math.round(body, 4), class),
                                    coords = vec2(1.0, 0.600),
                                    scale = 0.45,
                                    font = 6
                                })
                                qbx.drawText2d({
                                    text = ('~o~Sujeira: ~w~ %s | ~o~Vel. Máx. Est.: ~w~ %s | ~o~ID de Rede: ~w~ %s | ~o~Hash: ~w~ %s'):format(qbx.math.round(dirt, 4), qbx.math.round(maxSpeed, 4) * 3.6, netId, hash),
                                    coords = vec2(1.0, 0.625),
                                    scale = 0.45,
                                    font = 6
                                })
                                qbx.drawText2d({
                                    text = ('~o~Nome do Veículo: ~w~ %s'):format(name),
                                    coords = vec2(1.0, 0.650),
                                    scale = 0.45,
                                    font = 6
                                })
                                Wait(0)
                            else
                                Wait(800)
                            end
                        end
                    end)
                end
                ShowDevMenu()
            end },
        },
    })
    lib.showContext('qbx_adminmenu_dev_menu')
end
