fx_version 'cerulean'
game 'gta5'

name 'srv_tutorial'
description 'Servidor in-game guide - /tutorial, /ajuda, /guia'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

dependencies {
    'ox_lib',
}

lua54 'yes'
