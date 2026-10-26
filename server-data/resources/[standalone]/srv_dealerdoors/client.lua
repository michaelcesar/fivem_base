-- Servidor: the [E] door at each dealership that lives inside an interior. Purely a teleport - it
-- grants nothing, checks nothing, and is not an authorisation boundary of any kind, so unlike most
-- of this project there is deliberately no server half. Standing at a public shop door and pressing
-- [E] is not a privilege worth validating; the dealership's own buy flow is where money and
-- vehicles change hands, and that is already server-authoritative in `qbx_vehicleshop`.

local INTERACT_CONTROL = 38 -- Servidor: this project's own [E] convention (see srv_robbery, srv_jobs)

--- Servidor: the same two-tier marker + [E] zone shape every point in this project uses. Duplicated
--- rather than shared because FXServer gives each resource its own script environment, which is why
--- `srv_jobs`, `srv_weedfarm` and the farms all carry their own copy of this function too.
---@param coords vector3
---@param radius number outer radius, where the marker starts drawing
---@param innerRadius number where the prompt appears and [E] is answered
---@param prompt string
---@param onInteract fun()
local function setupInteractionZone(coords, radius, innerRadius, prompt, onInteract)
    local innerZone

    lib.zones.sphere({
        coords = coords,
        radius = radius,
        debug = false,
        onEnter = function()
            innerZone = lib.zones.sphere({
                coords = coords,
                radius = innerRadius,
                debug = false,
                onEnter = function()
                    lib.showTextUI(prompt)
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = function()
                    if not IsControlJustPressed(0, INTERACT_CONTROL) then return end

                    lib.hideTextUI()
                    onInteract()
                end,
            })
        end,
        onExit = function()
            if innerZone then
                innerZone:remove()
                innerZone = nil
            end
        end,
        inside = function()
            DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5,
                20, 246, 12, 200, false, false, 0, false, nil, nil, false)
        end,
    })
end

--- Servidor: `SetEntityCoords` then `SetEntityHeading`, and a `DoScreenFadeOut` around both. The fade
--- is not decoration: an unfaded teleport into an interior shows the player a frame or two of
--- unstreamed geometry - the black-void look this project has already chased once at the
--- `GTAOHouseHi` doors (ADR-106/107) - and it also hides the ped visibly snapping to a new heading.
---@param target vector4
local function teleportTo(target)
    DoScreenFadeOut(250)
    while not IsScreenFadedOut() do Wait(0) end

    SetEntityCoords(cache.ped, target.x, target.y, target.z, false, false, false, false)
    SetEntityHeading(cache.ped, target.w)

    -- Servidor: give the destination a moment to stream in before showing it. `lib.waitFor` bounds
    -- this rather than looping forever if the collision never loads - a player stuck on a black
    -- screen is worse than a player who lands a fraction early.
    lib.waitFor(function()
        if HasCollisionLoadedAroundEntity(cache.ped) then return true end
    end, 'o interior nao carregou', 5000)

    DoScreenFadeIn(500)
end

CreateThread(function()
    for i = 1, #Config.doors do
        local door = Config.doors[i]

        setupInteractionZone(door.outside.xyz, door.distance + 5.0, door.distance,
            ('[E] Entrar na %s.'):format(door.label),
            function() teleportTo(door.inside) end)

        setupInteractionZone(door.inside.xyz, door.distance + 5.0, door.distance,
            '[E] Sair.',
            function() teleportTo(door.outside) end)
    end
end)

--- Servidor: send the buyer out to the street before their vehicle is created there.
---
--- `qbx_vehicleshop` spawns both purchases and test drives at the shop's own `vehicleSpawns` and
--- asks the game to warp the player into the result. For an outdoor lot that is instant and
--- invisible. For a dealership in an interior it is not: the spawn points are on the street and the
--- buyer is underground, sometimes kilometres away, so the warp cannot resolve and simply stays
--- pending - the car appears at the kerb with nobody in it, and the player only lands in it minutes
--- later when they walk out under their own steam. Reported for both buying and test driving, which
--- share this exact path.
---
--- Called as a CALLBACK rather than an event so the server waits for the teleport to finish before
--- creating the vehicle. As a fire-and-forget event the two would race, and the warp would miss for
--- the same reason it misses now.
---
--- The destination is the SPAWN POINT the server picked, not this shop's own street door. The two
--- are not required to be near each other and at `vip` they are ~300m apart, so going out the door
--- would just move the walk rather than remove it. Landing on the spawn point means the vehicle is
--- created around the player and the warp lands them in the driver's seat immediately - which is
--- the behaviour every outdoor dealership already has, and the whole point of the fix.
---@param spawn { x: number, y: number, z: number, w: number }
lib.callback.register('srv_dealerdoors:client:leaveForPurchase', function(spawn)
    local coords = GetEntityCoords(cache.ped)

    for i = 1, #Config.doors do
        local door = Config.doors[i]

        if #(coords - door.inside.xyz) < Config.insideRadius then
            teleportTo(vector4(spawn.x, spawn.y, spawn.z, spawn.w))
            return true
        end
    end

    -- Servidor: not in any interior showroom - an outdoor dealership, or a purchase made from
    -- somewhere else entirely. Nothing to do, and the server carries on either way.
    return false
end)

-- Servidor: the salespeople. Same shape as `srv_interactions`' handcuff vendor - spawned once at
-- resource start, frozen, invincible, blocked from reacting to anything, standing in a scenario.
-- Local (non-networked) entities, so `srv_lib` owns deleting them: getting the ownership claim
-- wrong makes `DeleteEntity` a silent no-op and leaves a duplicate ped behind on every restart.
local vendorPeds = {}

CreateThread(function()
    lib.requestModel(Config.vendorPed, 10000)

    for i = 1, #Config.vendors do
        local vendor = Config.vendors[i]
        local coords = vendor.coords

        -- Servidor: `- 1.0` on the z, see the note in config.lua - the surveyed value is the ped's
        -- centre, not the floor.
        local ped = CreatePed(0, Config.vendorPed, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)

        SetEntityHeading(ped, coords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)

        vendorPeds[#vendorPeds + 1] = ped
    end

    SetModelAsNoLongerNeeded(Config.vendorPed)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    for i = 1, #vendorPeds do
        exports.srv_lib:DeleteLocalEntity(vendorPeds[i])
    end
end)
