return {
    discordWebhook = nil, -- Replace nil with your webhook if you chose to use discord logging over ox_lib logging
    minOnDutyLogTimeMinutes = 30,
    formatDateTime = '%m-%d-%Y %H:%M',

    -- While the config boss menu creation still works, it is recommended to use the runtime export instead.
    -- Single menu: { coords = ..., size = ..., rotation = ..., type = ... }
    -- Multiple menus: { { coords = ..., size = ..., rotation = ..., type = ... }, { ... }  }
    ---@alias GroupName string
    ---@type table<GroupName, ZoneInfo|ZoneInfo[]>
    menus = {
        lostmc = {
            {
                coords = vec3(983.69, -90.92, 74.85),
                size = vec3(1.5, 1.5, 1.5),
                rotation = 39.68,
                type = 'gang',
            },
            {
                coords = vec3(976.2, -100.57, 74.87),
                size = vec3(1.5, 1.5, 1.5),
                rotation = 42.76,
                type = 'gang',
            },
        },
        -- Servidor: the Triads' boss menu. Every gang on this server can be joined in-world, and
        -- `srv_gunlab`, the site that makes all ten weapons, is reachable in ordinary play.
        --
        -- Moved 2026-08-20 out of the Maze Bank tower (-80.18, -800.43, 243.40) into the bail
        -- office with the rest of the re-surveyed base; see ADR-152. 6.53m from its nearest
        -- neighbour - not the 9.62m the tower gave it, but well clear of the 3m minimum and far
        -- better than the Cartel's 3.54m.
        triads = {
            coords = vec3(562.38, -2705.87, -49.00),
            size = vec3(1.5, 1.5, 1.5),
            rotation = 358.80,
            type = 'gang',
        },
        -- Servidor: the Cartel's first boss menu, surveyed 2026-08-20, on the upper level of the
        -- Tuners garage with their vault and wardrobe. Fifth of six gangs to get one; only `triads`
        -- is left without.
        --
        -- 3.54m from the vault in `srv_gangs` - the tightest pair on the server. It clears the 3m
        -- two-radii minimum, so the spheres never touch, but there is only 0.54m of room. Do not
        -- nudge either point without redoing the arithmetic.
        cartel = {
            coords = vec3(-1359.02, 137.23, -95.12),
            size = vec3(1.5, 1.5, 1.5),
            rotation = 87.83,
            type = 'gang',
        },
        -- Servidor: the Families' first boss menu, surveyed 2026-08-20, inside the DrugWars
        -- Freakshop with the rest of their base. They had none before, so nobody could be hired
        -- into the gang in-world and `srv_weedfarm` was unreachable in ordinary play.
        --
        -- 7.07m from the nearest other Families point (the route ped). A second vault position was
        -- surveyed 2.56m from here and deliberately not used - see the note in `srv_gangs`.
        families = {
            coords = vec3(555.24, -422.75, -69.65),
            size = vec3(1.5, 1.5, 1.5),
            rotation = 263.71,
            type = 'gang',
        },
        -- Servidor: the Ballas' first boss menu, surveyed 2026-08-20. Until now they had none at
        -- all, so nobody could be hired into the gang in-world and `srv_cracklab` was unreachable
        -- in ordinary play. Inside the base interior with the rest of their base; 5.95m from the
        -- nearest other point (the stash) against a 1.5m zone.
        ballas = {
            coords = vec3(1010.81, -3150.99, -38.91),
            size = vec3(1.5, 1.5, 1.5),
            rotation = 87.03,
            type = 'gang',
        },
        -- Servidor: moved 2026-08-20 from the Rancho lot (351.18, -2054.92, 22.09) into the Vagos
        -- base interior, where the rest of the base already is. The lot is open grass with no
        -- building on it - a boss menu standing in a field was the last piece still outside.
        --
        -- 6.34m from the nearest other Vagos point (the stash), against a 1.5m radius, so no two
        -- prompts can fire in the same place. The lot is still where the base is entered; that door
        -- is `Config.bases.vagos.entrance` in `srv_gangs`.
        vagos = {
            coords = vec3(1115.75, -3160.76, -36.87),
            size = vec3(1.5, 1.5, 1.5),
            rotation = 263.19,
            type = 'gang',
        },
    },
}
