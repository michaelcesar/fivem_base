-- Servidor: no server-side decision to make here at all - `illenium-appearance` already owns and
-- authenticates the player's saved-outfit list (`illenium-appearance:server:getOutfits`) and the
-- real apply/save path (`illenium-appearance:client:changeOutfit`); this resource only has to tell
-- the client to open the picker. Never consumed - the item is a reusable tool, not a charge.
exports.qbx_core:CreateUseableItem(Config.bundleItem, function(source)
    TriggerClientEvent('srv_wardrobe:client:open', source)
end)
