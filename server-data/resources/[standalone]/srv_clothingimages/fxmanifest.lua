fx_version 'cerulean'
game 'gta5'

name 'srv_clothingimages'
description 'Servidor - clothing item preview images, served to the illenium-appearance NUI fork'
version '1.0.0'

files {
    'index.html',
    'images/*.png',
    'manifest.json',
}

-- Servidor: load-bearing, same reasoning as srv_vehicleimages - `files{}` alone does not mount a
-- resource's assets into the NUI filesystem, only a resource with `ui_page` gets that. This page
-- is never shown (nothing calls SetNuiFocus for this resource); its only job is to make the
-- directive true. See ADR-075 for how this was actually diagnosed, and ADR-078 for this resource.
ui_page 'index.html'
