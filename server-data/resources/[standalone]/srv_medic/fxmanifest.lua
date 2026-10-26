fx_version 'cerulean'
game 'gta5'

name 'srv_medic'
description 'Servidor - paid wound treatment, performed by a medic on a hospital bed'
author 'Servidor'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client.lua',
}

server_scripts {
    'server.lua',
}

files {
    'config.lua',
}

dependencies {
    'qbx_core',
    'qbx_medical',
    'qbx_ambulancejob',
    'srv_interactions',
    'ox_lib',
}

lua54 'yes'
