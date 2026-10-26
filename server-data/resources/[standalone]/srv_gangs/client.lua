-- Servidor: map blips for the gang bases. `qbx_management` owns the boss menus but draws nothing,
-- so until now a base existed in the world and nowhere on the map. See ADR-135.

-- The base is drawn by the same `srv_lib:CreateGangBlip` the production sites use - a coloured
-- circle in the gang's colour, matching qbx_garages' own area style (ADR-137).
--
-- It used to take the DEFAULT "Área <cor>" label, exactly like a production site, so that a gang's
-- ground read as one area rather than being split into base and territory (ADR-138). That is
-- reversed here: with six gangs live, every one of them had several identically-named circles
-- scattered across the map and no way to tell which was which. It is now "Base <cor>".
--
-- ADR-138's actual RULE is untouched - the label still takes a feminine noun so the stored colour
-- adjective agrees. `Base` is feminine, like `Área`. See ADR-154.
CreateThread(function()
    for gang, base in pairs(Config.bases) do
        if base.blip then
            exports.srv_lib:CreateGangBlip(base.blip, gang, 'Base %s')
        end
    end
end)

--- Moves the player to `dest` (a vector4) and waits for the ground to arrive before letting go.
---
--- A plain `SetEntityCoords` is enough for the farms, whose entrances hop a few dozen metres inside
--- an already-streamed cell. It is NOT enough here: the Vagos door and the Vagos base are ~1300m
--- apart, so at the moment of the teleport the destination cell has no collision loaded at all and
--- the ped falls through the world. That is the same failure `/tp` had, and it is fixed the same
--- way - freeze first so the fall cannot start, request collision AT the destination, release only
--- once it is there. See ADR-150.
---
--- The 5s ceiling means an unreachable destination reports instead of hanging, and it says which of
--- the two happened rather than claiming success either way (CLAUDE.md rule 5).
---@param dest vector4
local function teleportTo(dest)
    local ped = cache.ped

    DoScreenFadeOut(300)
    while not IsScreenFadedOut() do Wait(0) end

    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, dest.x, dest.y, dest.z, false, false, false, false)
    SetEntityHeading(ped, dest.w)

    local deadline = GetGameTimer() + 5000

    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < deadline do
        RequestCollisionAtCoord(dest.x, dest.y, dest.z)
        Wait(0)
    end

    FreezeEntityPosition(ped, false)
    DoScreenFadeIn(300)

    if not HasCollisionLoadedAroundEntity(ped) then
        lib.notify({
            title = 'O caminho não carregou',
            description = 'Tente de novo em alguns segundos.',
            type = 'error',
        })
    end
end

--- The `[E]` points inside a base. Only the player's OWN gang's base is interactive - a member of
--- another gang walking through sees nothing, which is the same rule the farms use.
---
--- A point whose coordinate is `nil` is skipped entirely, so a base fills in as its coordinates are
--- surveyed rather than needing all of them at once. See ADR-136.
---
--- `coords` resolves the point from the base rather than each entry naming a flat key, because the
--- entrance is not a flat key - it is a PAIR, and both halves are points in their own right.
---
--- `label` documents what the point is. `prompt`/`onSelect` are optional: a point with neither is
--- drawn but not interactive, which is how the boss menu appears here - `qbx_management` owns that
--- interaction and this must not add a second one on top of it.
local BASE_POINTS <const> = {
    {
        coords = function(base) return base.entrance and base.entrance.outside.xyz end,
        label = 'Entrada da Base',
        prompt = '[E] Entrar na base.',
        onSelect = function(base) teleportTo(base.entrance.inside) end,
    },
    {
        coords = function(base) return base.entrance and base.entrance.inside.xyz end,
        label = 'Saída',
        prompt = '[E] Sair da base.',
        -- No gang check on the way OUT, deliberately - and none is needed on the way in either,
        -- since this whole loop only runs for the player's own gang. The farms gate their entrance
        -- because their door is in the street where anyone can stand; a base door is only ever
        -- drawn for members. Either way the teleport is a client convenience, not a security
        -- boundary: everything worth protecting behind it (stash, vault, wardrobe) re-checks the
        -- player's gang AND position server-side (ADR-147).
        onSelect = function(base) teleportTo(base.entrance.outside) end,
    },
    {
        coords = function(base) return base.stash end,
        label = 'Baú da Gangue',
        prompt = '[E] Abrir o baú da gangue.',
        onSelect = function() TriggerServerEvent('srv_gangs:server:openStash') end,
    },
    {
        coords = function(base) return base.vault end,
        label = 'Cofre da Gangue',
        prompt = '[E] Abrir o cofre da gangue.',
        onSelect = function() TriggerServerEvent('srv_gangs:server:openVault') end,
    },
    {
        -- Drawn only. `qbx_management` owns the prompt and the menu; adding an `onSelect` here would
        -- put two prompts on one spot, which is the exact cross-resource collision the base survey
        -- kept running into (ADR-151). All this does is make the point visible, which that resource
        -- never did.
        coords = function(base) return base.bossMenu end,
        label = 'Menu do Chefe',
    },
    {
        coords = function(base) return base.wardrobe end,
        label = 'Guarda-Roupa',
        -- Goes through the SERVER like the other two, not a local `TriggerEvent`. It opens a
        -- clothing menu rather than moving anything valuable, but a base point that only the client
        -- decides is not a base point - it is a menu anyone can open anywhere. See ADR-147.
        prompt = '[E] Trocar de roupa.',
        onSelect = function() TriggerServerEvent('srv_gangs:server:openWardrobe') end,
    },
    -- `collectionRoute` is deliberately NOT here. It is a ped you talk to, not a spot you stand on,
    -- so it has its own loop further down that spawns the ped and owns its prompt (ADR-145).
}

--- The player's gang name, or `nil` while there is no player data yet.
---
--- This is NOT a defensive guard on a value that ought to exist (CLAUDE.md rule 5 forbids those).
--- `qbx_core/modules/playerdata.lua` initialises `QBX.PlayerData` to `{}` and only fills it when the
--- player loads, and empties it again on unload - so `gang` is legitimately absent for the first
--- seconds of every session. Reading `QBX.PlayerData.gang.name` unconditionally from a loop that
--- starts at resource start throws on its very first iteration and kills the thread permanently,
--- which is exactly what happened: no markers, no prompts, no ped, nothing at all. See ADR-146.
---@return string?
local function currentGang()
    local gang = QBX.PlayerData.gang

    return gang and gang.name
end

--- Tracks what the prompt says and WHICH loop put it there.
---
--- Three loops in this file can show a prompt - base points, the route ped, and the current route
--- stop - and they run independently. Without an owner, whichever loop ticked last cleared whatever
--- another had just shown: standing at the ped, the base-point loop found nothing in range and
--- wiped the ped's prompt on its next tick, every tick. A loop may now only clear a prompt it owns.
local shownPrompt
local promptOwner

---@param owner string which loop is asking
---@param prompt string?
local function setPrompt(owner, prompt)
    if prompt then
        if shownPrompt == prompt then return end

        shownPrompt, promptOwner = prompt, owner
        lib.showTextUI(prompt)
        return
    end

    -- Only the loop that showed it may take it away.
    if promptOwner ~= owner then return end

    shownPrompt, promptOwner = nil, nil
    lib.hideTextUI()
end

--- How far away a base point's ground marker starts drawing. Larger than the interaction radius on
--- purpose: the circle is what tells a player the spot is there, so it has to be visible from
--- further away than the distance at which they can already use it.
local MARKER_DISTANCE <const> = 15.0

-- Servidor: the base points used to get a small map circle each - stash, vault, wardrobe, boss menu,
-- both ends of the entrance and the route ped, seven of them inside one base.
--
-- Removed. They were requested, and they were wrong: every one sat inside the single "Base <cor>"
-- circle that already marks the place, 4 to 27m from its neighbours, so at map scale they merged
-- into one smear that said less than the circle containing them. The ground markers still draw
-- every point in the gang's colour when you are standing there, which is where that information is
-- actually useful - a map does not need to name furniture you can already see.
--
-- `label` on each `BASE_POINTS` entry is kept even though nothing reads it now: it documents what
-- the point IS, right next to the coordinate that finds it. See ADR-154.

CreateThread(function()
    while true do
        local wait = 500
        local gang = currentGang()
        local base = gang and gang ~= 'none' and Config.bases[gang]
        local active

        if base then
            local coords = GetEntityCoords(cache.ped)

            -- Servidor: the same `DrawMarker` type 1 (a filled cylinder, which reads as a lit circle
            -- on the ground) the six farms already use for their own stations, so a base point
            -- looks like every other interactable on this server. Coloured with the gang's own map
            -- colour so the ground and the map agree.
            --
            -- Drawn for every point in range, not only the one being stood on - a player walking in
            -- should see where all of them are, not discover them one at a time.
            local rgb = exports.srv_lib:GangMarkerColour(gang)

            for i = 1, #BASE_POINTS do
                local point = BASE_POINTS[i]
                local target = point.coords(base)

                if target then
                    local distance = #(coords - target)

                    if distance <= MARKER_DISTANCE then
                        wait = 0
                        DrawMarker(1, target.x, target.y, target.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                            1.0, 1.0, 0.5, rgb[1], rgb[2], rgb[3], 200, false, false, 0, false,
                            nil, nil, false)
                    end

                    -- `point.prompt` is what makes a point interactive. The boss menu has none on
                    -- purpose: it is drawn here but owned by `qbx_management`, and claiming it as
                    -- `active` would show a blank prompt over that resource's real one.
                    if not active and point.prompt and distance <= Config.baseInteractionDistance then
                        active = point
                    end
                end
            end
        end

        setPrompt('base', active and active.prompt or nil)

        if active and IsControlJustPressed(0, 38) then
            setPrompt('base', nil)
            active.onSelect(base)
            Wait(500)
        end

        Wait(wait)
    end
end)

-- ============================================================================
-- Rota de Cobrança (ADR-145)
--
-- The ped at the base hands out the route; the route sends the member to a handful of street
-- corners to collect. The client draws where to go and asks; the server decides and pays.
-- ============================================================================

local routeStops
local routeIndex
local routeBlip

local function clearRoute()
    if routeBlip then
        RemoveBlip(routeBlip)
        routeBlip = nil
    end

    routeStops = nil
    routeIndex = nil
end

--- Marks the current stop on the map. One blip, moved rather than a blip per stop - the member is
--- sent to them one at a time, and showing all five at once would let them plan a circuit the
--- route deliberately randomises.
local function markCurrentStop()
    if routeBlip then
        RemoveBlip(routeBlip)
        routeBlip = nil
    end

    local target = routeStops and routeStops[routeIndex]
    if not target then return end

    routeBlip = AddBlipForCoord(target.x, target.y, target.z)
    SetBlipSprite(routeBlip, 1)
    SetBlipColour(routeBlip, exports.srv_lib:GangBlipStyle(currentGang()).colour)
    SetBlipScale(routeBlip, 0.9)
    SetBlipRoute(routeBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Cobrança')
    EndTextCommandSetBlipName(routeBlip)
end

local function cancelCollection()
    local result = lib.callback.await('srv_gangs:server:cancelCollection', false)

    if not result or not result.ok then
        lib.notify({ title = 'Não foi possível cancelar a rota.', type = 'error' })
        return
    end

    clearRoute()
    lib.notify({ title = 'Rota cancelada', description = 'Fale com o contato para pegar outra.', type = 'inform' })
end

local function startCollection()
    local result = lib.callback.await('srv_gangs:server:startCollection', false)

    if not result or not result.ok then
        local reasons = {
            nogang = 'Você não faz parte de nenhuma gangue.',
            nobase = 'Sua gangue não tem uma base configurada.',
            far = 'Chegue mais perto.',
            dailylimit = 'Você já atingiu o limite diário de cobranças. Volte amanhã.',
            active = 'Você já está com uma rota. Cancele antes de pegar outra.',
        }

        lib.notify({
            title = (result and reasons[result.reason]) or 'Não foi possível pegar a rota.',
            type = 'error',
        })
        return
    end

    routeStops = result.stops
    routeIndex = 1
    markCurrentStop()

    lib.notify({
        title = 'Rota de cobrança',
        description = ('%s pontos. Restam %s hoje.'):format(#result.stops, result.remaining),
        type = 'success',
    })
end

local function collectStop()
    local result = lib.callback.await('srv_gangs:server:collectStop', false)

    if not result or not result.ok then
        local reasons = {
            nogang = 'Você não faz parte mais dessa gangue.',
            far = 'Chegue mais perto do ponto.',
            noroom = 'Você não tem espaço para o dinheiro.',
            dailylimit = 'Você já atingiu o limite diário de cobranças. Volte amanhã.',
        }

        if result and (result.reason == 'nogang' or result.reason == 'dailylimit') then
            clearRoute()
        end

        lib.notify({
            title = (result and reasons[result.reason]) or 'Não foi possível cobrar.',
            type = 'error',
        })
        return
    end

    routeIndex += 1

    -- The daily ceiling is announced the moment it is hit, not only at the ped next time - the
    -- member is told on the stop that spent their last point.
    if result.limitReached then
        clearRoute()
        lib.notify({
            title = 'Limite diário atingido',
            description = ('Recebeu $%s. Você já fez todas as cobranças de hoje - volte amanhã.'):format(result.paid),
            type = 'inform',
        })
        return
    end

    if result.finished then
        clearRoute()
        lib.notify({
            title = 'Rota concluída',
            description = ('Recebeu $%s. Restam %s cobranças hoje.'):format(result.paid, result.remaining),
            type = 'success',
        })
        return
    end

    markCurrentStop()

    lib.notify({
        title = ('Recebeu $%s'):format(result.paid),
        description = ('Próximo ponto marcado. Restam %s hoje.'):format(result.remaining),
        type = 'success',
    })
end

-- The ped that hands out the route. Spawned only for the gang that owns the base, same rule as the
-- base prompts - a member of another gang walking through sees nobody.
CreateThread(function()
    local spawned = {}

    while true do
        local wait = 1000
        local gang = currentGang()
        local base = gang and gang ~= 'none' and Config.bases[gang]
        local anchor = base and base.collectionRoute

        if anchor and gang and base then
            local distance = #(GetEntityCoords(cache.ped) - anchor)

            if distance <= 50.0 and not spawned[gang] then
                lib.requestModel(Config.collection.ped, 5000)

                local ped = CreatePed(4, Config.collection.ped, anchor.x, anchor.y, anchor.z - 1.0,
                    base.collectionRouteHeading or 0.0, false, false)

                FreezeEntityPosition(ped, true)
                SetEntityInvincible(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetModelAsNoLongerNeeded(Config.collection.ped)

                spawned[gang] = ped
            elseif distance > 60.0 and spawned[gang] then
                exports.srv_lib:DeleteLocalEntity(spawned[gang])
                spawned[gang] = nil
            end

            if distance <= Config.baseInteractionDistance then
                wait = 0

                -- The ped is both where a route is taken and where it is given back, so the prompt
                -- reflects which of the two is possible right now. Talking to it with a route
                -- running used to silently reroll the whole thing (ADR-148).
                local hasRoute = routeStops ~= nil

                setPrompt('ped', hasRoute and '[E] Cancelar a rota.' or '[E] Pegar rota de cobrança.')

                if IsControlJustPressed(0, 38) then
                    setPrompt('ped', nil)

                    if hasRoute then
                        cancelCollection()
                    else
                        startCollection()
                    end

                    Wait(500)
                end
            else
                setPrompt('ped', nil)
            end
        else
            setPrompt('ped', nil)
        end

        Wait(wait)
    end
end)

-- Arriving at the current stop.
CreateThread(function()
    while true do
        local wait = 750

        if routeStops and routeStops[routeIndex] then
            local target = routeStops[routeIndex]
            local distance = #(GetEntityCoords(cache.ped) - target)

            if distance <= 30.0 then
                wait = 0
                local rgb = exports.srv_lib:GangMarkerColour(currentGang())

                -- Servidor: 3.0 x 1.0, matching `srv_jobs`' own route markers exactly - a
                -- collection stop is the same kind of thing as a delivery stop and should look
                -- like one. The base points use the smaller 1.0 x 0.5 because they are furniture
                -- you walk up to, not a destination you drive to.
                DrawMarker(1, target.x, target.y, target.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    3.0, 3.0, 1.0, rgb[1], rgb[2], rgb[3], 200, false, false, 0, false, nil, nil, false)

                if distance <= Config.collection.stopDistance then
                    setPrompt('stop', '[E] Cobrar o vendedor.')

                    if IsControlJustPressed(0, 38) then
                        setPrompt('stop', nil)
                        collectStop()
                        Wait(500)
                    end
                else
                    setPrompt('stop', nil)
                end
            else
                setPrompt('stop', nil)
            end
        else
            setPrompt('stop', nil)
        end

        Wait(wait)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    clearRoute()
end)
