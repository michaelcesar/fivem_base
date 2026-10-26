-- Servidor: door-to-interior teleports for vehicle dealerships. `qbx_vehicleshop` has no concept of
-- an interior at all - it knows a polygon, a blip, showroom cars and spawn points, and assumes the
-- player can simply walk to all of them. That holds for an open-air lot and breaks the moment a
-- dealership is inside a building, which `luxo` now is.
--
-- Rather than teach `qbx_vehicleshop` about doors (a large patch to a third-party resource, on a
-- file we would have to re-apply on every update), the teleport lives here as its own resource,
-- using the exact `entrance = { outside, inside, distance }` shape every interior in this project
-- already uses - see `srv_weedfarm`, `srv_cracklab` and ADR-059.
--
-- A dealership that is NOT in an interior simply has no entry here and is unaffected.
Config = {
    -- Servidor: how far from a door's `inside` point still counts as "in that showroom", used when a
    -- purchase has to send the buyer out before their car appears on the street. It is not the
    -- prompt radius - it has to cover the whole showroom floor, since the player could be standing
    -- at any car when they buy. The widest showroom here (`premium`) puts a car ~39m from its
    -- arrival point, so 60 clears it with room; the two interiors are thousands of metres apart, so
    -- there is no risk of one matching the other.
    insideRadius = 60.0,

    doors = {
        {
            -- Must match the shop key in `qbx_vehicleshop/config/shared.lua`. Only used for the
            -- prompt text and for keeping these two files traceable to each other.
            shop = 'luxo',
            label = 'Lite Motors - Luxo',

            -- `outside` is on the street, `inside` is in the showroom. The same pair drives both
            -- directions: press [E] at one and you arrive at the other, which is why there is no
            -- separate "exit" coordinate.
            outside = vector4(-115.91, -605.03, 36.28, 70.44),
            inside = vector4(-197.70, -580.65, 136.00, 80.56),

            -- How close to either point the prompt appears. 1.5 rather than the tighter 0.5 the
            -- farms use: a dealership door is a public, walk-up entrance, not a hidden one.
            distance = 1.5,
        },
        {
            shop = 'premium',
            label = 'Lite Motors - Premium',

            -- Servidor: the longest teleport in the project by far - a street door in East Los
            -- Santos to a warehouse 66m below sea level, right across the map. `bob74_ipl`'s
            -- `dlc_import/vehicle_warehouse`, interior 252673.
            outside = vector4(234.14, -1874.07, 26.52, 48.03),
            inside = vector4(970.82, -2988.12, -39.65, 1.11),

            distance = 1.5,
        },
        {
            shop = 'vip',
            label = 'Lite Motors - VIP',

            -- Servidor: `bob74_ipl`'s `dlc_import/garage3`, interior 255489 - a three-level showroom.
            -- The door was first surveyed in Morningwood, ~300m from this shop's own delivery kerb,
            -- and was moved here on 2026-08-18 to sit at the real garage building instead, ~45m from
            -- the spawns. The purchase teleport does not depend on that distance either way (it
            -- targets the spawn point, not this door), but a player walking in and out does.
            outside = vector4(-1582.08, -557.23, 34.95, 209.10),
            inside = vector4(-1585.69, -562.28, 86.50, 35.59),

            distance = 1.5,
        },
    },

    -- Servidor: `ig_barry` is a PLACEHOLDER, not a choice - it is simply a model already confirmed
    -- present and already used at six `srv_jobs` depots and every drug vendor, which is the same
    -- call `srv_cocainelab` documents for its own NPCs. A salesman model has not been picked yet
    -- because CLAUDE.md rule 4 forbids committing to a ped name that has not been seen in game: a
    -- wrong hash fails silently and the vendor simply never appears. Confirm one with `srv_tools`'
    -- `/testped <model>` and change this single line.
    vendorPed = `ig_barry`,

    -- Servidor: decorative only - no interaction, no gameplay effect, the same shape as the armed
    -- peds standing at `srv_jobs`' depot. Buying still happens at the cars themselves, which is
    -- where `qbx_vehicleshop` puts it; a vendor that also opened the menu would be a second way to
    -- do the same thing in the same room.
    --
    -- Every `z` here is the surveyed reading MINUS 1.0. `/coords` reports the ped's centre, about a
    -- metre above the floor, so spawning at the raw value leaves the vendor hovering - the same
    -- offset `srv_interactions` already subtracts for its handcuff vendor, and the same one that
    -- left the `luxo` showroom cars in the air (see docs/conventions.md).
    vendors = {
        { shop = 'pdm', coords = vector4(-60.20, -1843.06, 26.58, 313.81) },
        { shop = 'premium', coords = vector4(997.16, -2998.58, -39.65, 111.01) },
        { shop = 'luxo', coords = vector4(-190.02, -585.68, 136.00, 2.93) },
        { shop = 'vip', coords = vector4(-1587.26, -572.14, 86.50, 299.99) },
    },
}

return Config
