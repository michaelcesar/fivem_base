fx_version 'cerulean'
game 'gta5'

name 'srv_shootingrange'
description 'Servidor artillery courses - each one grants the licence that unlocks the crosshair for a weapon class'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client.lua',
}

server_scripts {
    'server.lua',
}

dependencies {
    'srv_lib',
    'ox_lib',
    'ox_inventory',
    'qbx_core',
}

lua54 'yes'
