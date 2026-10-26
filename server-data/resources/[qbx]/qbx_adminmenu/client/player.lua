-- Servidor: this whole tree - the players list, a player's own detail screen, and its three
-- submenus (Geral/Administração/Extra) - used to be `lib.registerMenu` (the vertical list
-- component ox_lib's own monochrome reskin never touched). Converted to `lib.registerContext`
-- throughout, same as every other file in this resource - see main.lua's own note for why.
--
-- Every mutation (kill, ban, set food, change job, ...) reopens the screen it was fired from
-- afterward instead of closing - the request was that acting on a player should never kick the
-- admin back out, since doing several things to the same player in one visit is the normal case.
-- ESC or the header's own close button are still the only real exits.
local selectedPlayer

-- Servidor: the real job/gang definitions, so the two fields that set them can be PICKED from a
-- list of proper labels instead of typed as internal keys - see `groupRow` below. Fetched once at
-- load rather than per menu open; both are static config in `qbx_core/shared/`.
local Jobs = exports.qbx_core:GetJobs()
local Gangs = exports.qbx_core:GetGangs()

local showPlayerMenu
local showPlayerGeneralMenu
local showPlayerAdministrationMenu
local showPlayerExtraMenu

function GeneratePlayersMenu()
    local players = lib.callback.await('qbx_admin:server:getPlayers', false)
    if not players then
        ShowMainMenu()
        return
    end

    local options = {}
    for i = 1, #players do
        local player = players[i]
        options[i] = {
            title = ('ID: %s | Nome: %s'):format(player.id, player.name),
            description = ('CID: %s'):format(player.cid),
            icon = 'fas fa-user',
            arrow = true,
            onSelect = function() showPlayerMenu(player.id) end,
        }
    end

    lib.registerContext({
        id = 'qbx_adminmenu_players_menu',
        title = locale('title.players_menu'),
        menu = 'qbx_adminmenu_main_menu',
        options = options,
    })
    lib.showContext('qbx_adminmenu_players_menu')
end

showPlayerMenu = function(playerId)
    local player = lib.callback.await('qbx_admin:server:getPlayer', false, playerId)
    if not player then
        GeneratePlayersMenu()
        return
    end

    selectedPlayer = player

    --- One editable field row: shows the current value, opens `dialogRows` on click, sends
    --- `field`/the dialog result to the server exactly as `qbx_admin:server:changePlayerData`
    --- already expected it (the whole `dialog` array, never unwrapped - that shape is this
    --- event's own contract, unrelated to this menu's own rewrite).
    ---@param title string
    ---@param field string
    ---@param dialogTitle string
    ---@param dialogRows table
    local function editableRow(title, field, dialogTitle, dialogRows)
        return {
            title = title,
            icon = 'fas fa-pen',
            onSelect = function()
                local dialog = lib.inputDialog(dialogTitle, dialogRows)
                if dialog then
                    TriggerServerEvent('qbx_admin:server:changePlayerData', field, selectedPlayer, dialog)
                end
                showPlayerMenu(playerId)
            end,
        }
    end

    --- A job/gang row that is PICKED rather than typed: group list -> grade list -> done.
    ---
    --- `editableRow` above is a free-text `lib.inputDialog`, which for these two fields meant
    --- typing the internal lowercase key (`ballas`, `lostmc`, `bcso`...) and a bare grade number
    --- from memory - keys a player never sees anywhere in the UI, and a silent no-op when
    --- mistyped. Same "I have to type a command instead of clicking" complaint that turned the
    --- item and vehicle screens into pickers (ADR-118), applied to the last two fields that still
    --- had it. Both lists get ox_lib's own search box automatically once past 8 entries.
    ---
    --- Sends the exact same `{ name, grade }` array to the same `qbx_admin:server:changePlayerData`
    --- event, so the server contract is untouched.
    ---@param title string
    ---@param field 'job'|'gang'
    ---@param groups table<string, {label: string, grades: table<number, {name: string}>}>
    ---@param pickTitle string
    local function groupRow(title, field, groups, pickTitle)
        return {
            title = title,
            icon = 'fas fa-pen',
            arrow = true,
            onSelect = function()
                local names = {}
                for name in pairs(groups) do names[#names + 1] = name end
                table.sort(names, function(a, b) return groups[a].label < groups[b].label end)

                local options = {}
                for i = 1, #names do
                    local name = names[i]
                    local group = groups[name]

                    options[i] = {
                        title = group.label,
                        description = name,
                        icon = field == 'gang' and 'fas fa-users' or 'fas fa-briefcase',
                        arrow = true,
                        onSelect = function()
                            local levels = {}
                            for level in pairs(group.grades) do levels[#levels + 1] = level end
                            table.sort(levels)

                            local gradeOptions = {}
                            for j = 1, #levels do
                                local level = levels[j]

                                gradeOptions[j] = {
                                    title = group.grades[level].name,
                                    description = ('Grau %s'):format(level),
                                    icon = 'fas fa-ranking-star',
                                    onSelect = function()
                                        TriggerServerEvent('qbx_admin:server:changePlayerData', field,
                                            selectedPlayer, { name, level })
                                        showPlayerMenu(playerId)
                                    end,
                                }
                            end

                            lib.registerContext({
                                id = ('qbx_adminmenu_%s_grade_%s'):format(field, name),
                                title = group.label,
                                menu = ('qbx_adminmenu_%s_pick'):format(field),
                                options = gradeOptions,
                            })
                            lib.showContext(('qbx_adminmenu_%s_grade_%s'):format(field, name))
                        end,
                    }
                end

                lib.registerContext({
                    id = ('qbx_adminmenu_%s_pick'):format(field),
                    title = pickTitle,
                    menu = ('qbx_adminmenu_player_menu_%s'):format(playerId),
                    options = options,
                })
                lib.showContext(('qbx_adminmenu_%s_pick'):format(field))
            end,
        }
    end

    --- A copy-to-clipboard row for an identifier - reopens the same screen after, matching every
    --- other row here.
    ---@param label string
    ---@param value string
    ---@param prefix string
    local function copyRow(label, value, prefix)
        return {
            title = value,
            description = label,
            icon = 'fas fa-copy',
            onSelect = function()
                lib.setClipboard((value:gsub(prefix, '')))
                showPlayerMenu(playerId)
            end,
        }
    end

    lib.registerContext({
        id = ('qbx_adminmenu_player_menu_%s'):format(playerId),
        title = player.name,
        menu = 'qbx_adminmenu_players_menu',
        options = {
            { title = locale('player_options.label1'), description = locale('player_options.desc1'), icon = 'fas fa-wrench', arrow = true, onSelect = showPlayerGeneralMenu },
            { title = locale('player_options.label2'), description = locale('player_options.desc2'), icon = 'fas fa-file-invoice', arrow = true, onSelect = showPlayerAdministrationMenu },
            { title = locale('player_options.label3'), description = locale('player_options.desc3'), icon = 'fas fa-gamepad', arrow = true, onSelect = showPlayerExtraMenu },
            editableRow(('Nome: %s'):format(player.name), 'name', 'Alterar Nome', { 'Nome', 'Sobrenome' }),
            editableRow(('Fome: %s'):format(player.food), 'food', 'Fome', { { type = 'number', label = 'Porcentagem', min = 0, max = 100 } }),
            editableRow(('Sede: %s'):format(player.water), 'thirst', 'Sede', { { type = 'number', label = 'Porcentagem', min = 0, max = 100 } }),
            editableRow(('Estresse: %s'):format(player.stress), 'stress', 'Estresse', { { type = 'number', label = 'Porcentagem', min = 0, max = 100 } }),
            editableRow(('Colete: %s'):format(player.armor), 'armor', 'Colete', { { type = 'number', label = 'Porcentagem', min = 0, max = 100 } }),
            editableRow(('Telefone: %s'):format(player.phone), 'phone', 'Telefone', { 'Número' }),
            editableRow(('Reputação de Crafting: %s'):format(player.craftingrep), 'crafting', 'Reputação de Crafting', { { type = 'number', label = 'Reputação' } }),
            editableRow(('Reputação de Traficante: %s'):format(player.dealerrep), 'dealer', 'Reputação de Traficante', { { type = 'number', label = 'Reputação' } }),
            editableRow(('Dinheiro: %s'):format(lib.math.groupdigits(player.cash)), 'cash', 'Dinheiro em Espécie', { { type = 'number', label = 'Valor' } }),
            editableRow(('Banco: %s'):format(lib.math.groupdigits(player.bank)), 'bank', 'Conta Bancária', { { type = 'number', label = 'Valor' } }),
            groupRow(('Emprego: %s'):format(player.job), 'job', Jobs, 'Escolher Emprego'),
            groupRow(('Gangue: %s'):format(player.gang), 'gang', Gangs, 'Escolher Gangue'),
            editableRow(('Rádio: %s'):format(Player(playerId).state.radioChannel), 'radio', 'Frequência de Rádio', { { type = 'number', label = 'Frequência' } }),
            copyRow('Licença', player.license, 'license:'),
            copyRow('Discord', player.discord, 'discord:'),
            copyRow('Steam', player.steam, 'steam:'),
        },
    })
    lib.showContext(('qbx_adminmenu_player_menu_%s'):format(playerId))
end

showPlayerGeneralMenu = function()
    lib.registerContext({
        id = 'qbx_adminmenu_player_general_menu',
        title = locale('player_options.label1'),
        menu = ('qbx_adminmenu_player_menu_%s'):format(selectedPlayer.id),
        options = {
            { title = locale('player_options.general.labelkill'), description = locale('player_options.general.desckill'), icon = 'fas fa-skull', onSelect = function()
                TriggerServerEvent('qbx_admin:server:playerOptionsGeneral', 1, selectedPlayer)
                showPlayerGeneralMenu()
            end },
            { title = locale('player_options.general.labelrevive'), description = locale('player_options.general.descrevive'), icon = 'fas fa-cross', onSelect = function()
                TriggerServerEvent('qbx_admin:server:playerOptionsGeneral', 2, selectedPlayer)
                showPlayerGeneralMenu()
            end },
            { title = locale('player_options.general.labelfreeze'), description = locale('player_options.general.descfreeze'), icon = 'fas fa-icicles', onSelect = function()
                TriggerServerEvent('qbx_admin:server:playerOptionsGeneral', 3, selectedPlayer)
                showPlayerGeneralMenu()
            end },
            { title = locale('player_options.general.labelgoto'), description = locale('player_options.general.descgoto'), icon = 'fas fa-arrow-right-long', onSelect = function()
                TriggerServerEvent('qbx_admin:server:playerOptionsGeneral', 4, selectedPlayer)
                showPlayerGeneralMenu()
            end },
            { title = locale('player_options.general.labelbring'), description = locale('player_options.general.descbring'), icon = 'fas fa-arrow-left-long', onSelect = function()
                TriggerServerEvent('qbx_admin:server:playerOptionsGeneral', 5, selectedPlayer)
                showPlayerGeneralMenu()
            end },
            { title = locale('player_options.general.labelsitinveh'), description = locale('player_options.general.descsitinveh'), icon = 'fas fa-chair', onSelect = function()
                TriggerServerEvent('qbx_admin:server:playerOptionsGeneral', 6, selectedPlayer)
                showPlayerGeneralMenu()
            end },
            { title = locale('player_options.general.labelrouting'), description = locale('player_options.general.descrouting'), icon = 'fas fa-bucket', onSelect = function()
                local dialog = lib.inputDialog(selectedPlayer.name, {
                    { type = 'number', label = locale('player_options.general.labelrouting'), placeholder = '25' },
                })
                if dialog and dialog[1] then
                    TriggerServerEvent('qbx_admin:server:playerOptionsGeneral', 7, selectedPlayer, dialog[1])
                end
                showPlayerGeneralMenu()
            end },
        },
    })
    lib.showContext('qbx_adminmenu_player_general_menu')
end

showPlayerAdministrationMenu = function()
    local function permissionMenu()
        local permissions = {
            { key = 'remove', label = locale('player_options.administration.permvalue1') },
            { key = 'mod', label = locale('player_options.administration.permvalue2') },
            { key = 'admin', label = locale('player_options.administration.permvalue3') },
            { key = 'god', label = locale('player_options.administration.permvalue4') },
        }

        local options = {}
        for i = 1, #permissions do
            options[i] = {
                title = permissions[i].label,
                icon = 'fas fa-user-shield',
                onSelect = function()
                    TriggerServerEvent('qbx_admin:server:playerAdministration', 3, selectedPlayer, permissions[i].key)
                    showPlayerAdministrationMenu()
                end,
            }
        end

        lib.registerContext({
            id = 'qbx_adminmenu_permission_menu',
            title = locale('player_options.administration.labelperm'),
            menu = 'qbx_adminmenu_player_administration_menu',
            options = options,
        })
        lib.showContext('qbx_adminmenu_permission_menu')
    end

    lib.registerContext({
        id = 'qbx_adminmenu_player_administration_menu',
        title = locale('player_options.label2'),
        menu = ('qbx_adminmenu_player_menu_%s'):format(selectedPlayer.id),
        options = {
            { title = locale('player_options.administration.labelkick'), description = locale('player_options.administration.desckick'), icon = 'fas fa-plane-departure', onSelect = function()
                local dialog = lib.inputDialog(selectedPlayer.name, { locale('player_options.administration.inputkick') })
                if dialog and dialog[1] then
                    TriggerServerEvent('qbx_admin:server:playerAdministration', 1, selectedPlayer, dialog[1])
                end
                showPlayerAdministrationMenu()
            end },
            { title = locale('player_options.administration.labelban'), description = locale('player_options.administration.descban'), icon = 'fas fa-gavel', onSelect = function()
                local dialog = lib.inputDialog(selectedPlayer.name, {
                    { type = 'input', label = locale('player_options.administration.inputkick'), placeholder = 'VDM' },
                    { type = 'number', label = locale('player_options.administration.input1ban') },
                    { type = 'number', label = locale('player_options.administration.input2ban') },
                    { type = 'number', label = locale('player_options.administration.input3ban') },
                })
                if dialog and dialog[1] then
                    TriggerServerEvent('qbx_admin:server:playerAdministration', 2, selectedPlayer, dialog)
                end
                showPlayerAdministrationMenu()
            end },
            { title = locale('player_options.administration.labelperm'), description = locale('player_options.administration.descperm'), icon = 'fas fa-book-bookmark', arrow = true, onSelect = permissionMenu },
        },
    })
    lib.showContext('qbx_adminmenu_player_administration_menu')
end

-- Servidor: the item picker itself - real name and icon per row (`icon` renders inline,
-- `ContextButton.tsx` only shows `image` on hover), live search handled entirely by
-- `ContextMenu.tsx`'s own search box now (any list past 8 rows gets one automatically) - no
-- Lua-side filter dialog needed any more, this just builds and caches the full list once.
local imagePath = GetConvar('inventory:imagepath', 'nui://ox_inventory/web/images')

---@param item table
---@return string
local function resolveItemImage(item)
    return (item.client and item.client.image) or ('%s/%s.png'):format(imagePath, item.name)
end

local giveItemOptions

local function buildGiveItemOptions()
    if giveItemOptions then return giveItemOptions end

    local items = exports.ox_inventory:Items()
    local sorted = {}
    for _, item in pairs(items) do
        sorted[#sorted + 1] = item
    end

    table.sort(sorted, function(a, b) return (a.label or a.name) < (b.label or b.name) end)

    giveItemOptions = {}
    for i = 1, #sorted do
        local item = sorted[i]
        local icon = resolveItemImage(item)

        giveItemOptions[i] = {
            title = item.label or item.name,
            description = item.name,
            icon = icon,
            image = icon,
            onSelect = function()
                local dialog = lib.inputDialog(item.label or item.name, {
                    { type = 'number', label = 'Quantidade', icon = 'hashtag', default = 1, min = 1, required = true },
                })

                if dialog and dialog[1] then
                    ExecuteCommand('giveitem ' .. selectedPlayer.id .. ' ' .. item.name .. ' ' .. dialog[1])
                end

                GenerateGiveItemMenu()
            end,
        }
    end

    return giveItemOptions
end

function GenerateGiveItemMenu()
    lib.registerContext({
        id = 'qbx_adminmenu_give_item_menu',
        title = 'Dar Item',
        description = ('%s itens'):format(#buildGiveItemOptions()),
        menu = 'qbx_adminmenu_player_extra_menu',
        options = buildGiveItemOptions(),
    })
    lib.showContext('qbx_adminmenu_give_item_menu')
end

showPlayerExtraMenu = function()
    lib.registerContext({
        id = 'qbx_adminmenu_player_extra_menu',
        title = locale('player_options.label3'),
        menu = ('qbx_adminmenu_player_menu_%s'):format(selectedPlayer.id),
        options = {
            { title = 'Abrir Inventário', icon = 'fas fa-box-open', onSelect = function()
                exports.ox_inventory:openInventory('player', selectedPlayer.id)
            end },
            { title = 'Menu de Roupas', icon = 'fas fa-shirt', onSelect = function()
                local succeeded = lib.callback.await('qbx_admin:server:clothingMenu', false, selectedPlayer.id)
                if not succeeded then showPlayerExtraMenu() end
            end },
            { title = 'Dar Item', icon = 'fas fa-gift', arrow = true, onSelect = GenerateGiveItemMenu },
            { title = 'Mutar', icon = 'fas fa-microphone-slash', onSelect = function()
                exports['pma-voice']:toggleMutePlayer(selectedPlayer.id)
                showPlayerExtraMenu()
            end },
        },
    })
    lib.showContext('qbx_adminmenu_player_extra_menu')
end

RegisterNetEvent('qbx_admin:client:killPlayer', function()
    SetEntityHealth(cache.ped, 0)
end)
