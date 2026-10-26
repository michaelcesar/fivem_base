local config = require 'config.client'
local isScoreboardOpen, onDutyAdmins

local function shouldShowPlayerId(targetServerId)
    if config.idVisibility == 'all' then return true end
    if onDutyAdmins[cache.serverId] then return true end
    if config.idVisibility == 'admin_only' then return false end
    if config.idVisibility == 'admin_excluded' and onDutyAdmins[targetServerId] then return false end
    return true
end

local function drawPlayerNumbers()
    CreateThread(function()
        while isScoreboardOpen do
            local players = cache('nearbyPlayers', function()
                local p = lib.getNearbyPlayers(GetEntityCoords(cache.ped), config.visibilityDistance, true)

                for i = #p, 1, -1 do
                    p[i].serverId = GetPlayerServerId(p[i].id)

                    if not shouldShowPlayerId(p[i].serverId) then
                        p[i] = p[#p]
                        p[#p] = nil
                    end
                end

                return p
            end, 1000)

            for i = 1, #players do
                local player = players[i]
                local pedCoords = GetEntityCoords(player.ped)
                qbx.drawText3d({
                    text = '['..player.serverId..']',
                    coords = vec3(pedCoords.x, pedCoords.y, pedCoords.z + 1.0),
                })
            end
            Wait(0)
        end
    end)
end

-- Command

local function openScoreboard()
    local players, cops, admins = lib.callback.await('qbx_scoreboard:server:getScoreboardData')
    onDutyAdmins = admins

    SendNUIMessage({
        action = 'open',
        players = players,
        maxPlayers = config.maxPlayers,
        requiredCops = GlobalState.illegalActions,
        currentCops = cops
    })

    isScoreboardOpen = true
    drawPlayerNumbers()
end

local function closeScoreboard()
    SendNUIMessage({
        action = 'close',
    })

    isScoreboardOpen = false
end

if config.toggle then
    lib.addKeybind({
        name = 'scoreboard',
        description = 'Open Scoreboard',
        defaultKey = config.openKey,
        onPressed = function()
            if isScoreboardOpen then
                closeScoreboard()
            else
                openScoreboard()
            end
        end,
    })
else
    lib.addKeybind({
        name = 'scoreboard',
        description = 'Open Scoreboard',
        defaultKey = config.openKey,
        onPressed = openScoreboard,
        onReleased = closeScoreboard
    })
end

-- Threads

-- Servidor: waits for the state to exist instead of assuming one second is enough.
--
-- Reported as "the scoreboard shows only its header", intermittently - sometimes on a reconnect,
-- sometimes not. Upstream slept a flat 1000ms and then read `GlobalState.illegalActions`
-- unconditionally. That value is replicated to a joining client, and replication is not on a
-- schedule: when it had not arrived yet, `pairs(nil)` threw, THIS THREAD DIED, and the rows were
-- never built again for the whole session. The panel then opened with a header and an empty body,
-- which looks exactly like a styling bug - and is why it was chased through the stylesheet twice.
--
-- Polling costs a handful of 200ms waits once per session and cannot fail the same way. The ceiling
-- exists so a genuinely absent global reports instead of spinning forever, and it REPORTS rather
-- than leaving the same silent empty panel (CLAUDE.md rule 5). See ADR-162.
CreateThread(function()
    local actions
    local deadline = GetGameTimer() + 15000

    repeat
        actions = GlobalState.illegalActions

        if not actions then Wait(200) end
    until actions or GetGameTimer() > deadline

    if not actions then
        return lib.print.error('GlobalState.illegalActions never replicated - the scoreboard will have no rows.')
    end

    local items = {}

    for k, v in pairs(actions) do
        items[k] = v.label
    end

    SendNUIMessage({
        action = 'setup',
        items = items
    })
end)
