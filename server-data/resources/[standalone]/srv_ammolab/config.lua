-- Servidor: the ammo farm - buy scrap copper from an NPC, work one of 9 real stations to turn 4
-- copper into an `ammo_part` (2 real minutes), then take 4 parts to the one press bench and choose
-- which of 6 real ammo types to load (also 2 minutes - the press is `srv_ammolab_press` in
-- `ox_inventory/data/crafting.lua`, the same native slotted-crafting mechanism the drug farms and
-- `srv_gunlab` use, ADR-069). `srv_gunlab`'s sibling resource, not a module of it - two entirely
-- separate resources by request, same as every other pair of illegal farms in this project.
--
-- Six ammo types, not ten - one per distinct calibre `srv_gunlab`'s own ten weapons actually use
-- (`ox_inventory/data/weapons.lua`'s own `ammoname` field, several weapons share a calibre), not
-- one per weapon. See ADR-116.
--
-- No NPC buyer, by request - same reasoning as `srv_gunlab`'s own removal: what comes off the
-- press is for the player who built it, and a sale to another player goes through `srv_trade`,
-- not through this resource. See ADR-117.
--
-- **Fully mapped as of 2026-08-19.** Every real `/coords` below was taken by the user standing at
-- the actual spot, per CLAUDE.md's rule against guessing world positions.
Config = {
    -- Servidor: the gang that owns this site. Everything in the PRODUCTION chain - buying the input
    -- from the vendor, entering the interior, working a station, pressing, and selling wholesale to
    -- the dealer - is restricted to members of this gang. Street RETAIL is deliberately NOT gated:
    -- buying retail bags and running the selling route stay open to everyone, so a player with no
    -- gang still has illegal work. See ADR-125.
    --
    -- The Vagos take ammo, leaving all six gangs with exactly one site each.
    --
    -- Set to nil or 'none' to make this site unowned and open to everybody again; the checks read
    -- this field and nothing else, so ownership moves with one edit here.
    ownerGang = 'vagos',

    -- The Diamond Casino Arcade's basement, `dlc_casino/arcade_basement` (interior 278529) -
    -- replaces an earlier pick of the Chop Shop's Ferro-velho, dropped once it read as a
    -- mechanic's garage rather than anything ammo-related. Also replaces two other candidates
    -- tried and rejected because `bob74_ipl` doesn't know their interior IDs in this game build at
    -- all (`GetInteriorPosition` throws rather than returning 0,0,0 for them): every
    -- `dlc_kortz/*` interior, and `dlc_agents/factory`.
    lab = {
        interiorId = 278529,
    },

    -- Confirmed NOT to have a documented real walkable door - `bob74_ipl`'s own arcade files
    -- carry no exterior coordinate the way the Gunrunning Bunker's own file did for its 11 real
    -- doors. An `{ outside, inside, distance }` teleport pair instead, `srv_weedfarm`'s own
    -- ADR-059 shape, same as `srv_gunlab`'s. `outside` is a real street coordinate the user chose
    -- freely (no official door to match, since the teleport doesn't need one); `inside` is a real
    -- `/coords` right next to the interior.
    entrance = {
        outside = vector4(-11.59, -1829.61, 25.39, 320.58),
        inside = vector4(2737.84, -374.72, -47.99, 358.25),
        distance = 1.5,
    },

    -- 9 real stations, filled in with a `/coords` pass exactly like every other farm's own 9.
    stations = (function()
        local coords = {
            vector4(2683.39, -359.37, -55.19, 354.15),
            vector4(2703.03, -355.54, -55.19, 85.03),
            vector4(2702.89, -353.68, -55.19, 91.40),
            vector4(2711.13, -355.44, -55.19, 86.07),
            vector4(2711.19, -353.32, -55.19, 92.84),
            vector4(2704.44, -367.96, -54.78, 179.83),
            vector4(2720.34, -362.73, -53.59, 259.53),
            vector4(2718.47, -362.97, -53.59, 89.96),
            vector4(2701.49, -359.44, -55.19, 25.11),
        }
        local list = {}
        for i = 1, #coords do
            list[i] = { key = ('station%d'):format(i), label = ('Estação %d'):format(i), coords = coords[i] }
        end
        return list
    end)(),
    stationDistance = 0.4,

    -- The press bench - `srv_ammolab_press` in `ox_inventory/data/crafting.lua`. Same coordinate
    -- set in BOTH places. Moved here from an earlier reading that sat ~0.94m from station 7 (which
    -- had forced an explicit `distance` override on the bench, since reverted) - this spot is
    -- >25m from every station, no overlap risk at all.
    pressStation = vector4(2696.48, -394.02, -55.31, 184.40),

    -- 2 real minutes per station batch, matching `srv_gunlab` exactly - both farms share the same
    -- pacing by request, not just the same shape.
    processingMinutes = 2,

    -- ms, ox_lib progress circle shown while starting a batch.
    processDuration = 3000,

    -- How much raw part one station batch yields.
    yieldPerBatch = 1,

    -- Real items, in `ox_inventory/data/items.lua`: `copper` (reused, previously an unused stub)
    -- is the raw material; `ammo_part` (new) is what a station produces. The 6 real ammo types
    -- themselves need no new item - they already exist in the base game catalog.
    materialItem = 'copper',
    partItem = 'ammo_part',

    -- Servidor: `ig_barry` placeholder, same reasoning as every other illegal vendor in this
    -- project. Swap once a specific model is chosen and confirmed with `srv_tools`' `/testped`.
    vendor = vector4(1456.66, -1663.58, 66.07, 278.97),
    vendorPed = `ig_barry`,
    vendorDistance = 2.0,
    materialPrice = 120,
    materialPurchaseCeiling = 50,

    -- Servidor: the 6 real ammo types this farm can load - the recipes themselves live in
    -- `ox_inventory/data/crafting.lua`'s `srv_ammolab_press` bench; this list is kept here only so
    -- other parts of this resource (if any ever need to enumerate "every type this farm makes")
    -- have one place to read it from. Real item names, verified against
    -- `ox_inventory/data/weapons.lua`'s own `ammoname` field for each of `srv_gunlab`'s ten
    -- weapons (not guessed).
    ammoTypes = {
        'ammo-9',
        'ammo-45',
        'ammo-shotgun',
        'ammo-rifle',
        'ammo-rifle2',
        'ammo-sniper',
    },
}

return Config
