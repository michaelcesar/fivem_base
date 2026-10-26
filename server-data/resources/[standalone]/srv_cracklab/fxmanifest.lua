fx_version 'cerulean'
game 'gta5'

name 'srv_cracklab'
description 'Servidor - crack cooking and dealing, fed by srv_cocainelab output rather than by an NPC'

-- Reuses bob74_ipl's Los Santos Drug Wars "Acid Lab" interior (see config.lua) - depended on rather
-- than assumed to be running, so FXServer starts the interior owner first. Same reasoning as the
-- other three farms.
dependency 'bob74_ipl'

-- Servidor: the gang gate (`IsInGang`, `GangDeniedMessage`) and the territory blip colour
-- (`GangBlipStyle`) all come from here. Declared so a missing `srv_lib` is a boot-time complaint
-- rather than a runtime export failure inside a farm.
dependency 'srv_lib'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

lua54 'yes'
