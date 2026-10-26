-- Servidor: the one thing that has to be checked authoritatively before letting a player into either
-- of qbx_vehiclekeys' own minigames that key off the SAME item - the door lockpick (`LockpickDoor`)
-- and, once seated, the hotwire (`Hotwire`, which rolls the same break chance on the same item).
-- Both assume they were reached by actually using a `lockpick` item from the inventory
-- (`qbx_consumables`' `CreateUseableItem`), which is what implicitly gates them today. These `[E]`
-- prompts reach both minigames directly, so this callback is what stands in for that implicit gate
-- in both places - without it, a player with zero lockpicks would get free, unlimited attempts at
-- either.
lib.callback.register('srv_vehiclelocks:server:hasLockpick', function(source)
    return (exports.ox_inventory:GetItemCount(source, 'lockpick') or 0) > 0
end)
