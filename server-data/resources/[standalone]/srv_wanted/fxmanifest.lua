fx_version 'cerulean'
game 'gta5'

name 'srv_wanted'
description 'Servidor - the "procurado" mark: a visible backpack, blocked shops, a police alert on every attempt to use one while marked'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'

server_script 'server.lua'

-- The countdown badge - plain HTML/CSS/JS, no build step, same shape as `srv_trade`'s own web/.
ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
}

lua54 'yes'
