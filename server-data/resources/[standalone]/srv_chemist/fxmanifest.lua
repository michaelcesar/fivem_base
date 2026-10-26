fx_version 'cerulean'
game 'gta5'

name 'srv_chemist'
description 'Servidor - one NPC selling the production accelerator for all three illegal farms'

-- No `dependency` on any farm: this resource only sells items, and each farm owns what its own
-- accelerator does. Adding one would make the farms load-order-coupled for no reason. See ADR-082.

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'
server_script 'server.lua'

lua54 'yes'
