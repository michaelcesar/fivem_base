-- Servidor: city hall's employment list (qbx_core/shared/jobs.lua) only ever defined these
-- as a job name plus a passive per-interval paycheck - no gameplay behind any of them, and
-- nobody holds one full-time. This resource is that gameplay: walk up to a job's depot,
-- start a shift regardless of your actual qbx_core job, and it loops - one generated stop
-- at a time, paid as you go - until you drive to the job's return point (like a garage)
-- and park the work vehicle there. `/cancelarservico` abandons a shift early with no bonus
-- and leaves a fine on the player's citizenid until paid (see server.lua).
--
-- Three coordinates per job, all real positions the user read out via /coords/
-- /placecar+/lockcar and handed over one at a time - never hand-picked, per CLAUDE.md's
-- rule against guessing world positions:
--   - `depot`: the NPC you talk to (E) to start a shift.
--   - `vehicleSpawn`: where the work vehicle appears. Defaults to `depot` if not set.
--   - `returnPoint`: where you bring the vehicle back to end the shift (garage-style,
--     server-verifies both the player and the vehicle are here). Defaults to `depot`.
-- trucker, taxi, garbage and bus have all three. tow doesn't have a depot yet, and is simply
-- not playable until one is added - there is no command-based fallback that starts a job
-- without walking to its physical depot. See ADR-044.
--
-- `vehicleSlots` spawn positions are offset in a small ring around `vehicleSpawn` so two
-- players starting the same job around the same time don't spawn on top of each other -
-- the server hands out the first slot not already claimed by another active shift for
-- that job, freed automatically the moment that shift ends any way at all.
--
-- `icon` is a blip sprite ID, confirmed against FiveM's own blip reference
-- (docs.fivem.net/docs/game-references/blips) rather than guessed: 568 = radar_sm_cargo,
-- 318 = radar_garbage, 198 = radar_taxi, 513 = radar_bus, 68 = radar_tow_truck (the same
-- one qbx_garages already uses for the Impound Lot blip).
--
-- `ped` is the depot NPC model - `ig_barry`, already confirmed present in this exact
-- install (Renewed-Banking spawns it for several bank branches), reused here rather than
-- guessing a new one for six different job dispatchers.
-- Servidor: 30 real points, not new /coords - 15 each from taxi's and bus's own already-mapped
-- `stops` (every other entry, interleaved taxi/bus/taxi/bus...), by request rather than asking
-- for 30 more. These were real drop/stop points for other jobs already; reusing them here is
-- still real-world data, just shared across jobs instead of unique to one - not a guess, not
-- computed. See ADR-063. Pulled out to a local, not inlined per job, so `dealing` and
-- `methdealing` (ADR-071) share the exact same 30 points rather than two copies that could drift.
local DEALING_STOPS = {
    vector3(92.53, -1406.78, 28.73),
    vector3(306.42, -765.42, 28.77),
    vector3(-58.88, -1755.47, 28.75),
    vector3(-358.77, -1418.09, 28.77),
    vector3(149.35, -1027.77, 28.83),
    vector3(-679.78, -241.53, 36.19),
    vector3(643.85, 272.13, 102.71),
    vector3(-133.31, -103.11, 55.45),
    vector3(265.62, -1156.41, 28.85),
    vector3(1046.40, -413.03, 65.99),
    vector3(1202.94, -446.21, 66.33),
    vector3(426.83, -1980.50, 22.60),
    vector3(-77.49, 887.33, 235.16),
    vector3(-137.04, -1389.80, 29.22),
    vector3(203.23, -48.67, 68.26),
    vector3(-538.95, -684.24, 32.73),
    vector3(103.79, -970.32, 28.83),
    vector3(-1588.16, -621.87, 30.34),
    vector3(112.85, -1942.52, 20.33),
    vector3(-2979.23, 422.29, 14.58),
    vector3(-19.51, -1104.95, 26.25),
    vector3(-2553.52, 2321.40, 32.64),
    vector3(-694.10, -649.14, 30.58),
    vector3(221.87, 3087.35, 41.86),
    vector3(-1202.02, -1351.62, 4.10),
    vector3(2796.42, 4323.39, 49.64),
    vector3(-1175.32, -1776.25, 3.42),
    vector3(1854.06, 2603.51, 45.25),
    vector3(-992.62, -1437.93, 4.64),
    vector3(68.78, -634.72, 31.11),
}

Config = {
    -- How close (in-vehicle progress) each generated stop is allowed to be from the last.
    minStopDistance = 60.0,
    maxStopDistance = 220.0,

    -- Outer radius where the ground marker becomes visible, inner radius where the
    -- '[E]' prompt and the action itself become available - same two-tier convention
    -- as qbx_cityhall/qbx_garages/shops.
    markerRadius = 20.0,
    promptRadius = 4.0,

    -- A player who parks the job vehicle and walks this far away auto-cancels the shift,
    -- so an abandoned vehicle can't sit there blocking the job forever.
    abandonDistance = 60.0,

    -- Servidor: how close the job's own vehicle has to be to the return point to count as
    -- "parked here" - shared by client.lua's `vehicleIsHere` (decides which prompt to show) and
    -- server.lua's `checkOwnVehicleAt` (the actual, authoritative check). One number in one
    -- config both sides read, instead of the same distance hand-copied into two files where it
    -- could silently drift - the client would keep offering "guardar" past the point the server
    -- would actually accept it, or the reverse.
    returnVehicleDistance = 12.0,

    -- How many players can spawn a work vehicle for the same job at once. Slot offsets
    -- are plain X/Y meters from `vehicleSpawn`, not rotated to any heading - a wide
    -- parking area handles that fine without needing a fourth coordinate per job.
    vehicleSlotOffsets = {
        vector3(0.0, 0.0, 0.0),
        vector3(6.0, 0.0, 0.0),
        vector3(-6.0, 0.0, 0.0),
        vector3(0.0, 6.0, 0.0),
        vector3(0.0, -6.0, 0.0),
        vector3(6.0, 6.0, 0.0),
    },

    -- Servidor: the flat cost of not genuinely returning the job vehicle to its real return
    -- point - same amount whether that happens deliberately (ending a shift at the return
    -- point with the vehicle missing or too far away) or involuntarily (walked away from the
    -- vehicle mid-route, disconnected, /cancelarservico's old spot). "Not returned" costs the
    -- same $1000 everywhere, per the user's own instruction ("isso em todos"). The involuntary
    -- case still becomes a debt tied to the player's citizenid (server.lua's `pendingDebt`),
    -- blocking any job until paid, since nobody is present to charge it immediately. See
    -- ADR-046.
    pendingVehicleFine = 1000,

    -- A shift only pays its completion bonus once at least this many stops are done - a flat
    -- count, not a percentage of the eventual 30-point mapped route, per the user's own
    -- instruction.
    minStopsBeforeReturn = 15,

    -- Servidor: charged for ending a shift before `minStopsBeforeReturn` stops are done - never
    -- also pays the bonus, so the fine is a real cost for cutting the shift short, not a
    -- discount on the reward. Stacks with `pendingVehicleFine` above if the vehicle also isn't
    -- genuinely at the return point - $1000 to end early, $2000 to end early *and* not return
    -- the vehicle, by request. See ADR-025 and ADR-046.
    earlyEndFine = 1000,

    jobs = {
        trucker = {
            label = 'Caminhoneiro',
            vehicle = `mule`,
            payPerStop = 150,
            bonus = 400,
            startMessage = 'Carga carregada. Siga o GPS até o próximo ponto de entrega.',
            icon = 568, -- radar_sm_cargo
            ped = `ig_barry`,
            -- Servidor: what a single completed stop is called for this job - used in the
            -- per-stop notify and the "you need at least N of these" message.
            stepLabel = 'Entrega',
            stepLabelPlural = 'entregas',
            -- Servidor: real coordinates the user gave via /coords/placecar+lockcar, not guessed.
            depot = vec4(-590.30, -1790.28, 22.86, 191.31),
            vehicleSpawn = vec4(-582.38, -1795.19, 23.09, 147.89),
            returnPoint = vec4(-610.19, -1793.77, 23.84, 45.78),
        },
        taxi = {
            label = 'Taxista',
            vehicle = `taxi`,
            payPerStop = 120,
            -- Servidor: taxi's 30 mapped stops average ~17% farther apart than garbage's (real
            -- distance, measured across both lists) - payPerStop already priced that in, but
            -- the bonus didn't. Raised from 300 (tied with garbage) to 400, by request.
            bonus = 400,
            startMessage = 'Turno iniciado. Siga o GPS até a próxima corrida.',
            icon = 198, -- radar_taxi
            ped = `ig_barry`,
            stepLabel = 'Corrida',
            stepLabelPlural = 'corridas',
            -- Servidor: real coordinates the user gave via /coords/placecar+lockcar, not guessed.
            depot = vec4(-330.56, -1295.39, 31.39, 81.02),
            vehicleSpawn = vec4(-337.53, -1308.23, 30.92, 177.65),
            returnPoint = vec4(-346.47, -1295.72, 30.95, 178.52),
            -- Servidor: 30 real /coords readings the user mapped out by hand, same as garbage's -
            -- see client.lua's nextFixedStop, which walks this list in the exact order given, not
            -- shuffled. Left in the exact order they were sent, by request - an earlier pass
            -- re-sorted these into a rotating loop, then the user asked for the original mapping
            -- order back.
            stops = {
                vector3(92.53, -1406.78, 28.73),
                vector3(-208.32, -1999.32, 27.20),
                vector3(-58.88, -1755.47, 28.75),
                vector3(370.34, -1809.71, 28.67),
                vector3(149.35, -1027.77, 28.83),
                vector3(295.88, -581.82, 42.74),
                vector3(643.85, 272.13, 102.71),
                vector3(125.46, -910.52, 29.57),
                vector3(265.62, -1156.41, 28.85),
                vector3(898.74, -1032.07, 34.54),
                vector3(1202.94, -446.21, 66.33),
                vector3(282.88, 959.23, 210.63),
                vector3(-77.49, 887.33, 235.16),
                vector3(318.54, 569.04, 154.03),
                vector3(203.23, -48.67, 68.26),
                vector3(-48.31, -750.57, 32.56),
                vector3(103.79, -970.32, 28.83),
                vector3(-107.37, -1685.91, 28.78),
                vector3(112.85, -1942.52, 20.33),
                vector3(-277.82, -1597.13, 31.43),
                vector3(-19.51, -1104.95, 26.25),
                vector3(-78.77, -713.61, 33.71),
                vector3(-694.10, -649.14, 30.58),
                vector3(-748.80, -709.71, 29.04),
                vector3(-1202.02, -1351.62, 4.10),
                vector3(-1358.19, -1529.55, 4.00),
                vector3(-1175.32, -1776.25, 3.42),
                vector3(-1030.31, -1541.59, 4.61),
                vector3(-992.62, -1437.93, 4.64),
                vector3(-606.87, -952.54, 21.46),
            },
        },
        bus = {
            label = 'Motorista de Ônibus',
            vehicle = `bus`,
            payPerStop = 100,
            bonus = 350,
            startMessage = 'Rota iniciada. Siga o GPS até a próxima parada.',
            icon = 513, -- radar_bus
            ped = `ig_barry`,
            stepLabel = 'Parada',
            stepLabelPlural = 'paradas',
            -- Servidor: real coordinates the user gave via /coords/placecar+lockcar, not guessed.
            -- Heading flipped 180 from the first reading (91.08 -> 271.08) - the ped spawned
            -- facing the wall behind it.
            depot = vec4(456.30, -600.83, 28.50, 271.08),
            vehicleSpawn = vec4(463.04, -614.00, 28.48, 35.50),
            returnPoint = vec4(470.07, -582.25, 28.49, 267.08),
            -- Servidor: 30 of the 35 real /coords readings the user mapped out by hand, same as
            -- taxi's/garbage's - see client.lua's nextFixedStop, which walks this list in the
            -- exact order given, not shuffled. The 5 dropped were the most redundant (farthest-
            -- point sampling: keeps the subset that maximizes spread) - a tight cluster near
            -- (-244, -714)/(-270, -822)/(-249, -883) collapsed to one representative point, plus
            -- one each near (306, -765) and (-679, -241)/(-504, 20). The kept 30 are left in the
            -- order they were sent, by request - an earlier pass re-sorted them into a rotating
            -- loop, then the user asked for the original mapping order back.
            stops = {
                vector3(306.42, -765.42, 28.77),
                vector3(-249.98, -883.55, 30.12),
                vector3(-358.77, -1418.09, 28.77),
                vector3(-527.09, -1043.97, 22.12),
                vector3(-679.78, -241.53, 36.19),
                vector3(-504.79, 20.94, 44.25),
                vector3(-133.31, -103.11, 55.45),
                vector3(459.05, -158.49, 59.75),
                vector3(1046.40, -413.03, 65.99),
                vector3(1025.72, -2072.78, 30.52),
                vector3(426.83, -1980.50, 22.60),
                vector3(12.31, -1622.83, 28.85),
                vector3(-137.04, -1389.80, 29.22),
                vector3(-189.06, -1130.38, 22.48),
                vector3(-538.95, -684.24, 32.73),
                vector3(-1144.85, -804.63, 15.10),
                vector3(-1588.16, -621.87, 30.34),
                vector3(-2061.46, -170.99, 24.04),
                vector3(-2979.23, 422.29, 14.58),
                vector3(-3138.27, 980.14, 16.15),
                vector3(-2553.52, 2321.40, 32.64),
                vector3(-1114.13, 2662.29, 17.67),
                vector3(221.87, 3087.35, 41.86),
                vector3(1777.57, 3550.63, 35.46),
                vector3(2796.42, 4323.39, 49.64),
                vector3(2689.64, 3282.27, 54.82),
                vector3(1854.06, 2603.51, 45.25),
                vector3(1507.18, 873.77, 76.66),
                vector3(68.78, -634.72, 31.11),
                vector3(59.53, -1081.00, 28.96),
            },
        },
        garbage = {
            label = 'Lixeiro',
            vehicle = `trash`,
            payPerStop = 90,
            bonus = 300,
            startMessage = 'Rota de coleta iniciada. Siga o GPS até o próximo ponto.',
            icon = 318, -- radar_garbage
            ped = `ig_barry`,
            stepLabel = 'Coleta',
            stepLabelPlural = 'coletas',
            -- Servidor: real coordinates the user gave via /coords/placecar+lockcar, not guessed.
            depot = vec4(-348.82, -1569.45, 25.23, 42.63),
            vehicleSpawn = vec4(-356.87, -1561.41, 24.94, 111.39),
            returnPoint = vec4(-370.39, -1527.88, 27.48, 179.56),
            -- Servidor: 30 real /coords readings the user mapped out by hand, replacing
            -- procedural generation for this job - see client.lua's nextFixedStop, which walks
            -- this list in the exact order given, not shuffled. Left in the exact order they were
            -- sent, by request - an earlier pass re-sorted these into a rotating loop, then the
            -- user asked for the original mapping order back.
            stops = {
                vector3(-395.25, -1699.22, 18.26),
                vector3(-450.21, -1856.31, 18.10),
                vector3(-745.40, -1738.80, 28.69),
                vector3(-641.14, -1444.42, 10.05),
                vector3(-699.43, -1192.79, 10.08),
                vector3(-713.80, -1135.20, 10.19),
                vector3(-770.40, -1093.31, 10.12),
                vector3(-833.60, -978.33, 14.09),
                vector3(-1149.60, -663.57, 21.89),
                vector3(-1053.18, -391.66, 37.09),
                vector3(-1035.14, -245.26, 37.34),
                vector3(-745.03, -53.31, 37.34),
                vector3(-479.87, -8.61, 44.81),
                vector3(-387.17, 22.58, 46.61),
                vector3(-378.89, 119.97, 65.28),
                vector3(-358.27, 119.73, 65.86),
                vector3(-327.06, 119.39, 66.71),
                vector3(-283.87, 118.72, 67.93),
                vector3(-71.98, 208.76, 96.04),
                vector3(19.09, 373.09, 111.93),
                vector3(229.61, 347.56, 105.06),
                vector3(401.21, 268.55, 102.48),
                vector3(389.50, 235.74, 102.51),
                vector3(253.80, -135.32, 65.27),
                vector3(143.67, -794.68, 30.68),
                vector3(175.03, -1036.01, 28.82),
                vector3(199.56, -1094.75, 28.80),
                vector3(206.16, -1280.98, 28.80),
                vector3(198.46, -1307.39, 28.81),
                vector3(21.64, -1357.82, 28.84),
            },
        },
        tow = {
            label = 'Guincho',
            vehicle = `towtruck`,
            -- Servidor: the highest-paying job by design, per stop - 2.5x trucker's 150 (the
            -- highest of the other five), by request. Real towing takes more from the player
            -- (drive to the pickup, hook it, drive back, unhook - two trips per stop instead of
            -- one) than any generic stop-and-confirm job, so the rate is priced to match.
            payPerStop = 375,
            bonus = 450,
            startMessage = 'Turno iniciado. Siga o GPS até o próximo veículo quebrado.',
            icon = 68, -- radar_tow_truck
            ped = `ig_barry`,
            stepLabel = 'Reboque',
            stepLabelPlural = 'reboques',
            -- Servidor: "Reboque" is masculine ("concluído", not "concluída") - every other
            -- job's stepLabel is feminine, which is why this is the one job that needs it.
            stepFeminine = false,
            -- Servidor: real coordinates the user gave via /coords/placecar+lockcar, not guessed.
            -- Heading flipped 180 from the first reading (28.40 -> 208.40) - the ped spawned
            -- facing away from the player.
            depot = vec4(-229.05, -1378.66, 31.26, 208.40),
            vehicleSpawn = vec4(-205.61, -1389.46, 30.83, 298.99),
            returnPoint = vec4(-182.70, -1372.42, 31.26, 297.34),
            -- Servidor: the single fixed point every pickup delivers to (ADR-052) - not a stop
            -- itself, and not the same as `returnPoint`, which is only ever for the tow truck.
            dropoffPoint = vec4(-233.48, -1394.36, 30.85, 183.79),
            -- Servidor: 15 of the 16 real /coords readings the user mapped out by hand, same
            -- treatment as taxi's/garbage's/bus's - the most redundant one dropped (farthest-
            -- point sampling). Left in the exact order they were sent, by request - an earlier
            -- pass re-sorted these into a rotating loop, then the user asked for the original
            -- mapping order back. Unlike every other job's `stops`, these aren't places to stand -
            -- they're where a broken vehicle spawns, waiting to be hooked and hauled to
            -- `dropoffPoint` above. See ADR-052.
            stops = {
                vector3(-136.85, -1367.18, 28.81),
                vector3(273.27, -1529.59, 28.75),
                vector3(131.89, -1554.97, 28.81),
                vector3(-18.49, -1579.87, 28.75),
                vector3(403.22, -1017.22, 28.89),
                vector3(343.76, -323.90, 50.44),
                vector3(116.53, -934.04, 29.26),
                vector3(82.80, -1460.30, 28.79),
                vector3(-77.42, -1105.63, 25.53),
                vector3(133.87, -1057.62, 28.77),
                vector3(-170.84, -457.71, 33.55),
                vector3(146.74, -1461.61, 28.72),
                vector3(-1.47, -1745.43, 28.88),
                vector3(427.97, -2017.56, 22.60),
                vector3(986.67, -1891.06, 30.25),
            },
            -- `brokenVehicles` picks the model spawned at each pickup, one at random per stop.
            -- These are ordinary GTA V sedans, not modded content, so they should exist in any
            -- build - but per CLAUDE.md rule 4 that's still a guess, not a verification. The
            -- boot check above catches a wrong *name* (typo, doesn't exist at all); it cannot
            -- catch a *bad-looking choice* (spawns fine but looks wrong for "broke down on the
            -- road"). Confirm each one with `/testprop` before this job goes live.
            brokenVehicles = { `blista`, `asea`, `premier`, `primo`, `stanier` },
        },
        -- Servidor: the first item-gated job, not vehicle-gated - no `vehicle` field at all, which
        -- is enough on its own to skip every vehicle-slot/spawn/return/abandon-watchdog code path
        -- in both server.lua and client.lua (each already only runs `if jobConfig.vehicle`).
        -- `itemOptions` (server.lua's `startJob`/`completeStop`): the shift needs one real unit of
        -- whichever item the player picks at the depot to begin, and each stop consumes one more
        -- rather than being free to confirm. Originally a single hardcoded `itemRequired =
        -- 'weed_skunk'` (ADR-062); generalized to a picked-at-start list of options so the same
        -- depot/route/pay machinery covers every dealable drug instead of one per job. See
        -- ADR-070. Consumes each drug resource's own retail bag, so the resources share one
        -- economy: grow/process and press there, sell the brick to that drug's dealer, buy bags
        -- out of the stock that brick restocked, resell them here. The bag is deliberately a
        -- different item from the one the press consumes - see ADR-073.
        --
        -- All THREE drugs are options on this one job. Meth briefly had its own `methdealing`
        -- job (ADR-071) at this exact same `depot` coordinate, which stacked two interaction
        -- zones and two peds on one spot - they fought over the single shared text-UI element
        -- (the ADR-067 failure mode again), and when the meth job won, its single-option
        -- `itemOptions` made `askItemChoice` skip the dialog entirely, so no drug could be
        -- picked at all. One NPC, one job, one list. See ADR-074.
        dealing = {
            label = 'Vendedor de Rua',
            -- Servidor: the only illegal job of the six, and the flag `payJob` reads to pay in
            -- `black_money` instead of clean cash (ADR-142). A flag on the job rather than a list
            -- of names in `server.lua`, so a future illegal job cannot forget to be paid dirty.
            illegal = true,
            itemOptions = {
                { item = 'weed_bag', label = 'Maconha' },
                { item = 'cocaine_bag', label = 'Cocaína' },
                { item = 'meth_bag', label = 'Metanfetamina' },
            },
            -- Servidor: every drug randomises its route, confirmed by the user as the intended
            -- behaviour for all of them, not just the meth job this flag arrived with ("é pra
            -- randomizar mesmo, tudo é pra ser padrão"). This supersedes ADR-063's original
            -- walked-in-mapped-order choice outright - that ordering existed because the 30
            -- points were mapped by driving them in sequence, but keeping delivery points
            -- predictable was never the goal it was chosen for. See ADR-074.
            randomStops = true,
            -- Servidor: a starting guess weighed against srv_weedfarm's bagPrice = 200 (what a
            -- bag costs to buy in), not measured against real playtime.
            payPerStop = 400,
            bonus = 300,
            startMessage = 'Turno iniciado. Siga o GPS até o próximo ponto de entrega.',
            icon = 84, -- "Skull" - same marker as every illegal point of interest in
            -- srv_weedfarm, by request.
            blipColour = 9, -- grey, matching those same blips - not verified in-game, see
            -- srv_weedfarm's own note on why blip colour has no /testprop-style check.
            blipName = 'Desconhecido', -- same unidentifying label every illegal blip in this
            -- project uses, by request, instead of the real job name.
            ped = `ig_barry`,
            -- Servidor: "Entrega" (delivery), not "Venda" - by request, since there's no buyer NPC
            -- at each stop to sell to (same shape as every stop-and-confirm job: a marker + [E],
            -- nothing spawned there). `stops` below are drop points, not people.
            stepLabel = 'Entrega',
            stepLabelPlural = 'entregas',
            -- Servidor: real /coords in Vanilla, outdoors, as requested.
            depot = vec4(93.90, -1292.91, 29.27, 302.46),
            -- Servidor: three decorative peds standing around the depot - no interaction, no
            -- gameplay function, just atmosphere for a drug operation's pickup point. `ped` reuses
            -- `g_m_y_lost_01` (already verified present, and already the weed dealer's own model
            -- in srv_weedfarm - visually "the same crew" rather than a new guess) and
            -- `weapon` is `WEAPON_SMG`, a real entry in ox_inventory's own data/weapons.lua, not
            -- guessed. See ADR-064.
            securityPeds = {
                { coords = vec4(96.49, -1289.62, 29.27, 231.32), ped = `g_m_y_lost_01`, weapon = `WEAPON_SMG` },
                { coords = vec4(98.63, -1290.60, 29.27, 128.64), ped = `g_m_y_lost_01`, weapon = `WEAPON_SMG` },
                { coords = vec4(97.72, -1292.79, 29.27, 341.88), ped = `g_m_y_lost_01`, weapon = `WEAPON_SMG` },
            },
            -- Servidor: see the `DEALING_STOPS` local above this table for where these 30 real
            -- points come from - not new /coords, ADR-063.
            stops = DEALING_STOPS,
        },
        -- Servidor: the same 30 points are also the pool `srv_gangs`' Rota de Cobrança draws from
        -- (ADR-145). Published on `Config` rather than copied into that resource, so there is one
        -- list and it cannot drift. `DEALING_STOPS` stays a local - this is the only handle other
        -- code is meant to use.
        -- Servidor: `methdealing` used to live here as its own job (ADR-071), at the identical
        -- `depot` coordinate as `dealing` above. Merged into `dealing`'s `itemOptions` and
        -- deleted - two jobs on one spot is not a configuration this engine supports. See ADR-074.
    },
}

-- Servidor: the 30 shared street points, published for other resources. `srv_gangs`' Rota de
-- Cobrança sends a member to a random handful of these - the same corners a street dealer already
-- works, which is the point: the gang is collecting from the sellers who work them. Exposed here
-- rather than copied so the two can never drift apart. See ADR-145.
Config.sharedStops = DEALING_STOPS

-- Registered from the shared script, so it exists on BOTH sides: `srv_gangs` needs the list on the
-- client to draw the route and on the server to verify the player actually reached a stop.
exports('GetSharedStops', function()
    return Config.sharedStops
end)

return Config
