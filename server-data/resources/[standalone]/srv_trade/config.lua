-- Servidor: player-to-player trading. The point is that neither side has to trust the other and
-- neither has to use "give to nearest" - both offers are visible, both must confirm, and the swap
-- happens in one server-side step or not at all.
--
-- The dangerous part of this feature is not the screen, it is this: any trade system that moves
-- items between two inventories is one race condition away from duplicating them. Everything in
-- server.lua is written around that, and config.lua is deliberately small - there is very little
-- here worth tuning, because the rules are not preferences.
--
Config = {
    -- Servidor: how far apart the two may be. Checked when the trade is proposed, on every offer
    -- change, and again at the moment of the swap - a trade that starts face to face and finishes
    -- with one of them in a car two streets away is the shape every "trade scam" exploit takes.
    maxDistance = 3.0,

    -- Servidor: how often the server re-checks that both are still there and still close, in ms. The
    -- swap re-checks anyway, so this only decides how quickly an abandoned trade closes itself
    -- rather than sitting open.
    watchInterval = 2000,

    -- Servidor: how long an unanswered invite stays open, in seconds.
    inviteSeconds = 20,

    -- Servidor: slots each side may offer at once. Not a balance number - it is the size of the
    -- offer grid the UI draws, and the two have to agree.
    offerSlots = 10,
}

return Config
