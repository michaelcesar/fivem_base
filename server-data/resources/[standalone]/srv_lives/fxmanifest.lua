fx_version 'cerulean'
game 'gta5'

name 'srv_lives'
description 'Servidor - character lives and the permanent block when they run out'
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

ui_page 'html/index.html'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

files {
    'config.lua',
    'html/index.html',
}

lua54 'yes'
