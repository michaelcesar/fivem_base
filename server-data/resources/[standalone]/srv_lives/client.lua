local config = require 'config'

--- Servidor: the character-state panel.
---
--- Opened with a key rather than a command, for the same reason the downed panel is: a command
--- nobody is told about is a feature nobody uses. Registered through `RegisterKeyMapping` so the
--- player can rebind it in FiveM's own settings if F7 collides with something on their machine.
---
--- It only DISPLAYS. Buying lives back happens at the hospital counter and nowhere else, so this
--- panel can be opened anywhere without becoming a shop.

local open = false

local function close()
    if not open then return end

    open = false
    SendNUIMessage({ action = 'lives', show = false })
end

local function show()
    local status = lib.callback.await('srv_lives:client:status', false)

    if not status then
        return lib.notify({ description = 'Não foi possível ler o estado do personagem.', type = 'error' })
    end

    open = true

    SendNUIMessage({
        action = 'lives',
        show = true,
        lives = status.lives,
        max = status.max,
        blocked = status.blocked,
        debt = status.debt,
    })
end

RegisterCommand('srv_lives_panel', function()
    if open then return close() end

    show()
end, false)

RegisterKeyMapping('srv_lives_panel', 'Estado do personagem (vidas)', 'keyboard', 'F7')

--- Closed on death so it cannot sit on top of the downed panel, which occupies the same attention.
AddEventHandler('qbx_medical:client:playerDied', close)

--- Refreshed while open, so a life lost or a debt settled is visible without reopening.
CreateThread(function()
    while true do
        Wait(3000)

        if open then show() end
    end
end)

--- Placement after giving up. Server-driven so the client cannot choose where it lands.
RegisterNetEvent('srv_lives:client:respawnAt', function(coords)
    CreateThread(function()
        local ped = cache.ped

        DoScreenFadeOut(600)
        while not IsScreenFadedOut() do Wait(50) end

        FreezeEntityPosition(ped, true)
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(ped, coords.w)

        -- Both waits: an interior can report ready while its floor has not arrived, which is how a
        -- player ended up in the metro tunnel under Pillbox. See docs/conventions.md.
        local interior = GetInteriorAtCoords(coords.x, coords.y, coords.z)
        if interior ~= 0 then LoadInterior(interior) end

        local deadline = GetGameTimer() + 8000

        while GetGameTimer() < deadline do
            RequestCollisionAtCoord(coords.x, coords.y, coords.z)

            if HasCollisionLoadedAroundEntity(ped) and (interior == 0 or IsInteriorReady(interior)) then
                break
            end

            Wait(0)
        end

        FreezeEntityPosition(ped, false)
        DoScreenFadeIn(1200)
    end)
end)

--- The hospital counter: the only place a life can be bought back.
---
--- Written as an `[E]` prompt rather than an ox_target option, because that is what every other
--- fixed point in this project uses - the gang bases, the labs, the shops. A counter that needed
--- ALT when the rest of the world needs E is a second convention for one place, and the player
--- pays for it by having to remember which is which.
---
--- The pattern is `srv_gangs`': showTextUI while in range, IsControlJustPressed(0, 38) to act.
--- The counter menu.
---
--- A buy that takes money on a single keypress is a buy someone makes by walking past and
--- pressing E out of habit. 50k is too much to lose that way, so the purchase is confirmed;
--- the free claim is not, because the worst outcome there is getting something.
local function openCounter()
    local status = lib.callback.await('srv_lives:server:counter', false)

    if not status then
        return lib.notify({ description = 'O atendimento não está disponível.', type = 'error' })
    end

    local options = {
        {
            title = 'Atendimento gratuito',
            description = status.freeOwed > 0
                and ('%s %s disponíveis por conta do hospital.'):format(
                    status.freeOwed, status.freeOwed == 1 and config.label.singular or config.label.plural)
                or ('O próximo sai em %s dias.'):format(status.daysLeft),
            icon = 'hand-holding-heart',
            disabled = status.freeOwed < 1,
            onSelect = function()
                local ok, message = lib.callback.await('srv_lives:server:claimFree', false)

                lib.notify({ title = 'Hospital', description = message, type = ok and 'success' or 'error' })
            end,
        },
        {
            title = ('Comprar %s'):format(config.label.singular),
            description = ('$%s. Você tem %s de %s.'):format(status.price, status.lives, status.max),
            icon = 'cart-shopping',
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Confirmar tratamento',
                    content = ('Comprar uma %s por **$%s**?\n\nVocê tem %s de %s.'):format(
                        config.label.singular, status.price, status.lives, status.max),
                    centered = true,
                    cancel = true,
                    labels = { confirm = 'Pagar', cancel = 'Cancelar' },
                })

                if confirm ~= 'confirm' then return end

                local ok, message = lib.callback.await('srv_lives:server:buy', false)

                lib.notify({ title = 'Hospital', description = message, type = ok and 'success' or 'error' })
            end,
        },
    }

    lib.registerContext({ id = 'srv_lives_counter', title = 'Atendimento hospitalar', options = options })
    lib.showContext('srv_lives_counter')
end

local INTERACT_CONTROL <const> = 38
local COUNTER_DISTANCE <const> = 2.0

CreateThread(function()
    local promptShown = false

    while true do
        local distance = #(GetEntityCoords(cache.ped) - config.counter)
        local wait = 500

        if distance <= COUNTER_DISTANCE then
            wait = 0

            if not promptShown then
                promptShown = true
                lib.showTextUI('[E] Atendimento hospitalar.')
            end

            if IsControlJustPressed(0, INTERACT_CONTROL) then
                lib.hideTextUI()
                promptShown = false

                openCounter()
                Wait(800)
            end
        elseif promptShown then
            promptShown = false
            lib.hideTextUI()
        end

        Wait(wait)
    end
end)

--- The prompt must not survive the resource stopping, or it sits on screen with nothing behind it.
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then lib.hideTextUI() end
end)
