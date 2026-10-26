-- Servidor: "Trouxa de Roupas" - a menu of the player's own saved outfits (`illenium-appearance`'s
-- own personal-outfit system, `player_outfits` table), clicking one previews it live, a pinned
-- "Confirmar" option makes the last preview real. Built on `lib.registerContext`/`showContext` -
-- this project's own standard menu, used everywhere else (the farm plant menus, the robbery counter
-- menu) - rather than a bespoke NUI page: "our own layout" already means this component, and a
-- click-through list of text options is exactly what it is built for.

--- Servidor: applies components/props directly with the real GTA natives, matching
-- `illenium-appearance/game/util.lua`'s own `setPedComponent`/`setPedProp` shape exactly (verified
-- by reading that file, not guessed) - component ids 0/2 (head/hair) skipped on a freemode ped for
-- the same reason upstream skips them: a saved outfit is clothes, never a head or hairstyle change.
-- Deliberately NOT `illenium-appearance:client:changeOutfit` for every click - that event persists
-- to the database each time it fires, and browsing five outfits before settling on one would be
-- five unnecessary writes. This function is preview-only; nothing is saved until Confirmar.
---@param outfit { model: string, components: table, props: table }
local function previewOutfit(outfit)
    local ped = cache.ped
    local isFreemode = GetEntityModel(ped) == `mp_m_freemode_01` or GetEntityModel(ped) == `mp_f_freemode_01`

    for i = 1, #outfit.components do
        local component = outfit.components[i]
        if not (isFreemode and (component.component_id == 0 or component.component_id == 2)) then
            SetPedComponentVariation(ped, component.component_id, component.drawable, component.texture, 0)
        end
    end

    for i = 1, #outfit.props do
        local prop = outfit.props[i]
        if prop.drawable == -1 then
            ClearPedProp(ped, prop.prop_id)
        else
            SetPedPropIndex(ped, prop.prop_id, prop.drawable, prop.texture, false)
        end
    end
end

local previewedOutfit = nil ---@type table?

local function openPicker()
    local outfits = lib.callback.await('illenium-appearance:server:getOutfits', false)

    if not outfits or #outfits == 0 then
        lib.notify({ title = 'Trouxa de Roupas', description = 'Você não tem roupas salvas.', type = 'inform' })
        return
    end

    local options = {}

    for i = 1, #outfits do
        local outfit = outfits[i]
        options[#options + 1] = {
            title = outfit.name,
            description = 'Experimentar esta roupa.',
            icon = 'shirt',
            onSelect = function()
                previewedOutfit = outfit
                previewOutfit(outfit)
                openPicker() -- Servidor: reopens so browsing keeps going after each preview.
            end,
        }
    end

    options[#options + 1] = {
        title = 'Confirmar',
        description = previewedOutfit
            and ('Ficar com "%s".'):format(previewedOutfit.name)
            or 'Experimente uma roupa da lista primeiro.',
        icon = 'check',
        iconColor = previewedOutfit and '#3ecf7e' or nil,
        disabled = previewedOutfit == nil,
        onSelect = function()
            -- `disabled` above keeps the menu from calling this with no preview, but it is the
            -- menu library's contract, not something this function can see - checked again here
            -- so a change on that side fails safe instead of indexing nil.
            if not previewedOutfit then return end

            -- Servidor: the one real, persisted apply - same event the game's own outfit menu fires,
            -- so the chosen look is saved exactly the way choosing it manually would be.
            TriggerEvent('illenium-appearance:client:changeOutfit', {
                model = previewedOutfit.model,
                components = previewedOutfit.components,
                props = previewedOutfit.props,
            })
            lib.notify({ title = 'Trouxa de Roupas', description = 'Roupa trocada.', type = 'success' })
            previewedOutfit = nil
        end,
    }

    lib.registerContext({ id = 'srv_wardrobe_picker', title = 'Trouxa de Roupas', options = options })
    lib.showContext('srv_wardrobe_picker')
end

RegisterNetEvent('srv_wardrobe:client:open', function()
    previewedOutfit = nil
    openPicker()
end)
