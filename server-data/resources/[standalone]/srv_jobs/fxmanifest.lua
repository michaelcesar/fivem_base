fx_version 'cerulean'
game 'gta5'

name 'srv_jobs'
description 'Servidor - gameplay loops for the passive-paycheck city hall jobs'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'
server_script 'server.lua'

lua54 'yes'
