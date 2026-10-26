fx_version 'cerulean'
game 'gta5'

name 'srv_lib'
description 'Servidor shared primitives - the patterns every srv_* resource is expected to use'

client_scripts {
    -- Required by `IsInGang`'s client fast path, which reads `QBX.PlayerData.gang`. Every resource
    -- has its own Lua state, so this shim is what gives `srv_lib` a `QBX` table of its own - see
    -- docs/conventions.md, "QBX is not a shared global". Dropping this line makes the export crash
    -- rather than silently answer false, which is deliberate.
    '@qbx_core/modules/playerdata.lua',
    'client.lua',
}

server_scripts {
    'server.lua',
}

dependencies {
    'ox_lib',
    -- `IsInGang` uses `qbx_core` on both sides: the `GetPlayer` export server-side and the
    -- `playerdata.lua` shim client-side.
    'qbx_core',
}

lua54 'yes'
