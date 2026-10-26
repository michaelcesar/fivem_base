-- Servidor: the crack lab - the fourth illegal farm, and deliberately identical to the other three
-- in every number that matters. An earlier version fed it `cocaine_paste` from `srv_cocainelab`,
-- which coupled the two farms and was the most interesting thing this drug added - dropped anyway,
-- because a farm whose input is another farm's output has a supply bottleneck by construction, and
-- the four were asked to be equal and unbottlenecked. Depth traded for symmetry, knowingly.
-- See ADR-095.
--
-- Location: bob74_ipl's Los Santos Drug Wars "Acid Lab" (`dlc_drugwars/lab.lua`, interior 290305),
-- already loaded on this server - `bob74_ipl/client.lua` calls `DrugWarsLab.LoadDefault()`
-- unconditionally. Thematically it is an acid lab and this is a reskin, chosen deliberately over
-- building an LSD chain from nothing: crack already had a real item (`crack_baggy`) with a real,
-- tested effect and no way to obtain it, and LSD has neither. No player-facing text names the
-- interior - every blip in this project reads "Desconhecido".
--
-- Every coordinate below is a real `/coords` the user took standing at each spot, per CLAUDE.md's
-- rule against guessing world positions. None are computed.
--
Config = {
    -- Servidor: the gang that owns this site. Everything in the PRODUCTION chain - buying the input
    -- from the vendor, entering the interior, working a station, pressing, and selling wholesale to
    -- the dealer - is restricted to members of this gang. Street RETAIL is deliberately NOT gated:
    -- buying retail bags and running the selling route stay open to everyone, so a player with no
    -- gang still has illegal work. See ADR-125.
    --
    -- The Ballas are GTA's crack dealers, the counterpart to the Families' weed.
    --
    -- Set to nil or 'none' to make this site unowned and open to everybody again; the checks read
    -- this field and nothing else, so ownership moves with one edit here.
    ownerGang = 'ballas',

    lab = {
        interiorId = 290305,
    },

    -- Servidor: an {outside, inside} teleport pair, srv_weedfarm's ADR-059 shape - the interior sits
    -- at z=-49 with no walkable door to the street. `outside` is a real street point; `inside` is
    -- where the player lands.
    --
    -- `distance` is 0.5, not the 1.5 the other farms use, and that is forced rather than chosen: the
    -- inside point is only 1.15m from the press bench. At 1.5 the exit prompt would sit on top of
    -- the crafting bench's own zone. 0.5 here plus 0.6 on the bench (see `data/crafting.lua`) leaves
    -- 0.05m of clearance - it fits, but only just. Worth re-taking `inside` a metre further from the
    -- press if it ever feels cramped in game.
    entrance = {
        outside = vector4(661.56, -2644.12, 8.41, 169.19),
        inside = vector4(482.29, -2623.96, -49.06, 0.71),
        distance = 0.5,
    },

    -- Servidor: 9 stations, the same as the other three - but it took two rounds of real /coords to
    -- get there. The first pass produced a reading 0.70m from its neighbour, tighter than anything
    -- in this project and tighter than the 1.27m pair that caused the zone-overlap bug at
    -- srv_cocainelab (ADR-067/068). Two inner zones of radius r touch at 2r, so 0.70m would have
    -- forced a radius under 0.35 - small enough that a player would have to stand almost exactly on
    -- the spot. That reading was dropped and the farm shipped with 8.
    --
    -- The replacement, taken in the widest gap in the room, sits 1.56m from its nearest neighbour -
    -- nearly double the 0.80m the 0.40 radius needs, and the most comfortable station in here. See
    -- ADR-097.
    stations = (function()
        local coords = {
            vector4(487.12, -2624.16, -48.66, 42.08),
            vector4(488.23, -2624.05, -48.66, 221.53),
            vector4(488.13, -2625.24, -48.66, 185.74),
            vector4(488.23, -2626.13, -48.66, 188.75),
            vector4(487.06, -2625.76, -48.66, 180.14),
            vector4(484.77, -2625.65, -49.06, 102.07),
            vector4(482.83, -2625.69, -49.06, 145.03),
            vector4(484.89, -2624.25, -49.06, 165.09),
            vector4(481.33, -2625.53, -48.66, 203.88),
        }
        local list = {}
        for i = 1, #coords do
            list[i] = { key = ('station%d'):format(i), label = ('Estação %d'):format(i), coords = coords[i] }
        end
        return list
    end)(),

    -- Servidor: same value srv_cocainelab and srv_methlab already use. The closest pair here is
    -- 0.90m, which this radius clears with 0.10m to spare - see the `stations` note above.
    stationDistance = 0.4,

    -- Servidor: the press bench. `srv_cracklab_press` in ox_inventory/data/crafting.lua reuses this
    -- coordinate directly and pins its own radius to 0.6 - the two must be kept in sync if this
    -- point ever moves.
    pressStation = vector4(483.43, -2624.10, -49.06, 359.36),

    -- Servidor: 180 minutes, the same as the other three. It was 90 while the input was another
    -- farm's output, to pay for the extra stage; with its own vendor there is no extra stage to pay
    -- for, and a shorter cycle would just make this farm strictly better than its siblings.
    processingMinutes = 180,

    processDuration = 3000,

    -- Servidor: its own accelerator, not a borrowed one. It was `cocaine_solvent` while crack was fed
    -- by the cocaine lab and the two shared a supply chain; with the farms made independent
    -- (ADR-095) that reuse left crack as the only one of the four without a chemical of its own.
    -- Ammonia is what actually cooks cocaine base into crack, so the item is real rather than a
    -- reskin. Values mirror the other three exactly (ADR-082). See ADR-096.
    boostItem = 'crack_ammonia',
    boostLabel = 'Amônia',
    boostMinutes = 30,
    maxBoosts = 3,
    boostDuration = 2000,

    yieldPerBatch = 5,

    -- Servidor: the chain, one bought input like every other farm. `crack_base` is a new item and
    -- deliberately NOT `cocaine_paste`: the cocaine press turns 5 paste into a $3500 brick, so an NPC
    -- selling paste at $300 would let anyone buy 5 for $1500 and press $3500 without ever touching a
    -- lab. Same money-printer shape as ADR-073, arriving through the supplier instead of the dealer.
    inputItem = 'crack_base',
    productItem = 'crack_rock',
    brickItem = 'crack_brick',

    -- Servidor: `bagItem` is the resale form with no effect, `consumerItem` the one that does
    -- something. Unlike the other three, `consumerItem` needed no work at all: `crack_baggy` already
    -- existed with a full effect in `qbx_consumables` and simply had no origin anywhere on the
    -- server. See ADR-094.
    bagItem = 'crack_bag',
    consumerItem = 'crack_baggy',
    consumerLabel = 'Pedra de Crack',
    consumerLabelPlural = 'Pedras de Crack',
    consumerCardLabel = 'Pedra',
    consumerEffect = '8s, corrida 1,3x, tombo frequente',

    -- Servidor: the supplier who sells `crack_base` - this farm's equivalent of srv_weedfarm's seed
    -- vendor, srv_cocainelab's leaf vendor and srv_methlab's precursor vendor. `nil` until a real
    -- `/coords` exists: the same "not playable until mapped" rule every NPC in this project follows,
    -- and with it nil the vendor simply does not spawn. Nothing else here breaks.
    inputVendor = vector4(1043.40, -1957.52, 35.13, 248.14),
    inputVendorPed = `ig_barry`,
    inputVendorDistance = 2.0,
    -- Mirrors seedPrice/leafPrice/precursorPrice and their ceilings exactly.
    inputPrice = 300,
    inputPurchaseCeiling = 50,

    -- Servidor: a real /coords, deliberately far from the lab and from the other three dealers. This
    -- replaces an earlier reading at (972.04, -1871.62, 31.17) - kept here only so the old point is
    -- recoverable if this one turns out to be the wrong spot.
    dealer = vector4(452.65, -873.73, 27.44, 313.99),
    dealerPed = `ig_barry`,
    dealerDistance = 2.0,

    -- Servidor: every number below mirrors the other three exactly. `brickPrice` was $6000 while the
    -- cycle was 90 minutes and the input came from another farm; both of those are gone.
    brickPrice = 3500,
    bagsPerBrick = 10,
    bagPrice = 200,
    dailyBrickLimit = 5,
    dailyBuyLimit = 20,

    -- Servidor: priced between the Papelote and the Dose, matching where its effect sits - 1.3x
    -- sprint for 8s, but the heaviest ragdoll of the four (60% per second while running, against
    -- the Papelote's 10%). See ADR-085 for how the other three were placed.
    consumerPrice = 350,
}

return Config
