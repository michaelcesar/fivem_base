assert(lib.checkDependency('qbx_core', '1.18.1'), 'qbx_core v1.18.1 or higher is required')
assert(lib.checkDependency('qbx_vehicles', '1.2.0'), 'qbx_vehicles v1.2.0 or higher is required')
local Inventory = require 'modules.inventory.server'
local QBX = exports.qbx_core

AddEventHandler('qbx_core:server:playerLoggedOut', server.playerDropped)

AddEventHandler('qbx_core:server:onGroupUpdate', function(source, groupName, groupGrade)
    local inventory = Inventory(source)
    if not inventory then return end
    inventory.player.groups[groupName] = not groupGrade and nil or groupGrade
end)

local function setupPlayer(playerData)
    playerData.identifier = playerData.citizenid
    playerData.name = ('%s %s'):format(playerData.charinfo.firstname, playerData.charinfo.lastname)
    server.setPlayerInventory(playerData)

    local accounts = Inventory.GetAccountItemCounts(playerData.source)
    if not accounts then return end
    for account in pairs(accounts) do
        local playerAccount = account == 'money' and 'cash' or account
        Inventory.SetItem(playerData.source, account, playerData.money[playerAccount])
    end
end

AddStateBagChangeHandler('loadInventory', nil, function(bagName, _, value)
    if not value then return end
    local plySrc = GetPlayerFromStateBagName(bagName)
    if not plySrc then return end
    setupPlayer(QBX:GetPlayer(plySrc).PlayerData)
end)

SetTimeout(500, function()
    local playersData = QBX:GetPlayersData()
    for i = 1, #playersData do setupPlayer(playersData[i]) end
end)

function server.UseItem(source, itemName, data)
    local cb = QBX:CanUseItem(itemName)
    return cb and cb(source, data)
end

---@diagnostic disable-next-line: duplicate-set-field
function server.setPlayerData(player)
    local groups = QBX:GetGroups(player.source)
    return {
        source = player.source,
        name = ('%s %s'):format(player.charinfo.firstname, player.charinfo.lastname),
        groups = groups,
        sex = player.charinfo.gender,
        dateofbirth = player.charinfo.birthdate,
    }
end

---@diagnostic disable-next-line: duplicate-set-field
function server.syncInventory(inv)
    local accounts = Inventory.GetAccountItemCounts(inv)

    if not accounts then return end

    local player = QBX:GetPlayer(inv.id)
    player.Functions.SetPlayerData('items', inv.items)

    for account, amount in pairs(accounts) do
        account = account == 'money' and 'cash' or account
        if player.Functions.GetMoney(account) ~= amount then
            player.Functions.SetMoney(account, amount, ('Sync %s with inventory'):format(account))
        end
    end
end

-- Servidor: the weapon class licences here are the same metadata.licences keys
-- srv_shootingrange grants for completing each artillery course, and the same keys
-- srv_crosshair checks to unlock aiming. Buying any of them additionally requires the
-- 'weaponlicense' item (bought at city hall) - the base legal permit to be in the gun
-- trade at all. Buying the base pistol tier only needs that item; every class beyond it
-- also needs its own course done, so the shop can't sell a weapon nobody is trained for.
local WEAPON_CLASS_LICENCES = {
    weapon = true,
    weaponrifle = true,
    weaponshotgun = true,
    weaponexpert = true,
}

---@diagnostic disable-next-line: duplicate-set-field
function server.hasLicense(inv, license)
    if WEAPON_CLASS_LICENCES[license] then
        if (Inventory.Search(inv, 'count', 'weaponlicense') or 0) == 0 then return false end
        if license == 'weapon' then return true end

        local player = QBX:GetPlayer(inv.id)
        return player and player.PlayerData.metadata.licences[license] == true
    end

    local player = QBX:GetPlayer(inv.id)
    return player and player.PlayerData.metadata.licences[license]
end

---@diagnostic disable-next-line: duplicate-set-field
function server.buyLicense(inv, license)
    local player = QBX:GetPlayer(inv.id)
    if not player then return end

    if player.PlayerData.metadata.licences[license.name] then
        return false, 'already_have'
    elseif Inventory.GetItem(inv, 'money', false, true) < license.price then
        return false, 'can_not_afford'
    end

    Inventory.RemoveItem(inv, 'money', license.price)
    player.PlayerData.metadata.licences[license.name] = true
    player.Functions.SetMetaData('licences', player.PlayerData.metadata.licences)

    return true, 'have_purchased'
end

---@diagnostic disable-next-line: duplicate-set-field
function server.isPlayerBoss(playerId, group, grade)
    return QBX:IsGradeBoss(group, grade)
end

---@param entityId number
---@return number | string
---@diagnostic disable-next-line: duplicate-set-field
function server.getOwnedVehicleId(entityId)
    return Entity(entityId).state.vehicleid or exports.qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(entityId))
end
