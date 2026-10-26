fx_version 'cerulean'
game 'gta5'

description 'HUD for Qbox'
repository 'https://github.com/Qbox-project/qbx_hud'
version '0.1.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
}

server_script 'server/main.lua'

ui_page 'html/index.html'

files {
    'html/*',
    'html/index.html',
    'html/styles.css',
    'html/responsive.css',
    'html/app.js',
    -- Servidor: the weapon-class silhouettes the ammo panel masks. The `html/*` entry above does NOT
    -- reach into a subdirectory, so without this line every icon 404s and the panel shows nothing.
    'html/weapons/*.png',
    'locales/*.json',
    'config/client.lua',
    'config/shared.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
