-- Servidor: gang gameplay built on top of ADR-125's ownership of the six production sites.
--
-- ADR-125 made each site belong to a gang. This resource gives a gang something to DO with that:
-- a shared stash and a look at the shared bank account, both reached from the radial menu's own
-- `gangItems` slot - a hook `qbx_radialmenu` has always had and which shipped empty
-- (`gangItems = {}`) until now.
--
-- Deliberately NOT a new production system. Everything here hangs off resources that already
-- exist: `Renewed-Banking` for the account, `ox_inventory` for the stash, `qbx_radialmenu` for the
-- entry point. See ADR-126.

Config = {
    -- Servidor: where a gang's stash can be opened - inside that gang's own site, and nowhere else.
    --
    -- Every coordinate below is COPIED from the site's own already-surveyed press location (the
    -- farm's `pressStation`, or `srv_weedfarm_press`'s own point in `ox_inventory/data/crafting.lua`
    -- for the weed farm, which keeps its press there rather than in its config). None of these is a
    -- guessed position - they are real values this project already verified in-game, reused rather
    -- than re-surveyed (CLAUDE.md rule 4).
    --
    -- The radial needs no physical zone, so anchoring here does NOT collide with the crafting bench
    -- that already sits on the same spot: the bench is an `ox_inventory` target, this is a distance
    -- test the server runs when the radial item is clicked.
    --
    -- `stashRadius` is generous on purpose - it has to cover a whole interior from one point, and
    -- the stations can sit tens of metres from the press. Known and accepted consequence: the weed,
    -- cocaine and meth interiors are neighbours in the same `bob74_ipl` underground block, close
    -- enough that these radii overlap. That only ever lets a member open THEIR OWN gang's stash
    -- while standing in a neighbour's lab, never anyone else's, so it is untidy rather than
    -- exploitable.
    ---@type table<string, {label: string, coords: vector3, site: string}>
    stashes = {
        families = { label = 'Baú dos Verdes',    coords = vec3(1037.62, -3205.84, -37.97), site = 'srv_weedfarm' },
        cartel   = { label = 'Baú dos Laranjas',  coords = vec3(1101.22, -3198.75, -38.99), site = 'srv_cocainelab' },
        lostmc   = { label = 'Baú dos Brancos',   coords = vec3(1016.18, -3200.70, -38.99), site = 'srv_methlab' },
        ballas   = { label = 'Baú dos Roxos',     coords = vec3(483.43, -2624.10, -49.06),  site = 'srv_cracklab' },
        triads   = { label = 'Baú dos Vermelhos', coords = vec3(884.54, -3207.20, -98.20),  site = 'srv_gunlab' },
        vagos    = { label = 'Baú dos Amarelos',  coords = vec3(2696.48, -394.02, -55.31),  site = 'srv_ammolab' },
    },

    -- Servidor: 20m, down from 50m, so no gang's territory can ever reach another gang's ground.
    --
    -- The binding constraint is measured, not chosen: the closest two points belonging to different
    -- gangs are the weed and meth presses, 22.1m apart - they are neighbours in the same `bob74_ipl`
    -- underground block. Anything at or above that lets a member stand on one gang's floor and open
    -- their own stash, which is what 50m was doing. 20 clears it with 2.1m to spare.
    --
    -- **This changes what the radius MEANS.** At 50m it covered a whole interior, so the stash
    -- opened anywhere in the lab. At 20m it covers the press bench and its surroundings - a member
    -- at a far station now walks back to the press. That is the price of never conflicting, and it
    -- is affordable because gangs now have BASES with a dedicated stash point; the territory anchor
    -- is the fallback for the four that do not have one yet, not the main way in. See ADR-149.
    stashRadius = 20.0,

    -- Servidor: one tonne, by request. `ox_inventory` weights are in GRAMS - the 70000 this started
    -- at (copied from `policelocker`/`emslocker`) was 70kg, not 70 tonnes.
    --
    -- Slots stayed at 70, deliberately: the two limits bind on different things. A tonne is what
    -- lets a gang hoard heavy goods - a `repairkit` is 2.5kg, a brick of anything more - while 70
    -- slots still caps how many DISTINCT stacks fit. Raising only the weight is what was asked for
    -- and is the limit that was actually in the way.
    stashSlots = 70,
    stashWeight = 1000000,

    -- Servidor: the gang VAULT - a second shared container that takes money and nothing else, clean
    -- or dirty. Separate from the stash on purpose: mixing cash into general storage makes it
    -- invisible among the items, and a vault the whole gang can see is the point.
    --
    -- Two slots would technically do, one per accepted item, but a stack that hits its per-slot
    -- ceiling needs somewhere to spill; 5 leaves room without pretending the vault is general
    -- storage. The weight ceiling is deliberately large and untuned - there is nothing to balance
    -- it against yet.
    vaultSlots = 5,
    vaultWeight = 500000,

    -- What the vault accepts. Anything else is refused by the `swapItems` hook in `server.lua`.
    ---@type table<string, true>
    vaultItems = {
        money = true,
        black_money = true,
    },
}

-- Servidor: a gang's base, point by point. See ADR-136 for the shape and why it is filled in
-- gradually.
--
-- A base is made of six things on this server, and they do NOT all live here:
--
--   Menu do chefe   `qbx_management/config/server.lua` (`menus`) - hire, fire, promote
--   Garagem         `qbx_garages/config/server.lua`    - gang vehicles
--   Baú             HERE (`stash`)  - general storage
--   Cofre           HERE (`vault`)  - money only, clean or dirty
--   Guarda-roupa    HERE (`wardrobe`)
--   Rota de Cobrança HERE (`collectionRoute`) - the route ped (ADR-145)
--
-- The bank account is the seventh piece and has no coordinate at all - it lives in
-- `Renewed-Banking` and is reached from a Fleeca teller by the boss (ADR-131).
--
-- `blip` is copied from the boss-menu spot in `qbx_management`, since that is where a base
-- effectively is. Copied rather than read: it is another resource's server-side config with no
-- export. Kept in sync by hand, the same convention the press benches already use between a farm's
-- config and `ox_inventory/data/crafting.lua`.
--
-- The exception is a base with an `entrance`: there the blip marks the DOOR instead, because the
-- boss menu is inside an interior nobody can drive or walk to. A map marker has to point at
-- something a player can reach.
--
-- **A `nil` coordinate means that point does not exist yet, and the feature is simply absent for
-- that gang.** Nothing here guesses a position (CLAUDE.md rule 4), and nothing errors on a missing
-- one. This is the same "shipped fully implemented before the coordinates existed" shape
-- `srv_methlab` used (ADR-071).
--
-- **All six gangs now have a full base.** Every one can be joined in-world through its own boss
-- menu, and all six production sites are reachable in ordinary play. That closes ADR-125's open
-- gap, which stood from the moment the six sites were given owners: for most of that time four of
-- them could only be entered by setting a gang through `/admin`.
--
-- Lost MC is the only base without an `entrance`, because its base is a building you walk into.
---@class GangBase
---@field blip vector3      map marker for the base as a whole (the door, or the boss-menu spot)
---@field entrance {outside: vector4, inside: vector4}? [E] teleport pair, when the base is not walkable
--- Where `qbx_management`'s boss-menu zone is. **Copied from that resource's own server config**,
--- which has no export to read it from, so the two are kept in sync by hand - the same convention
--- the press benches already use between a farm's config and `ox_inventory/data/crafting.lua`.
---
--- Nothing here creates the boss menu; `qbx_management` owns it entirely. This exists so the point
--- can be DRAWN - that resource renders no ground marker and no map blip of its own, which left the
--- one part of a base a boss actually needs as the only invisible one.
---@field bossMenu vector3?
---@field stash vector3?    [E] to open the gang stash
---@field vault vector3?    [E] to open the gang vault (money only)
---@field wardrobe vector3? [E] to change clothes
--- Where the **Rota de Cobrança** ped stands. A member takes the route from it and is sent to a
--- handful of points picked at random from the 30 street corners `srv_jobs` already maps, to
--- collect what the sellers there owe the gang - "cobrança", not "entrega": nothing is delivered.
---
--- Named for what it is rather than when it is available. "Missão diária" describes a cooldown;
--- "Rota de Cobrança" describes the job. See ADR-145.
---@field collectionRoute vector3?
---@field collectionRouteHeading number? which way the route ped faces
---@type table<string, GangBase>
Config.bases = {
    -- Lost MC, surveyed 2026-08-19 and re-surveyed the same day with final labels.
    --
    -- The first pass produced two extra names, "armaria" and "armário", each landing ~10cm from a
    -- point that already existed. The re-survey resolved it: there are THREE containers here, not
    -- five - the extra names were the same physical objects walked twice. Those fields are gone
    -- rather than kept as dead config.
    --
    -- Closest pair is now 3.53m (boss menu to stash) against a 1.5m interaction radius, so no two
    -- prompts can fire in the same place.
    lostmc = {
        blip = vec3(983.69, -90.92, 74.85),
        bossMenu = vec3(983.69, -90.92, 74.85),
        stash = vec3(986.88, -92.43, 74.85),
        vault = vec3(976.72, -103.71, 74.85),
        wardrobe = vec3(971.99, -99.27, 74.85),
        collectionRoute = vec3(987.08, -95.40, 74.85),
        collectionRouteHeading = 228.93,
    },
    -- Triads, re-surveyed 2026-08-20 into the `SummerOffice` bail office, replacing the Maze Bank
    -- tower base surveyed the same day (see ADR-152 for what moved and what did not).
    --
    -- Free interior: nothing this project uses comes within 70m of any point.
    --
    -- Two levels, like the Cartel's: the stash sits at z = -52.80, everything else at -49.00. The
    -- 3.8m of vertical separation is real distance the horizontal figures do not show.
    --
    -- No collisions at all, and the boss menu has 6.53m of room - so this survey repeats the one
    -- good property the Maze Bank one had. Closest pair is 4.46m, wardrobe to vault, both in this
    -- file.
    --
    triads = {
        blip = vec3(903.52, -2273.29, 32.55),
        bossMenu = vec3(562.38, -2705.87, -49.00),
        entrance = {
            outside = vector4(903.52, -2273.29, 32.55, 85.31),
            inside = vector4(565.04, -2675.68, -49.00, 259.63),
        },
        stash = vec3(568.97, -2679.93, -52.80),
        vault = vec3(565.38, -2699.66, -49.00),
        wardrobe = vec3(568.27, -2703.06, -49.00),
        collectionRoute = vec3(560.82, -2690.19, -49.00),
        collectionRouteHeading = 268.35,
    },
    -- Cartel, surveyed 2026-08-20. The base is the Los Santos Tuners garage, 409.6m from a street
    -- door and 149.8m below it - the biggest vertical drop of any base here. Free interior: nothing
    -- this project already uses comes within 60m of any point.
    --
    -- The interior is on TWO LEVELS. The boss menu, vault and wardrobe sit at z = -95.12; the
    -- stash, exit and route ped at z ≈ -99. That is 4m of real separation the horizontal distances
    -- do not show, and it is why the upper three can sit as close together as they do.
    --
    -- TIGHTEST PAIR ON THE SERVER: boss menu to vault, 3.54m. It clears the 3m two-radii minimum by
    -- 0.54m, so the two spheres do not touch and only one prompt can ever show - but it is the
    -- cross-resource pair (`qbx_management` and here), the combination that has already gone wrong
    -- twice. It is correct as surveyed; it is simply the one with the least room left.
    --
    -- The route ped was surveyed TWICE. The first position was 0.12m from the exit - the same
    -- physical spot - so a member would have been standing in the doorway to take a route. The
    -- second, used here, is 13.96m clear.
    cartel = {
        blip = vec3(-1499.13, -201.18, 50.63),
        bossMenu = vec3(-1359.02, 137.23, -95.12),
        entrance = {
            outside = vector4(-1499.13, -201.18, 50.63, 116.81),
            inside = vector4(-1357.65, 152.80, -99.19, 168.15),
        },
        stash = vec3(-1366.75, 162.55, -98.99),
        vault = vec3(-1358.98, 140.77, -95.12),
        wardrobe = vec3(-1358.10, 145.37, -95.12),
        collectionRoute = vec3(-1358.11, 166.75, -98.93),
        collectionRouteHeading = 216.77,
    },
    -- Families, surveyed 2026-08-20. The base is the DrugWars Freakshop, at the bottom of a 95.7m
    -- drop from a street door 114.8m away. Free interior: the nearest thing this project already
    -- uses is 326m off, so nothing here shares a room with anyone.
    --
    -- Closest pair is 7.07m (boss menu to route ped) against a 1.5m radius, so no two prompts can
    -- fire in the same place.
    --
    -- TWO VAULT POSITIONS WERE SURVEYED and the SECOND one is not used. It sat 2.56m from the boss
    -- menu in `qbx_management` - under the 3m two-radii minimum, and worse, across a resource
    -- boundary, so both would have shown a prompt at once with neither knowing about the other.
    -- That is the exact defect the Vagos wardrobe had. The first position is 24.49m clear and is
    -- what is used here. Recorded rather than silently swapped.
    families = {
        -- The street door. Blip goes here, not on the boss menu, for the usual reason: the boss
        -- menu is 95m underground and nobody can walk to it.
        blip = vec3(615.68, -409.19, 26.03),
        bossMenu = vec3(555.24, -422.75, -69.65),
        entrance = {
            outside = vector4(615.68, -409.19, 26.03, 166.71),
            inside = vector4(556.97, -433.44, -69.65, 84.51),
        },
        stash = vec3(561.08, -405.15, -69.65),
        vault = vec3(573.85, -438.67, -69.52),
        wardrobe = vec3(563.79, -414.63, -69.65),
        collectionRoute = vec3(556.65, -415.82, -69.65),
        collectionRouteHeading = 174.77,
    },
    -- Ballas, surveyed 2026-08-20. Their base is in the same underground block the drug labs sit
    -- in, in its own room ~24m north of the Lost MC meth lab - checked, not assumed: every point
    -- here is more than 25m from every other gang's territory anchor, so the 20m `stashRadius`
    -- cannot reach across.
    --
    -- KNOWN, ACCEPTED: `wardrobe` and `vault` are 2.70m apart, under the 3m two-radii minimum.
    -- Unlike the Vagos case this is NOT two resources fighting - both are points in this file's own
    -- loop, which takes the first match in `BASE_POINTS` order, so the result is deterministic and
    -- only one prompt ever shows. The cost is a ~30cm band between them where the vault wins and
    -- the wardrobe cannot be reached. Usable; worth re-taking the wardrobe a metre further out.
    ballas = {
        -- The surface door, which is also where the garage is, 12.62m away - so one blip covers
        -- both ways into the gang's ground.
        blip = vec3(113.70, -1960.59, 21.32),
        bossMenu = vec3(1010.81, -3150.99, -38.91),
        -- 1489.9m end to end, the longest teleport on the server - see the note in `client.lua`'s
        -- `teleportTo` for why that distance is the whole reason this cannot be a plain
        -- `SetEntityCoords` (ADR-150).
        entrance = {
            outside = vector4(113.70, -1960.59, 21.32, 228.82),
            inside = vector4(997.98, -3158.14, -38.91, 84.49),
        },
        stash = vec3(1004.99, -3149.75, -38.91),
        vault = vec3(1008.43, -3171.15, -38.89),
        wardrobe = vec3(1009.83, -3168.84, -38.89),
        -- Note the z: -34.08, about 4.8m above every other point here. Taken as surveyed - the
        -- position came from standing there, so there is floor at that height.
        collectionRoute = vec3(1000.96, -3169.18, -34.08),
        collectionRouteHeading = 335.66,
    },
    -- Vagos, surveyed 2026-08-20. The base is INSIDE the `dlc_bikers` clubhouse 1 interior, in the
    -- same underground block the drug labs sit in, reached by a teleport pair from the Rancho lot
    -- where the gang's ground actually is - the same outside/inside shape the farms use (ADR-059).
    --
    -- Which clubhouse it is was got wrong once: an earlier comment here said `clubhouse2`, which is
    -- the interior around (998, -3164, -38) that was walked while searching. The points below are
    -- 120m east of that and belong to clubhouse 1. Corrected rather than left, because the next
    -- person to add a Vagos point would have gone looking in the wrong room.
    --
    -- The wardrobe was surveyed twice: the first spot sat 2.19m from the boss-menu zone in
    -- `qbx_management`, close enough that both would have shown a prompt at once - and they belong
    -- to different resources, so neither would have known the other was there. Re-surveyed 17.3m
    -- clear. Closest pair here is now 5.53m (wardrobe to route ped) against a 1.5m radius.
    vagos = {
        -- Servidor: the blip marks the DOOR, not the interior - the interior is underground and
        -- nobody walks to it. Same reasoning the farms' own blips follow.
        blip = vec3(364.73, -2064.39, 21.74),
        bossMenu = vec3(1115.75, -3160.76, -36.87),
        -- `[E]` teleport pair, same shape the farms use (ADR-059): the gang's ground is the Rancho
        -- lot, but that lot is open grass with no building, so the base itself lives in a loaded
        -- interior elsewhere and the two are joined by a door that is not a real door.
        entrance = {
            outside = vector4(364.73, -2064.39, 21.74, 231.13),
            inside = vector4(1120.91, -3151.93, -37.06, 178.19),
        },
        stash = vec3(1121.80, -3158.87, -37.06),
        vault = vec3(1111.55, -3147.05, -37.06),
        wardrobe = vec3(1118.00, -3143.57, -37.06),
        collectionRoute = vec3(1121.59, -3147.77, -37.06),
        collectionRouteHeading = 266.62,
    },
}

--- How close a player must stand to a base point for its `[E]` prompt to appear.
Config.baseInteractionDistance = 1.5

-- Servidor: the Rota de Cobrança. A member takes it from the base ped and is sent to a handful of
-- street corners to collect what the sellers there owe the gang. See ADR-145.
--
-- NOT a daily mission: no cooldown, no limit, run it as often as you like. It is illegal work that
-- only members can do, and like everything illegal on this server it pays in `black_money`
-- (ADR-142).
--
-- The stops are NOT defined here. They come from `srv_jobs`' own `GetSharedStops` - the same 30
-- real street points the street-dealing job already works, which is exactly the fiction: the gang
-- is collecting from the sellers who stand on those corners. One list, no copy to drift.
Config.collection = {
    -- How many of the 30 points one run visits. Picked at random each time, never repeating within
    -- a run, so two runs are different and a member cannot memorise a circuit.
    stops = 5,

    -- The daily ceiling, counted in STOPS COLLECTED, per citizenid, per real calendar day. 120 is
    -- 24 full runs. Read from the database's own CURDATE() rather than this server's clock - the
    -- same source the counter writes to, so "today" can never mean two different things.
    --
    -- Not a cooldown between runs: a member can run it back to back until the 120th point, and is
    -- then done until the next day. Told at the ped BEFORE starting, and again on the stop that
    -- hits the ceiling, so it is never a surprise.
    dailyStopLimit = 120,

    -- Paid per stop, in dirty money. A full run is 5x this. Deliberately in the same order as a
    -- legal job's per-stop pay (`srv_jobs` runs $90-$375) rather than far above it - the appeal
    -- is meant to be that it stacks with holding territory, not that it dwarfs honest work.
    payPerStop = 400,

    -- How close the member has to get before the collection prompt appears.
    stopDistance = 2.0,

    -- The ped that hands out the route. `ig_barry` is already spawned by several other resources on
    -- this server, so it is a model confirmed present in this install rather than a guess
    -- (CLAUDE.md rule 4).
    ped = `ig_barry`,
}
