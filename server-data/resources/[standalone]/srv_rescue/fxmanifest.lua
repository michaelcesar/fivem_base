fx_version 'cerulean'
game 'gta5'

name 'srv_rescue'
description 'Servidor - the paid NPC ambulance rescue for downed players'
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
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

ui_page 'html/index.html'

files {
    'config.lua',
    'html/index.html',
}

dependencies {
    'qbx_core',
    'qbx_medical',
    'ox_lib',
    'srv_wanted',
}

lua54 'yes'
