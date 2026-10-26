fx_version 'cerulean'
game 'gta5'

name 'srv_gunlab'
description 'Servidor - weapon parts farm (scrap -> weapon_part -> assembled weapon, srv_cocainelab sibling)'

-- The Gunrunning Bunker interior (see config.lua) - depended on rather than just assumed to be
-- running, same reasoning as every other bob74_ipl-backed farm in this project.
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
