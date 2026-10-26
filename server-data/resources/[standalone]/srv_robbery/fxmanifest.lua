fx_version 'cerulean'
game 'gta5'

name 'srv_robbery'
description 'Servidor - armed robbery in tiers: convenience stores, lockpick houses, guarded story houses'

-- The minigame this tier uses. Declared as a dependency rather than assumed to be running: the
-- whole interaction is a no-op without it, and a silent no-op is worse than a boot-time complaint.
-- The tiers above will add `ultra-voltlab` and `safecracker` here.
dependency 'mhacking'

-- Every successful robbery marks the player - see `srv_wanted`.
dependency 'srv_wanted'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

-- `playerdata.lua` is what populates `QBX.PlayerData` client-side - the closed launderer reads the
-- player's own gang from it to decide whether to show its prompt. Same include srv_shootingrange
-- already uses for licences.
client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

lua54 'yes'
