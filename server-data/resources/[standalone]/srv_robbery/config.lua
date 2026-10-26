-- Servidor: armed robbery - the first tier, convenience stores. Built as one resource with room for
-- the tiers above it (houses, then safes/jewellery) rather than one resource per tier: the three
-- share almost everything that matters - police gating, cooldowns, the minigame wrappers, the
-- payout path - and only differ in what they need to get in and what they leave with. See ADR-097.
--
-- This tier deliberately needs no tools. Houses will need a lockpick and safes a security card, by
-- request; making the entry rung free is what lets a new player attempt something at all.
--
Config = {
    -- Servidor: how many LEOs must be on duty before any robbery can start. This is the single most
    -- important number here and it is not a difficulty knob: a robbery with nobody to respond is
    -- not a robbery, it is a withdrawal. Counted server-side from `qbx_core`'s own player list on
    -- every attempt, never trusted from the client.
    --
    -- 2 is a starting guess for a server this size. Set it to 0 only to test.
    policeRequired = 2,

    -- Servidor: how long a specific store stays closed after being robbed, in real minutes. Stored
    -- in the database rather than in memory so a restart cannot be used to clear it - the same
    -- reasoning every farm's growth timer already follows.
    storeCooldownMinutes = 45,

    -- Servidor: how long the robber personally has to wait before their next store, anywhere. Without
    -- this, one player could walk the map hitting all 16 counters back to back, since each store's
    -- own cooldown is independent.
    playerCooldownMinutes = 30,

    -- Servidor: the same two-tier marker + `[E]` shape every point in this project uses (ADR-066) -
    -- the outer radius is only how far away the marker becomes visible. Applies to the 16 shop
    -- counters, the two launderers and the factory entrance alike; nothing here is on a different
    -- interaction system any more. See ADR-100.
    interactDistance = 1.5,

    -- Servidor: `mhacking` settings. The codes themselves are given away - `mhacking`'s own
    -- `writeSolution` was patched to mark them (see docs/patches.md) - and the difficulty is the clock.
    --
    -- What it actually is: a 9x18 grid of hex characters scrambling every 5ms, with TWO static
    -- codes hidden in it. The player drives two cursors at once - WASD plus Space for one, arrow
    -- keys plus Enter for the other - and both must be matched. A wrong confirmation cuts time, and
    -- the cut grows with each mistake.
    --
    -- The two numbers do different jobs now that the codes are marked. `solutionLength = 5` makes
    -- them EASIER, not harder: a five-cell highlighted block is unmissable where a two-cell one is
    -- easy to overlook, so finding the answer costs nothing. What is left is moving two cursors
    -- there, and that is where the clock bites - the grid is 9x18, so a cursor can be up to 27 key
    -- presses from its target, times two cursors, on two hands.
    --
    -- So: the answer is given, the clock is not. Requested as "some tension" after 60 seconds with
    -- marked codes turned out to be no challenge at all.
    --
    -- DO THE ARITHMETIC BEFORE CHANGING `duration` (hard rule 8). Two numbers inside `mhacking`
    -- decide what a given clock actually means, and neither is visible from here:
    --
    --   * a fixed 3s intro plays before the clock starts, so `duration` is real playing time;
    --   * a wrong confirmation costs `mistakes * penalty`, and `mistakes` grows each time, so the
    --     running total after n mistakes is `penalty * n(n+1)/2`.
    --
    -- `penalty` was cut from upstream's 5000ms to 2000ms for this clock (see docs/patches.md).
    -- At 10s that gives: 8s left after one mistake, 4s after two, and the third is fatal at 12s of
    -- penalty against a 10s clock. Upstream's 5000 would have ended the round on the SECOND
    -- mistake, which is a normal thing to do while driving two cursors in ten seconds.
    hack = {
        solutionLength = 5,
        duration = 10,
    },

    -- Servidor: a robbery cannot possibly finish faster than this, in seconds. The minigame runs on
    -- the client and reports its own result, which is the unavoidable weak point (see ADR-097's
    -- consequences) - this is the cheapest of the several server-side checks that bound how much a
    -- lying client can actually take.
    --
    -- Three, not six, and the number is derived rather than chosen. The clock is measured from the
    -- server callback that starts the robbery, and `mhacking` plays a fixed 3s intro before the
    -- player can press anything - so the floor of an honest attempt is 3s plus however long the
    -- solve takes. With the codes marked and a 10s clock, a good player solves in one or two
    -- seconds; at `6` that player would be refused, lose the payout AND burn both cooldowns for
    -- playing well. `3` still catches the only thing this check can catch - a client that replies
    -- "won" without playing - and can never punish someone who did.
    --
    -- `os.time()` has one-second resolution, so this comparison is fuzzy by up to a second either
    -- way. That is fine at 3 and was not fine at 6.
    minimumSeconds = 3,

    -- Servidor: paid in `black_money`, the dirty-money item ox_inventory already ships. It is not a
    -- dead reward: `BlackMarketArms` in `data/shops.lua` is already placed at (309.09, -913.75,
    -- 56.46) and prices everything it sells in that currency, so dirty money can be spent at face
    -- value the moment it is stolen. Laundering below is the other outlet, at a discount.
    --
    -- CLAUDE.md rule 8, and this corrects a number that was wrong when this file was first
    -- written. At $2500-6000 with a 20-minute player cooldown a robber could clear roughly
    -- $12,750 an hour, against a drug farm's ~$1067 - twelve times a farm, for a minute of work.
    -- That was never computed; it is now.
    --
    --   $1500-3000 dirty, laundered at 60%  ->  $900-1800 clean per robbery
    --   30-minute player cooldown           ->  2 robberies an hour
    --   so roughly $1800-3600/h clean, against a farm's ~$1067/h.
    --
    -- Two to three times a farm, for something that demands police be online, cannot be done from
    -- a chair, and ends in arrest often enough to matter. Spending it unlaundered at the black
    -- market is worth more per dollar, which is the tension worth having.
    payoutItem = 'black_money',
    payout = {
        min = 1500,
        max = 3000,
    },

    -- Servidor: laundering - the only way to turn dirty money into spendable cash. It lives in this
    -- resource rather than its own because the tiers above (houses, then safes) will pay in the same
    -- currency and need the same contacts.
    --
    -- Two launderers with different cuts and, right now, nothing else separating them: the group
    -- gate is open and neither has a daily ceiling, both by request. That means the 60% contact has
    -- no reason to be used while the 90% one exists - it is dead content by construction, and it is
    -- recorded here rather than quietly accepted.
    --
    -- Two one-line ways back, whenever it matters: close `allowedGangs` on the good contact so
    -- membership is the gate, or give it a `dailyLimit` again so it runs out. The gang gate is
    -- still enforced server-side; a cap would need its check restored alongside the config value.
    --
    -- `rate` is what the PLAYER RECEIVES, not the cut the contact keeps. The two were specified as
    -- fees ("10%" and "40%"), so they are written here as their complements - 0.90 and 0.60 - because
    -- that is the number the payout multiplies by and the number the menu shows. Naming it the other
    -- way would invert every comparison in this file.
    launderers = {
        {
            key = 'contact',
            label = 'Terminal',

            -- Servidor: the prompt, per launderer, because one of these is a machine and the other is
            -- a person - a single shared "[E] Falar com %s." reads wrong for a terminal, and building
            -- it from the label would also have to guess Portuguese article gender. Cheaper to write
            -- the sentence once each.
            prompt = '[E] Usar o terminal.',

            -- Servidor: 10% against the street contact's 40%, and the naming carries the reason. This
            -- one is an automated terminal in a counterfeiting factory - no middleman, so no
            -- middleman's cut. The 40% is a person who has to be paid to look away.
            rate = 0.90,

            -- Servidor: open to everyone for now, by request - the closed-group version is built and
            -- one value away. Put real keys from `qbx_core/shared/gangs.lua` here (`lostmc`,
            -- `ballas`, `vagos`, `cartel`, `families`, `triads`) and this contact closes to them; an
            -- EMPTY list means nobody, and nil means everyone. The gate is enforced server-side on
            -- every call regardless, so opening or closing it is only ever a config change.
            ---@type string[]?
            allowedGangs = nil,

            -- Servidor: inside `bob74_ipl`'s Counterfeit Cash Factory (interior 247809, anchor
            -- 1121.897, -3195.338, -40.4025), which loads unconditionally - unlike the Money Fronts
            -- car wash, the canonical laundering front, which sits behind `IsDlcPresent(`mp2025_01`)`
            -- and drops the player into the void on this server's build 3258. Confirmed in game.
            --
            -- The factory ships with printer and note-dryer prop groups, so dirty money going in and
            -- clean money coming out reads correctly, and it sits in the same underground complex as
            -- all three drug labs.
            vendor = vector4(1126.15, -3196.71, -39.67, 182.21),

            -- Servidor: NO ped here, by request - this contact is a place, not a person, the same way
            -- each farm's press bench is. A nil `vendorPed` means the zone and its marker exist but
            -- nothing is spawned to stand in them.
            ---@type number?
            vendorPed = nil,
            vendorDistance = 2.0,
        },
        {
            key = 'street',
            label = 'Lavanderia',
            prompt = '[E] Falar com o lavador.',

            -- Servidor: 40% - a person, and people take a cut. See the terminal above.
            rate = 0.60,

            -- Servidor: nil, not an empty table. Nil means open to everyone; empty means nobody. The
            -- distinction is deliberate and the two are one character apart, so it is worth stating.
            ---@type string[]?
            allowedGangs = nil,

            -- Servidor: a real /coords, on the street and deliberately nowhere near the factory - the
            -- whole point of the open contact is that a player with no gang can reach it.
            vendor = vector4(260.48, 204.62, 110.29, 339.77),
            vendorPed = `ig_barry`,
            vendorDistance = 2.0,
        },
    },

    -- Servidor: the way into the Counterfeit Cash Factory. The interior sits at z = -39 in the same
    -- sealed underground complex as the drug labs, so like `srv_weedfarm` and `srv_methlab` before
    -- it (ADR-059) it needs a teleport pair rather than a walkable door.
    --
    -- The arrival point sits 11.83m from the laundering point at (1126.15, -3196.71, -39.67), so the
    -- two zones cannot touch - checked before applying, unlike the first pass at the crack lab where
    -- the same class of collision cost two rounds of coordinates (ADR-094).
    factoryEntrance = {
        outside = vector4(37.92, -1404.78, 29.34, 0.04),
        inside = vector4(1137.87, -3198.29, -39.67, 211.08),
        distance = 1.5,
    },

    -- Servidor: what the police see. `police:server:policeAlert` attaches the robber's own coords.
    alert = 'Assalto em andamento',

    -- Servidor: the 16 real counters, copied from `ox_inventory/data/shops.lua`'s own `targets` list
    -- - the exact spot each shop's till already sits at, so no coordinate here was guessed or taken
    -- separately. The two files must be kept in sync if a shop ever moves, the same standing
    -- obligation the press benches already carry with each farm's `pressStation`.
    --
    -- `shopType`/`shopIndex` are what `exports.ox_inventory:openInventory` needs to open that exact
    -- till. They are here because this point owns BOTH actions now: those two shop types are
    -- flagged `srvExternalInteraction` in `shops.lua`, so ox_inventory registers only their blip
    -- and this resource provides the single [E] that offers opening or robbing. See ADR-100.
    --
    -- Only General and Liquor are robbable. Ammunation, the police armoury and YouTool are
    -- deliberately left out: an unarmed first-tier robbery of a gun store reads wrong, and the
    -- police armoury would be a straight provocation.
    --
    -- The closest two counters on this list are 207m apart, so unlike the farms there is no risk at
    -- all of two interaction zones overlapping.
    stores = {
        { key = 'general1', label = 'Loja Geral', shopType = 'General', shopIndex = 1, coords = vec3(25.06, -1347.32, 29.5) },
        { key = 'general2', label = 'Loja Geral', shopType = 'General', shopIndex = 2, coords = vec3(-3039.18, 585.13, 7.91) },
        { key = 'general3', label = 'Loja Geral', shopType = 'General', shopIndex = 3, coords = vec3(-3242.2, 1000.58, 12.83) },
        { key = 'general4', label = 'Loja Geral', shopType = 'General', shopIndex = 4, coords = vec3(1728.39, 6414.95, 35.04) },
        { key = 'general5', label = 'Loja Geral', shopType = 'General', shopIndex = 5, coords = vec3(1698.37, 4923.43, 42.06) },
        { key = 'general6', label = 'Loja Geral', shopType = 'General', shopIndex = 6, coords = vec3(1960.54, 3740.28, 32.34) },
        { key = 'general7', label = 'Loja Geral', shopType = 'General', shopIndex = 7, coords = vec3(548.5, 2671.25, 42.16) },
        { key = 'general8', label = 'Loja Geral', shopType = 'General', shopIndex = 8, coords = vec3(2678.29, 3279.94, 55.24) },
        { key = 'general9', label = 'Loja Geral', shopType = 'General', shopIndex = 9, coords = vec3(2557.19, 381.4, 108.62) },
        { key = 'general10', label = 'Loja Geral', shopType = 'General', shopIndex = 10, coords = vec3(373.13, 326.29, 103.57) },
        { key = 'liquor1', label = 'Loja de Bebidas', shopType = 'Liquor', shopIndex = 1, coords = vec3(1134.9, -982.34, 46.41) },
        { key = 'liquor2', label = 'Loja de Bebidas', shopType = 'Liquor', shopIndex = 2, coords = vec3(-1222.33, -907.82, 12.43) },
        { key = 'liquor3', label = 'Loja de Bebidas', shopType = 'Liquor', shopIndex = 3, coords = vec3(-1486.67, -378.46, 40.26) },
        { key = 'liquor4', label = 'Loja de Bebidas', shopType = 'Liquor', shopIndex = 4, coords = vec3(-2967, 390.9, 15.14) },
        { key = 'liquor5', label = 'Loja de Bebidas', shopType = 'Liquor', shopIndex = 5, coords = vec3(1165.95, 2710.2, 38.26) },
        { key = 'liquor6', label = 'Loja de Bebidas', shopType = 'Liquor', shopIndex = 6, coords = vec3(1393, 3605.95, 35.11) },
    },

    -- Servidor: tier 2, houses - by request, requiring a lockpick on every one (no free-entry house
    -- the way stores are free-entry; see the header note above and ADR-097). The list below is the
    -- candidate set: every ground-level, standalone-entrance house `bob74_ipl` already loads by
    -- default, gathered with `srv_tools`' former `/scouthouses`.
    --
    -- Coordinates only for now - `entrance`, `lootPoints` and a cooldown key get added to each
    -- entry as it is walked and mapped in person (CLAUDE.md: world positions come from the game,
    -- never from arithmetic). Until an entry has an `entrance`, the blip is the only thing it does;
    -- see the blip-spawning loop in client.lua for why that split is safe to ship incrementally.
    --
    -- The label is deliberately just "Casa", not the street address - the store blips name the
    -- shop because there is nothing to hide about a till, but naming a specific house up front
    -- would tell a robber which of the twelve is worth the trip before they have even looked.
    -- Servidor: split in two on 2026-08-15 after Houses 1 and 2 turned up an engine-level bug -
    -- these 8 are GTA Online-exclusive interiors, and something about their entrance collision
    -- doesn't resolve outside an actual Online session (their own interior state comes back
    -- valid/ready/uncapped - see docs/patches.md's `bob74_ipl` entry and srv_tools' `/doorinfo`,
    -- `/doortest`, `/interiorstate` - so this isn't the interior-capping bug it first looked like;
    -- root cause still open). Kept yellow and separate from the 4 story houses below, which are
    -- unrelated single-player content and have not shown the same symptom.
    -- Servidor: decided on 2026-08-15, after the entrance bug turned out to be unfixable from here -
    -- these 8 use the same teleport-pair shape as `srv_weedfarm`/`srv_cocainelab`/the factory
    -- entrance below (ADR-059), not a walkable door. `entrance.inside` is nil until each house is
    -- walked with noclip and a real landing spot is picked - the "not playable until mapped" rule
    -- every entrance in this project follows (see client.lua: the [E] to enter is skipped entirely
    -- until `inside` exists).
    --
    -- IMPORTANT: `coords` is the `bob74_ipl` INTERIOR reference point, NOT the front door - they
    -- are not interchangeable and the difference is large. House 1's real door, surveyed with
    -- /coords, is **17.05m** from its `coords` value. That gap is why the door-prop freeze in
    -- client.lua silently did nothing for several rounds: its 15m zone was drawn around `coords`
    -- and the actual door sat outside it. An entry WITHOUT an `entrance` is unsurveyed and still
    -- has that problem; it is left absent rather than placeholder-filled precisely so the code can
    -- tell the two apart. Houses 1-4 are surveyed.
    houses = {
        -- Surveyed 2026-08-15: both points are real /coords readings, not derived from `coords`.
        { key = 'house1', label = 'Casa', coords = vec3(-169.286, 486.494, 137.444),
            entrance = {
                outside = vector4(-175.67, 502.30, 137.42, 272.53),
                inside = vector4(-174.28, 496.99, 137.67, 187.01),
                distance = 1.0,
            },
            -- Servidor: one point per item in the loot table (see the note above `houseLootItems`),
            -- surveyed in person like every coordinate in this file. Each point is independently
            -- lootable and independently cools down - see `Config.houseLootCooldownMinutes`.
            lootPoints = {
                { item = 'stolen_tv', coords = vector4(-163.33, 482.73, 137.27, 257.53) },
                { item = 'stolen_stereo', coords = vector4(-170.31, 483.37, 137.24, 99.15) },
                { item = 'bearer_bond', coords = vector4(-163.55, 485.14, 133.87, 278.32) },
                { item = 'rolex', coords = vector4(-167.43, 487.75, 133.84, 311.60) },
                { item = 'goldbar', coords = vector4(-174.76, 489.90, 130.04, 105.89) },
                { item = 'goldchain', coords = vector4(-163.21, 481.91, 133.87, 286.46) },
                { item = 'diamond_necklace', coords = vector4(-172.69, 500.03, 130.04, 10.02) },
                { item = 'diamond_ring', coords = vector4(-174.56, 496.42, 130.04, 182.17) },
            } },  -- Casa Alta 1, 3655 Wild Oats Drive
        { key = 'house2', label = 'Casa', coords = vec3(340.941, 437.180, 149.393),
            entrance = {
                outside = vector4(347.10, 440.78, 147.70, 115.24),
                inside = vector4(341.16, 437.07, 149.39, 297.19),
                distance = 1.0,
            },
            lootPoints = {
                { item = 'stolen_tv', coords = vector4(331.13, 423.39, 148.99, 198.87) },
                { item = 'stolen_stereo', coords = vector4(329.91, 422.57, 148.99, 328.52) },
                { item = 'bearer_bond', coords = vector4(332.59, 431.80, 149.17, 18.51) },
                { item = 'rolex', coords = vector4(332.87, 424.16, 145.60, 103.18) },
                { item = 'goldbar', coords = vector4(327.40, 429.15, 145.61, 30.14) },
                { item = 'goldchain', coords = vector4(334.66, 428.37, 145.57, 218.91) },
                { item = 'diamond_necklace', coords = vector4(334.20, 429.03, 145.57, 358.79) },
                { item = 'diamond_ring', coords = vector4(344.63, 436.89, 141.77, 295.01) },
            } },   -- Casa Alta 2, 2044 North Conker Avenue
        { key = 'house3', label = 'Casa', coords = vec3(373.023, 416.105, 145.701),
            entrance = {
                outside = vector4(373.09, 427.97, 145.68, 253.91),
                inside = vector4(373.50, 423.15, 145.91, 348.08),
                distance = 1.0,
            },
            lootPoints = {
                { item = 'stolen_tv', coords = vector4(375.90, 405.61, 145.53, 263.99) },
                { item = 'stolen_stereo', coords = vector4(375.79, 404.14, 145.53, 242.73) },
                { item = 'bearer_bond', coords = vector4(373.74, 425.04, 142.10, 40.63) },
                { item = 'rolex', coords = vector4(374.88, 411.81, 142.10, 273.89) },
                { item = 'goldbar', coords = vector4(374.26, 411.92, 142.10, 50.95) },
                { item = 'goldchain', coords = vector4(369.33, 407.04, 142.13, 89.19) },
                { item = 'diamond_necklace', coords = vector4(369.56, 408.31, 142.10, 94.29) },
                { item = 'diamond_ring', coords = vector4(371.61, 426.37, 138.30, 76.94) },
            } },   -- Casa Alta 3, 2045 North Conker Avenue

        -- Unsurveyed: `entrance` is absent entirely rather than pre-filled with `coords` as a
        -- placeholder. That placeholder was actively harmful - the door-freeze in client.lua tests
        -- for `entrance.outside` to decide whether it has a real door position to scan around, and
        -- a placeholder made every unsurveyed house claim it had one, sending the scan to the
        -- interior reference point instead. Caught in the logs at House 3, which reported
        -- `surveyed: true` despite never having been walked.
        { key = 'house4', label = 'Casa', coords = vec3(-676.127, 588.612, 145.170),
            entrance = {
                outside = vector4(-686.27, 596.71, 143.64, 222.65),
                inside = vector4(-681.94, 592.10, 145.39, 43.55),
                distance = 1.0,
            },
            -- Servidor: `goldbar` was surveyed twice with no correction marked on either - the
            -- second reading was kept, since it clusters with the other points taken around the
            -- same time (rolex, the corrected goldchain, diamond_ring all sit within a few metres
            -- of it), while the first reading is off on its own near the TV/stereo pair, which
            -- reads as an early call made before the player had settled into this room. Not
            -- confirmed in game - flagged in case the discarded reading turns out to be the real one.
            lootPoints = {
                { item = 'stolen_tv', coords = vector4(-665.31, 585.22, 144.99, 276.29) },
                { item = 'stolen_stereo', coords = vector4(-671.82, 582.12, 144.97, 235.40) },
                { item = 'bearer_bond', coords = vector4(-673.72, 584.31, 145.17, 303.51) },
                { item = 'rolex', coords = vector4(-676.73, 590.36, 145.38, 312.64) },
                { item = 'goldbar', coords = vector4(-670.58, 580.26, 141.57, 137.57) },
                { item = 'goldchain', coords = vector4(-670.95, 580.63, 141.57, 153.89) },
                { item = 'diamond_ring', coords = vector4(-671.33, 587.47, 141.57, 29.38) },
                { item = 'diamond_necklace', coords = vector4(-682.08, 591.42, 137.77, 215.75) },
            } },  -- Casa Alta 4, 2862 Hillcrest Avenue
        { key = 'house5', label = 'Casa', coords = vec3(-763.107, 615.906, 144.140),
            entrance = {
                outside = vector4(-752.22, 620.63, 142.31, 107.91),
                inside = vector4(-759.12, 618.72, 144.15, 292.46),
                distance = 1.0,
            },
            lootPoints = {
                { item = 'stolen_tv', coords = vector4(-771.45, 605.97, 143.73, 194.47) },
                { item = 'stolen_stereo', coords = vector4(-772.90, 605.60, 143.75, 113.09) },
                { item = 'bearer_bond', coords = vector4(-773.22, 608.67, 143.75, 209.75) },
                { item = 'rolex', coords = vector4(-762.14, 608.87, 143.93, 272.69) },
                { item = 'goldbar', coords = vector4(-774.16, 612.37, 140.37, 22.10) },
                { item = 'goldchain', coords = vector4(-772.69, 612.93, 140.37, 292.62) },
                { item = 'diamond_necklace', coords = vector4(-756.28, 615.88, 136.53, 179.98) },
                { item = 'diamond_ring', coords = vector4(-766.28, 618.65, 136.53, 20.18) },
            } },  -- Casa Alta 5, 2868 Hillcrest Avenue
        { key = 'house6', label = 'Casa', coords = vec3(-857.798, 682.563, 152.653),
            entrance = {
                outside = vector4(-853.12, 696.05, 148.79, 192.57),
                inside = vector4(-859.72, 690.60, 152.86, 9.61),
                distance = 1.0,
            },
            -- Servidor: only `stolen_tv`/`stolen_stereo` were surveyed by name here - the remaining
            -- 6 coordinates were given unlabelled with explicit permission to assign the rest of
            -- the item table to them in any order.
            lootPoints = {
                { item = 'stolen_tv', coords = vector4(-852.28, 675.12, 152.48, 248.13) },
                { item = 'stolen_stereo', coords = vector4(-851.97, 673.71, 152.48, 354.87) },
                { item = 'bearer_bond', coords = vector4(-858.83, 675.49, 152.45, 355.46) },
                { item = 'rolex', coords = vector4(-858.00, 684.78, 152.85, 5.47) },
                { item = 'goldbar', coords = vector4(-858.68, 675.64, 149.09, 182.82) },
                { item = 'goldchain', coords = vector4(-851.63, 673.59, 149.08, 264.34) },
                { item = 'diamond_necklace', coords = vector4(-858.98, 697.98, 145.25, 5.23) },
                { item = 'diamond_ring', coords = vector4(-861.97, 697.94, 145.25, 79.09) },
            } },  -- Casa Alta 6, 2874 Hillcrest Avenue
        { key = 'house7', label = 'Casa', coords = vec3(120.500, 549.952, 184.097),
            entrance = {
                outside = vector4(119.33, 564.78, 183.96, 180.64),
                inside = vector4(117.26, 559.41, 184.30, 3.91),
                distance = 1.0,
            },
            -- Servidor: same shape as House 6 - `stolen_tv`/`stolen_stereo` surveyed by name, the
            -- other 6 coordinates given unlabelled with explicit permission to assign at random.
            lootPoints = {
                { item = 'stolen_stereo', coords = vector4(125.67, 543.31, 183.92, 234.45) },
                { item = 'stolen_tv', coords = vector4(125.96, 542.37, 183.92, 273.07) },
                { item = 'bearer_bond', coords = vector4(118.64, 544.27, 183.90, 185.95) },
                { item = 'rolex', coords = vector4(116.80, 561.71, 180.50, 88.21) },
                { item = 'goldbar', coords = vector4(114.93, 562.16, 176.70, 87.35) },
                { item = 'goldchain', coords = vector4(118.31, 563.19, 176.70, 280.90) },
                { item = 'diamond_necklace', coords = vector4(114.46, 568.86, 176.70, 6.08) },
                { item = 'diamond_ring', coords = vector4(118.29, 566.85, 176.70, 228.74) },
            } },   -- Casa Alta 7, 2677 Whispymound Drive
        { key = 'house8', label = 'Casa', coords = vec3(-1288.000, 440.748, 97.695),
            entrance = {
                outside = vector4(-1294.21, 455.29, 97.37, 180.75),
                inside = vector4(-1289.93, 448.88, 97.90, 353.66),
                distance = 1.0,
            },
            -- Servidor: same shape as Houses 6 and 7 - `stolen_tv`/`stolen_stereo` surveyed by name,
            -- the other 6 coordinates given unlabelled with explicit permission to assign at random.
            lootPoints = {
                { item = 'stolen_tv', coords = vector4(-1283.52, 433.08, 97.52, 265.19) },
                { item = 'stolen_stereo', coords = vector4(-1283.23, 431.40, 97.52, 94.72) },
                { item = 'bearer_bond', coords = vector4(-1289.71, 433.47, 97.50, 92.72) },
                { item = 'rolex', coords = vector4(-1290.47, 450.74, 94.09, 46.67) },
                { item = 'goldbar', coords = vector4(-1289.41, 433.39, 94.13, 173.94) },
                { item = 'goldchain', coords = vector4(-1286.39, 438.03, 94.09, 348.67) },
                { item = 'diamond_necklace', coords = vector4(-1283.77, 444.90, 94.09, 269.66) },
                { item = 'diamond_ring', coords = vector4(-1282.40, 444.88, 94.09, 246.54) },
            } },  -- Casa Alta 8, 2133 Mad Wayne Thunder
    },

    -- Servidor: the lockpick gate every house requires, by request - unlike the free-entry stores.
    -- `breakChance` mirrors `qbx_vehiclekeys`' own default for a normal lockpick
    -- (`removeNormalLockpickChance = 0.4`) rather than inventing a new number for the same item.
    -- `skillCheck` mirrors that same resource's "normal" difficulty (car door, not plane/military) -
    -- the item plays the same either way, so the challenge should feel the same either way too.
    houseLockpick = {
        item = 'lockpick',
        breakChance = 0.4,
        skillCheck = {
            difficulty = { 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'medium' },
            inputs = { '1', '2', '3', '4' },
        },
    },

    -- Servidor: how long a specific loot point stays empty after being taken, in real minutes -
    -- same 45 as `storeCooldownMinutes`, reused rather than picked fresh, since it is the same
    -- shape of decision (how often is one spot worth revisiting) with no reason to diverge. Applies
    -- per POINT, not per house: taking the TV does not lock out the jewelry box next to it.
    houseLootCooldownMinutes = 45,

    -- Servidor: the 4 single-player story houses - original base-game content, never capped for
    -- Online, and not (yet) seen to share House 1/2's entrance bug. Kept as their own list rather
    -- than merged into `houses` above so the two categories can be told apart on the map (red vs
    -- yellow, see client.lua) while their bug status is still genuinely different, not just a
    -- labelling choice - see the note above `houses`.
    -- Servidor: `guardCount` splits 20 guards across the 4 houses by an ESTIMATE of each property's
    -- real footprint (Michael's is a full estate with a pool and driveway; Trevor's is a single
    -- trailer) - not measured with /coords, so treat it as a first pass. If a house's guards feel
    -- packed on top of each other or the wander radius sends them into the street, `guardCount` and
    -- `guardRadius` are the two numbers to adjust; nothing else depends on them.
    storyHouses = {
        { key = 'story1', label = 'Casa', coords = vec3(-802.311, 175.056, 72.845),
            guardCount = 10, guardRadius = 25.0 },  -- Mansão do Michael
        { key = 'story2', label = 'Casa', coords = vec3(-9.966, -1438.540, 31.102),
            guardCount = 4, guardRadius = 12.0 },   -- Casa da tia do Franklin
        { key = 'story3', label = 'Casa', coords = vec3(-1150.703, -1520.713, 10.633),
            guardCount = 3, guardRadius = 10.0 },   -- Apartamento do Floyd
        { key = 'story4', label = 'Casa', coords = vec3(1985.481, 3828.768, 32.500),
            guardCount = 3, guardRadius = 10.0 },   -- Trailer do Trevor
    },

    -- Servidor: the story-house tier - no lockpick, walk straight in, but the property is guarded.
    -- Distinct from `houseLockpick`'s tier on purpose: that one gates on an item and a skill check,
    -- this one gates on combat. Two different kinds of obstacle for two different kinds of player,
    -- matching the ladder ADR-097 set out (free stores -> item+skill houses -> combat houses ->
    -- tier 3 card+minigame).
    storyHouseGuards = {
        -- `s_m_y_blackops_01` and `WEAPON_CARBINERIFLE` are both already used elsewhere on this
        -- server (the model verified live via `srv_tools`' `/testped`, the weapon already in
        -- `ox_inventory`'s own catalog) - reused rather than guessed, per CLAUDE.md rule 4.
        ped = `s_m_y_blackops_01`,
        weapon = `WEAPON_CARBINERIFLE`,
        ammo = 250,

        -- Servidor: peds are not hostile on sight - `esbarre ou olhe, o padrão de NPC violento`. GTA's
        -- own ped AI already does this for free once combat ability is on and the weapon is drawn:
        -- aim at a guard, shoot near one, or bump one hard enough and it reacts like any armed NPC
        -- would. Nothing here makes them passive; nothing here makes them hunt on sight either.
        accuracy = 40,

        -- Servidor: the deliberate trigger, on top of the ambient one above. `TriggerRobbery` (see
        -- client.lua) sets every guard's target to the player and fires the same
        -- `police:server:policeAlert` the store robbery uses - the alert fires when the robbery
        -- starts, matching that convention exactly, not when the fight ends.
    },
}

return Config
