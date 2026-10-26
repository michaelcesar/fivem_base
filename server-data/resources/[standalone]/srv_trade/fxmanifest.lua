fx_version 'cerulean'
game 'gta5'

name 'srv_trade'
description 'Servidor - player-to-player trading: two offers, two confirmations, one atomic swap'

-- `ox_inventory` is where the items live and where every move is made; `ox_target` is the menu the
-- trade is started from. Declared rather than assumed - without either, this resource is inert.
dependencies {
    'ox_inventory',
    'ox_target',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'
server_script 'server.lua'

-- Servidor: this resource draws its own screen rather than extending ox_inventory's React app. The
-- styling below is copied from ox_inventory's own stylesheet so the two look like one thing; see
-- ADR-103 for why the fork was abandoned.
ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
}

lua54 'yes'
