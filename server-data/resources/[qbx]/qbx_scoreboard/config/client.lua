return {
    visibilityDistance = 10,
    -- Servidor: moved off HOME, which collided with what the player had bound there. F10 was
    -- picked by elimination, not preference: every `RegisterKeyMapping` and config default on
    -- the server is taken by something else - LMENU radio, x cancel, e fuel, m phone, F5 emotes,
    -- F9 dev coords, F11 voice range - and F10 is the one left unclaimed. See ADR-162.
    openKey = 'F10',
    toggle = true, -- If true, scoreboard will open/close on button press. If false, scoreboard stays open as long as button is held down.

    maxPlayers = GetConvarInt('sv_maxclients', 48), -- It returns 48 if it cant find the Convar Int

    -- Allows or disallows the viewing of Player IDs when having the scoreboard open.
    -- If set to 'admin_only', only admins can see player IDs.
    -- If set to 'admin_excluded', all players will see player IDs except for those of admins.
    -- If set to 'all', all players will see player IDs.
    idVisibility = 'admin_only',
}
