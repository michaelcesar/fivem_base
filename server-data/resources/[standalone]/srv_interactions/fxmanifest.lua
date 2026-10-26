fx_version 'cerulean'
game 'gta5'

name 'srv_interactions'
description 'Servidor - player-to-player actions on the target key, routed to the resources that own them'

-- The target system this menu lives in, and the two resources whose server events it calls. Declared
-- rather than assumed: every option here is a no-op without them, and a silent no-op is worse than a
-- boot-time complaint.
dependencies {
    'ox_target',
    'qbx_police',
    'qbx_ambulancejob',
    'srv_wanted',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

-- `playerdata.lua` populates `QBX.PlayerData`, which is what the job and duty checks read.
client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client.lua',
}

server_script 'server.lua'

lua54 'yes'
