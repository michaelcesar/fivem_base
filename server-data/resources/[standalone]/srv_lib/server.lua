-- Servidor shared server primitives.

--- Single place client-side errors are reported to, so every srv_* resource logs them
--- the same way instead of inventing its own event name. Client errors otherwise reach
--- only the player's F8 console, where nobody responsible for the server sees them.
RegisterNetEvent('srv_lib:server:reportError', function(context, err)
    print(('[srv_lib] client error in %s (%s): %s'):format(
        tostring(context), GetPlayerName(source) or source, tostring(err)
    ))
end)

--- Whether a player belongs to a given gang.
---
--- The single implementation every `srv_*` resource is expected to use for gang gating, so the
--- rule lives in one place rather than being reimplemented six times with six different bugs.
--- Server-side and authoritative (CLAUDE.md rule 2) - the client-side twin in `client.lua` is a
--- responsiveness fast path only and is never the decision.
---
--- A `nil` or `'none'` owner means "unowned", which everyone passes. That is what makes gang
--- ownership switchable off per farm from config alone, without touching any callback.
---@param source number
---@param gangName string?
---@return boolean
local function isInGang(source, gangName)
    if not gangName or gangName == 'none' then return true end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    return player.PlayerData.gang.name == gangName
end

exports('IsInGang', isInGang)
