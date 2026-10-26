--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class TextUIOptions
---@field position? 'right-center' | 'left-center' | 'top-center' | 'bottom-center';
---@field icon? string | {[1]: IconProp, [2]: string};
---@field iconColor? string;
---@field style? string | table;
---@field alignIcon? 'top' | 'center';

-- Server: prompts are keyed by the resource that raised them, and several can be on screen at once,
-- stacked. Upstream keeps exactly one: the second caller to `showTextUI` silently replaces the
-- first, and whichever calls `hideTextUI` first takes down both.
--
-- That is not a hypothetical. Two zones overlapping and fighting over this one element is what
-- ADR-067/068 chased at the cocaine lab, and it surfaced again the moment a store robbery was put on
-- the same counter as the shop that owns it - the shop's own "[E]" vanished, leaving only "[G]".
-- Reported exactly that way.
--
-- Keying by `cache.resource` needs no API change at all: `showTextUI` already runs in the calling
-- resource's own context, so the key is free and every existing caller keeps working unchanged. A
-- resource showing twice still replaces its own prompt, which is the behaviour callers expect.
--
-- The one thing this cannot fix is two prompts raised by the SAME resource for two overlapping
-- zones - they share a key and still collide. That case stays the caller's problem, as it was.
---@type table<string, string>
local currentText = {}

---@param text string
---@param options? TextUIOptions
function lib.showTextUI(text, options)
    local resource = cache.resource

    if currentText[resource] == text then return end

    if not options then options = {} end

    options.text = text
    options.id = resource
    currentText[resource] = text

    SendNUIMessage({
        action = 'textUi',
        data = options
    })
end

function lib.hideTextUI()
    local resource = cache.resource

    if not currentText[resource] then return end

    currentText[resource] = nil

    SendNUIMessage({
        action = 'textUiHide',
        data = { id = resource }
    })
end

--- Reports on this resource's own prompt, not on whatever happens to be on screen. Upstream had
--- only one prompt to report on, so the distinction did not exist.
---@return boolean, string | nil
function lib.isTextUIOpen()
    local text = currentText[cache.resource]
    return text ~= nil, text
end

-- Server: a resource that stops without hiding its prompt would otherwise leave it on screen with
-- nothing left able to take it down. Upstream never needed this, since any other resource's
-- `hideTextUI` would clear the single shared element by accident.
AddEventHandler('onClientResourceStop', function(resource)
    if not currentText[resource] then return end

    currentText[resource] = nil

    SendNUIMessage({
        action = 'textUiHide',
        data = { id = resource }
    })
end)
