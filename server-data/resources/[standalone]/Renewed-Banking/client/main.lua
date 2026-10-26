local isVisible = false
PlayerPed = cache.ped

lib.onCache('ped', function(newPed)
	PlayerPed = newPed
end)

local function nuiHandler(val)
    isVisible = val
    SetNuiFocus(val, val)
end

--- Servidor: `openAccount` is the id the UI should LAND on, so picking "Conta - The Lost MC" at the
--- teller opens that account rather than dropping you on the personal one to find the right tab.
---
--- There is no NUI action for this - the compiled bundle handles exactly two, `setLoading` and
--- `setVisible`. But its `setVisible` handler sets the active account from the data it is given:
---
---     dt("setVisible", t => { lt.set(t.accounts), ct.update(() => t.accounts[0].id), ... })
---
--- It takes `accounts[0]`. So the selection is made by ORDERING the array, not by asking the UI -
--- the requested account is moved to the front and everything else keeps its order. No UI rebuild,
--- and nothing here depends on the bundle beyond that documented behaviour.
---
--- This reorders a local copy for display only; the server decides which accounts are in the list
--- at all, and a gang account is only ever in it for a boss (`IsGangAuth`, `server/framework.lua`).
---@param isAtm boolean
---@param openAccount string?
local function openBankUI(isAtm, openAccount)
    SendNUIMessage({action = 'setLoading', status = true})
    nuiHandler(true)
    lib.callback('renewed-banking:server:initalizeBanking', false, function(accounts)
        if not accounts then
            nuiHandler(false)
            SendNUIMessage({action = 'setLoading', status = false})
            lib.notify({title = locale('bank_name'), description = locale('loading_failed'), type = 'error'})
            return
        end

        if openAccount then
            for i = 1, #accounts do
                if accounts[i].id == openAccount then
                    table.insert(accounts, 1, table.remove(accounts, i))
                    break
                end
            end
        end

        SendNUIMessage({
            action = 'setVisible',
            status = isVisible,
            accounts = accounts,
            loading = false,
            atm = isAtm
        })
    end)
end

-- Servidor: opens immediately on [E] - no ATM-typing animation, no progress bar delay first.
-- The `setLoading` overlay inside openBankUI already covers the real (near-instant) wait for
-- the server's account data, so there's nothing left to fake a delay for.
RegisterNetEvent('Renewed-Banking:client:openBankUI', function(data)
    openBankUI(data.atm, data.account)
end)

RegisterNUICallback('closeInterface', function(_, cb)
    nuiHandler(false)
    cb('ok')
end)

RegisterCommand('closeBankUI', function() nuiHandler(false) end, false)

local bankActions = {'deposit', 'withdraw', 'transfer'}
CreateThread(function ()
    for k=1, #bankActions do
        local action = bankActions[k]
        RegisterNUICallback(action, function(data, cb)
            local newTransaction = lib.callback.await('Renewed-Banking:server:'..action, false, data)
            if newTransaction then
                lib.notify({ title = locale('bank_name'), description = locale(action .. '_success', data.amount), type = 'success' })
            end
            cb(newTransaction)
        end)
    end
end)

-- Servidor: ATMs are GTA's own world props scattered everywhere (not a fixed coord list),
-- so there's no fixed point to hang a lib.zones marker on. Instead this scans for the
-- nearest matching prop around the player every tick, the same way a fixed-point marker
-- would behave, without needing ox_target.
local atmModels = Config.atms
local ATM_SEARCH_RADIUS = 8.0
local ATM_PROMPT_DISTANCE = 1.2

CreateThread(function()
    local hasTextUi = false

    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(cache.ped)
        local closestCoords, closestDistance = nil, ATM_SEARCH_RADIUS

        for i = 1, #atmModels do
            local object = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, ATM_SEARCH_RADIUS, atmModels[i], false, false, false)

            if object ~= 0 then
                local objectCoords = GetEntityCoords(object)
                local distance = #(playerCoords - objectCoords)

                if distance < closestDistance then
                    closestCoords, closestDistance = objectCoords, distance
                end
            end
        end

        if closestCoords then
            sleep = 0
            DrawMarker(0, closestCoords.x, closestCoords.y, closestCoords.z - 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 20, 246, 12, 255, false, false, 0, false, nil, nil, false)

            if closestDistance < ATM_PROMPT_DISTANCE then
                if not hasTextUi then
                    hasTextUi = true
                    lib.showTextUI(('[E] %s.'):format(locale('view_bank')))
                end

                if IsControlJustPressed(0, 38) then
                    lib.hideTextUI()
                    hasTextUi = false
                    TriggerEvent('Renewed-Banking:client:openBankUI', { atm = true })
                end
            elseif hasTextUi then
                hasTextUi = false
                lib.hideTextUI()
            end
        elseif hasTextUi then
            hasTextUi = false
            lib.hideTextUI()
        end

        Wait(sleep)
    end
end)

local pedSpawned = false
local blips = {}
function CreatePeds()
    if pedSpawned then return end
    for k = 1, #Config.peds do
        local coords = Config.peds[k].coords
        local createAccounts = Config.peds[k].createAccounts
        local pedPoint = lib.points.new({
            coords = coords,
            distance = 300,
            model = joaat(Config.peds[k].model),
            heading = coords.w,
            ped = nil,
        })

        -- Servidor: same two-zone interaction pattern as qbx_cityhall/qbx_garages/shops -
        -- an outer sphere draws the ground marker from a normal approach distance, an
        -- inner zone (right at the teller) handles the [E] prompt and the action.
        function pedPoint:onEnter()
            lib.requestModel(self.model, 10000)

            self.ped = CreatePed(0, self.model, self.coords.x, self.coords.y, self.coords.z-1, self.heading, false, false)
            SetEntityHeading(self.ped, self.heading)
            SetModelAsNoLongerNeeded(self.model)

            TaskStartScenarioInPlace(self.ped, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
            FreezeEntityPosition(self.ped, true)
            SetEntityInvincible(self.ped, true)
            SetBlockingOfNonTemporaryEvents(self.ped, true)

            self.markerZone = lib.zones.sphere({
                coords = self.coords.xyz,
                radius = 8,
                debug = false,
                onEnter = function()
                    self.promptZone = lib.zones.sphere({
                        coords = self.coords.xyz,
                        radius = 2,
                        debug = false,
                        onEnter = function()
                            lib.showTextUI(('[E] %s.'):format(locale('view_bank')))
                        end,
                        onExit = function()
                            lib.hideTextUI()
                        end,
                        inside = function()
                            if not IsControlJustPressed(0, 38) then return end

                            lib.hideTextUI()

                            -- Servidor: the teller menu now names which account you are walking up
                            -- to, the same way a shop names what it sells, rather than opening
                            -- straight into a screen and leaving you to find the right tab.
                            --
                            -- The gang row only appears for a gang BOSS - `qbx_core`'s own
                            -- `isboss` flag, via `srv_lib`. That is a UI fast path and nothing
                            -- more: this resource's own server-side `IsGangAuth` already decides
                            -- who may actually touch a gang account, by reading `bankAuth` on the
                            -- same grade (`shared/gangs.lua` sets both only on Boss).
                            --
                            -- Both rows open the same UI, but on the account that was picked -
                            -- see `openBankUI`'s own note for how, since the bundle has no NUI
                            -- action for selecting one.
                            local boss = exports.srv_lib:GangBossLabel()
                            local options = {
                                {
                                    title = 'Conta Pessoal',
                                    icon = 'user',
                                    onSelect = function()
                                        TriggerEvent('Renewed-Banking:client:openBankUI', { atm = false })
                                    end,
                                },
                            }

                            if boss then
                                options[#options + 1] = {
                                    title = ('Conta - %s'):format(boss.label),
                                    description = 'Você é o chefe desta organização.',
                                    icon = 'users',
                                    onSelect = function()
                                        TriggerEvent('Renewed-Banking:client:openBankUI',
                                            { atm = false, account = boss.name })
                                    end,
                                }
                            end

                            if createAccounts then
                                options[#options + 1] = {
                                    title = locale('manage_bank'),
                                    icon = 'money-check',
                                    onSelect = function()
                                        TriggerEvent('Renewed-Banking:client:accountManagmentMenu')
                                    end,
                                }
                            end

                            lib.registerContext({
                                id = 'renewed_banking_menu',
                                title = locale('bank_name'),
                                options = options,
                            })
                            lib.showContext('renewed_banking_menu')
                        end,
                    })
                end,
                onExit = function()
                    if self.promptZone then
                        self.promptZone:remove()
                        self.promptZone = nil
                    end
                end,
                inside = function()
                    DrawMarker(0, self.coords.x, self.coords.y, self.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 20, 246, 12, 255, false, false, 0, false, nil, nil, false)
                end,
            })
        end

        function pedPoint:onExit()
            if self.markerZone then
                self.markerZone:remove()
                self.markerZone = nil
            end
            if self.promptZone then
                self.promptZone:remove()
                self.promptZone = nil
            end
            if DoesEntityExist(self.ped) then
                DeletePed(self.ped)
            end
            self.ped = nil
        end

        blips[k] = AddBlipForCoord(coords.x, coords.y, coords.z-1)
        SetBlipSprite(blips[k], 108)
        SetBlipDisplay(blips[k], 4)
        SetBlipScale  (blips[k], 0.80)
        SetBlipColour (blips[k], 2)
        SetBlipAsShortRange(blips[k], true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Fleeca')
        EndTextCommandSetBlipName(blips[k])
    end
    pedSpawned = true
end

function DeletePeds()
    if not pedSpawned then return end
    local points = lib.points.getAllPoints()
    for i = 1, #points do
        if DoesEntityExist(points[i].ped) then
            DeletePed(points[i].ped)
        end
        if points[i].markerZone then points[i].markerZone:remove() end
        if points[i].promptZone then points[i].promptZone:remove() end
        points[i]:remove()
    end
    for i = 1, #blips do
        RemoveBlip(blips[i])
    end
    pedSpawned = false
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    DeletePeds()
end)

-- Servidor: use the server's standard success/error badge (lib.notify) instead of a
-- custom in-NUI toast, same as every other notification this resource already sends.
RegisterNetEvent('Renewed-Banking:client:sendNotification', function(msg)
    if not msg then return end
    lib.notify({ title = locale('bank_name'), description = msg, type = 'error' })
end)

-- Servidor: lets bank.js route its own client-side validation messages (e.g. "informe um
-- valor válido") through the same standard badge instead of a custom toast.
RegisterNUICallback('notify', function(data, cb)
    lib.notify({
        title = locale('bank_name'),
        description = data.description,
        type = data.type or 'inform',
    })
    cb('ok')
end)

RegisterNetEvent('Renewed-Banking:client:viewAccountsMenu', function()
    TriggerServerEvent('Renewed-Banking:server:getPlayerAccounts')
end)
