fx_version 'cerulean'
game 'gta5'

name 'srv_gangs'
description 'Servidor gang gameplay - shared stash and account, reached from the radial menu'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    -- Required: the base points read `QBX.PlayerData.gang` to show only your OWN gang's base.
    -- Every resource has its own Lua state, so without this shim `QBX` is nil here - see
    -- docs/conventions.md, "QBX is not a shared global".
    '@qbx_core/modules/playerdata.lua',
    'client.lua',
}

server_scripts {
    -- The Rota de Cobrança keeps its daily stop count in a table of its own (ADR-145).
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'qbx_core',
    -- The gang account lives here; it registers the `qb-management` export names.
    'Renewed-Banking',
    -- `GangBlipStyle`, for the base blips' colour and name.
    'srv_lib',
    -- The Rota de Cobrança draws its stops from this resource's own `GetSharedStops` - the same 30
    -- street points the dealing job works, rather than a second copy of them.
    'srv_jobs',
    -- The base's wardrobe point opens this resource's own picker, via the server.
    'srv_wardrobe',
}

lua54 'yes'
