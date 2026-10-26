-- Servidor: client-side display only - every decision is made in server.lua. This file draws the
-- prompt, runs the minigame, and reports what happened. See ADR-097.

local INTERACT_CONTROL = 38

local function notify(description, notifyType)
    lib.notify({ title = 'Assalto', description = description, type = notifyType or 'inform' })
end

---@param seconds number
---@return string
local function formatDuration(seconds)
    local minutes = math.ceil(seconds / 60)
    if minutes < 60 then return ('%s min'):format(minutes) end
    return ('%sh%02d'):format(minutes // 60, minutes % 60)
end

--- Same two-tier marker + `[E]` zone shape every farm point uses (ADR-066) - duplicated rather than
--- shared, since FXServer gives each resource its own script environment.
--- Servidor: used by every point this resource owns - the two launderers, the factory entrance and
--- the 16 shop counters. A brief detour through ox_target (ADR-099) was reverted by ADR-100.
---
--- `marker` decides which of the project's two markers is drawn, and the split is by what is there
--- rather than by who draws it: a PERSON gets the flat green disc (type 1), a SHOP counter gets the
--- cone (type 0) at the same scale ox_inventory uses for every other shop. Defaults to the disc,
--- since most points here are people.
---@param marker { kind: number, scale: number }?
local function setupInteractionZone(coords, radius, innerRadius, getPrompt, onInteract, marker)
    local innerZone
    local kind = marker and marker.kind or 1
    local scale = marker and marker.scale or nil

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
                    local prompt = getPrompt()
                    if prompt then lib.showTextUI(prompt) end
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = function()
                    if not IsControlJustPressed(0, INTERACT_CONTROL) then return end
                    if not getPrompt() then return end

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
            if getPrompt() then
                -- Servidor: the same green every other point in this project draws. It was red while
                -- the robbery had its own separate marker beside the shop's; now that this is the
                -- only marker on the counter there is no second colour to distinguish it from.
                -- Servidor: the cone sits at the point itself and the disc a metre below it, which is
                -- how each is meant to look - a disc drawn at ground level and a cone hovering over
                -- it. Same green and alpha for both.
                if kind == 0 then
                    DrawMarker(0, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        scale or 1.5, scale or 1.5, scale or 1.5,
                        20, 246, 12, 200, false, false, 0, false, nil, nil, false)
                else
                    DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5,
                        20, 246, 12, 200, false, false, 0, false, nil, nil, false)
                end
            end
        end,
    })
end

--- Runs `mhacking` and resolves to whether it was won.
---
--- `mhacking` predates callback-style APIs: it is three separate events, and the result arrives
--- through a callback rather than a return. Wrapped here so the rest of this file - and the tiers
--- that will follow - never has to know that. `lib.waitFor` turns it back into something linear.
---@return boolean won
local function runHack()
    local finished, won = false, false

    TriggerEvent('mhacking:show')
    TriggerEvent('mhacking:start', Config.hack.solutionLength, Config.hack.duration, function(result)
        won = result == true
        finished = true
    end)

    -- Servidor: the timeout is the minigame's own duration plus a margin, not an arbitrary number. If
    -- `mhacking` ever fails to call back at all, this is what stops the player being frozen in a
    -- state nothing clears.
    lib.waitFor(function()
        if finished then return true end
    end, 'o minigame não respondeu', (Config.hack.duration + 10) * 1000)

    TriggerEvent('mhacking:hide')

    return won
end

---@param store {key: string, label: string, coords: vector3}
local function robStore(store)
    local result = lib.callback.await('srv_robbery:server:start', false, store.key)

    if not result or not result.ok then
        local reasons = {
            far = 'Chegue mais perto do caixa.',
            busy = 'Alguém já está mexendo nesse caixa.',
            nopolice = 'Não tem policiamento suficiente na cidade agora.',
            storecooldown = 'Essa loja já foi assaltada recentemente.',
            playercooldown = 'Você assaltou uma loja há pouco tempo. Espere.',
        }
        notify((result and reasons[result.reason]) or 'Não foi possível assaltar agora.', 'error')
        return
    end

    notify('A polícia foi acionada. Seja rápido.', 'inform')

    local won = runHack()

    -- Servidor: the flourish after a won hack - the store had no animation at all before this, the
    -- minigame is a pure UI overlay. Not cancellable: `start` already claimed the store in the
    -- `attempts` table above, so `finish` below has to run regardless to release that lock - see
    -- ADR-108's own note on why `srv_wanted`'s equivalent choice mattered. Only plays on a won
    -- hack; a failed one already has its own real consequence and nothing to mime picking up.
    if won then
        lib.progressCircle({
            duration = 3000,
            position = 'bottom',
            label = 'Pegando o dinheiro...',
            useWhileDead = false,
            canCancel = false,
            disable = { move = true, car = true, combat = true },
            anim = { dict = 'random@shop_robbery', clip = 'robbery_action_b' },
        })
    end

    local finish = lib.callback.await('srv_robbery:server:finish', false, store.key, result.token, won)

    if not finish or not finish.ok then
        local reasons = {
            far = 'Você saiu do caixa antes de terminar.',
            toofast = 'Tentativa recusada.',
            noroom = 'Você não tem espaço no inventário para carregar isso.',
        }
        notify((finish and reasons[finish.reason]) or 'Não foi possível concluir.', 'error')
        return
    end

    if not finish.won then
        notify('O caixa travou. Você saiu sem nada.', 'error')
        return
    end

    notify(('Levou $%s em dinheiro sujo.'):format(finish.payout), 'success')
end

-- Servidor: ONE point per counter, on [E], offering both actions in one menu - the project standard
-- everywhere else, and what was asked for after two failed attempts at making a separate robbery
-- interaction coexist with the shop's own.
--
-- The shop no longer registers its own interaction here: `General` and `Liquor` carry
-- `srvExternalInteraction` in `shops.lua`, so ox_inventory contributes the blip and nothing else.
-- Its data is untouched, which matters - the server builds the shop and range-checks it from that
-- same `targets` entry, so deleting it would have broken opening the shop at all. See ADR-100.
--
-- Because this is a menu rather than a bare prompt, the cooldown and the police count are visible
-- BEFORE acting again, the way every other point in this project shows its state.
---@param store {key: string, label: string, shopType: string, shopIndex: number, coords: vector3}
local function openCounterMenu(store)
    local state = lib.callback.await('srv_robbery:server:getStoreState', false, store.key)

    -- Servidor: `wanted` is the one reason that also blocks "Abrir loja" - every other reason on
    -- the "Assaltar" entry below only ever disabled the robbery, never buying. A marked player is
    -- refused by the whole counter, matching every other shop this project has.
    local options = {}

    if state and state.reason == 'wanted' then
        options[#options + 1] = {
            title = 'Abrir loja',
            description = 'Você está procurado - o lojista não te atende.',
            icon = 'basket-shopping',
            iconColor = '#e03131',
            disabled = true,
        }
    else
        options[#options + 1] = {
            title = 'Abrir loja',
            description = 'Comprar o que está à venda.',
            icon = 'basket-shopping',
            onSelect = function()
                -- Servidor: server-checked even though the menu above already hid the reason a
                -- moment ago - `state` is a read taken when the menu opened, and being marked mid-
                -- browse (unlikely, but the whole point of "never trust the client" is not trusting
                -- timing either) should not let a stale "not wanted yet" reading still open the shop.
                local canOpen = lib.callback.await('srv_robbery:server:canOpenStore', false, store.key)
                if not canOpen or not canOpen.ok then
                    notify('Você está procurado - o lojista não te atende.', 'error')
                    return
                end

                exports.ox_inventory:openInventory('shop', { id = store.shopIndex, type = store.shopType })
            end,
        }
    end

    -- Servidor: the robbery entry always appears, and says why it cannot be used rather than
    -- vanishing - a missing option reads as a bug, a disabled one with a reason reads as a rule.
    if not state then
        options[#options + 1] = {
            title = 'Assaltar a loja',
            description = 'Não foi possível consultar o caixa agora.',
            icon = 'sack-dollar',
            disabled = true,
        }
    elseif state.reason == 'wanted' then
        options[#options + 1] = {
            title = 'Assaltar a loja',
            description = 'Você está procurado - a polícia já está de olho.',
            icon = 'sack-dollar',
            iconColor = '#e03131',
            disabled = true,
        }
    elseif state.reason == 'nopolice' then
        options[#options + 1] = {
            title = 'Assaltar a loja',
            description = ('Sem policiamento na cidade (%s de %s).'):format(state.police, state.policeRequired),
            icon = 'sack-dollar',
            iconColor = '#e03131',
            disabled = true,
        }
    elseif state.reason == 'storecooldown' then
        options[#options + 1] = {
            title = 'Assaltar a loja',
            description = ('Caixa vazio - volte em %s.'):format(formatDuration(state.storeSecondsLeft)),
            icon = 'sack-dollar',
            iconColor = '#e03131',
            disabled = true,
        }
    elseif state.reason == 'playercooldown' then
        options[#options + 1] = {
            title = 'Assaltar a loja',
            description = ('Você está marcado - espere %s.'):format(formatDuration(state.playerSecondsLeft)),
            icon = 'sack-dollar',
            iconColor = '#e03131',
            disabled = true,
        }
    elseif state.reason == 'busy' then
        options[#options + 1] = {
            title = 'Assaltar a loja',
            description = 'Alguém já está mexendo nesse caixa.',
            icon = 'sack-dollar',
            iconColor = '#e03131',
            disabled = true,
        }
    else
        options[#options + 1] = {
            title = 'Assaltar a loja',
            description = 'A polícia é avisada na hora.',
            icon = 'sack-dollar',
            iconColor = '#e03131',
            onSelect = function() robStore(store) end,
            metadata = {
                { label = 'Policiamento', value = ('%s em serviço'):format(state.police) },
                { label = 'Alerta', value = 'imediato' },
            },
        }
    end

    lib.registerContext({
        id = ('srv_robbery_counter_%s'):format(store.key),
        title = store.label,
        options = options,
    })
    lib.showContext(('srv_robbery_counter_%s'):format(store.key))
end

CreateThread(function()
    for i = 1, #Config.stores do
        local store = Config.stores[i]

        -- Servidor: the cone, because this point is a shop counter. Every other point in this
        -- resource is a person and keeps the disc.
        setupInteractionZone(store.coords, Config.interactDistance + 5.0, Config.interactDistance,
            function() return ('[E] %s.'):format(store.label) end,
            function() openCounterMenu(store) end,
            { kind = 0, scale = 1.5 })
    end
end)

-- Servidor: the same unidentifying blip every illegal point in this project uses - sprite 84
-- ("Skull"), colour 9 (grey), named "Desconhecido". A glance at the map shows something is there,
-- never what, and never which of the two contacts it is.
local function addIllegalBlip(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 84)
    SetBlipColour(blip, 9)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Desconhecido')
    EndTextCommandSetBlipName(blip)
    return blip
end

-- Servidor: tier-2 house blips, permanent and visible to everyone - unlike `addIllegalBlip` above,
-- these are meant to be found. Sprite 40 ("Property") is the same house icon GTA itself uses for a
-- safehouse, and the label is deliberately just "Casa" on every one of them: see the long comment
-- on `Config.houses` for why the street address is not shown.
--
-- Spawned for every entry regardless of whether it has an `entrance` yet, on purpose - the blips
-- are how a house being mapped gets walked to and checked against the others, and pulling one the
-- moment its config is filled in would move it without anyone touching this file.
--
-- Two lists, two colours: `Config.houses` (yellow) are the GTA Online-exclusive interiors, where
-- Houses 1 and 2 turned up the still-unsolved entrance bug (see the comment above that list in
-- config.lua); `Config.storyHouses` (red) are the 4 single-player story houses, unrelated content
-- that has not shown the same symptom. The colour split is a genuine status difference, not
-- decoration - it says which four are worth mapping first.
local function addHouseBlips(houses, colour)
    for i = 1, #houses do
        local house = houses[i]
        local blip = AddBlipForCoord(house.coords.x, house.coords.y, house.coords.z)

        SetBlipSprite(blip, 40)
        SetBlipColour(blip, colour)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(house.label)
        EndTextCommandSetBlipName(blip)
    end
end

CreateThread(function()
    -- Servidor: both grey now, by request - the colour used to mark which 8 had the door-freeze
    -- bug (ADR-106/107), which was an engine-internal detail, not something worth a permanent
    -- colour code once fixed. Reassigned to mean something a player actually cares about: how you
    -- get in. `9` is the grey this project already uses for `addIllegalBlip` below, confirmed in
    -- game; `3` for the story houses is a second, darker shade - not yet confirmed in game, since
    -- blip colour indices aren't documented by any bundled native reference, only tested visually.
    addHouseBlips(Config.houses, 9)
    addHouseBlips(Config.storyHouses, 3)
end)

-- Servidor: stops the front door swinging open as a player walks up, which at these 8 houses reveals
-- the black wall behind it (see the note above `Config.houses`). The door is cosmetic - `/doorinfo`
-- found it is not registered in GTA's door system, and `/doortest` proved its collision is not what
-- blocks the doorway - but since these houses are entered by teleport now, a door that swings into
-- a void is pure noise.
--
-- WHAT WORKED, and why it was thrown away by mistake. Five attempts in, the only combination the
-- user ever confirmed as "the door didn't move" was `SetEntityCollision(false)` + freeze. Its one
-- complaint was that the player then sank into the doorway - so the collision call was removed to
-- fix that, which silently removed the fix as well. Everything tried afterwards (`SetEntityDynamic`,
-- GTA's own door system with a LOCKED state) failed, including at House 2 where the door is 7.33m
-- from the zone anchor and the zone was definitely running. So this returns to what worked.
--
-- The sinking was never caused by the collision call on its own - it was caused by WHEN it ran.
-- The scan looked for props within 2m OF THE PLAYER, so it could not reach the door until the
-- player was already at it, by which point the door had swung open and got frozen mid-swing,
-- across the doorway the player then walked through.
--
-- The fix is the timing, not the call: the scan now looks around the SURVEYED DOOR POSITION
-- instead, which fires the moment a player enters the 15m zone - while they are still far enough
-- away that the door has never opened. A door caught closed and left without collision stays shut
-- and stays out of the way, which is both halves of the problem at once.
--
-- This only works for surveyed houses, since it needs the door's real position. Unsurveyed ones
-- fall back to scanning around the player, i.e. the old behaviour with the old flaw - noted rather
-- than hidden, and it resolves itself as each house gets its `/coords` pass.
local lockedDoors = {}
local RESCAN_INTERVAL_MS = 500
-- Servidor: 6 scans (3s), not 2 (1s). The prop streams in some time after the player crosses the
-- 15m boundary, so the give-up window has to outlast the worst case, or a door that was about to
-- be caught gets abandoned one scan early. Still bounded, so this never becomes a permanent poll.
local STABLE_SCANS_TO_STOP = 6

--- Pins a door prop where it stands, KEEPING its collision so a player can lean on it rather than
--- walk through it.
---
--- Timing is the whole trick, and it is why this looks like a combination that was already ruled
--- out. `SetEntityDynamic(false)` + freeze was tried before and failed - but back then the scan ran
--- off the PLAYER's position, so it could not reach the door until the player was on top of it and
--- the door was already swinging. Taking a moving door out of the physics simulation leaves it
--- moving; taking a still one out leaves it still.
---
--- Now that the scan runs off the surveyed door position, this fires while the player is still
--- metres away and the door has not been touched - which the logs confirmed, catching House 2's
--- door at 4.43m. So collision stays ON: the door is already shut, and nothing needs to pass
--- through it now that these houses are entered by teleport.
---@param object number
local function disableDoorProp(object)
    SetEntityDynamic(object, false)
    FreezeEntityPosition(object, true)
end

CreateThread(function()
    for i = 1, #Config.houses do
        local house = Config.houses[i]

        -- Servidor: anchored to the surveyed FRONT DOOR, falling back to `house.coords` only for
        -- houses that have not been surveyed yet. Those are not the same place: House 1's real
        -- door is 17.05m from its `coords`, so a 15m zone drawn around `coords` never contained
        -- the door at all - which is exactly why this freeze appeared to do nothing for several
        -- rounds while looking correct in the source. Unsurveyed houses keep the old (wrong)
        -- anchor rather than being skipped, so they at least still work when approached from the
        -- side the interior point happens to be on.
        local coords = house.entrance and house.entrance.outside and house.entrance.outside.xyz
            or house.coords
        local nextScan = 0
        local quietScans = 0
        local zone

        zone = lib.zones.sphere({
            coords = coords,
            radius = 15.0,
            debug = false,
            inside = function()
                local now = GetGameTimer()
                if now < nextScan then return end
                nextScan = now + RESCAN_INTERVAL_MS

                -- Servidor: THE fix. Scanning around the surveyed door position rather than around
                -- the player is what lets this run while the player is still metres away, catching
                -- the door before a ped has ever pushed it - so it is disabled shut instead of
                -- pinned open. Scanning around the player could only ever reach the door after it
                -- had already swung.
                local pedCoords = GetEntityCoords(cache.ped)
                local surveyed = house.entrance and house.entrance.outside ~= nil
                local scanFrom = surveyed and coords or pedCoords
                local scanRadius = surveyed and 3.0 or 2.0

                local pool = GetGamePool('CObject')
                local caught = false

                for j = 1, #pool do
                    local object = pool[j]
                    if not lockedDoors[object] and #(scanFrom - GetEntityCoords(object)) <= scanRadius then
                        disableDoorProp(object)
                        lockedDoors[object] = true
                        caught = true
                    end
                end

                -- Servidor: only stop counting down once the player is close enough that anything
                -- that was going to stream in already has. Further out, a quiet scan means nothing.
                local closeEnoughToJudge = #(pedCoords - coords) <= 5.0

                if caught or not closeEnoughToJudge then
                    quietScans = 0
                else
                    quietScans += 1
                    if quietScans >= STABLE_SCANS_TO_STOP then zone:remove() end
                end
            end,
        })
    end

end)

--- Runs the lockpick skill check and reports the result to the server, which is the only thing
--- that may actually consume or break the item - the check itself is client-rendered and cannot be
--- otherwise, the same bounded exception `mhacking` already is (see ADR-097): the server does not
--- trust "I picked it", only what proximity, the item count and a break-chance roll say it is worth.
---@param houseKey string
---@return boolean entered
local function attemptLockpick(houseKey)
    if (exports.ox_inventory:Search('count', Config.houseLockpick.item) or 0) <= 0 then
        notify('Você precisa de uma chave mestra.', 'error')
        return false
    end

    local passed = lib.skillCheck(Config.houseLockpick.skillCheck.difficulty, Config.houseLockpick.skillCheck.inputs)

    local result = lib.callback.await('srv_robbery:server:enterHouse', false, houseKey, passed == true)

    if not result or not result.ok then
        local reasons = {
            nolockpick = 'Você precisa de uma chave mestra.',
            far = 'Chegue mais perto da porta.',
        }
        notify((result and reasons[result.reason]) or 'Não foi possível arrombar a porta.', 'error')
        return false
    end

    if not result.entered then
        notify(result.broke and 'Você errou e a chave mestra quebrou.' or 'Você errou a chave mestra.', 'error')
        return false
    end

    -- Servidor: success is always announced, by request. The break case says so in the same line
    -- rather than firing a second notification on top of the first - two stacked toasts for one
    -- action reads as something having gone wrong, when in fact the player got in either way.
    notify(result.broke and 'Porta arrombada. A chave mestra quebrou na fechadura.'
        or 'Porta arrombada. Você entrou na casa.', 'success')

    return true
end

-- Servidor: the teleport pair every interior without a real walkable door uses in this project
-- (ADR-059) - `entrance.inside` stays nil until the house is walked with noclip and a landing spot
-- is picked, so the [E] to enter simply does not exist until then. This is on top of the door-prop
-- freeze above, not instead of it - freezing stops the ugly swing for a house that is not enterable
-- yet either, since players can (and did) walk up and bump it while just scouting the blips.
CreateThread(function()
    for i = 1, #Config.houses do
        local house = Config.houses[i]
        local entrance = house.entrance
        local inside = entrance and entrance.inside
        if not inside then goto continue end

        setupInteractionZone(entrance.outside.xyz, entrance.distance + 5.0, entrance.distance,
            function() return '[E] Arrombar a porta.' end,
            function()
                if not attemptLockpick(house.key) then return end

                SetEntityCoords(cache.ped, inside.x, inside.y, inside.z, false, false, false, false)
                SetEntityHeading(cache.ped, inside.w)
            end)

        setupInteractionZone(inside.xyz, entrance.distance + 5.0, entrance.distance,
            function() return '[E] Sair.' end,
            function()
                SetEntityCoords(cache.ped, entrance.outside.x, entrance.outside.y, entrance.outside.z,
                    false, false, false, false)
                SetEntityHeading(cache.ped, entrance.outside.w)
            end)

        ::continue::
    end
end)

--- One launderer. There are two, with different rates and different daily allowances, and this is
--- written once for both rather than duplicated - the only thing that differs between them is
--- config. See ADR-097.
---@param launderer {key: string, label: string, prompt: string, rate: number, allowedGangs: string[]?, vendor: vector4?, vendorPed: number?, vendorDistance: number}
local function setupLaunderer(launderer)
    -- Servidor: a contact only exists once a real coordinate does - the same "not playable until
    -- mapped" rule every NPC here follows. With it nil the ped never spawns and dirty money stays
    -- spendable at the black market, so nothing else is affected. Read into a local right after the
    -- check: the type checker narrows a local through a closure boundary, but not a table field.
    local vendor = launderer.vendor
    if not vendor then return end

    local ped

    -- Servidor: a launderer with no `vendorPed` is a place rather than a person - the zone, its
    -- marker and its prompt all still exist, nothing is spawned to stand in them. The closed
    -- contact is one of these: a machine in a factory, the same shape as a farm press bench.
    if launderer.vendorPed then
        CreateThread(function()
            lib.requestModel(launderer.vendorPed, 10000)
            ped = CreatePed(0, launderer.vendorPed, vendor.x, vendor.y, vendor.z - 1.0, vendor.w, false, false)
            SetModelAsNoLongerNeeded(launderer.vendorPed)
            SetEntityHeading(ped, vendor.w)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_HANG_OUT_STREET', 0, true)
        end)
    end

    -- Servidor: read once on start rather than on every prompt draw. Gang membership can change
    -- mid-session, so this is refreshed whenever the player's own data changes - `getLaunderState`
    -- is the real gate regardless, so a stale read here only ever hides an offer that would have
    -- worked, never opens one that would not.
    local allowed = not launderer.allowedGangs or false

    local function refreshAllowed()
        if not launderer.allowedGangs then
            allowed = true
            return
        end

        local gang = QBX.PlayerData and QBX.PlayerData.gang
        allowed = false
        if not gang then return end

        for i = 1, #launderer.allowedGangs do
            if launderer.allowedGangs[i] == gang.name then allowed = true end
        end
    end

    -- Servidor: the blip is visible to everyone, by request - the same unidentifying grey skull every
    -- other illegal point in this project carries. An earlier version hid a closed contact's blip
    -- from non-members so it would not advertise where the gang launders; the project standard won,
    -- and a blip that says "Desconhecido" gives away little on its own.
    addIllegalBlip(vendor.xyz)

    refreshAllowed()
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', refreshAllowed)
    RegisterNetEvent('QBCore:Client:OnGangUpdate', refreshAllowed)

    ---@param state {held: number, rate: number, dailyUsed: number}
    local function launder(state)
        local input = lib.inputDialog('Lavar dinheiro', {
            { type = 'number', label = 'Quanto lavar', icon = 'hashtag',
                description = ('Você recebe %s%% do que entregar.'):format(math.floor(state.rate * 100)),
                default = state.held, min = 1, max = state.held, required = true },
        })
        if not input then return end

        local result = lib.callback.await('srv_robbery:server:launder', false, launderer.key, input[1])

        if not result or not result.ok then
            local reasons = {
                far = 'Chegue mais perto.',
                nomoney = 'Você não tem dinheiro sujo.',
                notenough = 'Você não tem tudo isso em dinheiro sujo.',
                notallowed = 'Esse contato não trabalha com você.',
            }
            notify((result and reasons[result.reason]) or 'Não foi possível lavar.', 'error')
            return
        end

        notify(('Lavou $%s e recebeu $%s.'):format(result.dirty, result.clean), 'success')
    end

    setupInteractionZone(vendor.xyz, launderer.vendorDistance + 5.0, launderer.vendorDistance,
        function()
            -- Servidor: a closed contact shows no prompt at all to someone who is not a member, rather
            -- than a prompt that refuses. `getLaunderState` returns nil for them server-side, which is
            -- what actually enforces it; this only decides whether the offer is visible.
            if not allowed then return nil end
            return launderer.prompt
        end,
        function()
            local state = lib.callback.await('srv_robbery:server:getLaunderState', false, launderer.key)
            if not state then return end

            if state.held <= 0 then
                notify('Você não tem dinheiro sujo para lavar.', 'error')
                return
            end

            lib.registerContext({
                id = ('srv_robbery_launderer_%s'):format(launderer.key),
                title = launderer.label,
                description = ('Paga %s%% do que você entregar.'):format(math.floor(state.rate * 100)),
                options = {
                    {
                        title = 'No bolso',
                        description = ('$%s sujos.'):format(state.held),
                        icon = 'money-bill-wave',
                        iconColor = '#3ecf7e',
                        readOnly = true,
                        inline = true,
                    },
                    {
                        title = 'Lavado hoje',
                        description = ('$%s até agora.'):format(state.dailyUsed),
                        icon = 'calendar-day',
                        iconColor = '#3ecf7e',
                        readOnly = true,
                        inline = true,
                    },
                    {
                        title = 'Lavar',
                        description = ('Você recebe %s%% do valor.'):format(math.floor(state.rate * 100)),
                        icon = 'soap',
                        onSelect = function() launder(state) end,
                        metadata = {
                            { label = 'Taxa', value = ('%s%% para você'):format(math.floor(state.rate * 100)) },
                            { label = 'No bolso', value = ('$%s sujos'):format(state.held) },
                            { label = 'Lavado hoje', value = ('$%s'):format(state.dailyUsed) },
                        },
                    },
                },
            })
            lib.showContext(('srv_robbery_launderer_%s'):format(launderer.key))
        end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= cache.resource then return end
        if ped then exports.srv_lib:DeleteLocalEntity(ped) end
    end)
end

CreateThread(function()
    for i = 1, #Config.launderers do
        setupLaunderer(Config.launderers[i])
    end
end)

-- Servidor: the way into the Counterfeit Cash Factory, where the closed contact lives. Same shape as
-- srv_weedfarm's and srv_methlab's own entrances (ADR-059): the interior has no walkable door, so
-- `[E]` at a real street point teleports in, and `[E]` inside teleports back to that same street
-- coordinate. A plain SetEntityCoords, no fade - bob74_ipl keeps the IPL loaded at all times.
--
-- Both halves only exist once both coordinates do. With `inside` still nil the entrance is absent
-- entirely rather than half-built, which is the same "not playable until mapped" rule every NPC
-- here follows.
CreateThread(function()
    local entrance = Config.factoryEntrance
    local inside = entrance.inside
    if not inside then return end

    addIllegalBlip(entrance.outside.xyz)

    setupInteractionZone(entrance.outside.xyz, entrance.distance + 5.0, entrance.distance,
        function() return '[E] Entrar.' end,
        function()
            SetEntityCoords(cache.ped, inside.x, inside.y, inside.z, false, false, false, false)
            SetEntityHeading(cache.ped, inside.w)
        end)

    setupInteractionZone(inside.xyz, entrance.distance + 5.0, entrance.distance,
        function() return '[E] Sair.' end,
        function()
            SetEntityCoords(cache.ped, entrance.outside.x, entrance.outside.y, entrance.outside.z,
                false, false, false, false)
            SetEntityHeading(cache.ped, entrance.outside.w)
        end)
end)

-- Servidor: exposed for `srv_tools`' `/housedist`, which measures how far a player is from every
-- configured house - the check that tells whether these coordinates (copied from `bob74_ipl`
-- comments, which mark interior reference points rather than front doors) actually sit near the
-- doors the zones above are supposed to cover. Read-only; returns a copy so a dev command cannot
-- mutate the live config.
exports('GetHouseCoords', function()
    local out = {}

    for i = 1, #Config.houses do
        out[#out + 1] = { key = Config.houses[i].key, coords = Config.houses[i].coords }
    end

    return out
end)

-- Servidor: the story-house tier - no lockpick, no minigame, walk straight in. The obstacle is the
-- guards themselves, not a gate at the door, which is why there is no `setupInteractionZone` at an
-- entrance here at all: the whole property is the interaction.
--
-- Guards spawn once per house, the first time a player gets within 40m - streamed lazily like every
-- other NPC in this project, not all 20 the moment the resource starts. Each one wanders its house's
-- `guardRadius` with `TaskWanderInArea`, which needs only a centre point and a radius, not a hand
-- authored patrol route - the project's own rule against inventing world positions (CLAUDE.md) would
-- otherwise block this entirely, since no patrol waypoints have been surveyed for any of the 4
-- properties.
local spawnedGuardHouses = {}

--- Every guard belongs to its own relationship group, hostile only to the player's, so shooting one
--- house's guards does not alert the other three. Created once, reused per ped.
---
--- Native relationship values, confirmed against the bundled docs rather than assumed:
--- 0 Companion, 1 Respect, 2 Like, 3 Neutral, 4 Dislike, 5 Hate. Starts at 4 (Dislike) - wary, not
--- hostile - so the ambient "look at or bump a guard" reaction GTA's own combat AI already gives an
--- armed, alert ped still applies without every guard opening fire the instant a player spawns in.
---@param houseKey string
---@return number groupHash
local function getGuardRelationshipGroup(houseKey)
    local name = ('srv_guards_%s'):format(houseKey)
    local hash = AddRelationshipGroup(name)
    SetRelationshipBetweenGroups(4, hash, `PLAYER`)
    SetRelationshipBetweenGroups(4, `PLAYER`, hash)
    return hash
end

--- Servidor: sets every guard at `houseKey` hostile (4 Dislike -> 5 Hate) and reports the robbery to
--- the police, mirroring the store tier's own alert exactly - fired when the robbery STARTS, not
--- when the fight ends (ADR-097's own convention). Server-authoritative: the client cannot be
--- trusted to decide whether police were actually told, only to ask.
---@param houseKey string
local function triggerStoryRobbery(houseKey)
    local hash = getGuardRelationshipGroup(houseKey)
    SetRelationshipBetweenGroups(5, hash, `PLAYER`)
    SetRelationshipBetweenGroups(5, `PLAYER`, hash)

    TriggerServerEvent('srv_robbery:server:storyRobberyAlert', houseKey)
end

CreateThread(function()
    for i = 1, #Config.storyHouses do
        local house = Config.storyHouses[i]
        local guards = Config.storyHouseGuards

        lib.zones.sphere({
            coords = house.coords,
            radius = 40.0,
            debug = false,
            onEnter = function()
                if spawnedGuardHouses[house.key] then return end
                spawnedGuardHouses[house.key] = true

                local relGroup = getGuardRelationshipGroup(house.key)

                lib.requestModel(guards.ped)

                CreateThread(function()
                    for _ = 1, house.guardCount do
                        -- Servidor: spawned around the house centre with a small random offset so
                        -- 10 guards at Michael's do not stack on the exact same point on spawn -
                        -- `TaskWanderInArea` spreads them out from there on its own.
                        local angle = math.random() * 2 * math.pi
                        local dist = math.random() * (house.guardRadius * 0.5)
                        local x = house.coords.x + math.cos(angle) * dist
                        local y = house.coords.y + math.sin(angle) * dist

                        local ped = CreatePed(4, guards.ped, x, y, house.coords.z, math.random(0, 359) + 0.0, true, true)

                        SetPedRelationshipGroupHash(ped, relGroup)
                        GiveWeaponToPed(ped, guards.weapon, guards.ammo, false, true)
                        SetPedAccuracy(ped, guards.accuracy)
                        SetPedCombatAbility(ped, 2) -- professional
                        SetPedCombatAttributes(ped, 46, true) -- can use cover
                        SetPedFleeAttributes(ped, 0, false) -- stands and fights rather than routing

                        TaskWanderInArea(ped, house.coords.x, house.coords.y, house.coords.z, house.guardRadius, 5.0, 10.0)
                    end
                end)
            end,
        })
    end
end)

-- Servidor: the deliberate trigger. `Roubar` is offered anywhere within a story house's guard
-- radius, since there is no single door to stand at (unlike the lockpick tier) - the whole property
-- is the target. Pressing it does not hand over loot on its own (no loot points are mapped for
-- these houses yet, the same "not playable until mapped" gap the lockpick tier's `entrance.inside`
-- has); it only starts the fight and the alert, which is the part that has to exist before loot can
-- mean anything.
CreateThread(function()
    for i = 1, #Config.storyHouses do
        local house = Config.storyHouses[i]

        setupInteractionZone(house.coords, house.guardRadius + 10.0, house.guardRadius,
            function() return '[E] Roubar a casa.' end,
            function()
                -- Servidor: nothing is claimed yet at this point (unlike the store's `attempts`
                -- lock) - guards only turn hostile inside `triggerStoryRobbery`, which always runs
                -- after this: no robbery animation in this project is cancellable, by request.
                lib.progressCircle({
                    duration = 3000,
                    position = 'bottom',
                    label = 'Forçando a entrada...',
                    useWhileDead = false,
                    canCancel = false,
                    disable = { move = true, car = true, combat = true },
                    anim = { dict = 'random@shop_robbery', clip = 'robbery_action_b' },
                })

                triggerStoryRobbery(house.key)
            end,
            { kind = 1 })
    end
end)

-- Servidor: the loot itself, for the lockpick tier's houses - independent of the entrance/lockpick
-- setup above, since a point only matters once a player has already gotten in. One `[E]` per
-- surveyed point; a house with no `lootPoints` yet simply has none, the same "not playable until
-- mapped" gap `entrance.inside` has for the houses not yet walked.
CreateThread(function()
    for i = 1, #Config.houses do
        local house = Config.houses[i]
        if not house.lootPoints then goto continue end

        for pointIndex = 1, #house.lootPoints do
            local point = house.lootPoints[pointIndex]

            -- Servidor: the label comes from the item's own catalog entry, not repeated here in a
            -- second place - if `data/items.lua` ever relabels one of the 8, this prompt follows
            -- without anyone having to remember it exists.
            local itemDef = exports.ox_inventory:Items(point.item)
            local label = itemDef and itemDef.label or point.item

            setupInteractionZone(point.coords.xyz, 6.0, 1.5,
                function() return ('[E] Pegar %s.'):format(label) end,
                function()
                    -- Servidor: the same short `lib.progressCircle` + verified animation every other
                    -- "quick grab" in this project uses (see `srv_weedfarm`'s fertiliser boost) -
                    -- reused rather than left as an instant grant, and the anim itself is not a new
                    -- guess: `random@shop_robbery`/`robbery_action_b` is already loaded and playing
                    -- elsewhere on this server (`qbx_police`'s own player-robbery interaction), so
                    -- it is confirmed to exist rather than assumed. Purely cosmetic - the server
                    -- callback below still re-checks proximity and cooldown on its own regardless
                    -- of when the client gets around to calling it. Not cancellable - no robbery
                    -- animation in this project is, by request; the `if not ... then return end`
                    -- shape stays only because death (`useWhileDead = false`) can still interrupt it.
                    if not lib.progressCircle({
                        duration = 2000,
                        position = 'bottom',
                        label = 'Pegando...',
                        useWhileDead = false,
                        canCancel = false,
                        disable = { move = true, car = true, combat = true },
                        anim = { dict = 'random@shop_robbery', clip = 'robbery_action_b' },
                    }) then
                        return
                    end

                    local result = lib.callback.await('srv_robbery:server:lootHousePoint', false, house.key, pointIndex)

                    if not result or not result.ok then
                        local reasons = {
                            far = 'Chegue mais perto.',
                            empty = 'Já foi levado daqui recentemente.',
                            noroom = 'Você não tem espaço no inventário.',
                        }
                        notify((result and reasons[result.reason]) or 'Não foi possível pegar.', 'error')
                        return
                    end

                    notify(('Você pegou: %s.'):format(label), 'success')
                end)
        end

        ::continue::
    end
end)
