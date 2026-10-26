return {
	{
        -- Servidor: srv_weedfarm's press table - the real slotted crafting UI (open inventory +
        -- ingredient slots + a craft button) instead of a custom ox_lib context menu, by request:
        -- this is exactly the layout the project's own HUD design calls "our standard" for
        -- crafting, and it stops a player from being able to flood [E] the way a plain prompt
        -- could. `points` is `srv_weedfarm/config.lua`'s own real `processStation` coordinate
        -- (`/coords`, not guessed) - the two must be kept in sync if that point ever moves.
        -- `ingredients = { weed_skunk = 5 }` matches `srv_weedfarm`'s old `processCount` exactly.
        -- See ADR-069.
        name = 'srv_weedfarm_press',
        label = 'Prensa de Maconha',
        items = {
            {
                name = 'weed_brick',
                ingredients = { weed_skunk = 5 },
                duration = 8000,
            },
        },
        points = {
            vec3(1037.62, -3205.84, -37.97),
        },
    },
	{
        -- Servidor: srv_cocainelab's press table - same reasoning and shape as srv_weedfarm's
        -- above (ADR-069), reused for its sibling resource (ADR-070+). `points` is
        -- `srv_cocainelab/config.lua`'s own real `pressStation` coordinate, a user-taken
        -- `/coords` inside bob74_ipl's Cocaine Lockup - the two must be kept in sync if that
        -- point ever moves. `ingredients = { cocaine_paste = 5 }` mirrors `weed_skunk = 5` above
        -- exactly, by request ("mantém exatamente igual").
        name = 'srv_cocainelab_press',
        label = 'Prensa de Cocaína',
        items = {
            {
                name = 'cocaine_brick',
                ingredients = { cocaine_paste = 5 },
                duration = 8000,
            },
        },
        points = {
            vec3(1101.22, -3198.75, -38.99),
        },
    },
	{
        -- Servidor: srv_cracklab's press table - same shape as the other three (ADR-069). `points` is
        -- srv_cracklab/config.lua's own real `pressStation` coordinate; the two must be kept in sync.
        --
        -- `distance` is set explicitly here, unlike the other three, and it is not cosmetic: the
        -- default is 2.0, and at that radius this bench would swallow the lab's exit point (1.15m
        -- away) and three of its eight stations (1.47m, 1.70m, 1.97m). 0.6 clears all of them. See
        -- ADR-094.
        name = 'srv_cracklab_press',
        label = 'Prensa de Crack',
        items = {
            {
                name = 'crack_brick',
                ingredients = { crack_rock = 5 },
                duration = 8000,
            },
        },
        points = {
            vec3(483.43, -2624.10, -49.06),
        },
        distance = 0.6,
    },
	{
        -- Servidor: srv_methlab's press table - same reasoning and shape as the two above
        -- (ADR-069/070), reused for this third sibling resource (ADR-071). `points` is
        -- `srv_methlab/config.lua`'s own real `pressStation` coordinate, a user-taken `/coords`
        -- inside bob74_ipl's Meth Lab, in a separate corner of the room from the row of 9
        -- processing stations - the two must be kept in sync if that point ever moves.
        -- `ingredients = { meth = 5 }` mirrors `weed_skunk = 5`/`cocaine_paste = 5` above exactly.
        name = 'srv_methlab_press',
        label = 'Prensa de Metanfetamina',
        items = {
            {
                name = 'meth_brick',
                ingredients = { meth = 5 },
                duration = 8000,
            },
        },
        points = {
            vec3(1016.18, -3200.70, -38.99),
        },
    },
	{
        -- Servidor: `srv_gunlab`'s single press bench - same ADR-069 shape as the three drug
        -- presses above, but TEN recipes instead of one: the station step below only ever produces
        -- the generic `weapon_part`, and which of the ten real weapons it becomes is chosen here,
        -- at the bench, the same way a player picks a strain when planting rather than when
        -- harvesting. `ingredients = { weapon_part = 4 }` and `duration = 120000` (2 real minutes)
        -- on every recipe, by request - unlike the drug presses' instant 8s, this step is meant to
        -- take real time, the same as the station step that feeds it.
        --
        -- `metadata = { registered = false }` on every recipe - these are illegally manufactured,
        -- the same flag `BlackMarketArms` already sells unregistered weapons under
        -- (`ox_inventory/data/shops.lua`), not a new convention.
        --
        -- `points` is empty until `srv_gunlab/config.lua`'s own real `pressStation` coordinate
        -- exists - the same "not playable until mapped" shape `srv_methlab` shipped fully
        -- implemented under before its own coordinates existed (ADR-071).
        name = 'srv_gunlab_press',
        label = 'Bancada de Armas',
        items = {
            { name = 'WEAPON_PISTOL', ingredients = { weapon_part = 4 }, duration = 120000, metadata = { registered = false } },
            { name = 'WEAPON_COMBATPISTOL', ingredients = { weapon_part = 4 }, duration = 120000, metadata = { registered = false } },
            { name = 'WEAPON_SMG', ingredients = { weapon_part = 4 }, duration = 120000, metadata = { registered = false } },
            { name = 'WEAPON_MICROSMG', ingredients = { weapon_part = 4 }, duration = 120000, metadata = { registered = false } },
            { name = 'WEAPON_SAWNOFFSHOTGUN', ingredients = { weapon_part = 4 }, duration = 120000, metadata = { registered = false } },
            { name = 'WEAPON_PUMPSHOTGUN', ingredients = { weapon_part = 4 }, duration = 120000, metadata = { registered = false } },
            { name = 'WEAPON_CARBINERIFLE', ingredients = { weapon_part = 4 }, duration = 120000, metadata = { registered = false } },
            { name = 'WEAPON_ASSAULTRIFLE', ingredients = { weapon_part = 4 }, duration = 120000, metadata = { registered = false } },
            { name = 'WEAPON_COMBATMG', ingredients = { weapon_part = 4 }, duration = 120000, metadata = { registered = false } },
            { name = 'WEAPON_SNIPERRIFLE', ingredients = { weapon_part = 4 }, duration = 120000, metadata = { registered = false } },
        },
        points = {
            vec3(884.54, -3207.20, -98.20),
        },
    },
	{
        -- Servidor: `srv_ammolab`'s own press bench, same shape as `srv_gunlab_press` above - SIX
        -- recipes (one per distinct ammo type the ten weapons actually use, not one per weapon;
        -- several of them share a calibre), each `ammo_part = 4`, 120000ms. No `registered` flag -
        -- ammo doesn't carry one anywhere else in this catalog.
        --
        -- `points` is `srv_ammolab/config.lua`'s own real `pressStation` coordinate - the two
        -- must be kept in sync if that point ever moves. Far enough from every station (>25m) that
        -- no explicit `distance` override is needed, unlike the drug presses' own tighter spots.
        name = 'srv_ammolab_press',
        label = 'Bancada de Munição',
        -- Servidor: `count = 200` on every recipe, by request - one press cycle (4x `ammo_part`,
        -- 2 real minutes) yields a 200-round pack, not a single round. `ox_inventory`'s own
        -- crafting `count` field is the yield quantity, same as `debug_crafting`'s own `lockpick`
        -- recipe (`count = 2`) elsewhere in this file - not a new mechanism.
        items = {
            { name = 'ammo-9', ingredients = { ammo_part = 4 }, duration = 120000, count = 200 },
            { name = 'ammo-45', ingredients = { ammo_part = 4 }, duration = 120000, count = 200 },
            { name = 'ammo-shotgun', ingredients = { ammo_part = 4 }, duration = 120000, count = 200 },
            { name = 'ammo-rifle', ingredients = { ammo_part = 4 }, duration = 120000, count = 200 },
            { name = 'ammo-rifle2', ingredients = { ammo_part = 4 }, duration = 120000, count = 200 },
            { name = 'ammo-sniper', ingredients = { ammo_part = 4 }, duration = 120000, count = 200 },
        },
        points = {
            vec3(2696.48, -394.02, -55.31),
        },
    },
	{
        name = 'debug_crafting',
		items = {
			{
				name = 'lockpick',
				ingredients = {
					scrapmetal = 5,
					WEAPON_HAMMER = 0.05
				},
				duration = 5000,
				count = 2,
			},
		},
		points = {
			vec3(-1147.083008, -2002.662109, 13.180260),
			vec3(-345.374969, -130.687088, 39.009613)
		},
		zones = {
			{
				coords = vec3(-1146.2, -2002.05, 13.2),
				size = vec3(3.8, 1.05, 0.15),
				distance = 1.5,
				rotation = 315.0,
			},
			{
				coords = vec3(-346.1, -130.45, 39.0),
				size = vec3(3.8, 1.05, 0.15),
				distance = 1.5,
				rotation = 70.0,
			},
		},
		blip = { id = 566, colour = 31, scale = 0.8 },
	},
}
