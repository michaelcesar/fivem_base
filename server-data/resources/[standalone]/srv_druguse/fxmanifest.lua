fx_version 'cerulean'
game 'gta5'

name 'srv_druguse'
description 'Servidor: shows which drug effects are running, with time left and combined figures.'
author 'Servidor'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
}

lua54 'yes'
