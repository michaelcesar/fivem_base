-- Servidor: the weapon farm - buy scrap metal from an NPC, work one of 9 real stations to turn 4
-- scrap into a `weapon_part` (2 real minutes), then take 4 parts to the one press bench and choose
-- which of 10 real weapons to assemble (also 2 minutes - the press is `srv_gunlab_press` in
-- `ox_inventory/data/crafting.lua`, the same native slotted-crafting mechanism the drug farms use,
-- ADR-069). Every weapon comes out unregistered, the same flag `BlackMarketArms` already sells
-- under.
--
-- Deliberately NOT the drug farms' shape in every other way: no real-time "growth" (the station
-- timer is a flat 2 minutes, not hours), no accelerator, no retail/consumer split - a weapon is not
-- a consumable, there is only the one form. See ADR-116.
--
-- No NPC buyer, by request - unlike every drug farm's `dealer`, what comes off this press is for
-- the player who built it. Selling to another player, if it happens at all, goes through this
-- project's own player-to-player trade (`srv_trade`), not through this resource. See ADR-117.
--
-- **Fully mapped as of 2026-08-18.** Every real `/coords` below was taken by the user standing at
-- the actual spot, per CLAUDE.md's rule against guessing world positions.
Config = {
    -- Servidor: the gang that owns this site. Everything in the PRODUCTION chain - buying the input
    -- from the vendor, entering the interior, working a station, pressing, and selling wholesale to
    -- the dealer - is restricted to members of this gang. Street RETAIL is deliberately NOT gated:
    -- buying retail bags and running the selling route stay open to everyone, so a player with no
    -- gang still has illegal work. See ADR-125.
    --
    -- The Triads read as arms trafficking. This pairing and `srv_ammolab`'s are the least
    -- canonical of the six, and the two most worth swapping if either feels wrong in play.
    --
    -- Set to nil or 'none' to make this site unowned and open to everybody again; the checks read
    -- this field and nothing else, so ownership moves with one edit here.
    ownerGang = 'triads',

    -- The Gunrunning Bunker, `bob74_ipl/dlc_gunrunning/bunkers.lua` (interior 258561). It has 11
    -- real exterior entrances scattered across the map, all leading to the same interior; the
    -- Farmhouse one (Route 68 area) was picked as `entrance.outside` below.
    lab = {
        interiorId = 258561,
    },

    -- Confirmed NOT to have a real walkable door - same as `srv_methlab`, this is an
    -- `{ outside, inside, distance }` teleport pair, `srv_weedfarm`'s own ADR-059 shape. `outside`
    -- is the real Farmhouse bunker door (Route 68 area, one of the 11 real exterior entrances -
    -- `bob74_ipl/dlc_gunrunning/bunkers.lua`'s own comment coordinates); `inside` is what was first
    -- read as "saída", a real `/coords` right next to the interior. Both real, taken by the user,
    -- not computed. `distance` mirrors `srv_weedfarm`'s/`srv_methlab`'s own `entrance.distance`.
    entrance = {
        outside = vector4(1573.30, 2255.06, 78.61, 270.26),
        inside = vector4(901.96, -3182.50, -97.06, 270.89),
        distance = 1.5,
    },

    -- 9 real stations, filled in with a `/coords` pass exactly like srv_cocainelab's own 9 -
    -- closest pair (4-5) is 2.67m apart, comfortably clear of `stationDistance = 0.4`'s inner zones
    -- (2x0.4 = 0.8m) - no ADR-067/068-style overlap risk here.
    stations = (function()
        local coords = {
            vector4(885.30, -3200.13, -98.20, 45.89),
            vector4(887.40, -3209.22, -98.20, 206.81),
            vector4(891.91, -3197.82, -98.20, 351.99),
            vector4(897.65, -3217.93, -98.23, 62.30),
            vector4(897.60, -3220.60, -98.24, 198.64),
            vector4(899.57, -3224.79, -98.27, 26.44),
            vector4(905.39, -3229.33, -98.29, 188.24),
            vector4(909.29, -3222.63, -98.27, 293.06),
            vector4(908.76, -3211.71, -98.22, 15.63),
        }
        local list = {}
        for i = 1, #coords do
            list[i] = { key = ('station%d'):format(i), label = ('Estação %d'):format(i), coords = coords[i] }
        end
        return list
    end)(),
    stationDistance = 0.4,

    -- The press bench - `srv_gunlab_press` in `ox_inventory/data/crafting.lua`. Same coordinate
    -- set in BOTH places, the "kept in sync by hand" note every other press in this project
    -- carries. Nearest station (station 2, 887.40, -3209.22) sits 3.5m away, clear of the crafting
    -- bench's default 2.0m interaction radius - no explicit `distance` override needed there.
    pressStation = vector4(884.54, -3207.20, -98.20, 123.08),

    -- 2 real minutes per station batch, by request - short on purpose, unlike the drug farms'
    -- multi-hour real-time growth. The press bench's own 120000ms (`data/crafting.lua`) matches
    -- this exactly, so both halves of the chain take the same real time.
    processingMinutes = 2,

    -- ms, ox_lib progress circle shown while starting a batch - mirrors the drug farms' own
    -- `processDuration`.
    processDuration = 3000,

    -- How much raw part one station batch yields.
    yieldPerBatch = 1,

    -- Real items, in `ox_inventory/data/items.lua`: `metalscrap` (reused, previously an unused
    -- stub) is the raw material; `weapon_part` (new) is what a station produces. The 10 real
    -- weapons themselves need no new item - they already exist in the base game catalog.
    materialItem = 'metalscrap',
    partItem = 'weapon_part',

    -- Servidor: `ig_barry` - a placeholder, not a choice, same reasoning as every other illegal
    -- vendor in this project (`srv_weedfarm`'s seed vendor, `srv_cocainelab`'s leaf vendor):
    -- already confirmed present, not a new unverified guess. Swap once a specific model is chosen
    -- and confirmed with `srv_tools`' `/testped`.
    vendor = vector4(713.82, 4093.79, 34.73, 86.91),
    vendorPed = `ig_barry`,
    vendorDistance = 2.0,
    materialPrice = 150,
    materialPurchaseCeiling = 50,

    -- Servidor: the 10 real weapons this farm can assemble - the recipes themselves live in
    -- `ox_inventory/data/crafting.lua`'s `srv_gunlab_press` bench; this list is kept here only so
    -- other parts of this resource (if any ever need to enumerate "every weapon this farm makes")
    -- have one place to read it from, rather than duplicating the bench's own recipe list. Real
    -- weapon names, verified against `ox_inventory/data/weapons.lua` rather than picked freehand -
    -- chosen to span as many distinct GTA weapon classes as this catalog has, per request ("pt,
    -- fuzil, etc... cobrir todas as classes").
    weapons = {
        'WEAPON_PISTOL',
        'WEAPON_COMBATPISTOL',
        'WEAPON_SMG',
        'WEAPON_MICROSMG',
        'WEAPON_SAWNOFFSHOTGUN',
        'WEAPON_PUMPSHOTGUN',
        'WEAPON_CARBINERIFLE',
        'WEAPON_ASSAULTRIFLE',
        'WEAPON_COMBATMG',
        'WEAPON_SNIPERRIFLE',
    },
}

return Config
