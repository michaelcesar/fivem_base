-- Servidor: the weed farm - persistent, real-time growing, chosen deliberately over a session-
-- based "active turn" like srv_jobs (the user picked this explicitly): a planted seed keeps
-- growing whether or not anyone is online, so leaving and coming back later is the whole point.
--
-- Location and growth-stage props: reused wholesale from `bob74_ipl`'s Biker DLC "Weed Farm"
-- interior (server-data/resources/[standalone]/bob74_ipl/dlc_bikers/weed.lua) - a real MLO
-- already loaded on this server, with 9 real grow spots and real small/medium/full growth-stage
-- props built in. Every coordinate, interior ID and prop name below was read directly from that
-- file or from a real /coords taken standing at each grow spot, not guessed or computed, per
-- CLAUDE.md's rules against guessing world positions and asset names.
--
Config = {
    -- Servidor: the gang that owns this site. Everything in the PRODUCTION chain - buying the input
    -- from the vendor, entering the interior, working a station, pressing, and selling wholesale to
    -- the dealer - is restricted to members of this gang. Street RETAIL is deliberately NOT gated:
    -- buying retail bags and running the selling route stay open to everyone, so a player with no
    -- gang still has illegal work. See ADR-125.
    --
    -- The Families are GTA's own weed gang (Grove Street), the most canonical pairing of the six.
    --
    -- Set to nil or 'none' to make this site unowned and open to everybody again; the checks read
    -- this field and nothing else, so ownership moves with one edit here.
    ownerGang = 'families',

    -- The Weed Farm interior itself: anchor point and interior ID, both read verbatim from
    -- bob74_ipl/dlc_bikers/weed.lua. Confirmed on-site via /tp - the interior really is there.
    -- Used for the map blip and as the growth-stage props' interior ID - every actual
    -- interaction point below (plots, dealer) has its own real coords instead.
    farm = {
        coords = vector3(1051.491, -3196.536, -39.14842),
        interiorId = 247297,
    },

    -- The interior has no walkable door of its own (see ADR-059) - this is the fix: a real
    -- street-level point where `[E]` teleports in, and a real interior point where `[E]`
    -- teleports back out to that same street coordinate. Both real /coords, not computed.
    entrance = {
        outside = vector4(1240.18, -3178.90, 7.10, 85.39),
        inside = vector4(1065.42, -3183.67, -39.16, 276.05),
        distance = 1.5,
    },

    -- How long a plant takes to go from seed to harvestable, in real minutes - this is the
    -- number that makes "even offline" matter. 180 (3 hours) is a starting guess, not measured;
    -- tune it once there's real playtime to weigh it against.
    growthMinutes = 180,

    -- ms, ox_lib progress circle shown while planting a seed - a starting guess, not measured.
    plantDuration = 3000,

    -- Servidor: the fertilizer - `weed_nutrition`, an item that already existed unused in
    -- ox_inventory's own catalog (see items.lua). Applied to a plot that is planted but not yet
    -- ready, it consumes one item and cuts `boostMinutes` off that plant's remaining time, up to
    -- `maxBoosts` times per plant. Sold by `srv_chemist`, never produced. See ADR-082.
    --
    -- CLAUDE.md rule 8 - the arithmetic, stated before it ships. At 180 growth minutes, 30 minutes
    -- per application and a cap of 3, the fastest possible cycle is 90 minutes: fertilizer can
    -- halve the wait and can never make it instant, so persistent real-time growth (the whole
    -- reason this was chosen over a srv_jobs-style session, see the top of this file) survives.
    --
    -- And the money, at $500 an application: an unfertilized cycle is one $300 seed to one $3500
    -- brick over 3h, so $3200/3h = ~$1067/h. Fully fertilized it is $300 + $1500 into $3500 over
    -- 1.5h, so $1700/1.5h = ~$1133/h. Deliberately near break-even - fertilizer buys *time*, not
    -- profit, so a player with hours to spare has no reason to use it and a player with one hour
    -- of session left does. If it ever reads as mandatory, `boostPrice` is the number to raise.
    boostItem = 'weed_nutrition',
    boostLabel = 'Fertilizante',
    boostMinutes = 30,
    maxBoosts = 3,

    -- ms, ox_lib progress circle shown while applying fertilizer - shorter than planting, since it
    -- is a top-up rather than the main action.
    boostDuration = 2000,

    -- Servidor: only the INNER radius (this value) drives the shared text-UI element - two
    -- overlapping inner zones is what actually fights over "[E] ...", never the outer/marker
    -- zone alone (markers draw at absolute coords, no shared state to fight over). The nearest
    -- two real plots ("f"/"g") are 4.32m apart, so `1.25` still leaves ~1.8m of real clearance
    -- between their inner zones - looser than the `0.75` first tried, for more tolerance against
    -- the original /coords readings not being pixel-perfect. See ADR-067 and its follow-up.
    plotDistance = 1.25,

    -- The farm's 9 real grow spots (`BikerWeedFarm.Plant1`..`Plant9` in bob74_ipl). `propLetter`
    -- is the suffix bob74_ipl uses for that spot's prop names (`weed_growth<letter>_stageN`,
    -- `weed_hose<letter>`, `light_growth<letter>_stage23_standard`). `coords` is a real /coords
    -- taken standing at each one, in the order they were walked - the room had 11 tarps; these
    -- are the first 9, matched 1:1 to bob74_ipl's own 9 named spots so every one gets the real
    -- growth-stage prop animation.
    plots = (function()
        local letters = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i' }
        local coords = {
            vector4(1063.41, -3203.49, -39.14, 106.70),
            vector4(1058.22, -3205.85, -39.12, 177.53),
            vector4(1051.53, -3205.87, -39.14, 356.88),
            vector4(1051.04, -3200.72, -39.14, 317.10),
            vector4(1057.00, -3199.96, -39.13, 184.04),
            vector4(1062.95, -3198.20, -39.12, 281.20),
            vector4(1062.65, -3193.89, -39.11, 303.88),
            vector4(1062.68, -3187.87, -39.11, 357.88),
            vector4(1056.92, -3189.83, -39.12, 89.28),
        }
        local list = {}
        for i = 1, #letters do
            list[i] = { key = letters[i], label = ('Vaso %d'):format(i), propLetter = letters[i], coords = coords[i] }
        end
        return list
    end)(),

    -- Servidor: pressing is no longer this resource's own mechanism - it's ox_inventory's real
    -- crafting bench (`srv_weedfarm_press` in its own `data/crafting.lua`), reusing this same
    -- real coordinate directly there. Nothing here needs a `processStation`/`processCount`/
    -- `processDistance`/`processDuration` anymore. See ADR-069.

    -- The dealer who buys bricks. `g_m_y_lost_01` - a Lost MC biker, confirmed with /testprop -
    -- swapped in by request for a "heavier" look than ig_barry, and thematically fits: this is
    -- the Biker DLC's own gang. A real /coords, deliberately far from the farm itself (Vespucci
    -- Canals) - not tied to it physically.
    dealer = vector4(-1648.29, -1012.90, 6.30, 129.92),
    dealerPed = `g_m_y_lost_01`,
    -- Servidor: the actual interact radius, checked both client-side (the [E] prompt only shows
    -- and works this close) and server-side (the real proximity check `sell`/`buyRetail` enforce) -
    -- same two-tier marker+[E] shape the 9 plots already use, not the whole-15m zone this used to
    -- be. See ADR-066.
    dealerDistance = 2.0,
    brickPrice = 3500,

    -- Servidor: every brick sold restocks the dealer's shared retail supply - anyone, not just
    -- whoever delivered the brick, can then buy a bag from that same shared stock, first-come-
    -- first-served (same open-access reasoning as ADR-057's harvest).
    --
    -- `bagItem` is its OWN item, not the harvested `weed_skunk` it used to reuse. That reuse was
    -- an economy exploit, not just a naming quirk: the press consumes `weed_skunk`, so a player
    -- could buy 5 bags ($1000), press them straight into a brick, sell it ($3500), and pocket
    -- the difference while restocking 10 more bags - a money printer that never touched a plot.
    -- The four steps are now four distinct items: seed -> bud -> brick -> bag. See ADR-073.
    bagItem = 'weed_bag',
    bagsPerBrick = 10, -- 2000 brick weight / 200 bag weight - a real ratio, not a guess

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
    --   * Baseado - stress relief only (6 ticks of 15-18 over ~60s), no movement or combat edge.
    --     Real utility, no power, and the one whose loop was broken until ADR-085 fixed it.
    --   * Papelote - 20s, 1.1x sprint, and a 10% chance per second of ragdolling you mid-run.
    --   * Dose - 8s, 1.49x sprint, no ragdoll at all.
    --
    -- So: cheapest here. It is the only one of the three with no combat application, and pricing
    -- it level with the Dose would have meant nobody ever bought it.
    --
    -- Producer economics are still untouched - a brick sells for `brickPrice` and restocks
    -- `bagsPerBrick` regardless of which form buyers take. See ADR-085.
    --
    -- Producer economics are deliberately untouched - a brick still sells for `brickPrice` and
    -- still restocks `bagsPerBrick`, whichever form buyers then choose.
    consumerItem = 'joint',
    consumerLabel = 'Baseado',
    consumerLabelPlural = 'Baseados',

    -- Servidor: the short name, used ONLY on the half-width quantity card in the dealer menu. An
    -- inline option gets half a row (ADR-088) and the title wraps on `overflowWrap: break-word`,
    -- so `Dose de Metanfetamina` broke mid-word there - reported. The plain bag card already had
    -- its own short label (`Saquinho`/`Porção`); this gives the consumer card the same. Every
    -- other place - the buy row, the notifications, the hover card - keeps the full name, since
    -- those have the width for it. See ADR-093.
    consumerCardLabel = 'Baseado',
    consumerPrice = 150,

    -- Servidor: one line, shown in the dealer menu's hover card so a buyer can compare the three
    -- forms before spending. Descriptive text only - the real effect lives in qbx_consumables (and,
    -- for meth, in this resource's own client.lua). If the two ever disagree this string is the
    -- wrong one. See ADR-086.
    consumerEffect = 'alívio de estresse',
    bagPrice = 200, -- a starting guess, cheap enough to leave margin for reselling in the city
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

    -- A separate NPC, elsewhere on the map, who sells seeds - the only way to get one at all,
    -- since ox_inventory's own seed items exist in its catalog but nothing else in this project
    -- sells or hands them out. A real /coords, up in the hills near Grapeseed. `cs_dale` -
    -- confirmed with /testprop after u_m_y_hillbilly_01/02 both turned out not to exist in this
    -- build - a real base-game character with exactly the hillbilly look asked for.
    seedVendor = vector4(1901.72, 4922.60, 48.80, 191.78),
    seedVendorPed = `cs_dale`,
    -- Servidor: same tightened, checked-both-sides radius as the dealer above.
    seedVendorDistance = 2.0,
    seedPrice = 300, -- a starting guess weighed against brickPrice, not a measured value
    seedPurchaseCeiling = 50, -- a sanity ceiling for the quantity dialog, not a real stock limit

    -- How much raw weed one harvest yields, regardless of strain.
    yieldPerHarvest = 5,

    -- Servidor: only Skunk, by request - keeps the whole loop coherent end to end, since the
    -- dealer's retail `bagItem` above was already hardcoded to `weed_skunk`. The other five
    -- strains ox_inventory's items.lua defines (AK47, Amnesia, OG Kush, White Widow, Purple
    -- Haze) are real, existing items, just not offered by this farm - trivial to add back to
    -- this list later if the farm ever grows more than one strain.
    strains = {
        { seed = 'weed_skunk_seed', plant = 'weed_skunk', label = 'Skunk' },
    },
}

return Config
