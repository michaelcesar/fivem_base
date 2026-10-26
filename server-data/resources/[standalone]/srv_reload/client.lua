-- Servidor: R reloads from inventory ammo. See config.lua for why this resource is as thin as it is.

local lastReload = 0

---@param message string
local function notify(message)
    if not Config.notify then return end

    lib.notify({ description = message, type = 'error' })
end

--- The inventory slot holding ammo for `ammoName`, or `nil`.
---
--- Returns the slot with the FEWEST rounds, not the most. That sounds backwards and is deliberate:
--- `ox_inventory` takes what a slot holds up to what the magazine is missing, so draining the small
--- stacks first tidies the inventory as you fight instead of leaving a trail of 3-round leftovers
--- that can never be merged.
---@param ammoName string
---@return number? slot
---@return number? count
local function findAmmoSlot(ammoName)
    local slots = exports.ox_inventory:Search('slots', ammoName)
    if not slots or #slots == 0 then return end

    local best, bestCount

    for i = 1, #slots do
        local slot = slots[i]

        if slot.count > 0 and (not bestCount or slot.count < bestCount) then
            best, bestCount = slot.slot, slot.count
        end
    end

    return best, bestCount
end

local function tryReload()
    local now = GetGameTimer()
    if now - lastReload < Config.cooldown then return end

    local weapon = exports.ox_inventory:getCurrentWeapon()
    if not weapon then return end

    -- `ammoname` comes from the item catalog, not from the equipped item - the weapon in hand knows
    -- its hash, the catalog knows which ammo item feeds it.
    local item = exports.ox_inventory:Items(weapon.name)
    local ammoName = item and item.ammoname

    -- A melee weapon or a throwable has no `ammoname`. Silent on purpose: pressing R with a knife
    -- out is not a mistake worth interrupting anyone over.
    if not ammoName then return end

    local ped = cache.ped
    local clipSize = GetMaxAmmoInClip(ped, weapon.hash, true)
    local currentAmmo = GetAmmoInPedWeapon(ped, weapon.hash)

    -- Already full. Also silent - the engine's own reload does nothing here either, so saying
    -- something would be noise on a key players press reflexively.
    if currentAmmo >= clipSize then return end

    local slot, count = findAmmoSlot(ammoName)

    if not slot then
        lastReload = now
        notify('Você não tem munição para essa arma.')
        return
    end

    lastReload = now

    -- Hand off to `ox_inventory`. It decides how much of this stack actually goes in - the whole
    -- point of routing through `useSlot` rather than calling `AddAmmoToPed` here is that the
    -- inventory stays the single authority on ammo, so the count in the magazine and the count in
    -- the inventory can never disagree.
    exports.ox_inventory:useSlot(slot)

    if count < clipSize - currentAmmo then
        lib.notify({
            description = ('Recarregou %s de munição.'):format(count),
            type = 'inform',
        })
    end
end

CreateThread(function()
    while true do
        local wait = 500

        -- Only run the tight loop while something is actually in hand. `cache.weapon` is `false`
        -- when unarmed, so an unarmed player costs one check every half second rather than one
        -- every frame.
        if cache.weapon then
            wait = 0

            if IsControlJustPressed(0, Config.reloadControl) then
                tryReload()
            end
        end

        Wait(wait)
    end
end)
