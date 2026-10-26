-- Servidor: player-to-player actions, reachable two ways - the ALT target menu and an `[E]` prompt
-- on the nearest person. Every entry either routes to an existing server event that already takes a
-- target id, or to this resource's own callbacks for the two actions nothing had implemented.
-- See config.lua for the entry-point split, and ADR-101/ADR-112 for the authorisation holes found
-- while wiring it and for why `[E]` was added alongside the target key.

local INTERACT_CONTROL = 38 -- Servidor: this project's own [E] convention (see srv_robbery, srv_jobs)

local function notify(description, notifyType)
    lib.notify({ title = 'Interação', description = description, type = notifyType or 'inform' })
end

--- The player the option was used on, as a server id.
---@param data table ox_target passes the entity it resolved
---@return number?
local function targetServerId(data)
    local ped = data and data.entity
    if not ped or not DoesEntityExist(ped) then return nil end

    local player = NetworkGetPlayerIndexFromPed(ped)
    if player == -1 then return nil end

    return GetPlayerServerId(player)
end

--- Servidor: `job.type` rather than `job.name`, so every police force counts - the project has three
--- (`police`, `bcso`, `sasp`) and naming one would silently exclude the others. `onduty` matters as
--- much as the job: an officer who has clocked off is a citizen.
---@return boolean
local function isPolice()
    local job = QBX.PlayerData?.job
    return job ~= nil and job.type == 'leo' and job.onduty == true
end

---@return boolean
local function isMedic()
    local job = QBX.PlayerData?.job
    return job ~= nil and job.type == 'ems' and job.onduty == true
end

---@return boolean
local function hasHandcuffs()
    local counts = exports.ox_inventory:Search('count', Config.handcuffItems)
    for _, count in pairs(counts) do
        if count > 0 then return true end
    end
    return false
end

---@return boolean
local function hasLockpick()
    local counts = exports.ox_inventory:Search('count', 'lockpick')
    return (counts and counts.lockpick or 0) > 0
end

--- Money handed over, and the receipt on the other side.
---@param targetSrc number
local function giveMoney(targetSrc)
    local input = lib.inputDialog('Dar dinheiro', {
        { type = 'number', label = 'Quanto', icon = 'hashtag', description = 'Em dinheiro vivo.',
            default = 100, min = 1, max = Config.maxGiveAmount, required = true },
    })
    if not input then return end

    local result = lib.callback.await('srv_interactions:server:giveMoney', false, targetSrc, input[1])

    if not result or not result.ok then
        local reasons = {
            far = 'A pessoa se afastou.',
            nomoney = 'Você não tem esse valor em dinheiro.',
        }
        notify((result and reasons[result.reason]) or 'Não foi possível entregar.', 'error')
        return
    end

    notify(('Entregou $%s.'):format(result.amount), 'success')
end

RegisterNetEvent('srv_interactions:client:received', function(fromName, amount)
    notify(('%s te entregou $%s.'):format(fromName, amount), 'success')
end)

--- Servidor: shown as a read-only context menu rather than a notification, because an ID is three
--- fields and a notification is one line. Same card shape every other menu in this project uses.
---@param targetSrc number
local function showIdentity(targetSrc)
    local id = lib.callback.await('srv_interactions:server:showId', false, targetSrc)
    if not id then
        notify('Não foi possível ver a identidade.', 'error')
        return
    end

    lib.registerContext({
        id = 'srv_interactions_identity',
        title = 'Identidade',
        options = {
            { title = 'Nome', description = id.name, icon = 'user', readOnly = true },
            { title = 'Nascimento', description = id.birthdate, icon = 'cake-candles', readOnly = true },
            { title = 'Nacionalidade', description = id.nationality, icon = 'flag', readOnly = true },
        },
    })
    lib.showContext('srv_interactions_identity')
end

---@param targetSrc number
local function jailPlayer(targetSrc)
    local input = lib.inputDialog('Prender', {
        { type = 'number', label = 'Meses', icon = 'hashtag', default = 10, min = 1, required = true },
    })
    if not input then return end

    TriggerServerEvent('police:server:JailPlayer', targetSrc, input[1])
end

---@param targetSrc number
local function clearWanted(targetSrc)
    local result = lib.callback.await('srv_wanted:server:policeClear', false, targetSrc)

    if not result or not result.ok then
        notify((result and result.reason == 'notwanted') and 'Essa pessoa não está procurada.'
            or 'Não foi possível remover.', 'error')
        return
    end

    notify('Marca de procurado removida.', 'success')
end

-- Servidor: every action, defined exactly once, because there are now TWO ways to reach them - the
-- ALT target menu and the `[E]` prompt further down - and two copies of this list would drift the
-- first time one gained an option. Both entry points are built from this table and nothing else.
--
-- `icon` is the bare Font Awesome name: the `[E]` context menu takes it as-is (the shape every
-- ox_lib menu in this project uses, e.g. srv_robbery's `sack-dollar`), and the target registration
-- below prefixes `fas fa-` for ox_target's own full-class form. One name, two renderings, rather
-- than two icon fields that can disagree.
--
-- `canInteract` is DISPLAY ONLY, stated here as it is in config.lua and in ADR-101: it decides what
-- the menu offers, never what the server allows. Every action is re-checked by whichever resource
-- owns it.
local ACTIONS = {
    {
        name = 'cuff',
        icon = 'handcuffs',
        label = 'Algemar / Desalgemar',
        -- Servidor: anyone carrying handcuffs, by request - not police-only.
        canInteract = hasHandcuffs,
        run = function(targetSrc) TriggerServerEvent('police:server:CuffPlayer', targetSrc, false) end,
    },
    {
        -- Servidor: `rope` releases for anyone (the normal `Algemar / Desalgemar` action above
        -- already allows that); `handcuffs` only releases for whoever put them on - everyone else
        -- needs this. No client gate on whether the target is actually handcuffed by someone else,
        -- same reasoning `putin`/`takeout` below already state: that flag lives in metadata this
        -- client cannot see for another player. `qbx_police`'s own event refuses (with a message)
        -- if there is nothing to pick. See ADR-120.
        name = 'pickcuffs',
        icon = 'unlock-keyhole',
        label = 'Arrombar Algema',
        canInteract = hasLockpick,
        run = function(targetSrc) TriggerServerEvent('police:server:PickCuffs', targetSrc) end,
    },
    {
        name = 'escort',
        icon = 'people-pulling',
        label = 'Escoltar',
        run = function(targetSrc) TriggerServerEvent('police:server:EscortPlayer', targetSrc) end,
    },
    {
        name = 'putin',
        icon = 'car-side',
        label = 'Colocar no veículo',
        -- Servidor: no client gate, on purpose. The rule - only someone cuffed, dead or downed - is
        -- already enforced inside qbx_police's own event, which refuses with a message. A second
        -- check here would have to read a cuffed flag the client does not have for other players:
        -- it lives in their PlayerData metadata, not in a replicated statebag.
        run = function(targetSrc) TriggerServerEvent('police:server:PutPlayerInVehicle', targetSrc) end,
    },
    {
        name = 'takeout',
        icon = 'door-open',
        label = 'Tirar do veículo',
        run = function(targetSrc) TriggerServerEvent('police:server:SetPlayerOutVehicle', targetSrc) end,
    },
    -- Servidor: moved here out of the radial menu, which had an entire "Interação" branch of
    -- things done TO another player. The radial is reached by pressing a key on yourself and is
    -- now only about yourself; anything aimed at someone else belongs on the prompt that",
    -- appears when you are standing in front of them. See ADR-169.
    {
        name = 'kidnap',
        icon = 'user-group',
        label = 'Sequestrar',
        run = function(targetSrc)
            TriggerEvent('police:client:KidnapPlayer', targetSrc)
        end,
    },
    {
        name = 'trunk',
        icon = 'car-rear',
        label = 'Colocar no porta-malas',
        run = function()
            ExecuteCommand('putintrunk')
        end,
    },
    {
        name = 'search',
        icon = 'magnifying-glass',
        label = 'Revistar',
        canInteract = isPolice,
        run = function(targetSrc) TriggerServerEvent('police:server:SearchPlayer', targetSrc) end,
    },
    {
        name = 'seize',
        icon = 'sack-dollar',
        label = 'Apreender dinheiro',
        canInteract = isPolice,
        run = function(targetSrc) TriggerServerEvent('police:server:SeizeCash', targetSrc) end,
    },
    {
        name = 'tracker',
        icon = 'location-crosshairs',
        label = 'Tornozeleira',
        canInteract = isPolice,
        run = function(targetSrc) TriggerServerEvent('police:server:SetTracker', targetSrc) end,
    },
    {
        name = 'jail',
        icon = 'lock',
        label = 'Prender',
        canInteract = isPolice,
        run = jailPlayer,
    },
    {
        -- Servidor: the only way to clear `srv_wanted`'s mark besides waiting it out or the
        -- suspect's own escape-valve item - an arrest is what the mark exists to lead to, so this
        -- belongs on the same menu as `Prender` rather than a separate command.
        name = 'clearwanted',
        icon = 'user-check',
        label = 'Remover Procurado',
        canInteract = isPolice,
        run = clearWanted,
    },
    {
        name = 'revive',
        icon = 'heart-pulse',
        label = 'Reanimar',
        canInteract = isMedic,
        run = function(targetSrc) TriggerServerEvent('hospital:server:RevivePlayer', targetSrc) end,
    },
    {
        name = 'treat',
        icon = 'bandage',
        label = 'Tratar ferimentos',
        canInteract = isMedic,

        -- Servidor: was hospital:server:TreatWounds, which healed for free and from anywhere.
        -- Treatment is now a paid service performed on a hospital bed - see srv_medic - and
        -- leaving the old free one beside it would make the paid one pointless.
        run = function(targetSrc) TriggerEvent('srv_medic:client:offerTreatment', targetSrc) end,
    },
    {
        name = 'rob',
        icon = 'gun',
        label = 'Roubar',
        -- Servidor: anyone, by request - but the server refuses unless a weapon is actually drawn
        -- (ADR-101), so this gate only keeps the option out of an unarmed player's menu.
        canInteract = function() return GetSelectedPedWeapon(cache.ped) ~= `weapon_unarmed` end,
        run = function(targetSrc) TriggerServerEvent('police:server:RobPlayer', targetSrc) end,
    },
    {
        name = 'give',
        icon = 'hand-holding-dollar',
        label = 'Dar dinheiro',
        run = giveMoney,
    },
    {
        name = 'identity',
        icon = 'id-card',
        label = 'Ver identidade',
        run = showIdentity,
    },
}

-- Servidor: one registration covering every option, because ox_target merges what it is given and
-- `canInteract` is what decides which appear. Built from `ACTIONS` above rather than spelled out
-- again, so the target menu and the `[E]` menu can never offer different things.
CreateThread(function()
    local options = {}

    for i = 1, #ACTIONS do
        local action = ACTIONS[i]

        options[i] = {
            name = ('srv_interactions_%s'):format(action.name),
            icon = ('fas fa-%s'):format(action.icon),
            label = action.label,
            distance = Config.maxDistance,
            canInteract = action.canInteract,
            onSelect = function(data)
                local targetSrc = targetServerId(data)
                if not targetSrc then return end
                action.run(targetSrc)
            end,
        }
    end

    exports.ox_target:addGlobalPlayer(options)
end)

-- Servidor: the `[E]` entry point, added on top of the target key rather than replacing it - see
-- ADR-112, which supersedes ADR-101's "a PERSON is never `[E]`" split and records why the original
-- reasoning does not actually bite here.
--
-- The menu is rebuilt on every open, never cached: `canInteract` reads live state (duty, drawn
-- weapon, handcuffs in inventory) and a cached menu would offer yesterday's answer.
---@param targetPed number
local function openInteractionMenu(targetPed)
    local player = NetworkGetPlayerIndexFromPed(targetPed)
    if player == -1 then return end

    local targetSrc = GetPlayerServerId(player)
    local options = {}

    for i = 1, #ACTIONS do
        local action = ACTIONS[i]

        if not action.canInteract or action.canInteract() then
            options[#options + 1] = {
                title = action.label,
                icon = action.icon,
                onSelect = function() action.run(targetSrc) end,
            }
        end
    end

    if #options == 0 then
        notify('Nada a fazer com essa pessoa agora.')
        return
    end

    lib.registerContext({ id = 'srv_interactions_menu', title = 'Interagir', options = options })
    lib.showContext('srv_interactions_menu')
end

--- Servidor: the nearest player this prompt would act on, or nil. Skipped entirely while the local
--- player is in a vehicle - `[E]` belongs to driving-adjacent prompts there, and every action here
--- is an on-foot one. A target sitting in a vehicle is still valid (that is what `Tirar do veículo`
--- is for); only the *acting* player's own vehicle state gates it.
---@return number? ped
local function findPromptablePlayer()
    if cache.vehicle then return end

    local _, ped = lib.getClosestPlayer(GetEntityCoords(cache.ped), Config.maxDistance, false)
    return ped
end

-- Servidor: same two-speed shape `srv_vehiclelocks` uses, and for the same two reasons -
-- `IsControlJustPressed` is only true on the frame the key went down, so it has to be polled every
-- frame, while sweeping the player list every frame is wasteful. There is no ox_lib zone to hang
-- this off, because the thing being interacted with moves.
local RESCAN_INTERVAL_MS = 200

CreateThread(function()
    while true do
        local ped = findPromptablePlayer()

        -- Servidor: places claimed `[E]` first (ADR-101), so a person never steals a prompt that a
        -- counter, farm or vehicle door is already showing - if something else owns the text UI,
        -- this stands down entirely rather than overwriting it, and does not answer `[E]` either.
        -- That resolves the one case ADR-101 was actually worried about - two prompts on one key in
        -- one spot - in favour of the fixed thing rather than the moving one.
        if ped and lib.isTextUIOpen() then ped = nil end

        if not ped then
            Wait(RESCAN_INTERVAL_MS)
        else
            lib.showTextUI('[E] Interagir.')

            local nextScan = GetGameTimer() + RESCAN_INTERVAL_MS

            while true do
                Wait(0)

                -- Servidor: the disc this project draws for a PERSON, the same marker and colour the
                -- handcuff vendor further down uses - the visible "there is someone here" cue the
                -- `[E]` prompt on its own does not give. Redrawn per frame from the target's live
                -- position, since unlike every other marker in this project the thing under it moves.
                local targetCoords = GetEntityCoords(ped)
                DrawMarker(1, targetCoords.x, targetCoords.y, targetCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0.8, 0.8, 0.3, 20, 246, 12, 120, false, false, 0, false, nil, nil, false)

                if IsControlJustPressed(0, INTERACT_CONTROL) then
                    lib.hideTextUI()
                    openInteractionMenu(ped)

                    -- Servidor: hold the loop until the menu is gone. Without this the outer loop
                    -- immediately re-raises the `[E]` prompt underneath the open menu, and every
                    -- action that opens a dialog of its own (Prender, Dar dinheiro, Ver identidade)
                    -- would be sitting on top of a prompt telling the player to press `[E]` again.
                    while lib.getOpenContextMenu() do Wait(100) end

                    break
                end

                if GetGameTimer() >= nextScan then
                    if findPromptablePlayer() ~= ped then
                        lib.hideTextUI()
                        break
                    end

                    nextScan = GetGameTimer() + RESCAN_INTERVAL_MS
                end
            end
        end
    end
end)

-- Servidor: the police ped standing at the handcuff vendor. It lives here rather than in the shop
-- config because `ox_inventory` only spawns a ped on the target-mode path, and this server runs
-- `inventory:target false` - the `locations` path it actually uses draws a marker and a prompt and
-- nothing else. So the shop itself is `PoliceSupply` in `data/shops.lua`, and this is only the
-- person standing at it.
--
-- It belongs to this resource because handcuffs exist for this menu: `Config.handcuffItems` is read
-- three lines from here, and the item had no seller at all until the cuff option needed one.
-- See ADR-101.
local vendorPed
local vendor = Config.handcuffVendor

if vendor then
    CreateThread(function()
        lib.requestModel(Config.handcuffVendorPed, 10000)
        vendorPed = CreatePed(0, Config.handcuffVendorPed, vendor.x, vendor.y, vendor.z - 1.0, vendor.w, false, false)
        SetModelAsNoLongerNeeded(Config.handcuffVendorPed)
        SetEntityHeading(vendorPed, vendor.w)
        FreezeEntityPosition(vendorPed, true)
        SetEntityInvincible(vendorPed, true)
        SetBlockingOfNonTemporaryEvents(vendorPed, true)
        TaskStartScenarioInPlace(vendorPed, 'WORLD_HUMAN_GUARD_STAND', 0, true)
    end)

    -- Servidor: the point itself, because `PoliceSupply` in ox_inventory/data/shops.lua carries
    -- `srvExternalInteraction = 'srv_interactions'` - so ox_inventory contributes its blip and
    -- nothing else, and this draws the disc the project uses for a PERSON rather than the cone it
    -- draws for a shop counter. Opening the shop is the same export the robbery menu calls.
    local zone

    CreateThread(function()
        zone = lib.zones.sphere({
            coords = vendor.xyz,
            radius = Config.maxDistance,
            debug = false,
            onEnter = function()
                lib.showTextUI('[E] Equipamento Policial.')
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function()
                DrawMarker(1, vendor.x, vendor.y, vendor.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5,
                    20, 246, 12, 200, false, false, 0, false, nil, nil, false)

                if not IsControlJustPressed(0, 38) then return end

                lib.hideTextUI()
                exports.ox_inventory:openInventory('shop', { id = 1, type = 'PoliceSupply' })
            end,
        })
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= cache.resource then return end
        if vendorPed then exports.srv_lib:DeleteLocalEntity(vendorPed) end
        if zone then zone:remove() end
    end)
end
