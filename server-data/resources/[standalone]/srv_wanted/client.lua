-- Servidor: draws the backpack and the on-screen countdown the server tells it to, and nothing
-- else - whether a player is marked, for how long, and what clears it are all server.lua's
-- decisions. See config.lua for the backpack drawable.

--- Servidor: whichever of `Config.backpack.male`/`female` matches this ped's own model - the same
--- `mp_m_freemode_01`/`mp_f_freemode_01` check `illenium-appearance` itself uses (`game/util.lua`),
--- not a separate guess at how to tell gender apart.
---@return { drawable: number?, texture: number }
local function backpackForPed()
    local isMale = GetEntityModel(cache.ped) == `mp_m_freemode_01`
    return isMale and Config.backpack.male or Config.backpack.female
end

-- Servidor: 0 is the base game's own "nothing equipped" drawable for every clothing component, not
-- a guess specific to bags - the same value every ped starts with before any customization runs.
local function clearBackpackVisual()
    SetPedComponentVariation(cache.ped, Config.backpack.component, 0, 0, 0)
end

-- Servidor: the HUD countdown - `os.time()` does not exist client-side in FiveM (see
-- `srv_weedfarm/client.lua`'s own note on this), so the server sends a relative `secondsLeft`
-- rather than an epoch, and this thread ticks it down locally with `GetGameTimer()`. One shared
-- deadline rather than one thread per mark: a refresh just moves `wantedEndsAt` forward and the
-- already-running loop picks it up on its next second, so a fast double-robbery never spawns a
-- second competing thread.
--
-- The thread also drops the backpack itself the moment it hits zero, rather than waiting for the
-- server's own 15s expiry sweep (`server.lua`) to notice and say so - `IsWanted` already flips to
-- false at the real deadline regardless of when the sweep gets to it (it compares against
-- `os.time()` directly), so nothing is actually still enforced during that window; only the visual
-- would have lagged up to 15s behind a HUD that had already hit 0:00. No local notify here - the
-- one real "você não está mais procurado" toast still comes from the server's own unmark event,
-- arriving up to 15s later, same as before; this only keeps the backpack and the badge in sync
-- with each other.
local wantedEndsAt = nil ---@type number? game-timer ms
local wantedThreadRunning = false

local function startWantedCountdown(secondsLeft)
    wantedEndsAt = GetGameTimer() + secondsLeft * 1000
    if wantedThreadRunning then return end
    wantedThreadRunning = true

    CreateThread(function()
        while wantedEndsAt do
            local remaining = math.ceil((wantedEndsAt - GetGameTimer()) / 1000)
            if remaining <= 0 then
                wantedEndsAt = nil
                clearBackpackVisual()
                SendNUIMessage({ action = 'srv_wanted:hide' })
                break
            end

            SendNUIMessage({ action = 'srv_wanted:show', secondsLeft = remaining })
            Wait(1000)
        end
        wantedThreadRunning = false
    end)
end

-- Servidor: the escape valve's actual disguise - a random pick from the player's OWN saved outfits
-- (`illenium-appearance:server:getOutfits`, the same personal-outfit list `srv_wardrobe` lets a
-- player browse deliberately), applied through `illenium-appearance:client:changeOutfit`, the same
-- real event the game's own outfit menu fires - not a hand-rolled component/prop loop, so the
-- result is properly saved as the player's current appearance exactly the way choosing it manually
-- would be. Picking from real saved clothes rather than `SetPedRandomComponentVariation` (GTA's own
-- randomizer) is deliberate: that native can land on drawables that clash or read as wrong for the
-- ped's gender, while a player's own saved outfit is guaranteed to already be a real, worn combination.
RegisterNetEvent('srv_wanted:client:disguise', function()
    local outfits = lib.callback.await('illenium-appearance:server:getOutfits', false)

    if not outfits or #outfits == 0 then
        -- Servidor: the mark is already cleared by the time this fires (server.lua clears it before
        -- triggering this event) - having no saved outfit to change into does not undo that, it
        -- only means the disguise half of the item has nothing to work with this time.
        lib.notify({
            title = 'Kit de Disfarce',
            description = 'Você não tem roupas salvas - a marca foi removida, mas o disfarce não pôde ser aplicado.',
            type = 'inform',
        })
        return
    end

    local outfit = outfits[math.random(#outfits)]
    TriggerEvent('illenium-appearance:client:changeOutfit', {
        model = outfit.model,
        components = outfit.components,
        props = outfit.props,
    })
end)

RegisterNetEvent('srv_wanted:client:setMarked', function(marked, secondsLeft)
    local backpack = backpackForPed()

    if marked then
        if backpack.drawable then
            SetPedComponentVariation(cache.ped, Config.backpack.component, backpack.drawable, backpack.texture, 0)
        else
            -- Servidor: the mark itself still applies with no drawable set - shops still refuse,
            -- the alert still fires, the timer still runs. Only the costume is missing, and this
            -- is the one place that would go silently wrong without a line saying so.
            print('^1[srv_wanted]^7 Config.backpack has no drawable set for this ped\'s gender - marking without changing appearance. Verify one with srv_tools\' /testbag.')
        end

        lib.notify({ title = 'Procurado', description = 'Você está procurado pela polícia.', type = 'error' })
        startWantedCountdown(secondsLeft)
    else
        clearBackpackVisual()
        lib.notify({ title = 'Procurado', description = 'Você não está mais procurado.', type = 'success' })

        wantedEndsAt = nil
        SendNUIMessage({ action = 'srv_wanted:hide' })
    end
end)
