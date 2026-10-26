fx_version 'cerulean'
game 'gta5'

description 'Servidor: chat theme and toggle override, layered on the base FXServer `chat` resource'
version '1.0.0'

-- Servidor: the base `chat` resource is bundled with the FXServer binary itself, outside
-- server-data/resources and this repo's git tree (see /fxserver/ in .gitignore) - it cannot be
-- patched here without being silently overwritten on the next server update. `chat` already
-- exposes a theming extension point for exactly this (chat_theme_gtao is Cfx.re's own example,
-- installed but never `ensure`d in server.cfg). This resource uses that mechanism for the look,
-- and a plain command override for the keybind behaviour, instead of touching `chat` directly.
-- See ADR-047 and ADR-049.
--
-- The dependency is load-bearing twice over: it guarantees `chat` exists at all, and guarantees
-- it starts first, so client.lua's `toggleChat` override always replaces the base handler rather
-- than being replaced by it.
dependency 'chat'

client_script 'client.lua'

files {
    'style.css',
    'fonts/*.ttf',
}

chat_theme 'lite' {
    styleSheet = 'style.css',
}
