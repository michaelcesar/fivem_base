fx_version 'cerulean'
game 'gta5'

name 'srv_vehiclelocks'
description 'Servidor - [E] prompts for a car you do not have the key to: unlock/lockpick at the door, search for keys or hotwire once seated'

-- Reuses qbx_vehiclekeys' own lock-toggle server event and its own lockpick minigame
-- (`lockpicks:UseLockpick`) rather than reimplementing either. Declared so a missing
-- qbx_vehiclekeys fails loudly at boot instead of this resource silently doing nothing in play.
dependencies {
    'qbx_vehiclekeys',
}

shared_scripts {
    '@ox_lib/init.lua',
}

client_script 'client.lua'

server_script 'server.lua'

lua54 'yes'
