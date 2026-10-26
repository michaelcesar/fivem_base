-- Servidor rule: the weapon crosshair (HUD_RETICLE) only shows for weapon classes the
-- player is certified in, via the artillery courses (srv_shootingrange). Certificates
-- live in qbx_core's existing metadata.licences table. Without one you aim "by eye".
--
-- Component 14 is deliberately NOT in qbx_hudcomponents' disable list, so this resource
-- fully owns the reticle instead of fighting that resource's shared table.

local HUD_RETICLE = 14

-- Native weapon groups mapped to the licence that unlocks them. Groups left out
-- (melee, unarmed, petrol can, extinguisher, parachute) are never gated.
local licenceByGroup = {
    [`GROUP_PISTOL`] = 'weapon',
    [`GROUP_STUNGUN`] = 'weapon',
    [`GROUP_SMG`] = 'weaponrifle',
    [`GROUP_MG`] = 'weaponrifle',
    [`GROUP_RIFLE`] = 'weaponrifle',
    [`GROUP_SHOTGUN`] = 'weaponshotgun',
    [`GROUP_SNIPER`] = 'weaponexpert',
    [`GROUP_HEAVY`] = 'weaponexpert',
    [`GROUP_THROWN`] = 'weaponexpert',
}

-- Scoped weapons look broken with no reticle at all, so instead of hiding it they get
-- a decoy: a reticle that is drawn off-centre and drifts, while shots still land at the
-- true centre. The scope reads as real glass, but an untrained shooter can't hit with it.
local decoy = {
    groups = { [`GROUP_SNIPER`] = true },
    maxOffset = 0.035, -- how far off the true centre the decoy sits
    driftAmount = 0.012, -- how far it wanders around that offset
    driftSpeed = 0.6,
    colour = { 255, 255, 255, 190 },
}

local function getLicences()
    return QBX.PlayerData.metadata?.licences
end

---@return number group, boolean allowed
local function getWeaponState()
    local group = GetWeapontypeGroup(GetSelectedPedWeapon(PlayerPedId()))
    local licences = getLicences()

    if not licences then return group, false end

    -- The expert course covers every class.
    if licences.weaponexpert then return group, true end

    local required = licenceByGroup[group]

    if not required then return group, true end

    return group, licences[required] == true
end

---@param x number
---@param y number
local function drawDecoyReticle(x, y)
    local r, g, b, a = decoy.colour[1], decoy.colour[2], decoy.colour[3], decoy.colour[4]

    DrawRect(x, y, 0.014, 0.0018, r, g, b, a)
    DrawRect(x, y, 0.0008, 0.024, r, g, b, a)
end

CreateThread(function()
    local wasAiming = false
    local offsetX, offsetY = 0.0, 0.0

    while true do
        local group, allowed = getWeaponState()

        if allowed then
            wasAiming = false
            Wait(100)
        else
            HideHudComponentThisFrame(HUD_RETICLE)

            if decoy.groups[group] and IsPlayerFreeAiming(PlayerId()) then
                if not wasAiming then
                    wasAiming = true
                    offsetX = (math.random() * 2.0 - 1.0) * decoy.maxOffset
                    offsetY = (math.random() * 2.0 - 1.0) * decoy.maxOffset
                end

                local t = GetGameTimer() / 1000.0

                drawDecoyReticle(
                    0.5 + offsetX + math.sin(t * decoy.driftSpeed) * decoy.driftAmount,
                    0.5 + offsetY + math.cos(t * decoy.driftSpeed * 0.8) * decoy.driftAmount
                )
            else
                wasAiming = false
            end

            Wait(0)
        end
    end
end)
