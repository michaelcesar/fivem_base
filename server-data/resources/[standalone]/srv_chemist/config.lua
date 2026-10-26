-- Servidor: the chemist - one NPC, elsewhere on the map, selling the production accelerator for
-- all three farms. Deliberately a resource of its own rather than a fourth vendor bolted onto
-- srv_weedfarm/srv_cocainelab/srv_methlab: selling an item needs none of a farm's plot state,
-- database tables or growth arithmetic, and putting a vendor that serves all three inside any one
-- of them would make that farm a dependency of the other two. See ADR-082.
--
-- The farms themselves own what their accelerator *does* (each has its own `boost*` values and its
-- own server-side callback). This resource only sells the items.
--
Config = {
    -- Servidor: a real /coords, out by the Elysian docks - deliberately away from all four farms and
    -- from every farm vendor, so the chemist is a trip of its own rather than a stop on an existing
    -- route. This field was `nil` from ADR-082 until now, which meant none of the accelerators could
    -- be bought by anyone; the resource shipped inert for exactly as long as it had no real point.
    vendor = vector4(806.07, -2373.72, 29.10, 72.73),

    -- Servidor: `ig_barry` - already confirmed present in this build and reused at every srv_jobs
    -- depot and at both of srv_cocainelab's own NPCs, rather than a new unverified model guess.
    -- Swap once a specific model is chosen and confirmed with `/testprop`.
    vendorPed = `ig_barry`,

    -- Servidor: same tight two-tier marker+[E] radius every other illegal NPC in this project uses
    -- (ADR-066), checked both client-side and server-side.
    vendorDistance = 2.0,

    -- Servidor: one entry per farm. `item` is what the player receives; `boostMinutes` is repeated
    -- here purely so the shop can *describe* what it sells - the number that actually applies is
    -- each farm's own `boostMinutes`, read server-side in that farm's own callback. If these ever
    -- disagree the shop copy is wrong but nothing breaks, which is why the real value deliberately
    -- does not live here.
    products = {
        {
            item = 'weed_nutrition',
            label = 'Fertilizante',
            description = 'Acelera o crescimento de um vaso da plantação.',
            icon = 'seedling',
            price = 500,
            boostMinutes = 30,
        },
        {
            item = 'cocaine_solvent',
            label = 'Solvente Químico',
            description = 'Acelera uma estação do laboratório de cocaína.',
            icon = 'flask',
            price = 500,
            boostMinutes = 30,
        },
        {
            item = 'crack_ammonia',
            label = 'Amônia',
            description = 'Acelera uma estação do laboratório de crack.',
            icon = 'flask-vial',
            price = 500,
            boostMinutes = 30,
        },
        {
            item = 'meth_catalyst',
            label = 'Catalisador',
            description = 'Acelera uma estação do laboratório de metanfetamina.',
            icon = 'vial',
            price = 500,
            boostMinutes = 30,
        },
    },

    -- Servidor: a sanity ceiling for the quantity dialog, not a stock limit - mirrors every other
    -- vendor in this project (`seedPurchaseCeiling`, `leafPurchaseCeiling`,
    -- `precursorPurchaseCeiling`), all of which use 50.
    purchaseCeiling = 50,
}

return Config
