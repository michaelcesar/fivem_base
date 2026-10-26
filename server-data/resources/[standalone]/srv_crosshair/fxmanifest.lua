fx_version 'cerulean'
game 'gta5'

name 'srv_crosshair'
description 'Servidor rule: the weapon crosshair only shows for players who completed the artillery course'

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client.lua',
}

dependencies {
    'qbx_core',
}

lua54 'yes'
