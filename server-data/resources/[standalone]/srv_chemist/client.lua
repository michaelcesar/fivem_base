-- Servidor: client-side display only - the purchase itself is re-validated server-side
-- (server.lua). Mirrors the shape of srv_weedfarm's own seed vendor almost line for line: same
-- two-tier marker+[E] zone (ADR-066), same "Desconhecido" illegal blip, same quantity dialog.

local INTERACT_CONTROL = 38

local function notify(description, notifyType)
    lib.notify({ title = 'Químico', description = description, type = notifyType or 'inform' })
end

--- Servidor: "3x" is shorthand; "3 unidades" is language. Requested across every message these
--- resources show, so a count and its noun are always built together rather than glued to an "x".
--- Both plural forms are passed in rather than derived - Portuguese plurals are irregular enough
--- (unidade/unidades, aplicação/aplicações, porção/porções) that deriving them would be wrong more
--- often than right. See ADR-088.
---@param count number
---@param one string singular form, used when count is exactly 1
---@param many string plural form
---@return string
local function counted(count, one, many)
    return ('%s %s'):format(count, count == 1 and one or many)
end

--- The standard quantity-input shape used at every vendor in this project - one number field,
--- minimum 1, required, with the price in the description. `max` is enforced by the dialog as a
--- display convenience only; the server re-checks its own real ceiling regardless.
---@param title string
---@param description string
---@param max number?
---@return number?
local function askQuantity(title, description, max)
    local input = lib.inputDialog(title, {
        { type = 'number', label = 'Quantidade', description = description, icon = 'hashtag',
            default = 1, min = 1, max = max, required = true },
    })
    if not input then return nil end

    return input[1]
end

--- Same two-tier marker+[E] zone shape as every farm's own - duplicated rather than shared, since
--- FXServer gives each resource its own script environment with no way to import a local from
--- another one.
local function setupInteractionZone(coords, radius, innerRadius, getPrompt, onInteract)
    local innerZone

    lib.zones.sphere({
        coords = coords,
        radius = radius,
        debug = false,
        onEnter = function()
            innerZone = lib.zones.sphere({
                coords = coords,
                radius = innerRadius,
                debug = false,
                onEnter = function()
                    local prompt = getPrompt()
                    if prompt then lib.showTextUI(prompt) end
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = function()
                    if not IsControlJustPressed(0, INTERACT_CONTROL) then return end
                    if not getPrompt() then return end

                    lib.hideTextUI()
                    onInteract()
                end,
            })
        end,
        onExit = function()
            if innerZone then
                innerZone:remove()
                innerZone = nil
            end
        end,
        inside = function()
            if getPrompt() then
                DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5,
                    20, 246, 12, 200, false, false, 0, false, nil, nil, false)
            end
        end,
    })
end

-- Servidor: the same illegal point-of-interest blip every farm uses - sprite 84 ("Skull"), colour 9
-- (grey), named "Desconhecido" rather than anything identifying. A glance at the map shows
-- something is there, never what.
local ILLEGAL_BLIP_SPRITE = 84
local ILLEGAL_BLIP_COLOUR = 9
local ILLEGAL_BLIP_NAME = 'Desconhecido'

local function addIllegalBlip(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, ILLEGAL_BLIP_SPRITE)
    SetBlipColour(blip, ILLEGAL_BLIP_COLOUR)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(ILLEGAL_BLIP_NAME)
    EndTextCommandSetBlipName(blip)
end

local vendorPed
local vendor = Config.vendor

-- Servidor: the vendor only ever starts up once a real coordinate exists (see config.lua) - same
-- "not playable until mapped" rule every farm NPC already follows, rather than crashing on a nil
-- vec4. Read into a local right after the check, not re-read as `Config.vendor` inside the
-- closures below: the type checker narrows a local's type through a closure boundary, but not a
-- table field's.
if vendor then
    CreateThread(function()
        lib.requestModel(Config.vendorPed, 10000)
        vendorPed = CreatePed(0, Config.vendorPed, vendor.x, vendor.y, vendor.z - 1.0, vendor.w, false, false)
        SetModelAsNoLongerNeeded(Config.vendorPed)
        SetEntityHeading(vendorPed, vendor.w)
        FreezeEntityPosition(vendorPed, true)
        SetEntityInvincible(vendorPed, true)
        SetBlockingOfNonTemporaryEvents(vendorPed, true)
        TaskStartScenarioInPlace(vendorPed, 'WORLD_HUMAN_HANG_OUT_STREET', 0, true)
    end)

    addIllegalBlip(vendor.xyz)

    ---@param product {item: string, label: string, description: string, price: number, boostMinutes: number}
    local function buy(product)
        local amount = askQuantity(('Comprar %s'):format(product.label),
            ('$%s cada - máximo de %s por compra.'):format(product.price,
                counted(Config.purchaseCeiling, 'unidade', 'unidades')),
            Config.purchaseCeiling)
        if not amount then return end

        local result = lib.callback.await('srv_chemist:server:buy', false, product.item, amount)

        if not result or not result.ok then
            local reasons = {
                far = 'Chegue mais perto do químico.',
                nomoney = 'Você não tem dinheiro suficiente.',
                noroom = 'Você não tem espaço no inventário.',
                toomany = ('Máximo de %s por compra.'):format(
                    counted(Config.purchaseCeiling, 'unidade', 'unidades')),
            }
            notify((result and reasons[result.reason]) or 'Não foi possível comprar.', 'error')
            return
        end

        notify(('Comprou %s de %s por $%s.'):format(
            counted(result.count, 'unidade', 'unidades'), product.label, result.paid), 'success')
    end

    setupInteractionZone(vendor.xyz, Config.vendorDistance + 5.0, Config.vendorDistance, function()
        return '[E] Falar com o químico.'
    end, function()
        local options = {}

        for i = 1, #Config.products do
            local product = Config.products[i]
            options[i] = {
                title = product.label,
                -- Servidor: one line, like every other context-menu sublabel in this project - the
                -- price and the effect, nothing else. See ADR-080.
                description = ('$%s - adianta %s min.'):format(product.price, product.boostMinutes),
                icon = product.icon,
                onSelect = function() buy(product) end,
            }
        end

        lib.registerContext({ id = 'srv_chemist_shop', title = 'Químico', options = options })
        lib.showContext('srv_chemist_shop')
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= cache.resource then return end
        if vendorPed then exports.srv_lib:DeleteLocalEntity(vendorPed) end
    end)
end
