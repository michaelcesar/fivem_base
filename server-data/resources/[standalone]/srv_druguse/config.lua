-- Servidor: the HUD needs to know which drug effects are running. Nothing told it.
--
-- The effects themselves live in `qbx_consumables` (and, for the meth dose, in `srv_methlab`). This
-- resource does not reimplement or modify any of them - it listens to the SAME net events the
-- server already fires to start them, and keeps a note of what is running and until when.
--
-- Listening rather than patching matters: `qbx_consumables` is third-party, and ADR-007's trap is
-- that an edit inside one survives exactly until the next update. A `RegisterNetEvent` on a name
-- that resource already uses adds a second handler and changes nothing about the first.
--
-- **Every number below was read out of the effect's own code, not estimated.** That is also the
-- weakness of this design: these values are a COPY of upstream's, and nothing detects them drifting
-- apart. If a stimulant is retuned in `qbx_consumables`, the panel will confidently display the old
-- figure. The numbers are all in one place here precisely so re-reading them is a small job.

Config = {
    --- Every effect worth showing, keyed by the net event that starts it.
    ---
    --- `key` matches the string `qbx_consumables` registers its sprint boost under, so two entries
    --- sharing a key (the plain meth item and srv_methlab's dose) correctly count as one effect
    --- rather than stacking with themselves.
    ---
    --- `speed` is the sprint multiplier the effect passes to `stimulant`. `stamina` is its percent
    --- chance, per second, of restoring stamina.
    ---@type table<string, {key: string, label: string, icon: string, duration: number, speed: number, stamina: number}>
    effects = {
        -- `smokeWeed` counts `relieveCount` to 6 with `Wait(10000)` between each: 60s. It never
        -- calls `stimulant`, so it has no speed boost and no stamina - it relieves stress, which
        -- is why `speed` is 1.0 here rather than absent.
        ['consumables:client:UseJoint'] = {
            key = 'weed', label = 'Maconha', icon = 'cannabis',
            duration = 60000, speed = 1.0, stamina = 0,
        },
        -- `cokeBaggyEffect`: stimulant('coke', 1.1, 20, 20).
        ['consumables:client:Cokebaggy'] = {
            key = 'coke', label = 'Cocaína', icon = 'snowflake',
            duration = 20000, speed = 1.1, stamina = 20,
        },
        -- `crackBaggyEffect`: stimulant('crack', 1.3, 8, 10).
        --
        -- The icon is `fire-alt`, NOT `fire-flame-curved`. The latter is the Font Awesome 6 name
        -- for the same glyph, and qbx_hud loads Font Awesome 5.13 - so the icon existed in the
        -- map, resolved to nothing, and crack was the one drug that showed a blank slot.
        ['consumables:client:Crackbaggy'] = {
            key = 'crack', label = 'Crack', icon = 'fire-alt',
            duration = 8000, speed = 1.3, stamina = 10,
        },
        -- `ecstasyEffect`: stimulant('ecstasy', 1.0, 30, 100).
        ['consumables:client:EcstasyBaggy'] = {
            key = 'ecstasy', label = 'Ecstasy', icon = 'compact-disc',
            duration = 30000, speed = 1.0, stamina = 100,
        },
        -- `methBagEffect`: stimulant('meth', 1.49, 8, 5). Both the plain `meth` item and
        -- `srv_methlab`'s own `meth_dose` end up in this same function, so they share a key.
        ['consumables:client:meth'] = {
            key = 'meth', label = 'Metanfetamina', icon = 'vial',
            duration = 8000, speed = 1.49, stamina = 5,
        },
        ['srv_methlab:client:useDose'] = {
            key = 'meth', label = 'Metanfetamina', icon = 'vial',
            duration = 8000, speed = 1.49, stamina = 5,
        },
    },

    -- Deliberately absent: `consumables:client:oxy`. Oxycodone calls `healOxy()` and clears blood
    -- damage - it is a heal, not a high, and there is no state to show afterwards. An icon there
    -- would be announcing something that is already over.

    --- Shown in the HUD's status column when more than one effect is running, in place of any
    --- single drug's icon. Which one would it otherwise pick? Whichever was taken last is a lie
    --- about what the player is currently on.
    combo = { label = 'Combo', icon = 'layer-group' },

    --- The ceiling `applySprint` clamps the product to. Mirrored, not read: there is no export
    --- that reports it. Showing an uncapped product would promise a speed the game refuses to
    --- give, which is worse than showing no number.
    speedCap = 1.49,

    -- How long the effect can still be showing after its own duration, in ms. The events fire the
    -- effect and the effect starts with an animation, so the icon would otherwise clear a moment
    -- before the player stops feeling it.
    grace = 1500,
}
