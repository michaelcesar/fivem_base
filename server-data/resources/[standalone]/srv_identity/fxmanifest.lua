fx_version 'cerulean'
game 'gta5'

name 'srv_identity'
description 'Servidor character document - /documento, and the radial Meu Personagem group'

client_scripts {
    -- Required: this resource reads `QBX.PlayerData` directly. Every resource has its own Lua
    -- state, so without this shim `QBX` is nil here - see docs/conventions.md.
    '@qbx_core/modules/playerdata.lua',
    '@ox_lib/init.lua',
    'client.lua',
}

ui_page 'web/index.html'

files {
    'web/index.html',
}

dependencies {
    'ox_lib',
    'qbx_core',
}

lua54 'yes'
