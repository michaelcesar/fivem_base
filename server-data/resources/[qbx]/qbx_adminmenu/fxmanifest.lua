fx_version 'cerulean'
game 'gta5'

description 'qbx_adminmenu'
repository 'https://github.com/Qbox-project/qbx_adminmenu'
version '0.1.0'

ox_lib 'locale'

-- Servidor: the vehicle spawn menu shows a real preview image per model (see vehicle.lua) - the
-- same `VehicleImages` set `qbx_garages` already reads, per ADR-075. Declared as a dependency so
-- FXServer starts it first and the `data.lua` shared script below has something real to load.
dependency 'srv_vehicleimages'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    '@srv_vehicleimages/data.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

client_scripts {
    'client/*.lua',
}

files {
    'locales/*.json',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
