-- Servidor: the meth lab - srv_cocainelab's sibling, same buy -> process -> collect -> press ->
-- sell loop (no "planting" verb here either - bob74_ipl's Meth Lab, like the Cocaine Lockup, is a
-- processing lab with style/security prop groups, not a field with grow-spot props). Shipped
-- fully implemented before any real /coords existed, by explicit request - every location field
-- below now has one, gathered across several follow-up messages. See ADR-071.
--
-- Servidor: every location field below reads real, user-taken /coords now - none were guessed.
-- While they were still pending, every field was `nil` (or an empty list, for `stations`) rather
-- than a placeholder number, the same "not playable until mapped" rule `srv_jobs`' own `tow` job
-- documents (see srv_jobs/config.lua's top comment) - kept here as a reminder of that shape in
-- case any field needs to move back to `nil` for some future addition to this resource.
--
Config = {
    -- Servidor: the gang that owns this site. Everything in the PRODUCTION chain - buying the input
    -- from the vendor, entering the interior, working a station, pressing, and selling wholesale to
    -- the dealer - is restricted to members of this gang. Street RETAIL is deliberately NOT gated:
    -- buying retail bags and running the selling route stay open to everyone, so a player with no
    -- gang still has illegal work. See ADR-125.
    --
    -- The Lost MC run meth in GTA Online's own biker businesses, which is also where this interior comes from.
    --
    -- Set to nil or 'none' to make this site unowned and open to everybody again; the checks read
    -- this field and nothing else, so ownership moves with one edit here.
    ownerGang = 'lostmc',

    -- The Meth Lab interior itself, from bob74_ipl/dlc_bikers/meth.lua (interior ID 247041) - the
    -- one real value already known without needing a /coords, since it's read straight from that
    -- file, the same way srv_weedfarm's and srv_cocainelab's own `interiorId` were.
    lab = {
        interiorId = 247041,
    },

    -- Servidor: this interior has no walkable door of its own after all - corrects the earlier
    -- assumption that the single "saida" coordinate was a real door (like srv_cocainelab's own
    -- entrance). It's an {outside, inside} teleport pair instead, srv_weedfarm's ADR-059 shape:
    -- `outside` is a real street-level entrance ~800 units from the lab itself, `inside` is what
    -- was first read as "saida" - a real /coords right next to the interior. Both real, confirmed
    -- by the user, not computed. `distance` mirrors srv_weedfarm's own `entrance.distance`.
    entrance = {
        outside = vector4(1021.24, -2434.86, 29.65, 62.13),
        inside = vector4(997.70, -3200.43, -36.39, 112.86),
        distance = 1.5,
    },

    -- The lab's 9 real processing spots, all real /coords the user took standing at each one -
    -- the same clustered row (same Y, walked down the line), not computed. Two near-duplicate
    -- readings (retaken at the same spot) were dropped, keeping one real coordinate per spot.
    stations = (function()
        local coords = {
            vector4(1014.54, -3195.54, -38.99, 15.89),
            vector4(1013.24, -3195.35, -38.99, 44.90),
            vector4(1012.11, -3195.45, -38.99, 57.28),
            vector4(1010.71, -3195.28, -38.99, 59.72),
            vector4(1009.09, -3195.28, -38.99, 50.83),
            vector4(1007.50, -3195.31, -38.99, 64.11),
            vector4(1005.93, -3195.60, -38.99, 77.98),
            vector4(1003.95, -3195.21, -38.99, 78.59),
            vector4(1002.00, -3195.30, -38.99, 352.81),
        }
        local list = {}
        for i = 1, #coords do
            list[i] = { key = ('station%d'):format(i), label = ('Estação %d'):format(i), coords = coords[i] }
        end
        return list
    end)(),

    -- Servidor: same tightened-radius reasoning as srv_cocainelab's own `stationDistance` (see
    -- that resource's config.lua) - these 9 spots sit ~1.2-1.9m apart along the same row, close
    -- enough that copying a wider radius risks the exact ADR-067/068 zone-overlap bug. 0.4 keeps
    -- every pair's inner zones clear, same value already proven safe at srv_cocainelab's own,
    -- even more tightly packed stations.
    stationDistance = 0.4,

    -- Servidor: a real /coords - the "mesa de trabalho" (work table), confirmed by the user as the
    -- real press bench location, correcting an earlier guess at this same field (a different
    -- corner-of-the-room point that turned out not to be it). `srv_methlab_press` in
    -- ox_inventory/data/crafting.lua reuses this coordinate directly - the two must be kept in
    -- sync if this point ever moves.
    pressStation = vector4(1016.18, -3200.70, -38.99, 177.52),

    -- How long one batch takes at a station, in real minutes - mirrors srv_weedfarm's/
    -- srv_cocainelab's own value exactly. A starting guess, not measured.
    processingMinutes = 180,

    -- ms, ox_lib progress circle shown while starting a batch - mirrors srv_weedfarm's/
    -- srv_cocainelab's own `plantDuration`/`processDuration`.
    processDuration = 3000,

    -- Servidor: the accelerator - `meth_catalyst`, this lab's equivalent of srv_weedfarm's
    -- fertilizer, mirroring its values exactly (see that file for the arithmetic behind 30/3 and
    -- the $500 price). Sold by `srv_chemist`, never produced. See ADR-082.
    boostItem = 'meth_catalyst',
    boostLabel = 'Catalisador',
    boostMinutes = 30,
    maxBoosts = 3,

    -- ms, mirrors srv_weedfarm's/srv_cocainelab's own `boostDuration`.
    boostDuration = 2000,

    -- How much raw product one batch yields - mirrors srv_weedfarm's/srv_cocainelab's own
    -- `yieldPerHarvest`/`yieldPerBatch`.
    yieldPerBatch = 5,

    -- Real items, added to ox_inventory/data/items.lua alongside this resource. Four distinct
    -- items, one per step: precursor (bought) -> product (processed) -> brick (pressed) ->
    -- bag (retail). `meth` already existed in ox_inventory's own default catalog (unused, no
    -- `client.image`) and is reused as the processed product rather than inventing a new key.
    -- `bagItem` used to be `meth` as well, which was an economy exploit - the press consumes
    -- `meth`, so bought bags could be pressed straight back into a brick worth more than they
    -- cost. Same bug srv_weedfarm/srv_cocainelab had, fixed the same way. See ADR-073.
    precursorItem = 'meth_precursor',
    productItem = 'meth',
    brickItem = 'meth_brick',
    bagItem = 'meth_bag',

    -- Servidor: a real /coords. `ig_barry` reused as a placeholder ped, same reasoning as
    -- srv_cocainelab's own leaf vendor/dealer (already confirmed present, used at every
    -- srv_jobs depot) - swap once a specific model is chosen and confirmed with `/testprop`.
    precursorVendor = vector4(488.81, -2206.17, 5.92, 117.18),
    precursorVendorPed = `ig_barry`,
    precursorVendorDistance = 2.0,
    -- Mirrors srv_weedfarm's/srv_cocainelab's own seedPrice/leafPrice and
    -- seedPurchaseCeiling/leafPurchaseCeiling exactly.
    precursorPrice = 300,
    precursorPurchaseCeiling = 50,

    -- Servidor: a real /coords, given by the user labelled "comprador e vendedor" (buyer and
    -- seller) - this resource's own wholesale brick buyer, same role srv_weedfarm's/
    -- srv_cocainelab's own `dealer` play for their drugs. The street-selling shift itself
    -- (`srv_jobs`' `methdealing` job) uses a different, shared coordinate - the same vanilla
    -- depot every dealable drug's shift starts at (confirmed by the user: "o trabalho de vender é
    -- no vanilla também, todas as drogas por padrão lá"), not this one.
    dealer = vector4(-320.14, -1077.82, 30.39, 222.65),
    dealerPed = `ig_barry`,
    dealerDistance = 2.0,
    -- Mirrors srv_weedfarm's/srv_cocainelab's own brickPrice/bagsPerBrick/bagPrice/
    -- dailyBrickLimit exactly.
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
    --   * Papelote - 20s, 1.1x sprint, and a 10% chance per second of ragdolling you mid-run.
    --   * Dose - 8s, 1.49x sprint, 5%/s stamina, no ragdoll, and the only one that sets two
    --     evidence statuses (`widepupils` and `agitated`) rather than one.
    --
    -- So: dearest. Strictly better than the Papelote on every axis except duration, so at a flat
    -- price it made the other two pointless. The higher cost and the extra forensic trail are what
    -- pay for that.
    --
    -- Producer economics are still untouched - a brick sells for `brickPrice` and restocks
    -- `bagsPerBrick` regardless of which form buyers take. See ADR-085.
    --
    -- Producer economics are deliberately untouched - a brick still sells for `brickPrice` and
    -- still restocks `bagsPerBrick`, whichever form buyers then choose.
    consumerItem = 'meth_dose',
    consumerLabel = 'Dose de Metanfetamina',
    consumerLabelPlural = 'Doses de Metanfetamina',

    -- Servidor: the short name, used ONLY on the half-width quantity card in the dealer menu. An
    -- inline option gets half a row (ADR-088) and the title wraps on `overflowWrap: break-word`,
    -- so `Dose de Metanfetamina` broke mid-word there - reported. The plain bag card already had
    -- its own short label (`Saquinho`/`Porção`); this gives the consumer card the same. Every
    -- other place - the buy row, the notifications, the hover card - keeps the full name, since
    -- those have the width for it. See ADR-093.
    consumerCardLabel = 'Dose de M.',
    consumerPrice = 550,

    -- Servidor: one line, shown in the dealer menu's hover card so a buyer can compare the three
    -- forms before spending. Descriptive text only - the real effect lives in qbx_consumables (and,
    -- for meth, in this resource's own client.lua). If the two ever disagree this string is the
    -- wrong one. See ADR-086.
    consumerEffect = '8s, corrida 1,49x, sem tombo',
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
