-- Servidor: the base `chat` resource registers a `toggleChat` command and binds it to `L` by
-- default (cl_chat.lua). `L` is also the near-universal FiveM convention for vehicle
-- lock/unlock, which `qbx_vehiclekeys` uses and which players press constantly - so pressing it
-- cycled the chat between "show when active", "always show" and "always hide" as a side effect.
--
-- Cycling chat visibility is a feature nobody here wants, so rather than move the key, the
-- command itself is neutralised: re-registering the same command name replaces the base
-- resource's handler with this no-op, leaving the keybind registered but harmless. `L` then only
-- ever unlocks a vehicle.
--
-- This is why the chat is NOT vendored into this repo. An earlier pass copied the whole resource
-- (17 files) out of the FXServer binary tree just to change that one default key, which meant
-- freezing it against every future upstream update. Overriding one command from our own resource
-- costs nothing and leaves `chat` on the stock, auto-updating copy. See ADR-049.
--
-- `chat` is declared as a dependency in fxmanifest.lua, so it is always started before this file
-- runs - the override therefore always lands after the base registration, never before it.
RegisterCommand('toggleChat', function()
    -- Deliberately empty. The chat keeps whatever visibility state it starts with.
end, false)
