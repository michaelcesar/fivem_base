-- Servidor: completing an artillery course sets its licence in metadata.licences.
-- This reuses qbx_core's existing licence table instead of inventing a new storage
-- system. These licences mean "completed the course" (which unlocks the crosshair for
-- that weapon class), not "bought the weapon licence" - that's the 'weaponlicense' item.

local config = CourseConfig

---@param player table
---@return table
local function getLicences(player)
    return player.PlayerData.metadata.licences
end

---@param player table
---@param course table
---@return boolean
local function canStart(player, course)
    local licences = getLicences(player)

    if licences[course.licence] then return false end -- already certified
    if course.requires and not licences[course.requires] then return false end

    return true
end

---@param source number
---@param course table
---@return boolean
local function isAtCourse(source, course)
    local coords = GetEntityCoords(GetPlayerPed(source))
    return #(coords - config.coords) <= config.maxDistance
end

--- Charges a course attempt, taking cash first and falling back to the bank - the higher
--- tiers cost more than a player would sensibly carry on hand. The fee buys the attempt,
--- not the certificate: failing the course does not refund it.
---@param player table
---@param price number
---@return boolean paid
local function chargeAttempt(player, price)
    if not price or price <= 0 then return true end

    local money = player.PlayerData.money

    if money.cash + money.bank < price then return false end

    return player.Functions.RemoveMoney('cash', price, 'artillery-course')
        or player.Functions.RemoveMoney('bank', price, 'artillery-course')
end

--- Course weapons are tagged with this metadata so they can always be identified and
--- taken back. Without it, disconnecting mid-course would be a way to farm free weapons.
local TRAINING_TAG = { training = true }

--- How long after a course's own time limit the server reclaims the weapon on its own,
--- in case the client never reports back (crash, disconnect, tampering).
local RECLAIM_GRACE = 20000

--- Players with a course in progress, so a second one can't be started on top of it
--- (which would spawn a duplicate set of targets and hand out a second weapon).
---@type table<number, boolean>
local activeCourse = {}

AddEventHandler('playerDropped', function()
    activeCourse[source] = nil
end)

--- Takes back every training weapon a player is holding, whatever slot it ended up in.
---
--- The removal passes no metadata filter, because RemoveItem matches metadata strictly
--- (the entire table, serial and ammo included) and would never match a partial tag. That
--- makes the slot number the only thing pinning down which item goes, so each slot is
--- re-read and re-checked immediately before removal: if the player has since moved things
--- around, we must not delete whatever legitimately took that slot.
---@param source number
local function reclaimTrainingWeapons(source)
    local reclaimed = 0

    for i = 1, #config.courses do
        local weapon = config.courses[i].weapon
        local slots = exports.ox_inventory:Search(source, 'slots', weapon, TRAINING_TAG)

        if slots then
            for j = 1, #slots do
                local slotId = slots[j].slot
                local current = exports.ox_inventory:GetSlot(source, slotId)

                if current and current.name == weapon and current.metadata?.training then
                    if exports.ox_inventory:RemoveItem(source, weapon, current.count, nil, slotId) then
                        reclaimed += 1
                    end
                end
            end
        end
    end

    if reclaimed > 0 then
        print(('[srv_shootingrange] %s arma(s) de treino recolhida(s) de %s'):format(reclaimed, GetPlayerName(source) or source))
    end
end

-- Gives the practice weapon as a real, tracked inventory item (auto-equipped
-- client-side) instead of a raw native weapon - keeps ox_inventory's weapon-mismatch
-- protection intact for everyone.
lib.callback.register('srv_shootingrange:server:startCourse', function(source, courseId)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    -- courseId comes from the client, so everything below is re-validated against it here.
    local course = config.getById(courseId)
    if not course then return end

    if activeCourse[source] then return end
    if not isAtCourse(source, course) then return end
    if not canStart(player, course) then return end

    local success, response = exports.ox_inventory:AddItem(source, course.weapon, 1, {
        durability = 100,
        ammo = course.ammo,
        training = true,
    })

    if not success then return end

    -- Charged only once the weapon is definitely in hand, so a failed hand-out can never
    -- take the player's money. If the charge itself fails, the weapon goes straight back.
    if not chargeAttempt(player, course.price) then
        reclaimTrainingWeapons(source)
        exports.qbx_core:Notify(source, 'Dinheiro insuficiente para pagar o curso.', 'error')

        return
    end

    activeCourse[source] = true

    -- The client asks for cleanup when the course ends, but never trust that it will:
    -- reclaim on a timer regardless of what the client does or doesn't send.
    SetTimeout(course.time + RECLAIM_GRACE, function()
        activeCourse[source] = nil

        if GetPlayerName(source) then reclaimTrainingWeapons(source) end
    end)

    -- Leaving the range ends the course and takes the weapon back. Checked here rather
    -- than on the client, since the whole point is that the player can't opt out of it.
    CreateThread(function()
        while activeCourse[source] do
            Wait(config.leashCheckInterval)

            if not activeCourse[source] then return end
            if not GetPlayerName(source) then return end

            local coords = GetEntityCoords(GetPlayerPed(source))

            if #(coords - config.coords) > config.leashDistance then
                activeCourse[source] = nil

                reclaimTrainingWeapons(source)
                TriggerClientEvent('srv_shootingrange:client:abort', source)

                return
            end
        end
    end)

    return response[1].slot
end)

--- Training weapons are only ever meant to exist inside the course. Reclaiming them only
--- searches the player's own inventory, so anything moved out of it - dropped on the
--- ground, stashed in a trunk, handed to a friend - would survive as a free weapon.
--- This blocks that at the source: a tagged item may be rearranged inside your own
--- inventory, but never leave it.
local function isTrainingSlot(slot)
    return type(slot) == 'table' and slot.metadata ~= nil and slot.metadata.training == true
end

CreateThread(function()
    local courseWeapons = {}

    for i = 1, #config.courses do
        courseWeapons[config.courses[i].weapon] = true
    end

    exports.ox_inventory:registerHook('swapItems', function(payload)
        if payload.fromInventory == payload.toInventory then return true end

        if isTrainingSlot(payload.fromSlot) or isTrainingSlot(payload.toSlot) then
            return false
        end

        return true
    end, {
        itemFilter = courseWeapons,
    })
end)

RegisterNetEvent('srv_shootingrange:server:cleanup', function()
    activeCourse[source] = nil

    reclaimTrainingWeapons(source)
end)

-- Last line of defence: a player who quit mid-course keeps the weapon in their saved
-- inventory, so strip any leftovers as soon as they load back in.
AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    local playerId = player.PlayerData.source

    -- Brief delay: ox_inventory may still be building the player's inventory at this point.
    SetTimeout(3000, function()
        if GetPlayerName(playerId) then reclaimTrainingWeapons(playerId) end
    end)
end)

--- Clears every course certificate for a player, so the courses can be re-tested without
--- editing the database by hand. Exposed for srv_tools' /resetcourses dev command;
--- the licence keys live here so the list can't drift out of sync with the config.
---@param source number
---@return boolean
local function resetCourses(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    local licences = getLicences(player)

    for i = 1, #config.courses do
        licences[config.courses[i].licence] = false
    end

    player.Functions.SetMetaData('licences', licences)

    return true
end

exports('ResetCourses', resetCourses)

lib.callback.register('srv_shootingrange:server:complete', function(source, courseId)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    local course = config.getById(courseId)
    if not course then return false end

    if not isAtCourse(source, course) then return false end
    if not canStart(player, course) then return false end

    local licences = getLicences(player)
    licences[course.licence] = true
    player.Functions.SetMetaData('licences', licences)

    return true
end)
