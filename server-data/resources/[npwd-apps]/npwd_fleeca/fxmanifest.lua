fx_version 'cerulean'
game 'gta5'

description 'Fleeca banking app for NPWD'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
}

client_script 'client/client.lua'

server_scripts {
    'server/server.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
