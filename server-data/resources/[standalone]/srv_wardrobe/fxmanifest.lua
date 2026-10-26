fx_version 'cerulean'
game 'gta5'

name 'srv_wardrobe'
description 'Servidor - "Trouxa de Roupas": browse and switch to your own saved outfits from anywhere, unlimited uses'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'

server_script 'server.lua'

lua54 'yes'
