return {
    finance = {
        minimumDown = 10, -- minimum percentage allowed down
        maximumPayments = 24, -- maximum payments allowed
        enable = true, -- Enables the financing system. Turning this off does not affect already financed vehicles
        zone = vec3(-29.53, -1103.67, 26.42), -- Where the finance menu is located
    },

    enableFreeUseBuy = true, -- Allows players to buy from NPC shops
    enableTestDrive = true,

    vehicles = {

        -- Curated catalog: only vehicles explicitly listed in models below are sellable
        -- anywhere (no "default" catch-all) - keeps each dealership's inventory small and
        -- keeps us from streaming every vehicle model in the game at the shops.
        categories = {
            boats = 'boats',
            air = 'air',
        },

        models = {
            -- popular
            vorschlaghammer = 'pdm',
            boxville = 'pdm',
            regina = 'pdm',
            youga2 = 'pdm',
            rumpo3 = 'pdm',
            burrito5 = 'pdm',
            bison3 = 'pdm',
            asea = 'pdm',
            tailgater = 'pdm',
            glendale = 'pdm',
            prairie = 'pdm',
            issi2 = 'pdm',
            deity = 'pdm',
            cognoscenti = 'pdm',
            chavosv6 = 'pdm',
            -- premium
            blazer2 = 'premium',
            marshall = 'premium',
            tornado = 'premium',
            voodoo2 = 'premium',
            monster4 = 'premium',
            riata = 'premium',
            moonbeam2 = 'premium',
            manana2 = 'premium',
            baller6 = 'premium',
            sentinel = 'premium',
            sabregt = 'premium',
            phoenix = 'premium',
            imperator2 = 'premium',
            dune4 = 'premium',
            toreador = 'premium',
            -- luxo
            veto = 'luxo',
            issi7 = 'luxo',
            futo = 'luxo',
            driftfuto = 'luxo',
            tampa2 = 'luxo',
            coureur = 'luxo',
            ruston = 'luxo',
            bestiagts = 'luxo',
            rt3000 = 'luxo',
            coquette6 = 'luxo',
            jugular = 'luxo',
            growler = 'luxo',
            rapidgt = 'luxo',
            massacro2 = 'luxo',
            italirsx = 'luxo',
            -- vip
            voltic = 'vip',
            virtue = 'vip',
            penetrator = 'vip',
            bullet = 'vip',
            cheetah = 'vip',
            s80 = 'vip',
            le7b = 'vip',
            entityxf = 'vip',
            visione = 'vip',
            champion = 'vip',
            torero2 = 'vip',
            deveste = 'vip',
            prototipo = 'vip',
            taipan = 'vip',
            scramjet = 'vip',

            --- Boats
            squalo = 'boats',
            marquis = 'boats',
            seashark = 'boats',
            seashark2 = 'boats',
            seashark3 = 'boats',
            jetmax = 'boats',
            tropic = 'boats',
            tropic2 = 'boats',
            dinghy = 'boats',
            dinghy2 = 'boats',
            dinghy3 = 'boats',
            dinghy4 = 'boats',
            suntrap = 'boats',
            speeder = 'boats',
            speeder2 = 'boats',
            longfin = 'boats',
            toro = 'boats',
            toro2 = 'boats',

            --- Helicopters
            buzzard2 = 'air',
            frogger = 'air',
            frogger2 = 'air',
            maverick = 'air',
            swift = 'air',
            swift2 = 'air',
            seasparrow = 'air',
            seasparrow2 = 'air',
            seasparrow3 = 'air',
            supervolito = 'air',
            supervolito2 = 'air',
            volatus = 'air',
            havok = 'air',

            --- Planes
            duster = 'air',
            luxor = 'air',
            luxor2 = 'air',
            stunt = 'air',
            mammatus = 'air',
            velum = 'air',
            velum2 = 'air',
            shamal = 'air',
            vestra = 'air',
            dodo = 'air',
            howard = 'air',
            alphaz1 = 'air',
            nimbus = 'air',
            conada = 'air',
        },

        blocklist = {
            'police',
            'police2',
            'police3',
            'police4',
        }
    },

    ---@type table<string, Dealership>
    shops = {
        -- New spot the user picked and verified in-game via /coords.
        pdm = {
            type = 'free-use',
            -- Servidor: `zone.shape` is what sets `insideShop`, and client/main.lua refuses to show
            -- a showroom car's `[E]` prompt - and every menu below it - unless that is set. So the
            -- shape has to CONTAIN this shop's own showroomVehicles, and the original 8x8 box
            -- around the blip contained none of the four: three sat past its south edge and one
            -- past its west edge, so this dealership had no working `[E]` at all. Reported in game
            -- as "only the standard dealership works" - `luxo` was the only one whose (stock,
            -- inherited) polygon happened to enclose its cars. Rebuilt as the bounding box of the
            -- four showroomVehicles below plus 6m, so it is derived from coordinates that were
            -- already placed by hand rather than being a second guess at where the lot is.
            zone = {
                shape = {
                    vec3(-46.02, -1834.51, 26.08),
                    vec3(-68.30, -1834.51, 26.08),
                    vec3(-68.30, -1855.28, 26.08),
                    vec3(-46.02, -1855.28, 26.08),
                },
                size = vec3(3, 3, 4),
                targetDistance = 1,
            },
            blip = {
                label = 'Lite Motors - Popular',
                coords = vec3(-54.26, -1839.52, 26.08),
                show = true,
                sprite = 326,
                color = 3,
            },
            categories = {
                sedans = 'Sedans',
                compacts = 'Compactos',
                vans = 'Vans',
            },
            testDrive = {
                limit = 5.0,
                endBehavior = 'return'
            },
            -- Servidor: the middle `vehicleSpawn`, by request - a test drive ends where a purchase
            -- appears, at every dealership. This one used to point at its own separate spot inside
            -- the lot, which is why it was the odd one out.
            returnLocation = vec3(-71.79, -1833.80, 26.51),
            -- Every coord below was placed by hand in-game with /placecar + /lockcar,
            -- lined up against the real painted parking spots.
            vehicleSpawns = {
                vec4(-71.63, -1824.46, 26.51, 323.38),
                vec4(-71.79, -1833.80, 26.51, 318.43),
                vec4(-67.07, -1826.91, 26.51, 227.69),
            },
            showroomVehicles = {
                { coords = vec4(-62.30, -1840.51, 26.24, 315.44), vehicle = 'asea' },
                { coords = vec4(-52.02, -1849.28, 25.91, 319.84), vehicle = 'tailgater' },
                { coords = vec4(-54.66, -1846.90, 26.08, 320.31), vehicle = 'glendale' },
                { coords = vec4(-57.64, -1845.00, 26.16, 316.99), vehicle = 'issi2' },
            },
        },

        -- Servidor: moved indoors on 2026-08-18, out of the original open-air PDM lot and into
        -- `bob74_ipl`'s Import/Export garage (`dlc_import/garage1`, interior 253441) up at z=136.
        -- This is the only dealership in an interior, and it needs two things no other one does:
        -- a teleport pair (there is no walkable route from the street to a garage 100m up inside a
        -- tower - `srv_dealerdoors` owns that, the same ADR-059 pattern the farms use) and a taller
        -- `zone.thickness`, because its showroom spans two floors.
        luxo = {
            type = 'free-use',
            -- Bounding box of the six showroomVehicles below plus 6m, same derivation as `pdm` and
            -- `premium`. `thickness` is 12 rather than the upstream default 5: the cars sit at
            -- z=136.00 and z=141.35, a 5.35m spread that a 5m-tall zone cannot contain, so the
            -- upper floor would have had no `[E]` at all.
            zone = {
                shape = {
                    vec3(-166.55, -565.38, 138.70),
                    vec3(-198.33, -565.38, 138.70),
                    vec3(-198.33, -589.51, 138.70),
                    vec3(-166.55, -589.51, 138.70),
                },
                thickness = 12,
                size = vec3(3, 3, 4),
                targetDistance = 1,
            },
            -- Servidor: the blip marks the STREET DOOR, not the showroom. A blip on the interior
            -- itself would route a player to a point 100m above the road with no way in.
            blip = {
                label = 'Lite Motors - Luxo',
                coords = vec3(-115.91, -605.03, 36.28),
                show = true,
                sprite = 326,
                color = 5,
            },
            categories = {
                sports = 'Esportivos',
            },
            testDrive = {
                limit = 5.0,
                endBehavior = 'return'
            },
            -- Servidor: both are on the STREET, never in the showroom. A car handed over inside the
            -- garage would be 100m up with no drivable route down - `bob74_ipl` loads the room, not
            -- the ramp connecting it to the road. So the buyer takes the teleport back out and the
            -- car is waiting at the kerb. All four placed by hand in game on 2026-08-18.
            returnLocation = vec3(-107.59, -618.67, 36.07),
            vehicleSpawns = {
                vec4(-104.02, -608.30, 36.07, 162.47),
                vec4(-107.59, -618.67, 36.07, 160.23),
                vec4(-100.91, -598.55, 36.07, 159.93),
            },
            -- Servidor: placed by hand inside the interior. The last two sit on the upper floor
            -- (z=141.35) - see `zone.thickness` above, which exists for exactly that.
            showroomVehicles = {
                { coords = vec4(-192.33, -573.07, 136.00, 198.69), vehicle = 'italirsx' },
                { coords = vec4(-183.91, -571.38, 136.00, 180.08), vehicle = 'futo' },
                { coords = vec4(-174.10, -574.01, 136.00, 127.71), vehicle = 'growler' },
                { coords = vec4(-172.55, -583.51, 136.00, 60.28), vehicle = 'bestiagts' },
                { coords = vec4(-190.90, -573.21, 141.35, 205.57), vehicle = 'veto' },
                { coords = vec4(-179.69, -571.78, 141.35, 154.14), vehicle = 'jugular' },
            },
        },

        -- La Mesa industrial yard. Best-effort placement (not visually verified) - test
        -- and nudge the coords with /coords if anything clips into terrain.
        premium = {
            type = 'free-use',
            -- Servidor: moved indoors on 2026-08-18, into `bob74_ipl`'s Vehicle Warehouse
            -- (`dlc_import/vehicle_warehouse`, interior 252673) at z=-39.65 - underground, and far
            -- across the map from its own street door in East Los Santos. Second dealership in an
            -- interior after `luxo`; `srv_dealerdoors` owns the teleport.
            --
            -- Bounding box of the four showroomVehicles below plus 6m. No `zone.thickness` override
            -- here, unlike `luxo`: all four cars sit on a single level, so upstream's 5m is enough.
            zone = {
                shape = {
                    vec3(1011.52, -2986.70, -39.65),
                    vec3(985.55, -2986.70, -39.65),
                    vec3(985.55, -3021.19, -39.65),
                    vec3(1011.52, -3021.19, -39.65),
                },
                size = vec3(3, 3, 4),
                targetDistance = 1,
            },
            -- Servidor: the blip marks the STREET DOOR, not the showroom - a blip on the warehouse
            -- itself would route a player to a point 66m below sea level with no way in.
            blip = {
                label = 'Lite Motors - Premium',
                coords = vec3(234.14, -1874.07, 26.52),
                show = true,
                sprite = 326,
                color = 66,
            },
            categories = {
                offroad = 'Off-road',
                sportsclassics = 'Clássicos Esportivos',
                muscle = 'Muscle',
                suvs = 'SUVs',
                coupes = 'Cupês',
            },
            testDrive = {
                limit = 5.0,
                endBehavior = 'return'
            },
            -- Servidor: both on the STREET beside the door, never in the warehouse - it sits 66m
            -- below sea level and `bob74_ipl` loads the room, not a ramp out of it, so a car handed
            -- over down there could never be driven anywhere. All three spawns placed by hand in
            -- game on 2026-08-18, within 10m of the entrance.
            --
            -- `returnLocation` reuses the middle spawn rather than being surveyed separately: it is
            -- an already-verified drivable spot, and a test drive returning to the same kerb a
            -- purchase appears at is the behaviour anyway. It is the one coordinate here nobody
            -- explicitly stood on for that purpose - replace it if a dedicated point is wanted.
            returnLocation = vec3(234.63, -1883.25, 25.39),
            vehicleSpawns = {
                vec4(236.07, -1875.61, 25.78, 230.82),
                vec4(234.63, -1883.25, 25.39, 139.25),
                vec4(242.53, -1873.18, 25.88, 137.61),
            },
            -- Servidor: placed by hand inside the warehouse on 2026-08-18. All four sit on one
            -- level, so no `zone.thickness` override is needed here (unlike `luxo`, whose showroom
            -- spans two floors).
            showroomVehicles = {
                { coords = vec4(1005.52, -3005.53, -39.65, 86.36), vehicle = 'baller6' },
                { coords = vec4(1002.45, -3015.19, -39.65, 0.48), vehicle = 'tornado' },
                { coords = vec4(992.23, -3013.17, -39.65, 3.12), vehicle = 'sentinel' },
                { coords = vec4(991.55, -2992.70, -39.65, 180.14), vehicle = 'toreador' },
            },
        },

        vip = {
            type = 'free-use',
            -- Servidor: moved indoors on 2026-08-18, into `bob74_ipl`'s Import/Export garage
            -- (`dlc_import/garage3`, interior 255489). Third dealership in an interior, and the
            -- tallest - its showroom spans THREE levels, at z=86.50, 91.85 and 97.19.
            --
            -- Bounding box of the six showroomVehicles below plus 6m. `thickness` is 16 rather than
            -- upstream's 5: the levels are 10.69m apart top to bottom, so a 5m-tall zone would set
            -- `insideShop` on the ground floor only and the two upper levels would have no `[E]` at
            -- all - the same failure `luxo` had before this became configurable, twice as tall.
            zone = {
                shape = {
                    vec3(-1562.09, -556.72, 91.85),
                    vec3(-1582.51, -556.72, 91.85),
                    vec3(-1582.51, -586.00, 91.85),
                    vec3(-1562.09, -586.00, 91.85),
                },
                thickness = 16,
                size = vec3(3, 3, 4),
                targetDistance = 1,
            },
            -- Servidor: the blip marks the STREET DOOR, not the showroom.
            blip = {
                label = 'Lite Motors - VIP',
                coords = vec3(-1582.08, -557.23, 34.95),
                show = true,
                sprite = 326,
                color = 2,
            },
            categories = {
                super = 'Super',
            },
            testDrive = {
                limit = 5.0,
                endBehavior = 'return'
            },
            -- Servidor: placed by hand in game on 2026-08-18, on the street below the garage itself,
            -- ~45m from this shop's door once that was moved to the same building.
            --
            -- `returnLocation` is the middle spawn, by request: a test drive ends where a purchase
            -- appears, at every dealership.
            returnLocation = vec3(-1546.62, -584.34, 25.71),
            vehicleSpawns = {
                vec4(-1537.32, -577.84, 25.71, 33.57),
                vec4(-1546.62, -584.34, 25.71, 35.65),
                vec4(-1555.41, -571.17, 25.71, 214.93),
            },
            -- Servidor: placed by hand in game on 2026-08-18 - three on the ground level, two on the
            -- middle, one alone on the top as the showpiece.
            --
            -- Only three models were configured here before (`entityxf`, `scramjet`, `cheetah`) and
            -- six positions were surveyed, so `deveste`, `taipan` and `prototipo` were picked from
            -- this shop's own catalog to fill the rest. That choice is mine, not a request - swap
            -- any of them for another `vip` entry in `vehicles.models` above.
            showroomVehicles = {
                { coords = vec4(-1576.21, -562.72, 86.50, 146.05), vehicle = 'entityxf' },
                { coords = vec4(-1570.92, -570.56, 86.50, 123.28), vehicle = 'cheetah' },
                { coords = vec4(-1568.50, -580.00, 86.50, 71.35), vehicle = 'scramjet' },
                { coords = vec4(-1576.21, -563.43, 91.85, 149.57), vehicle = 'deveste' },
                { coords = vec4(-1568.09, -579.01, 91.85, 71.39), vehicle = 'taipan' },
                { coords = vec4(-1576.51, -564.58, 97.19, 132.27), vehicle = 'prototipo' },
            },
        },

        boats = {
            type = 'free-use',
            zone = {
                shape = {
                    vec3(-729.39, -1315.84, 0),
                    vec3(-766.81, -1360.11, 0),
                    vec3(-754.21, -1371.49, 0),
                    vec3(-716.94, -1326.88, 0)
                },
                size = vec3(8, 8, 6),
                targetDistance = 10,
            },
            blip = {
                label = 'Loja Náutica',
                coords = vec3(-738.25, -1334.38, 1.6),
                show = true,
                sprite = 410,
                color = 3,
            },
            categories = {
                boats = 'Boats'
            },
            testDrive = {
                limit = 5.0,
                endBehavior = 'return'
            },
            returnLocation = vec3(-714.34, -1343.31, 0.0),
            vehicleSpawns = {
                vec4(-727.87, -1353.1, -0.17, 137.09),
            },
            showroomVehicles = {
                { coords = vec4(-727.05, -1326.59, -0.50, 229.5), vehicle = 'seashark' },
                { coords = vec4(-732.84, -1333.5, -0.50, 229.5), vehicle = 'dinghy' },
                { coords = vec4(-737.84, -1340.83, -0.50, 229.5), vehicle = 'speeder' },
                { coords = vec4(-741.53, -1349.7, -0.50, 229.5), vehicle = 'marquis' },
            },
        },

        air = {
            type = 'free-use',
            zone = {
                shape = {
                    vec3(-1607.58, -3141.7, 12.99),
                    vec3(-1672.54, -3103.87, 12.99),
                    vec3(-1703.49, -3158.02, 12.99),
                    vec3(-1646.03, -3190.84, 12.99)
                },
                size = vec3(10, 10, 8),
                targetDistance = 5,
            },
            blip = {
                label = 'Loja Aérea',
                coords = vec3(-1652.76, -3143.4, 13.99),
                show = true,
                sprite = 251,
                color = 3,
            },
            categories = {
                helicopters = 'Helicopters',
                planes = 'Planes'
            },
            testDrive = {
                limit = 5.0,
                endBehavior = 'return'
            },
            returnLocation = vec3(-1628.44, -3104.7, 13.94),
            vehicleSpawns = {
                vec4(-1617.49, -3086.17, 13.94, 329.2),
            },
            showroomVehicles = {
                { coords = vec4(-1651.36, -3162.66, 12.99, 346.89), vehicle = 'volatus' },
                { coords = vec4(-1668.53, -3152.56, 12.99, 303.22), vehicle = 'luxor2' },
                { coords = vec4(-1632.02, -3144.48, 12.99, 31.08), vehicle = 'nimbus' },
                { coords = vec4(-1663.74, -3126.32, 12.99, 275.03), vehicle = 'frogger' },
            },
        },
    },
}