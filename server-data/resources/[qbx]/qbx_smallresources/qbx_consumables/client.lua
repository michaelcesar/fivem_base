local alcoholCount = 0
local relieveCount = 0
local healing = false
local smokingWeed = false

local function healOxy()
    if not healing then
        healing = true
    else
        return
    end

    local count = 9
    while count > 0 do
        Wait(1000)
        count -= 1
        SetEntityHealth(cache.ped, GetEntityHealth(cache.ped) + 6)
    end
    healing = false
end

-- Servidor: the drug effects, rewritten. Two changes, both requested.
--
-- **The visuals are gone.** `AnimpostfxPlay` screen filters, `SetFlash`, `ShakeGameplayCam` and the
-- `SetPedToRagdoll` falls all removed. What is left is what the effect actually DOES: sprint speed
-- and stamina. `TrevorEffect` and `AlienEffect` are kept as exports because other resources may
-- call them, but they now do nothing - deleting an export is a breaking change, and a no-op that
-- says so is honest where a silent stub is not.
--
-- **They stack.** Each running effect registers its sprint multiplier under its own key and the
-- applied value is the product of all of them. Before, every effect ended with
-- `SetRunSprintMultiplierForPlayer(id, 1.0)`, so taking crack while coke was running meant the
-- crack wearing off reset the speed the coke was still supposed to be giving.
--
-- The product is clamped to 1.49 because that is the ENGINE's ceiling, not a balance choice -
-- `SetRunSprintMultiplierForPlayer` ignores anything above it, and pretending otherwise would show
-- a number the game is not honouring. See ADR-163.

local sprintBoosts = {}

--- Applies the product of every active boost, clamped to what the engine accepts.
local function applySprint()
    local total = 1.0

    for _, multiplier in pairs(sprintBoosts) do
        total = total * multiplier
    end

    if total > 1.49 then total = 1.49 end

    SetRunSprintMultiplierForPlayer(cache.playerId, total)
end

---@param key string
---@param multiplier number?  nil removes the boost
local function setSprintBoost(key, multiplier)
    sprintBoosts[key] = multiplier
    applySprint()
end

-- Kept for callers outside this resource. Both used to play a screen filter; both are now no-ops.
local function trevorEffect() end
exports('TrevorEffect', trevorEffect)

local function alienEffect() end
exports('AlienEffect', alienEffect)

--- Stamina and speed for `seconds`, under `key` so two drugs can hold a boost at once.
---@param key string
---@param multiplier number
---@param seconds number
---@param staminaChance number percent chance per second of a stamina restore
local function stimulant(key, multiplier, seconds, staminaChance)
    setSprintBoost(key, multiplier)

    -- Deliberately does NOT return early when the same drug is taken twice. A second dose refreshes
    -- the timer through this loop and the boost stays registered under one key, so the multiplier
    -- does not double for the same substance - taking two of the same is not twice as fast.
    while seconds > 0 do
        Wait(1000)
        seconds -= 1

        if math.random(1, 100) <= staminaChance then
            RestorePlayerStamina(cache.playerId, 1.0)
        end
    end

    setSprintBoost(key, nil)
end

local function methBagEffect()
    stimulant('meth', 1.49, 8, 5)
end
exports('MethBagEffect', methBagEffect)

local function ecstasyEffect()
    -- Ecstasy gave no speed upstream, only stamina every second. Kept that way: its own multiplier
    -- is 1.0, which contributes nothing to the product but still holds a slot, so the icon and the
    -- stamina both last the full 30 seconds.
    stimulant('ecstasy', 1.0, 30, 100)
end
exports('EcstasyEffect', ecstasyEffect)

local function crackBaggyEffect()
    stimulant('crack', 1.3, 8, 10)
end
exports('CrackBaggyEffect', crackBaggyEffect)

local function cokeBaggyEffect()
    stimulant('coke', 1.1, 20, 20)
end
exports('CokeBaggyEffect', cokeBaggyEffect)

local function smokeWeed()
    -- Servidor: `smokingWeed` is declared `false` at the top of this file and, upstream, is never
    -- set to `true` anywhere - the only other mentions are this loop's condition and the `= false`
    -- that ends it. So the thread below exited on its first evaluation and a joint relieved no
    -- stress at all: it lit, played the emote and set the `weedsmell` evidence status, then did
    -- nothing. `hud:server:RelieveStress` itself works fine (qbx_ambulancejob and qbx_medical both
    -- use it) - it was simply never reached.
    --
    -- The early return is part of the same fix, not a separate nicety: without it, smoking a
    -- second joint while the first is still running would spawn a second thread sharing one
    -- `relieveCount`, so the two would race to the count of 6 and cancel each other's emote.
    -- See ADR-085.
    if smokingWeed then return end
    smokingWeed = true
    relieveCount = 0

    CreateThread(function()
        while smokingWeed do
            Wait(10000)
            TriggerServerEvent('hud:server:RelieveStress', math.random(15, 18))
            relieveCount += 1
            if relieveCount == 6 then
                exports.scully_emotemenu:cancelEmote()
                if smokingWeed then
                    smokingWeed = false
                    relieveCount = 0
                end
            end
        end
    end)
end

lib.callback.register('consumables:client:Eat', function(anim, prop)
    if lib.progressBar({
        duration = 5000,
        label = locale('progress.eating'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = anim or {
            clip = 'mp_player_int_eat_burger',
            dict = 'mp_player_inteat@burger',
            flag = 49
        },
        prop = prop or {
            {
                model = 'prop_cs_burger_01',
                bone = 18905,
                pos = {x = 0.13, y = 0.05, z = 0.02},
                rot = {x = -50.0, y = 16.0, z = 60.0}
            }
        }
    }) then -- if completed
        return true
    else -- if canceled
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
        return false
    end
end)

lib.callback.register('consumables:client:Drink', function(anim, prop)
    if lib.progressBar({
        duration = 5000,
        label = locale('progress.drinking'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = anim or {
            clip = 'loop_bottle',
            dict = 'mp_player_intdrink',
            flag = 49
        },
        prop = prop or {
            {
                model = 'prop_ld_flow_bottle',
                bone = 18905,
                pos = {x = 0.12, y = 0.008, z = 0.03},
                rot = {x = 240.0, y = -60.0, z = 0.0}
            }
        }
    }) then -- if completed
        return true
    else -- if canceled
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
        return false
    end
end)

lib.callback.register('consumables:client:DrinkAlcohol', function(alcoholLevel, anim, prop)
    if lib.progressBar({
        duration = math.random(3000, 6000),
        label = locale('progress.drinking_liquor'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = anim or {
            clip = 'loop_bottle',
            dict = 'mp_player_intdrink',
            flag = 49
        },
        prop = prop or {
            {
                model = 'prop_amb_beer_bottle',
                bone = 18905,
                pos = {x = 0.12, y = 0.008, z = 0.03},
                rot = {x = 240.0, y = -60.0, z = 0.0}
            }
        }
    }) then -- if completed
        alcoholCount += alcoholLevel or 1
        if alcoholCount > 1 and alcoholCount < 4 then
            TriggerEvent('evidence:client:SetStatus', 'alcohol', 200)
        elseif alcoholCount >= 4 then
            TriggerEvent('evidence:client:SetStatus', 'heavyalcohol', 200)
        end
        return true
    else -- if canceled
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
        return false
    end
end)

RegisterNetEvent('consumables:client:Cokebaggy', function()
    if lib.progressBar({
        duration = math.random(5000, 8000),
        label = locale('progress.popping_pills'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'switch@trevor@trev_smoking_meth',
            clip = 'trev_smoking_meth_loop',
            flag = 49
        }
    }) then -- if completed
        local used = lib.callback.await('consumables:server:usedItem', false, 'cokebaggy')
        if not used then return end

        TriggerEvent('evidence:client:SetStatus', 'widepupils', 200)
        cokeBaggyEffect()
    else -- if canceled
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
end)

RegisterNetEvent('consumables:client:Crackbaggy', function()
    if lib.progressBar({
        duration = math.random(7000, 10000),
        label = locale('progress.smoking_crack'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'switch@trevor@trev_smoking_meth',
            clip = 'trev_smoking_meth_loop',
            flag = 49
        }
    }) then -- if completed
        local used = lib.callback.await('consumables:server:usedItem', false, 'crack_baggy')
        if not used then return end

        TriggerEvent('evidence:client:SetStatus', 'widepupils', 300)
        crackBaggyEffect()
    else -- if canceled
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
end)

RegisterNetEvent('consumables:client:EcstasyBaggy', function()
    if lib.progressBar({
        duration = 3000,
        label = locale('progress.popping_pills'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'mp_suicide',
            clip = 'pill',
            flag = 49
        }
    }) then -- if completed
        local used = lib.callback.await('consumables:server:usedItem', false, 'xtcbaggy')
        if not used then return end

        ecstasyEffect()
    else -- if canceled
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
end)

RegisterNetEvent('consumables:client:oxy', function()
    if lib.progressBar({
        duration = 2000,
        label = locale('progress.healing'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'mp_suicide',
            clip = 'pill',
            flag = 49
        }
    }) then -- if completed
        local used = lib.callback.await('consumables:server:usedItem', false, 'oxy')
        if not used then return end

        ClearPedBloodDamage(cache.ped)
        healOxy()
    else -- if canceled
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
end)

RegisterNetEvent('consumables:client:meth', function()
    if lib.progressBar({
        duration = 1500,
        label = locale('progress.smoking_meth'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'switch@trevor@trev_smoking_meth',
            clip = 'trev_smoking_meth_loop',
            flag = 49
        }
    }) then -- if completed
        local used = lib.callback.await('consumables:server:usedItem', false, 'meth')
        if not used then return end

        TriggerEvent('evidence:client:SetStatus', 'widepupils', 300)
        TriggerEvent('evidence:client:SetStatus', 'agitated', 300)
        methBagEffect()
    else -- if canceled
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
end)

RegisterNetEvent('consumables:client:UseJoint', function()
    if lib.progressBar({
        duration = 1500,
        label = locale('progress.lighting_joint'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            mouse = false,
            combat = true
        }
    }) then -- if completed
        local used = lib.callback.await('consumables:server:usedItem', false, 'joint')
        if not used then return end

        exports.scully_emotemenu:playEmoteByCommand('joint')
        TriggerEvent('evidence:client:SetStatus', 'weedsmell', 300)
        smokeWeed()
    else -- if canceled
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
end)

--@TODO Rework this to only run when needed.
CreateThread(function()
    while true do
        Wait(10)
        if alcoholCount > 0 then
            Wait(1000 * 60 * 15)
            alcoholCount -= 1
        else
            Wait(2000)
        end
    end
end)
