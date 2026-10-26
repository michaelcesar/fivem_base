-- Servidor: "Trouxa de Roupas" - opens a menu of the player's own saved outfits from anywhere, no
-- shop or wanted state involved. Deliberately its own resource rather than living in `srv_wanted`
-- alongside the "Kit de Disfarce": that item exists FOR the "procurado" mark, this one has nothing
-- to do with it - usable any time, by anyone, unlimited times.
Config = {
    bundleItem = 'clothes_bundle',
}

return Config
