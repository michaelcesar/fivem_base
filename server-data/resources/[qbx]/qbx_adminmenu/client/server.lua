local weatherOptions = {
    { label = locale('server_options.value1_1'), value = 'Extrasunny' },
    { label = locale('server_options.value1_2'), value = 'Clear' },
    { label = locale('server_options.value1_3'), value = 'Neutral' },
    { label = locale('server_options.value1_4'), value = 'Smog' },
    { label = locale('server_options.value1_5'), value = 'Foggy' },
    { label = locale('server_options.value1_6'), value = 'Overcast' },
    { label = locale('server_options.value1_7'), value = 'Clouds' },
    { label = locale('server_options.value1_8'), value = 'Clearing' },
    { label = locale('server_options.value1_9'), value = 'Rain' },
    { label = locale('server_options.value1_10'), value = 'Thunder' },
    { label = locale('server_options.value1_11'), value = 'Snow' },
    { label = locale('server_options.value1_12'), value = 'Blizzard' },
    { label = locale('server_options.value1_13'), value = 'Snowlight' },
    { label = locale('server_options.value1_14'), value = 'Xmas' },
    { label = locale('server_options.value1_15'), value = 'Halloween' },
}

local timeOptions = {}
for hour = 0, 23 do
    local padded = ('%02d'):format(hour)
    timeOptions[#timeOptions + 1] = { label = ('%s:00'):format(padded), value = padded }
end

local function weatherMenu()
    local options = {}
    for i = 1, #weatherOptions do
        options[i] = {
            title = weatherOptions[i].label,
            icon = 'fas fa-cloud',
            onSelect = function()
                TriggerServerEvent('qb-weathersync:server:setWeather', weatherOptions[i].value)
                ShowServerMenu()
            end,
        }
    end

    lib.registerContext({
        id = 'qbx_adminmenu_weather_menu',
        title = locale('server_options.label1'),
        menu = 'qbx_adminmenu_server_menu',
        options = options,
    })
    lib.showContext('qbx_adminmenu_weather_menu')
end

local function timeMenu()
    local options = {}
    for i = 1, #timeOptions do
        options[i] = {
            title = timeOptions[i].label,
            icon = 'fas fa-clock',
            onSelect = function()
                TriggerServerEvent('qb-weathersync:server:setTime', timeOptions[i].value)
                ShowServerMenu()
            end,
        }
    end

    lib.registerContext({
        id = 'qbx_adminmenu_time_menu',
        title = locale('server_options.label2'),
        menu = 'qbx_adminmenu_server_menu',
        options = options,
    })
    lib.showContext('qbx_adminmenu_time_menu')
end

ShowServerMenu = function()
    lib.registerContext({
        id = 'qbx_adminmenu_server_menu',
        title = locale('title.server_menu'),
        menu = 'qbx_adminmenu_main_menu',
        options = {
            { title = locale('server_options.label1'), description = locale('server_options.desc1'), icon = 'fas fa-cloud', arrow = true, onSelect = weatherMenu },
            { title = locale('server_options.label2'), description = locale('server_options.desc2'), icon = 'fas fa-clock', arrow = true, onSelect = timeMenu },
            { title = locale('server_options.label3'), description = locale('server_options.desc3'), icon = 'fas fa-walkie-talkie', onSelect = function()
                local dialog = lib.inputDialog(locale('server_options.label3'), {
                    { type = 'number', label = locale('server_options.input3label'), min = 0, max = 1000 },
                })
                if not dialog or not dialog[1] then
                    ShowServerMenu()
                    return
                end

                lib.callback('qbx_admin:callback:getradiolist', false, function(players, frequency)
                    local optionsList = {}
                    for i = 1, #players do
                        optionsList[i] = { title = ('%s | %s'):format(players[i].name, players[i].id) }
                    end

                    lib.registerContext({
                        id = 'frequency_list',
                        title = ('Frequência %s'):format(frequency),
                        menu = 'qbx_adminmenu_server_menu',
                        options = optionsList,
                    })
                    lib.showContext('frequency_list')
                end, dialog[1])
            end },
            { title = locale('server_options.label4'), description = locale('server_options.desc4'), icon = 'fas fa-box-open', onSelect = function()
                local dialog = lib.inputDialog(locale('server_options.label4'), { locale('server_options.input4label') })
                if not dialog or not dialog[1] then
                    ShowServerMenu()
                    return
                end

                TriggerServerEvent('inventory:server:OpenInventory', 'stash', dialog[1])
                TriggerEvent('inventory:client:SetCurrentStash', dialog[1])
            end },
        },
    })
    lib.showContext('qbx_adminmenu_server_menu')
end
