fx_version 'cerulean'
game 'gta5'

name 'srv_dealerdoors'
description 'Servidor - [E] teleport doors for vehicle dealerships that live inside an interior'

-- The dealerships these doors serve, and the interior owner that has to be started first for the
-- destination to exist at all. Declared rather than assumed: a teleport into an interior that never
-- loaded drops the player into a black void, which reads as a broken teleport rather than a missing
-- dependency.
dependencies {
    'qbx_vehicleshop',
    'bob74_ipl',
    -- Servidor: owns the correct way to delete the vendor peds, which are local (non-networked)
    -- entities - a wrong ownership claim makes `DeleteEntity` a silent no-op and leaves a duplicate
    -- standing there after every restart.
    'srv_lib',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'

lua54 'yes'
