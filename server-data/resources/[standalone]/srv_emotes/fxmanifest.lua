fx_version 'cerulean'
game 'gta5'

name 'srv_emotes'
description 'Servidor quick emote keybinds - the ones the server presets, not the player'

client_scripts {
    '@ox_lib/init.lua',
    'client.lua',
}

dependencies {
    'ox_lib',
    'scully_emotemenu',
}

lua54 'yes'
