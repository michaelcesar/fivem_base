fx_version 'cerulean'
game 'gta5'

name 'srv_cocainelab'
description 'Servidor - cocaine processing and dealing (srv_weedfarm sibling, different loop)'

-- Reuses bob74_ipl's Cocaine Lockup interior (see config.lua) - depended on rather than just
-- assumed to be running, so FXServer starts it first and the interior this resource points at
-- actually exists by the time client.lua's own thread runs. Same reasoning as srv_weedfarm.
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
