-- Servidor: nobody holds one of these jobs full-time - anyone can start a shift at any
-- depot, so there is no job-name check here. What *is* fully server-authoritative:
--   - a stop only pays once the player's real ped position - read server-side, never
--     client-reported - is near the coordinate *this server* was told about for that
--     specific stop;
--   - ending a shift (`endShift`, ADR-046) always succeeds once the player is physically at
--     the job's real return point, but only pays the bonus, and only skips both fines, when
--     the job vehicle (resolved from its real network ID, not trusted from a claim) is
--     actually parked there too and enough stops were done - anything less is billed, never
--     blocked;
--   - a shift that ends any other way (abandoned, disconnected mid-shift, resource stop)
--     leaves the vehicle deleted here rather than orphaned in the world, and owes a fine
--     tied to the player's citizenid - checked before any job, any depot, can be started
--     again. The debt table is in-memory only, so it clears itself on the next server
--     restart, the same as every other abandoned world vehicle already does.
--- `item` is the option this route picked at startJob (see ADR-070) - it was added to the table
--- without being added here, so the analyser flagged every read of it as an undefined field while
--- the code worked fine. Listed now so the annotation matches what is actually stored.
local activeRoutes = {} ---@type table<number, {jobName: string, stop: vector3?, count: number, vehicleNetId: number?, slot: number?, vehicleResolved: boolean?, haulNetId: number?, haulNonce: number?, item: string?}>
local pendingDebt = {} ---@type table<string, number>

local COMPLETE_DISTANCE = 15.0
local DEPOT_DISTANCE = 15.0
-- Servidor: `Config.returnVehicleDistance`, not a local literal - client.lua's `vehicleIsHere`
-- reads the same value, so the two can't drift apart. See config.lua's own comment on it.
local RETURN_VEHICLE_DISTANCE = Config.returnVehicleDistance
-- Servidor: a bit more generous than COMPLETE_DISTANCE - the job vehicle has to be parked
-- near the stop, not necessarily somewhere a pedestrian could squeeze right up against.
local STOP_VEHICLE_DISTANCE = 20.0
-- Servidor: same generosity, applied to a job's hauled cargo vehicle (tow, ADR-052) instead of
-- its own work vehicle - a hooked vehicle trails a little behind the truck's exact position.
local HAUL_DISTANCE = 20.0
-- Servidor: float positions read off the same `vector3` twice (once mapped, once reported) are
-- never bit-identical, so `isConfiguredStop` below needs slack rather than an exact match.
local STOP_MATCH_EPSILON = 0.5

-- Servidor: boot-time self-check meant to turn a silent runtime failure into a loud one on the
-- very first restart after a config edit, rather than into a confusing bug report from whoever
-- plays the job next. A tow-style job (`dropoffPoint` set, ADR-052) needs `stops` too -
-- client.lua's `nextFixedStop` indexes straight into it with no nil guard (`#stops`), by design
-- (rule 5: a missing list here is a config mistake, not something to paper over) - so a
-- `dropoffPoint` without `stops` would otherwise crash the very first player to start that job's
-- shift. The equivalent check for `brokenVehicles`' model names lives in client.lua instead -
-- `IsModelInCdimage` is a client-only native, confirmed the hard way (this crashed the whole
-- resource here before the model check was moved).
--
-- The duplicate-depot check exists because two jobs once shared one `depot` coordinate exactly
-- (ADR-074): both registered an interaction zone and spawned a ped on the same spot, they fought
-- over the single shared text-UI element, and the one that won answered the prompt - silently
-- giving the player the wrong job. Nothing crashed and nothing logged; it only surfaced as "the
-- drug picker doesn't appear". Two depots that merely *overlap* are the same hazard (see ADR-067
-- for the zone-overlap failure mode), so this compares squared distance against a radius a bit
-- wider than the interaction zone rather than testing for an exact coordinate match.
local DEPOT_MIN_SEPARATION = 5.0

CreateThread(function()
    local seen = {}

    for jobName, jobConfig in pairs(Config.jobs) do
        if jobConfig.dropoffPoint and not jobConfig.stops then
            print(('^1[srv_jobs] %s: has a dropoffPoint but no stops list - starting this job will crash on the first pickup.^7')
                :format(jobName))
        end

        if jobConfig.depot then
            for i = 1, #seen do
                if #(jobConfig.depot.xyz - seen[i].coords) < DEPOT_MIN_SEPARATION then
                    print(('^1[srv_jobs] %s and %s have depots %.2fm apart - their zones and peds will overlap and only one will answer the [E] prompt. Give them separate locations, or merge them into one job.^7')
                        :format(jobName, seen[i].name, #(jobConfig.depot.xyz - seen[i].coords)))
                end
            end

            seen[#seen + 1] = { name = jobName, coords = jobConfig.depot.xyz }
        end
    end
end)

local function getCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

--- True if `source`'s real, server-read ped position is within `maxDist` of `coords` - the one
--- distance check every position-sensitive callback here needs (`startJob`, `storeVehicle`,
--- `payVehicleFine`, `withdrawVehicle`, `endShift`), so it exists in exactly one place rather than
--- five copies of `GetEntityCoords(GetPlayerPed(source))` that could drift out of sync.
local function isPlayerWithin(source, coords, maxDist)
    return #(GetEntityCoords(GetPlayerPed(source)) - coords) <= maxDist
end

--- Resolves a networked vehicle by ID and deletes it if it still exists - the one delete-by-netId
--- shape every settlement path here shares (`endRoute`'s own vehicle and haul, `despawnRouteVehicle`,
--- `despawnRouteHaul`). `SetEntityAsMissionEntity` is NOT called first - it is client-only and
--- crashed this handler every time it was tried, caught live. `DeleteEntity` alone is enough
--- server-side.
local function deleteNetworkedVehicle(netId)
    if not netId then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle ~= 0 and DoesEntityExist(vehicle) then DeleteEntity(vehicle) end
end

--- First vehicle-spawn slot for `jobName` not already claimed by another active shift for
--- that same job - see config.lua's `vehicleSlotOffsets`. Slots free themselves the
--- moment a route ends, any way at all, since they're only ever read off `activeRoutes`.
local function findFreeSlot(jobName)
    local taken = {}

    for _, route in pairs(activeRoutes) do
        if route.jobName == jobName and route.slot then
            taken[route.slot] = true
        end
    end

    for i = 1, #Config.vehicleSlotOffsets do
        if not taken[i] then return i end
    end

    return nil
end

local function chargeFine(source, amount, reason)
    return exports.qbx_core:RemoveMoney(source, 'cash', amount, reason)
        or exports.qbx_core:RemoveMoney(source, 'bank', amount, reason)
end

--- Pays `jobConfig.payPerStop` for completing a stop and advances `route.count` - identical
--- between `completeStop`'s two branches (generic stop, tow-style delivery), so it exists once.
--- Returns the amount actually paid, `0` if the job pays nothing or `AddMoney` itself fails.
--- Servidor: pays `amount` in the currency the JOB deals in - clean cash for the five city-hall
--- jobs, the `black_money` item for anything flagged `illegal` in config.
---
--- Illegal income is dirty by request (ADR-142), and the flag lives on the job rather than being a
--- list of job names here, so adding an illegal job cannot forget to pay it correctly. `dealing` is
--- the only one today.
---@param source number
---@param jobConfig table
---@param amount number
---@param reason string
---@return boolean paid
local function payJob(source, jobConfig, amount, reason)
    if jobConfig.illegal then
        return exports.ox_inventory:AddItem(source, 'black_money', amount) and true or false
    end

    return exports.qbx_core:AddMoney(source, 'cash', amount, reason) and true or false
end

local function payForStop(source, route, jobConfig)
    local pay = jobConfig.payPerStop or 0

    if pay > 0 and not payJob(source, jobConfig, pay, ('srv_jobs:%s'):format(route.jobName)) then
        pay = 0
    end

    route.count += 1

    return pay
end

--- Ends whatever route `source` has *involuntarily* - cancelling, walking away from the
--- vehicle, disconnecting mid-shift. A deliberate end always goes through `endShift` instead
--- (see ADR-046), which pays its own fines on the spot rather than leaving a debt, so this is
--- only ever reached when the player isn't present to charge immediately: if the route had its
--- own vehicle, it's deleted here (never left orphaned) and the player owes `pendingVehicleFine`
--- before starting any job again. A route that never took its own vehicle (rode along in a
--- colleague's, see `startJob`) has nothing to be fined over.
local function endRoute(source)
    local route = activeRoutes[source]
    activeRoutes[source] = nil
    if not route then return end

    -- Servidor: `vehicleResolved` is set once the vehicle has been stored at the return point or
    -- paid off there (ADR-050). A route that already settled it owes nothing here, even if it
    -- then disconnects mid-shift - the obligation this debt exists for is already discharged.
    if route.vehicleNetId and not route.vehicleResolved then
        deleteNetworkedVehicle(route.vehicleNetId)

        local cid = getCitizenId(source)
        if cid then pendingDebt[cid] = Config.pendingVehicleFine end
    end

    -- A hauled vehicle mid-delivery (ADR-052) has no fine of its own - the trip simply never
    -- paid out - but it still can't be left standing in the world, same reasoning as the
    -- route's own vehicle above.
    deleteNetworkedVehicle(route.haulNetId)
end

lib.callback.register('srv_jobs:server:startJob', function(source, jobName, wantsVehicle, itemChoice)
    if not Config.jobs[jobName] then return { ok = false } end
    if activeRoutes[source] then return { ok = false, reason = 'already' } end

    local cid = getCitizenId(source)
    if not cid then return { ok = false } end

    if pendingDebt[cid] then
        return { ok = false, reason = 'debt', fine = pendingDebt[cid] }
    end

    local jobConfig = Config.jobs[jobName]

    -- Servidor: `endShift` already checks the player's real position against the job's own
    -- coordinate before paying out or letting a shift end - this one didn't, so a client could
    -- call `startJob` directly with any `jobName` that has a depot and begin a shift from
    -- anywhere on the map, bypassing both the `[E]` prompt's proximity gate and ADR-044's "no
    -- job without walking to it" rule entirely, since neither of those live server-side.
    -- `jobConfig.depot` is required, not `jobConfig.depot or jobConfig.vehicleSpawn` - the depot
    -- is specifically where a shift is meant to start. See ADR-045.
    if not jobConfig.depot then return { ok = false } end
    if not isPlayerWithin(source, jobConfig.depot.xyz, DEPOT_DISTANCE) then
        return { ok = false, reason = 'fardepot' }
    end

    -- Servidor: an item-gated job (no vehicle at all - `dealing`, ADR-062) refuses to even start
    -- with nothing to sell, same spirit as `full`/`debt` already refusing a shift that can't
    -- proceed. Checked here, not just at each stop, so the player finds out immediately rather
    -- than after already walking to the first generated point. `itemChoice` comes from the
    -- client, so it has to resolve to one of this job's own real `itemOptions` before anything
    -- else checks it - a job with no `itemOptions` at all skips this whole gate. See ADR-070.
    local chosenItem
    if jobConfig.itemOptions then
        for i = 1, #jobConfig.itemOptions do
            if jobConfig.itemOptions[i].item == itemChoice then
                chosenItem = itemChoice
                break
            end
        end
        if not chosenItem then return { ok = false } end

        if (exports.ox_inventory:GetItemCount(source, chosenItem) or 0) <= 0 then
            return { ok = false, reason = 'noitem' }
        end
    end

    local slot

    -- Servidor: a player can decline their own vehicle and ride along in a colleague's instead
    -- (ADR-023 already lets any same-job vehicle count for completing stops) - only reserve a
    -- slot, and later only require a return, for a route that actually wants one. See ADR-024.
    if jobConfig.vehicle and wantsVehicle then
        slot = findFreeSlot(jobName)
        if not slot then return { ok = false, reason = 'full' } end
    end

    activeRoutes[source] = { jobName = jobName, count = 0, slot = slot, item = chosenItem }

    return { ok = true, slot = slot }
end)

--- True if some other active route already claims `netId` under `field` (`vehicleNetId` for a
--- job's own work vehicle, `haulNetId` for a tow-style haul, ADR-052) - a player cannot report
--- another player's (or their own earlier) claimed vehicle to skip theirs.
local function routeFieldClaimed(field, netId, exceptSource)
    for src, route in pairs(activeRoutes) do
        if src ~= exceptSource and route[field] == netId then return true end
    end
    return false
end

--- True if `value` is present anywhere in `list` - used to check a vehicle's model against a
--- job's configured list (`jobConfig.vehicle` is a single hash so doesn't need this; a broken-
--- vehicle model does, since `brokenVehicles` is a list of several).
local function tableContains(list, value)
    for _, candidate in ipairs(list) do
        if candidate == value then return true end
    end
    return false
end

RegisterNetEvent('srv_jobs:server:setVehicle', function(netId)
    local route = activeRoutes[source]
    if not route or type(netId) ~= 'number' then return end
    -- Servidor: only the first report per shift counts, and it must genuinely be this job's
    -- vehicle type - otherwise a client could report its own already-owned car (parked next
    -- to the return point) instead of the real spawned vehicle, collect the completion bonus
    -- for nothing, and leave the real job vehicle orphaned in the world. See ADR-017.
    if route.vehicleNetId then return end

    local jobConfig = Config.jobs[route.jobName]
    if not jobConfig or not jobConfig.vehicle then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if GetEntityModel(vehicle) ~= jobConfig.vehicle then return end
    if routeFieldClaimed('vehicleNetId', netId, source) then return end

    route.vehicleNetId = netId

    -- Servidor: the work vehicle is the player's own for the shift - no reason to make them
    -- hunt for keys on something the job itself just handed them.
    if GetResourceState('qbx_vehiclekeys') == 'started' then
        exports.qbx_vehiclekeys:GiveKeys(source, vehicle)
    end
end)

--- Reports the vehicle a tow-style job (ADR-052) just hooked at its pickup stop. Validated the
--- same way `setVehicle` validates the job's own vehicle: real entity, real model from this
--- job's `brokenVehicles` list, not already claimed - plus one more check that has no equivalent
--- there, since a pickup is a *specific* point rather than a shared spawn: the vehicle has to
--- actually be near `route.stop`, or a client could report any nearby car (including someone
--- else's parked personal vehicle) as the haul and skip ever finding the real one.
-- Servidor: model + position + not-already-claimed alone would accept a player's own real car
-- (a `blista`, say - ordinary, cheap, plausibly owned) parked near a pickup, letting them skip
-- the hook entirely and just drive it to the drop-off. `spawnHaulVehicle` always zeroes the
-- engine health of what it actually spawns (client.lua), so requiring that too closes the gap:
-- a personal vehicle would need to be deliberately broken down to pass, not just parked nearby.
local HAUL_ENGINE_HEALTH_MAX = 1.0

-- Servidor: entity state bags replicate client-to-server over the network, not instantly - the
-- client sets `haulTag` and fires this event in the same breath (client.lua's
-- `spawnHaulVehicle`), so the tag can genuinely not have arrived yet on a slow connection. A
-- short, bounded retry tells that apart from an actually-wrong or missing tag, which never
-- resolves no matter how long this waits.
local HAUL_TAG_RETRIES = 3
local HAUL_TAG_RETRY_WAIT = 150

RegisterNetEvent('srv_jobs:server:setHaul', function(netId)
    local route = activeRoutes[source]
    if not route or type(netId) ~= 'number' then return end
    if not route.stop or route.haulNetId or not route.haulNonce then return end

    local jobConfig = Config.jobs[route.jobName]
    if not jobConfig or not jobConfig.brokenVehicles then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if not tableContains(jobConfig.brokenVehicles, GetEntityModel(vehicle)) then return end
    if GetVehicleEngineHealth(vehicle) > HAUL_ENGINE_HEALTH_MAX then return end
    if #(GetEntityCoords(vehicle) - route.stop) > HAUL_DISTANCE then return end
    if routeFieldClaimed('haulNetId', netId, source) then return end

    -- Servidor: the identity check (ADR-055) - a vehicle can match every state check above (model,
    -- broken down, in the right spot) and still not be the one this route was actually issued.
    -- Only a client that genuinely called `setPickup` for this stop ever saw this number.
    local tag
    for _ = 1, HAUL_TAG_RETRIES do
        tag = Entity(vehicle).state.haulTag
        if tag then break end
        Wait(HAUL_TAG_RETRY_WAIT)
    end
    if tag ~= route.haulNonce then return end

    route.haulNetId = netId
    route.haulNonce = nil
end)

--- The point a job's own vehicle is settled at - `returnPoint` if the job has one, `depot`
--- otherwise. Shared by `storeVehicle` and `payVehicleFine`, the only two callbacks that resolve
--- this coordinate.
local function returnCoordsFor(jobConfig)
    return jobConfig and (jobConfig.returnPoint or jobConfig.depot)
end

--- Deletes this route's hauled vehicle wherever it currently is, by network ID - the same
--- despawn-by-netId pattern `despawnRouteVehicle` uses for the job's own vehicle, kept separate
--- since the two are tracked independently and can be settled at different times.
local function despawnRouteHaul(route)
    deleteNetworkedVehicle(route.haulNetId)
    route.haulNetId = nil
    route.haulNonce = nil
end

--- True if any currently-claimed vehicle for `jobName` (any active route's, not just one
--- specific route's) is parked near `coords` - lets separate players doing the same job share
--- one truck for the work itself, while `endShift` still requires each route's own vehicle back.
local function isJobVehicleNearby(jobName, coords)
    for _, route in pairs(activeRoutes) do
        if route.jobName == jobName and route.vehicleNetId then
            local vehicle = NetworkGetEntityFromNetworkId(route.vehicleNetId)

            if vehicle ~= 0 and DoesEntityExist(vehicle) and #(GetEntityCoords(vehicle) - coords) <= STOP_VEHICLE_DISTANCE then
                return true
            end
        end
    end

    return false
end

--- True if `coords` is (close enough to) one of `jobConfig.stops`. Jobs still on procedural
--- generation (no `stops` list yet) have no finite set to check against, so this passes
--- everything through for them - the same accepted, bounded gap ADR-015 already named.
local function isConfiguredStop(jobConfig, coords)
    if not jobConfig.stops then return true end

    for i = 1, #jobConfig.stops do
        if #(jobConfig.stops[i] - coords) < STOP_MATCH_EPSILON then return true end
    end

    return false
end

RegisterNetEvent('srv_jobs:server:setStop', function(coords)
    local route = activeRoutes[source]
    if not route or type(coords) ~= 'vector3' then return end

    local jobConfig = Config.jobs[route.jobName]
    -- Servidor: for a job with a real `stops` list, the client can no longer just self-report
    -- any coordinate (e.g. its own current position) and immediately complete it for free
    -- money - it has to be one of the job's real, finite points. See ADR-019.
    if not jobConfig or not isConfiguredStop(jobConfig, coords) then return end

    route.stop = coords
end)

-- Servidor: the tow-only counterpart to `setStop` (ADR-055) - a callback, not a fire-and-forget
-- event, because the client needs something back: a secret this specific pickup's haul vehicle
-- has to carry. `setHaul` was previously trusting model + broken-down state alone to identify the
-- right vehicle, which a player's own matching, deliberately-broken car could pass (ADR-054). A
-- server-issued, per-pickup number the client never sees in advance and can only get by actually
-- requesting this stop closes that - it can be embedded in a vehicle, never predicted.
lib.callback.register('srv_jobs:server:setPickup', function(source, coords)
    local route = activeRoutes[source]
    if not route or type(coords) ~= 'vector3' then return { ok = false } end

    local jobConfig = Config.jobs[route.jobName]
    if not jobConfig or not jobConfig.brokenVehicles or not isConfiguredStop(jobConfig, coords) then
        return { ok = false }
    end

    route.stop = coords
    route.haulNonce = math.random(100000000, 999999999)

    return { ok = true, nonce = route.haulNonce }
end)

lib.callback.register('srv_jobs:server:completeStop', function(source)
    local route = activeRoutes[source]
    if not route or not route.stop then return { ok = false } end

    local jobConfig = Config.jobs[route.jobName]
    if not jobConfig then
        endRoute(source)
        return { ok = false }
    end

    -- Servidor: a tow-style job (ADR-052) confirms *delivery*, not pickup - the player has to be
    -- at the fixed drop-off with the actual hauled vehicle in tow, not just standing where they
    -- found it. `route.stop` still marks the pickup they were sent to (see `setStop`/`setHaul`),
    -- it's just not what gets checked here. Every other job confirms against `route.stop` itself.
    if jobConfig.dropoffPoint then
        if not route.haulNetId then return { ok = false, reason = 'nohaul' } end

        local haul = NetworkGetEntityFromNetworkId(route.haulNetId)
        if haul == 0 or not DoesEntityExist(haul) then
            -- Servidor: the hooked vehicle despawned or desynced somehow (resource restart on
            -- someone else's client, extreme edge case) - clearing this lets the player try
            -- hooking it again rather than getting stuck owing a haul that no longer exists.
            route.haulNetId = nil
            return { ok = false, reason = 'haullost' }
        end

        local dropoff = jobConfig.dropoffPoint.xyz

        if not isPlayerWithin(source, dropoff, COMPLETE_DISTANCE) then
            return { ok = false }
        end

        if #(GetEntityCoords(haul) - dropoff) > HAUL_DISTANCE then
            return { ok = false, reason = 'haulfar' }
        end

        -- Servidor: without this, nothing here actually required the vehicle to be *towed* -
        -- fixing the "broken" vehicle with a repair kit and simply driving it to the drop-off
        -- would pass both checks above (real haul, real position) while never touching the hook.
        -- Reuses the exact same check every other job's stop already uses, which is also what
        -- makes this work in a group without any change: it accepts *any* claimed tow-job
        -- vehicle nearby, not specifically this route's own truck (ADR-023).
        if not isJobVehicleNearby(route.jobName, dropoff) then
            return { ok = false, reason = 'notruck' }
        end

        despawnRouteHaul(route)
        route.stop = nil

        return { ok = true, paid = payForStop(source, route, jobConfig) }
    end

    if not isPlayerWithin(source, route.stop, COMPLETE_DISTANCE) then
        return { ok = false }
    end

    -- Servidor: a stop only counts while *some* claimed vehicle for this same job is parked
    -- near it - not necessarily this route's own one, so friends doing the same job separately
    -- (separate routes, separate counts, separate bonuses) can still ride and work together in
    -- just one of their trucks. Still has to be a real, claimed job vehicle (ADR-017 already
    -- guarantees that for every candidate this checks), never an arbitrary personal car, and
    -- ending a shift (below) still requires this route's *own* vehicle specifically. See ADR-023.
    if jobConfig.vehicle and not isJobVehicleNearby(route.jobName, route.stop) then
        return { ok = false, reason = 'novehiclenearby' }
    end

    -- Servidor: an item-gated job's real gate - removed here, not just counted, so the same stop
    -- can never be confirmed twice off one unit (a bare GetItemCount check would leave a race
    -- between checking and spending). RemoveItem returning false covers both "never had one" and
    -- "spent it on something else mid-shift" - either way, no item, no sale. See ADR-062. Spends
    -- `route.item` - the option this specific route picked at `startJob`, not a job-wide config
    -- field - so a route started with cocaine can't be completed by handing over weed. See
    -- ADR-070.
    if route.item and not exports.ox_inventory:RemoveItem(source, route.item, 1) then
        return { ok = false, reason = 'noitem' }
    end

    route.stop = nil

    return { ok = true, paid = payForStop(source, route, jobConfig) }
end)

--- Vehicle presence/position check used by `endShift` - `route.slot` is only set for a route
--- that actually took its own vehicle (ADR-024), so a route with none simply has nothing to
--- check here. Returns `true, vehicle` (vehicle may be nil), or `false, reason`.
local function checkOwnVehicleAt(route, coords)
    if not route.slot then return true end

    local vehicle = route.vehicleNetId and NetworkGetEntityFromNetworkId(route.vehicleNetId)

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return false, 'novehicle'
    end

    if #(GetEntityCoords(vehicle) - coords) > RETURN_VEHICLE_DISTANCE then
        return false, 'farvehicle'
    end

    return true, vehicle
end

--- Deletes this route's vehicle wherever it currently is, by network ID. Used by both ways of
--- settling the vehicle (parking it properly, or paying it off) - in neither case should it be
--- left standing in the world afterwards. Unlike `despawnRouteHaul`, this does not clear
--- `route.vehicleNetId` afterward - "settled" is signalled via `route.vehicleResolved` at each
--- call site instead. Nothing currently reads `vehicleNetId` again after settlement, so this is
--- an existing asymmetry preserved as-is, not a deliberate dependency.
local function despawnRouteVehicle(route)
    deleteNetworkedVehicle(route.vehicleNetId)
end

--- True when this route has nothing outstanding on its vehicle - either it never took one
--- (`route.slot` is nil, ADR-024's ride-along case) or it has since been parked or paid off.
local function isVehicleSettled(route)
    return not route.slot or route.vehicleResolved == true
end

-- Servidor: the return point does exactly two things and neither of them ends a shift (ADR-050) -
-- it is the vehicle's place, not the job's. Parking the vehicle here is the free way to settle
-- it; `payVehicleFine` below is the paid way, for a vehicle that is lost, stuck or simply too
-- far to bother retrieving. A vehicle can only ever be stored *here* - nowhere else counts.
lib.callback.register('srv_jobs:server:storeVehicle', function(source, jobName)
    local route = activeRoutes[source]
    if not route or route.jobName ~= jobName then return { ok = false } end
    if not route.slot then return { ok = false, reason = 'novehicleroute' } end
    if route.vehicleResolved then return { ok = false, reason = 'alreadysettled' } end

    local jobConfig = Config.jobs[jobName]
    local returnCoords = returnCoordsFor(jobConfig)
    if not returnCoords then return { ok = false } end

    if not isPlayerWithin(source, returnCoords.xyz, DEPOT_DISTANCE) then
        return { ok = false, reason = 'fardepot' }
    end

    local vehicleOk, vehicle = checkOwnVehicleAt(route, returnCoords.xyz)
    if not vehicleOk then return { ok = false, reason = vehicle } end

    despawnRouteVehicle(route)
    route.vehicleResolved = true

    return { ok = true }
end)

-- The paid alternative to parking it, also only offered at the return point. Settles the vehicle
-- for `pendingVehicleFine` and despawns it wherever it actually is, so a written-off vehicle
-- doesn't stay abandoned in the world either.
lib.callback.register('srv_jobs:server:payVehicleFine', function(source, jobName)
    local route = activeRoutes[source]
    if not route or route.jobName ~= jobName then return { ok = false } end
    if not route.slot then return { ok = false, reason = 'novehicleroute' } end
    if route.vehicleResolved then return { ok = false, reason = 'alreadysettled' } end

    local jobConfig = Config.jobs[jobName]
    local returnCoords = returnCoordsFor(jobConfig)
    if not returnCoords then return { ok = false } end

    if not isPlayerWithin(source, returnCoords.xyz, DEPOT_DISTANCE) then
        return { ok = false, reason = 'fardepot' }
    end

    -- Servidor: claimed before the charge, not after - `chargeFine` likely awaits a database
    -- write, and a second call for this same route could interleave in that yield window before
    -- `vehicleResolved` was ever set, passing the guard above and charging the fine twice.
    -- Claiming it first closes that window; a failed charge below rolls the claim back so the
    -- player can still retry.
    route.vehicleResolved = true

    if not chargeFine(source, Config.pendingVehicleFine, 'srv_jobs:vehiclefine') then
        route.vehicleResolved = nil
        return { ok = false, reason = 'cantafford', fine = Config.pendingVehicleFine }
    end

    despawnRouteVehicle(route)

    return { ok = true, fine = Config.pendingVehicleFine }
end)

-- Servidor: the counterpart to storing it (ADR-051). Storing the vehicle is easy to do by accident
-- - the return point offers it on a single [E] - and before this the mistake was unrecoverable:
-- stops need a job vehicle nearby to confirm (ADR-023), so a shift with its vehicle parked and 15
-- stops to go was stuck. Taking it back out is free, because it settles nothing: the route goes
-- straight back to owing a vehicle, so the fine at the NPC is deferred, never waived.
lib.callback.register('srv_jobs:server:withdrawVehicle', function(source, jobName)
    local route = activeRoutes[source]
    if not route or route.jobName ~= jobName then return { ok = false } end

    local jobConfig = Config.jobs[jobName]
    if not jobConfig or not jobConfig.vehicle then return { ok = false, reason = 'novehiclejob' } end

    -- Only ever handed out at the depot NPC, like starting a shift - never remotely.
    if not isPlayerWithin(source, jobConfig.depot.xyz, DEPOT_DISTANCE) then
        return { ok = false, reason = 'fardepot' }
    end

    -- The guard against duplicating vehicles: a route that still owes one gets nothing. Only a
    -- settled route (parked or paid off) - or a ride-along that never took one - may draw a
    -- vehicle, so at most one is out per shift at any moment.
    if not isVehicleSettled(route) then return { ok = false, reason = 'stillhasvehicle' } end

    -- A route that already had a slot keeps it: no other route could claim it while this one held
    -- it, so the bay is both free and still reserved. Only a ride-along needs a fresh one, and
    -- with every slot in use it simply doesn't get a vehicle.
    local slot = route.slot or findFreeSlot(jobName)
    if not slot then return { ok = false, reason = 'noslot' } end

    route.slot = slot
    route.vehicleResolved = nil
    -- Cleared so `setVehicle` accepts the new vehicle's net ID - it only ever records the first
    -- report per route, which is what stops a client claiming someone else's vehicle later.
    route.vehicleNetId = nil

    return { ok = true, slot = slot }
end)

-- Servidor: ending a shift happens at the depot NPC, where it started - the return point handles
-- the vehicle and nothing else (ADR-050). It always succeeds once the player is physically at the
-- depot; what varies is the bill, never whether ending is allowed. Two independent fines can
-- apply and stack, each needing its own explicit confirmation (`payEarlyFine`/`payVehicleFine`)
-- rather than ever being charged as a surprise:
--   - `earlyEndFine` if fewer than `minStopsBeforeReturn` stops were done;
--   - `pendingVehicleFine` if the vehicle was never settled at the return point.
-- The completion bonus only pays when neither applies - enough stops, vehicle genuinely stored.
lib.callback.register('srv_jobs:server:endShift', function(source, jobName, payEarlyFine, payVehicleFine)
    local route = activeRoutes[source]
    if not route or route.jobName ~= jobName then return { ok = false } end

    local jobConfig = Config.jobs[jobName]
    if not jobConfig or not jobConfig.depot then return { ok = false } end

    if not isPlayerWithin(source, jobConfig.depot.xyz, DEPOT_DISTANCE) then
        return { ok = false, reason = 'fardepot' }
    end

    local isEarly = route.count < Config.minStopsBeforeReturn

    if isEarly and not payEarlyFine then
        return { ok = false, reason = 'notenough', have = route.count, need = Config.minStopsBeforeReturn }
    end

    local vehicleUnsettled = not isVehicleSettled(route)

    if vehicleUnsettled and not payVehicleFine then
        return { ok = false, reason = 'vehiclenotsettled', fine = Config.pendingVehicleFine }
    end

    -- Servidor: see docs/security.md's paid-action ordering - validate everything (including what
    -- the fine will be), then charge, then deliver (bonus / vehicle despawn).
    local fine = (isEarly and Config.earlyEndFine or 0) + (vehicleUnsettled and Config.pendingVehicleFine or 0)

    -- Servidor: claimed (removed from `activeRoutes`) before the charge, not after - same race as
    -- `payVehicleFine` (ADR-054): `chargeFine` likely awaits a database write, and a second call
    -- for this same route could interleave in that window while the route was still present,
    -- passing every guard above again and charging twice. Removing it first closes that window;
    -- a failed charge puts it back so the player can still retry.
    activeRoutes[source] = nil

    if fine > 0 and not chargeFine(source, fine, 'srv_jobs:endshift') then
        activeRoutes[source] = route
        return { ok = false, reason = 'cantaffordearly', fine = fine }
    end

    -- An unsettled vehicle is despawned here too - the fine covers losing track of it, it
    -- shouldn't also be left abandoned in the world.
    if vehicleUnsettled then despawnRouteVehicle(route) end

    -- Servidor: a tow-style shift (ADR-052) can end mid-haul - hooked something, then walked away
    -- from the delivery instead of finishing it. No separate fine for this (the trip already just
    -- doesn't pay), but the hauled vehicle still can't be left standing in the world either.
    despawnRouteHaul(route)

    local pay = (fine == 0 and jobConfig.bonus) or 0

    if pay > 0 and not payJob(source, jobConfig, pay, ('srv_jobs:%s:shift'):format(jobName)) then
        pay = 0
    end

    return {
        ok = true,
        paid = pay,
        earlyFine = (isEarly and Config.earlyEndFine) or nil,
        vehicleFine = (vehicleUnsettled and Config.pendingVehicleFine) or nil,
    }
end)

lib.callback.register('srv_jobs:server:payDebt', function(source)
    local cid = getCitizenId(source)
    if not cid or not pendingDebt[cid] then return { ok = false } end

    local fine = pendingDebt[cid]

    if not chargeFine(source, fine, 'srv_jobs:debt') then
        return { ok = false, reason = 'insufficient' }
    end

    pendingDebt[cid] = nil

    return { ok = true, paid = fine }
end)

RegisterNetEvent('srv_jobs:server:cancelJob', function()
    endRoute(source)
end)

AddEventHandler('playerDropped', function()
    endRoute(source)
end)
