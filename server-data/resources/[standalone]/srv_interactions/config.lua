-- Servidor: player-to-player interaction, reachable two ways - the target key (this is the only
-- place in the project that uses the target system) and an `[E]` prompt on the nearest person.
--
-- ADR-101 originally kept people OFF `[E]` entirely - a PLACE was `[E]` (every farm, shop counter,
-- launderer and depot) and a PERSON was the target key, so the two could never compete for one
-- spot, which is exactly the collision that cost ADR-097 through ADR-100 four attempts. ADR-112
-- added `[E]` anyway, by request, and resolves that collision more narrowly instead: the `[E]` loop
-- in client.lua stands down whenever something else already owns the text UI, so a place always
-- wins the tie and the target key stays the way to pick a specific person out of a crowd.
--
-- What existed before this was commands: `/cuff`, `/escort`, `/jail`. They work, but they require
-- remembering a command and they act on `getClosestPlayer()` - with two people side by side, the
-- wrong one gets cuffed. Every action below passes the exact player the menu was opened on, using
-- `qbx_police`'s own server events, which all take a target id.
--
-- SECURITY: the `canInteract` gates below are DISPLAY ONLY. Three of the police events they guard
-- (`SearchPlayer`, `SeizeCash`, `SetTracker`) shipped with no authorisation at all - distance was
-- the only check - so a modified client could fire them regardless of any menu. That was fixed in
-- `qbx_police` itself rather than papered over here; see ADR-101 and docs/patches.md. Read the
-- gates below as "what the menu offers", never as "what the server allows".
--
Config = {
    -- Servidor: how close the target has to be for an option to appear at all. The police events do
    -- their own distance check server-side, so this only keeps the menu tidy.
    maxDistance = 2.5,

    -- Servidor: any of these items lets a player cuff - `qbx_police` reads the exact same list from
    -- its own `config.handcuffItems` (`config/client.lua`) and refuses without one server-side;
    -- this is here so the menu can hide the option rather than offering something that will be
    -- refused. Kept as this resource's own copy rather than a cross-resource require, matching how
    -- every other config value here works.
    --
    -- By request, cuffing is NOT police-only: anyone holding one of these can do it. `handcuffs` is
    -- sold by `PoliceSupply`, `rope` by `YouTool` (both in ox_inventory/data/shops.lua, whose peds
    -- are spawned further down this file). See ADR-101.
    handcuffItems = { 'handcuffs', 'rope' },

    -- Servidor: how much a player may hand over in one go. A sanity bound on the input dialog, not a
    -- balance decision - the server re-checks the payer actually has it.
    maxGiveAmount = 1000000,

    -- Servidor: where the handcuff vendor stands. The SHOP itself is `PoliceSupply` in
    -- ox_inventory/data/shops.lua at this same coordinate - only the ped is spawned here, because
    -- ox_inventory spawns one on the target-mode path and this server runs `inventory:target false`.
    -- A real /coords, up in Grapeseed and deliberately away from the city.
    handcuffVendor = vector4(1852.80, 3689.65, 34.27, 206.71),

    -- `s_m_y_cop_01` - a real base-game police model, and the only ped in this project not reusing
    -- `ig_barry`. Worth confirming with /testprop before trusting it: a wrong model fails silently
    -- and the vendor simply never appears (CLAUDE.md hard rule 4).
    handcuffVendorPed = `s_m_y_cop_01`,
}

return Config
