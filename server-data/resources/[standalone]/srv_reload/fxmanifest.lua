fx_version 'cerulean'
game 'gta5'

name 'srv_reload'
description 'Servidor: press R to reload from inventory ammo, FPS-style.'
author 'Servidor'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'

lua54 'yes'
