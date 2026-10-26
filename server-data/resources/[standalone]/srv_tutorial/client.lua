-- Servidor: /tutorial - the in-game guide. See config.lua for the content and ADR-129 for why it
-- is built on the standard context menu rather than a bespoke NUI page.

local MENU_ID <const> = 'srv_tutorial_menu'

--- Shows one section, then returns to the index. `lib.alertDialog` renders markdown and already
--- carries the project's own reskin, so the tables and bold in `config.lua` come out styled
--- without this resource owning any CSS.
---@param section table
local function showSection(section)
    lib.alertDialog({
        header = section.title,
        content = section.body,
        centered = true,
        size = 'lg',
        -- Sections run long and several carry tables; without this the content is clipped rather
        -- than scrolled.
        overflow = true,
        -- No cancel button - there is nothing to cancel, only to close. Left unlabelled it renders
        -- ox_lib's own English "Confirm" (CLAUDE.md rule 1).
        cancel = false,
        labels = { confirm = 'Fechar' },
    })

    -- Reopening rather than closing matches every other menu in this project: reading one section
    -- is almost never all a player wanted (ADR-118's own rule, applied here).
    OpenTutorial()
end

function OpenTutorial()
    local options = {}

    for i = 1, #Config.sections do
        local section = Config.sections[i]

        options[i] = {
            title = section.title,
            description = section.description,
            icon = section.icon,
            arrow = true,
            onSelect = function()
                showSection(section)
            end,
        }
    end

    lib.registerContext({
        id = MENU_ID,
        title = 'Guia do Servidor',
        options = options,
    })
    lib.showContext(MENU_ID)
end

-- Servidor: three names for the same thing. A player who needs the guide is exactly the player who
-- does not know what it is called, so /ajuda and /guia work too.
--
-- Plain `RegisterCommand` rather than `lib.addCommand`: that one is SERVER-ONLY in ox_lib
-- (`imports/addCommand/` ships a `server.lua` and nothing else), and this command touches no
-- server state at all - it opens a menu built entirely from a shared config. Routing it through
-- the server to come straight back would add a round trip and an exploitable net event for
-- nothing. Same plain-`RegisterCommand` shape `srv_tools` uses for its own client commands.
for _, name in ipairs({ 'tutorial', 'ajuda', 'guia' }) do
    RegisterCommand(name, function()
        OpenTutorial()
    end, false)

    TriggerEvent('chat:addSuggestion', ('/%s'):format(name), 'Abre o guia do servidor.')
end
