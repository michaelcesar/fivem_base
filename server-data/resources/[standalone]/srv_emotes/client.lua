-- Servidor: quick emote keys, by request.
--
-- `scully_emotemenu` does ship an emote-bind feature, but it is five slots with no default key
-- (`defaultKey = ''`) that each PLAYER fills from the emote menu - there is no way to preset one
-- server-side to a specific emote. Hence this resource: the binds the server decides, next to the
-- ones the player still decides for themselves.
--
-- Hands-up is deliberately NOT here. `scully_emotemenu` has a dedicated module for it that does
-- considerably more than play an animation - it disables firing, handles being on a bike, and
-- recovers the pose after a ragdoll. That one just needed its key moved to X, which is a convar in
-- `server.cfg`, not code. See ADR-128.
--
-- Both emotes below were checked against `scully_emotemenu/shared/data/emotes/general_emotes.lua`.
-- A wrong command name fails at the far end with "not a valid emote" and no other signal.
local BINDS <const> = {
    {
        name = 'srv_emotes_whistle',
        description = 'Assoviar',
        defaultKey = 'DOWN',
        emote = 'whistle',
    },
    {
        name = 'srv_emotes_damn',
        description = 'Reação de decepção',
        defaultKey = 'RIGHT',
        emote = 'damn',
    },
}

for i = 1, #BINDS do
    local bind = BINDS[i]

    lib.addKeybind({
        name = bind.name,
        description = bind.description,
        defaultKey = bind.defaultKey,
        onPressed = function()
            -- The resource's own net event, the same one the radial's Ações group uses, rather
            -- than `ExecuteCommand('e ...')` - the `e`/`emote`/`eplay` aliases are convar-driven
            -- and nothing here should depend on them staying as they are.
            TriggerEvent('scully_emotemenu:playEmoteByCommand', bind.emote)
        end,
    })
end

-- Servidor: a SECOND cancel key on F6, by request - it is what most servers use, so it is what
-- players arrive expecting. `scully_emotemenu`'s own `emoteCancelKey` convar holds one key and
-- keeps X (its default), so the alternative has to be registered separately rather than by
-- changing that value. Both call the same `cancelEmote`, so there is no second implementation.
lib.addKeybind({
    name = 'srv_emotes_cancel',
    description = 'Parar animação (alternativa ao X)',
    defaultKey = 'F6',
    onPressed = function()
        TriggerEvent('scully_emotemenu:cancelEmote')
    end,
})
