-- Servidor: the whole admin menu tree used to be built on `lib.registerMenu` (a vertical list
-- component ox_lib's own monochrome reskin never touched) - reported as looking foreign next to
-- every other menu on the server. Converted to `lib.registerContext` throughout (this file and
-- every other one in this resource) - the same card-based, clickable, image-capable component the
-- dealer menus and `player.lua`'s own "Dar Item" picker already use, so `/admin` finally renders
-- with "nosso layout padrão" by construction rather than needing its own separate skin.
ShowMainMenu = function()
    lib.registerContext({
        id = 'qbx_adminmenu_main_menu',
        title = locale('title.main_menu'),
        options = {
            { title = locale('main_options.label1'), description = locale('main_options.desc1'), icon = 'fas fa-hammer', onSelect = ShowAdminMenu },
            { title = locale('main_options.label2'), description = locale('main_options.desc2'), icon = 'fas fa-user', onSelect = GeneratePlayersMenu },
            { title = locale('main_options.label3'), description = locale('main_options.desc3'), icon = 'fas fa-server', onSelect = ShowServerMenu },
            { title = locale('main_options.label4'), description = locale('main_options.desc4'), icon = 'fas fa-car', onSelect = ShowVehiclesMenu },
            { title = locale('main_options.label5'), description = locale('main_options.desc5'), icon = 'fas fa-toolbox', onSelect = ShowDevMenu },
            { title = locale('main_options.label6'), description = locale('main_options.desc6'), icon = 'fas fa-list', onSelect = GenerateReportMenu },
        },
    })
    lib.showContext('qbx_adminmenu_main_menu')
end

RegisterNetEvent('qbx_admin:client:openMenu', function()
    ShowMainMenu()
end)

RegisterNetEvent('qbx_admin:client:setModel', function(skin)
    local model = joaat(skin)
    SetEntityInvincible(cache.ped, true)
    if IsModelInCdimage(model) and IsModelValid(model) then
        lib.requestModel(model)
        SetPlayerModel(cache.playerId, model)
        SetPedRandomComponentVariation(cache.ped, 1)
        SetModelAsNoLongerNeeded(model)
    end
    SetEntityInvincible(cache.ped, false)
end)
