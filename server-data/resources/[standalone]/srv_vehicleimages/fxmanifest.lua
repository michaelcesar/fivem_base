fx_version 'cerulean'
game 'gta5'

name 'srv_vehicleimages'
description 'Servidor - vehicle preview images, shared by the in-world garage and the phone garage app'
version '1.0.0'

-- Servidor: files only, no logic. Both garages need the same images (qbx_garages' context-menu
-- hover card and npwd_qbx_garages' list thumbnails), and keeping one copy in a resource of our
-- own beats duplicating ~14MB into two vendored third-party resources - or patching either of
-- them just to carry assets. Consumers reference `nui://srv_vehicleimages/images/<model>.png`.
--
-- `data.lua` is the list of which models actually have an image. It currently covers every model
-- qbx_core knows about, but a consumer still has to check membership before pointing at a file:
-- that coverage is a fact about today's data, not a guarantee, since a future DLC adds models
-- before the image set catches up. Generated, not hand-written - see docs/operations.md.
files {
    'index.html',
    'images/*.png',
}

-- Servidor: load-bearing despite the page being blank. `files` alone does NOT make a resource's
-- assets reachable over `nui://` - FiveM mounts them into the NUI filesystem only for resources
-- that declare a `ui_page`. Without this line the images sit on disk, the resource starts
-- cleanly, and every image request fails silently with no error anywhere. Verified the hard way:
-- see index.html's own comment and ADR-075.
ui_page 'index.html'

shared_script 'data.lua'
