local hasPhone = false

local function doPhoneCheck(isUnload, totalCount)
    hasPhone = false

    if isUnload then
        exports.npwd:setPhoneDisabled(true)
        return
    end

    if totalCount then
        hasPhone = totalCount > 0
        exports.npwd:setPhoneDisabled(not hasPhone)
        return
    end

    local items = exports.ox_inventory:Search('count', PhoneList)

    if type(items) == 'number' then
        hasPhone = items > 0
    else
        for _, v in pairs(items) do
            if v > 0 then
                hasPhone = true
                break
            end
        end
    end

    exports.npwd:setPhoneDisabled(not hasPhone)
end

exports("HasPhone", function()
    return hasPhone
end)

-- Handles state right when the player selects their character and location.
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    doPhoneCheck()
end)

-- Resets state on logout, in case of character change.
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    doPhoneCheck(true)
    TriggerServerEvent('qbx_npwd:server:UnloadPlayer')
end)

AddEventHandler('ox_inventory:itemCount', function(itemName, totalCount)
    for i = 1, #PhoneList do
        if PhoneList[i] == itemName then
            doPhoneCheck(false, totalCount)
            break
        end
    end
end)

-- Handles state if resource is restarted live.
AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource or GetResourceState('npwd') ~= 'started' then return end

    doPhoneCheck()
end)

-- Allows use of phone as an item.
RegisterNetEvent('qbx_npwd:client:setPhoneVisible', function(isPhoneVisible)
    exports.npwd:setPhoneVisible(isPhoneVisible)
end)

-- npwd's own toggle command (bound to the same config.json key) silently no-ops when the phone
-- item is missing. Bound to the exact same key, read from npwd's own config so it can never
-- drift out of sync, so the player gets told why instead of nothing happening.
local npwdConfig = assert(json.decode(LoadResourceFile('npwd', 'config.json')), 'Could not load npwd/config.json')
local toggleKey = npwdConfig.general.toggleKey

RegisterKeyMapping('phone_missing_check', 'Servidor: aviso de celular ausente', 'keyboard', toggleKey)
RegisterCommand('phone_missing_check', function()
    if not hasPhone and not IsPauseMenuActive() then
        lib.notify({ description = 'Você não tem um celular.', type = 'error' })
    end
end, false)