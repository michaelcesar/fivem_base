-- Servidor: the cocaine lab - srv_weedfarm's sibling, same buy -> [processing step] -> harvest ->
-- press -> sell loop, but the "planting" verb doesn't apply here at all: there is no coca-growing
-- interior anywhere in this server's asset set (bob74_ipl's Biker DLC only ships a processing
-- lockup, `dlc_bikers/cocaine.lua` - a lab with cutting/pressing tables, not a field with grow-spot
-- props). By request, the loop stays otherwise identical to srv_weedfarm; only the step's name
-- and its lack of a real-time "growth" visual change.
--
-- Every coordinate below is a real `/coords` the user took standing at each real spot inside
-- bob74_ipl's Cocaine Lockup, per CLAUDE.md's rule against guessing world positions - none of
-- these are computed or estimated.
--
Config = {
    -- Servidor: the gang that owns this site. Everything in the PRODUCTION chain - buying the input
    -- from the vendor, entering the interior, working a station, pressing, and selling wholesale to
    -- the dealer - is restricted to members of this gang. Street RETAIL is deliberately NOT gated:
    -- buying retail bags and running the selling route stay open to everyone, so a player with no
    -- gang still has illegal work. See ADR-125.
    --
    -- The Cartel and cocaine needs no explanation.
    --
    -- Set to nil or 'none' to make this site unowned and open to everybody again; the checks read
    -- this field and nothing else, so ownership moves with one edit here.
    ownerGang = 'cartel',

    -- The Cocaine Lockup interior itself, from bob74_ipl/dlc_bikers/cocaine.lua (interior ID
    -- 247553).
    lab = {
        interiorId = 247553,
    },

    -- Servidor: an {outside, inside} pair, the ADR-059 shape the other five sites use.
    --
    -- This was WRONG for a long time and the mistake is worth recording. The config used to say
    -- this interior "DOES have a real walkable door - confirmed by the user in-game", and carried a
    -- single `entrance = vector4(907.61, -1588.96, 30.29, 256.90)` used for nothing but a blip.
    -- There is no real door. What was walked through in-game was an UNGATED TELEPORT shipped by
    -- `qbx_smallresources/qbx_teleports`, whose own entrance sits 1.9m from that coordinate - so
    -- the door looked real, and the conclusion drawn from it was that this site needed no gate.
    -- It needed one the whole time. See ADR-153.
    --
    -- Both coordinates below are lifted from that teleport's own config rather than re-surveyed:
    -- they are values proven to work, since a player used them to get inside (CLAUDE.md rule 4 -
    -- reuse a verified position, never guess a new one). The upstream teleport is deleted, so this
    -- is now the only way in and it is gated.
    entrance = {
        outside = vector4(909.49, -1589.22, 30.51, 91.74),
        inside = vector4(1088.81, -3187.57, -38.99, 181.2),
        distance = 1.5,
    },

    -- The lab's 9 real processing spots (bob74_ipl's cutting/production tables). Unlike
    -- srv_weedfarm's 9 plots, these have no per-spot growth-stage props to swap (the Cocaine
    -- Lockup's Style table only tracks two lab-wide states, "basic"/"upgrade", not per-table
    -- state) - so a station's occupied/ready state is tracked the same way server-side (timer in
    -- the DB), but has no client-visible prop change to go with it, only the [E] prompt text.
    --
    -- Servidor: these 9 spots sit MUCH closer together than srv_weedfarm's 9 plots (4.32m at
    -- their closest there vs ~1.27m here, between stations 1 and 2) - close enough that copying
    -- srv_weedfarm's own `plotDistance = 1.25` would put two inner interaction zones on top of
    -- each other before this even ships (see ADR-067/068, the exact bug that tightened
    -- srv_weedfarm's own radius after the fact). `stationDistance` below is picked up front
    -- instead, small enough that even the closest pair's two inner zones can't touch.
    stations = (function()
        local coords = {
            vector4(1095.94, -3194.82, -38.99, 3.15),
            vector4(1094.67, -3194.91, -38.99, 269.45),
            vector4(1093.37, -3194.81, -38.99, 87.67),
            vector4(1091.65, -3194.85, -38.99, 95.74),
            vector4(1088.58, -3195.72, -38.99, 7.14),
            vector4(1089.72, -3196.62, -38.99, 281.90),
            vector4(1091.79, -3196.74, -38.99, 1.67),
            vector4(1093.08, -3196.73, -38.99, 271.66),
            vector4(1094.85, -3196.66, -38.99, 272.58),
        }
        local list = {}
        for i = 1, #coords do
            list[i] = { key = ('station%d'):format(i), label = ('Estação %d'):format(i), coords = coords[i] }
        end
        return list
    end)(),

    -- Servidor: only the INNER radius drives the shared text-UI element (srv_weedfarm's own
    -- `plotDistance` comment explains why) - 0.4 keeps every pair of stations' inner zones from
    -- touching, including the closest pair (~1.27m apart: 2x0.4 = 0.8, leaving ~0.47m clearance),
    -- with more room everywhere else. The outer/marker radius doesn't need the same care (markers
    -- don't share state to fight over), so it gets a smaller-than-srv_weedfarm's `+ 0.75` pad
    -- for the same reason - a wider one here really would start lapping into the next station.
    stationDistance = 0.4,

    -- The press bench - not this resource's own mechanism, same call as srv_weedfarm's pressing
    -- (ADR-069): a real ox_inventory crafting bench (`srv_cocainelab_press`), reusing this
    -- coordinate directly there.
    pressStation = vector4(1101.22, -3198.75, -38.99, 188.67),

    -- How long one batch takes at a station, in real minutes - mirrors srv_weedfarm's
    -- `growthMinutes` value exactly, by request ("mantém exatamente igual"), even though nothing
    -- here is actually growing. A starting guess, not measured; tune once there's real playtime.
    processingMinutes = 180,

    -- ms, ox_lib progress circle shown while starting a batch - mirrors srv_weedfarm's own
    -- `plantDuration` exactly.
    processDuration = 3000,

    -- Servidor: the accelerator - `cocaine_solvent`, this lab's equivalent of srv_weedfarm's
    -- fertilizer, mirroring its values exactly (see that file for the arithmetic behind 30/3 and
    -- the $500 price: a 180-minute batch can be brought down to 90 minutes and never to zero, at
    -- roughly break-even $/hour, so the accelerator buys time rather than profit). Sold by
    -- `srv_chemist`, never produced. See ADR-082.
    boostItem = 'cocaine_solvent',
    boostLabel = 'Solvente Químico',
    boostMinutes = 30,
    maxBoosts = 3,

    -- ms, mirrors srv_weedfarm's own `boostDuration`.
    boostDuration = 2000,

    -- How much raw paste one batch yields - mirrors srv_weedfarm's `yieldPerHarvest`.
    yieldPerBatch = 5,

    -- Real items, added to ox_inventory/data/items.lua alongside this resource. Four distinct
    -- items, one per step: leaf (bought) -> paste (processed) -> brick (pressed) -> bag (retail).
    -- `bagItem` used to be `cocaine_paste` as well, which was an economy exploit - the press
    -- consumes paste, so bought bags could be pressed straight back into a brick worth more than
    -- they cost. Same bug srv_weedfarm had, fixed the same way. See ADR-073.
    leafItem = 'coca_leaf',
    pasteItem = 'cocaine_paste',
    brickItem = 'cocaine_brick',
    bagItem = 'cocaine_bag',

    -- The leaf vendor - a real /coords, up in Vinewood Hills. `ig_barry` reused rather than a new,
    -- unverified ped guess - already confirmed present (`srv_jobs`' own 6 job depots all use it)
    -- and, by the same "Desconhecido" blip convention below, identity was never meant to be the
    -- point for an illegal NPC. Swap for something else once a specific model is chosen and
    -- confirmed with `/testprop`.
    leafVendor = vector4(1759.36, -1656.99, 112.71, 271.30),
    leafVendorPed = `ig_barry`,
    leafVendorDistance = 2.0,
    -- Mirrors srv_weedfarm's `seedPrice`/`seedPurchaseCeiling` exactly.
    leafPrice = 300,
    leafPurchaseCeiling = 50,

    -- The dealer who buys bricks - a real /coords, downtown near Mission Row. Same `ig_barry`
    -- reuse and reasoning as the leaf vendor above.
    dealer = vector4(-215.39, -633.21, 48.23, 276.56),
    dealerPed = `ig_barry`,
    dealerDistance = 2.0,
    -- Mirrors srv_weedfarm's brickPrice/bagsPerBrick/bagPrice/dailyBrickLimit exactly.
    brickPrice = 3500,
    bagsPerBrick = 10,

    -- Servidor: the consumer form - the same retail tier as `bagItem`, drawn from the SAME stock
    -- pool, but the version that actually does something when used. One brick still restocks
    -- `bagsPerBrick` units and the buyer picks which form to take, so supply is unchanged; what
    -- changes is that the dealer now offers a choice instead of a single option. See ADR-084.
    --
    -- Priced against the other two farms by how strong each effect actually is, rather than
    -- uniformly with them - and deliberately not anchored to `bagPrice`. The two tiers are not
    -- substitutes, so one being cheaper than the other creates no arbitrage: see the `dealing`
    -- note below. This corrects two things in ADR-084's original flat $450.
    --
    -- First, an inaccuracy in what that comment claimed: the consumer form is not "a loss to
    -- resell". `srv_jobs`' `dealing` job lists only the three plain `_bag` items in its
    -- `itemOptions`, so a consumer form cannot be resold through it *at any price*. Price was
    -- never what separated the tiers - the job's own item list is. That leaves pricing free to do
    -- something more useful.
    --
    -- Second, the three effects are not equivalent, so charging the same for them was wrong. Read
    -- from `qbx_consumables`, they are:
    --   * Baseado - stress relief only, no movement or combat edge.
    --   * Papelote - 20s, 1.1x sprint, 20%/s stamina, and a 10% chance per second of ragdolling
    --     you mid-run, plus one more roll when it ends.
    --   * Dose - 8s, 1.49x sprint, no ragdoll at all.
    --
    -- So: middle. Longest of the three, but the weakest sprint bonus and the only one that can
    -- actively put the player on the floor - it is dearer than the Baseado for the duration and
    -- cheaper than the Dose for the downside.
    --
    -- Producer economics are still untouched - a brick sells for `brickPrice` and restocks
    -- `bagsPerBrick` regardless of which form buyers take. See ADR-085.
    --
    -- Producer economics are deliberately untouched - a brick still sells for `brickPrice` and
    -- still restocks `bagsPerBrick`, whichever form buyers then choose.
    consumerItem = 'cokebaggy',
    consumerLabel = 'Papelote de Cocaína',
    consumerLabelPlural = 'Papelotes de Cocaína',

    -- Servidor: the short name, used ONLY on the half-width quantity card in the dealer menu. An
    -- inline option gets half a row (ADR-088) and the title wraps on `overflowWrap: break-word`,
    -- so `Dose de Metanfetamina` broke mid-word there - reported. The plain bag card already had
    -- its own short label (`Saquinho`/`Porção`); this gives the consumer card the same. Every
    -- other place - the buy row, the notifications, the hover card - keeps the full name, since
    -- those have the width for it. See ADR-093.
    consumerCardLabel = 'Papelote',
    consumerPrice = 275,

    -- Servidor: one line, shown in the dealer menu's hover card so a buyer can compare the three
    -- forms before spending. Descriptive text only - the real effect lives in qbx_consumables (and,
    -- for meth, in this resource's own client.lua). If the two ever disagree this string is the
    -- wrong one. See ADR-086.
    consumerEffect = '20s, corrida 1,1x, risco de tombo',
    bagPrice = 200,
    -- Servidor: the daily cap, per citizenid, per real calendar day - expressed in BRICKS, not in
    -- units, because that is how it was specified ("5x tijolos") and because it is the number that
    -- carries the intent. The unit figure is derived (`dailyBrickLimit * bagsPerBrick` = 50), so if
    -- a brick's yield ever changes the cap follows it instead of silently drifting.
    --
    -- It applies to EACH form separately, not to the two together: 5 bricks' worth of the plain
    -- `bagItem` and 5 bricks' worth of `consumerItem`, tracked in their own columns. Buying up all
    -- 50 joints does not cost a single bag of allowance. See ADR-086.
    --
    -- CLAUDE.md rule 8, the arithmetic before it ships: `srv_jobs`' `dealing` shift needs
    -- `minStopsBeforeReturn = 15` stops, one bag consumed per stop, all of the same drug. 50 a day
    -- clears that three times over. An earlier draft of this cap read "5 bags" rather than "5
    -- bricks' worth" and would have made a full shift impossible - 5 is a third of one route.
    dailyBrickLimit = 5,

    -- Servidor: the buying cap, per form, per citizenid, per real calendar day - separate from
    -- `dailyBrickLimit`, which caps SELLING. A player may convert 5 bricks of each form and buy 20
    -- units of each form, and the two never draw from each other. See ADR-090.
    --
    -- CLAUDE.md rule 8, the arithmetic before it ships: `srv_jobs`' `dealing` shift needs
    -- `minStopsBeforeReturn = 15` stops and consumes one bag per stop, all of the same drug. 20 a
    -- day covers one full route with five to spare, so a street dealer can always finish a shift
    -- but cannot run two on the same drug in one day. Running a second route means switching drug,
    -- which is the intended pressure.
    dailyBuyLimit = 20,
}

return Config
