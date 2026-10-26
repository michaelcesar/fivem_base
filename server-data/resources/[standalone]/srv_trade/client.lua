-- Servidor: the trade screen and the option that opens it. Nothing here decides anything - every
-- callback below is a request the server is free to refuse, and the panel only ever draws what the
-- server last sent. See server.lua for where the rules actually live.

local partnerName

local function notify(description, notifyType)
    lib.notify({ title = 'Negociação', description = description, type = notifyType or 'inform' })
end

-- Servidor: the same convar ox_inventory reads, so a server that relocates its images relocates this
-- screen's too. Not hardcoded even though the default has never been changed here.
local imagePath = GetConvar('inventory:imagepath', 'nui://ox_inventory/web/images')

--- Which picture a slot shows, resolved exactly the way ox_inventory's own UI resolves it:
--- `metadata.imageurl` wins as a full URL, then `metadata.image` as a name under the image path,
--- then the item's own `client.image`, then the item name.
---
--- This has to happen client-side. `ox_inventory` strips `item.client` on the server, so the server
--- cannot see a custom image at all - it would fall back to the item name for every item that has
--- one and quietly show the wrong picture.
---@param entry table
local function resolveImage(entry)
    if entry.imageurl then
        entry.image = entry.imageurl
        return
    end

    if entry.image then
        entry.image = ('%s/%s.png'):format(imagePath, entry.image)
        return
    end

    local item = exports.ox_inventory:Items(entry.name)
    entry.image = (item and item.client and item.client.image) or ('%s/%s.png'):format(imagePath, entry.name)
end

--- Servidor: the bottom-left panel is re-read from the server on every update rather than kept in
--- sync locally. Cheap, and it means an item picked up mid-trade appears without a special case.
local function pushState(state)
    local snapshot = lib.callback.await('srv_trade:server:snapshot', false) or {}

    state.inventory = snapshot.items or {}
    state.weight = snapshot.weight or 0
    state.maxWeight = snapshot.maxWeight or 0

    for _, entry in ipairs(state.inventory) do resolveImage(entry) end
    for _, offers in ipairs({ state.mine, state.theirs }) do
        for _, entry in pairs(offers or {}) do resolveImage(entry) end
    end

    state.action = 'update'
    state.partner = partnerName
    SendNUIMessage(state)
end

RegisterNetEvent('srv_trade:client:invited', function(fromSrc, fromName)
    local accepted = lib.alertDialog({
        header = 'Negociação',
        content = ('**%s** quer negociar com você.'):format(fromName),
        centered = true,
        cancel = true,
        labels = { confirm = 'Aceitar', cancel = 'Recusar' },
    })

    if accepted ~= 'confirm' then return end

    local result = lib.callback.await('srv_trade:server:accept', false, fromSrc)

    if not result or not result.ok then
        local reasons = {
            expired = 'O convite expirou.',
            busy = 'Alguém já está negociando.',
            far = 'A pessoa se afastou.',
            gone = 'A pessoa saiu.',
            incapable = 'Não dá para negociar ferido ou algemado.',
        }
        notify((result and reasons[result.reason]) or 'Não foi possível abrir a negociação.', 'error')
    end
end)

RegisterNetEvent('srv_trade:client:open', function(_, name)
    partnerName = name
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', partner = name, offerSlots = Config.offerSlots })
end)

RegisterNetEvent('srv_trade:client:update', function(state)
    pushState(state)
end)

RegisterNetEvent('srv_trade:client:closed', function(reason)
    partnerName = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    -- Servidor: `done` is the only success. Everything else is a refusal, and each one says which,
    -- because "não foi possível" on a trade someone spent a minute setting up is useless.
    local reasons = {
        done = { 'Negociação concluída.', 'success' },
        cancelled = { 'Negociação cancelada.', 'inform' },
        far = { 'Negociação cancelada: vocês se afastaram.', 'error' },
        gone = { 'Negociação cancelada: a outra pessoa saiu.', 'error' },
        changed = { 'Negociação cancelada: um dos itens ofertados mudou.', 'error' },
        incapable = { 'Negociação cancelada: alguém ficou ferido ou algemado.', 'error' },
        space = { 'Negociação cancelada: falta espaço ou peso em um dos lados.', 'error' },
        failed = { 'Negociação cancelada: falha ao mover os itens. Nada foi perdido.', 'error' },
    }

    local message = reasons[reason]
    if message then notify(message[1], message[2]) end
end)

RegisterNUICallback('setOffer', function(data, cb)
    lib.callback.await('srv_trade:server:setOffer', false, data.index, data.slot, data.count)
    cb(1)
end)

RegisterNUICallback('confirm', function(data, cb)
    lib.callback.await('srv_trade:server:confirm', false, data.confirmed == true)
    cb(1)
end)

RegisterNUICallback('cancel', function(_, cb)
    lib.callback.await('srv_trade:server:cancel', false)
    cb(1)
end)

--- Servidor: on the target key, alongside every other player-to-player action. `srv_interactions`
--- owns that menu, but this option lives here so the whole feature is one resource - the menu merges
--- what each resource registers, so nothing has to know about this one.
CreateThread(function()
    exports.ox_target:addGlobalPlayer({
        {
            name = 'srv_trade_start',
            icon = 'fas fa-right-left',
            label = 'Negociar',
            distance = Config.maxDistance,
            onSelect = function(data)
                local ped = data and data.entity
                if not ped or not DoesEntityExist(ped) then return end

                local player = NetworkGetPlayerIndexFromPed(ped)
                if player == -1 then return end

                local result = lib.callback.await('srv_trade:server:invite', false, GetPlayerServerId(player))

                if not result or not result.ok then
                    local reasons = {
                        busy = 'Alguém já está negociando.',
                        far = 'A pessoa está longe demais.',
                        incapable = 'Não dá para negociar ferido ou algemado.',
                    }
                    notify((result and reasons[result.reason]) or 'Não foi possível convidar.', 'error')
                    return
                end

                notify('Convite enviado. Aguardando resposta.')
            end,
        },
    })
end)

-- Servidor: the NUI keeps focus until the server closes the trade, so a resource restart mid-trade
-- would leave the player stuck with a mouse cursor and no screen. Cheap insurance.
AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    SetNuiFocus(false, false)
end)
