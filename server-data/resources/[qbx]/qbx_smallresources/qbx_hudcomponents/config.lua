return {
    disable = {
        -- https://docs.fivem.net/natives/?_0x6806C51AD12B83B8
        -- NOTE: 14 (HUD_RETICLE, the weapon crosshair) was intentionally removed from this
        -- list. The srv_crosshair resource owns it now: the crosshair is hidden unless
        -- the player is carrying a weapon license.
        hudComponents = {1, 2, 3, 4, 7, 9, 13, 19, 20, 21, 22},

        -- https://docs.fivem.net/docs/game-references/controls/
        controls = {37},

        -- Servidor: off. GTA's own ammo counter sits top right and says the same thing the HUD's
        -- own readout does, in a different typeface and a different place. Ours stays.
        --
        -- The name reads backwards: `false` DISABLES the display. It is passed straight to
        -- `DisplayAmmoThisFrame`. See ADR-163.
        displayAmmo = false,
    }
}
