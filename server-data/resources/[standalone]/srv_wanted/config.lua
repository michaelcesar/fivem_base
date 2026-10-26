-- Servidor: the "procurado" mark - anyone who finishes robbing a store or a house wears a visible
-- black backpack for a fixed window, and while it is on them, every clothing store and every
-- convenience store refuses to open at all, telling them why, and reports the attempt to the
-- police. The backpack is the point: it is not a stat only the player can see, it is something
-- every other player can see across the map, the same way a wanted level in GTA Online reads from
-- outside the HUD.
Config = {
    -- Servidor: how long the mark lasts on its own, in real minutes, if nothing else clears it first.
    durationMinutes = 10,

    -- Servidor: component 5 is "bags" in this project's own clothing system - confirmed against
    -- `illenium-appearance`'s `componentBlacklistMap` (`componentId == 5` returns
    -- `genderSettings.bags`), not guessed. Drawable 45 confirmed in game via `srv_tools`'
    -- `/testbag 45` on both `mp_m_freemode_01` and `mp_f_freemode_01` - a black backpack on both.
    backpack = {
        component = 5,
        male = { drawable = 45, texture = 0 },
        female = { drawable = 45, texture = 0 },
    },

    -- Servidor: the escape valve. Using this item opens the full appearance editor directly
    -- (`illenium-appearance:client:openClothingShopMenu`, the same one a clothing store's own point
    -- opens) regardless of the mark - the block above is specifically on the WORLD shop points, not
    -- on this item, since the item is the one legitimate way to change clothes while marked. Using
    -- it clears the mark immediately once the editor opens, rather than trying to detect whether
    -- the player specifically removed slot 5 - simpler, and the item is themed as spending it to
    -- "go to ground and change", which reads fine either way.
    wardrobeItem = 'wardrobe_pass',

    -- Servidor: the message `police:server:policeAlert` shows for a marked player attempting a shop
    -- - matches `srv_robbery`'s own `alert` string's shape ("Assalto em andamento") so both read
    -- as the same kind of report rather than two different alert systems.
    alert = 'Procurado tentando usar loja',
}

return Config
