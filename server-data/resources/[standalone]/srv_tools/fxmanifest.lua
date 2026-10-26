fx_version 'cerulean'
game 'gta5'

name 'srv_tools'
description 'Dev tools used while building the Servidor server (e.g. /coords) - do not ship to production'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

dependencies {
    'srv_lib',
    'ox_lib',
    'srv_shootingrange',
}

lua54 'yes'
