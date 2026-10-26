-- Servidor: client-side display only - every action below is re-validated server-side (server.lua).
-- Mirrors the drug farms' own client.lua structure (`setupInteractionZone`, the ready-prompt style,
-- the refresh cadence) with the accelerator/retail-split machinery removed - see config.lua for why.

local INTERACT_CONTROL = 38

local READY_PROMPT_STYLE = {
    backgroundColor = 'rgba(62, 207, 126, 0.18)',
    border = '1px solid #3ecf7e',
}

local function notify(description, notifyType)
    lib.notify({ title = 'Oficina', description = description, type = notifyType or 'inform' })
end

---@param count number
---@param one string
---@param many string
---@return string
local function counted(count, one, many)
    return ('%s %s'):format(count, count == 1 and one or many)
end

---@param title string
---@param description string
---@param max number?
---@return number?
local function askQuantity(title, description, max)
    local input = lib.inputDialog(title, {
        { type = 'number', label = 'Quantidade', description = description, icon = 'hashtag',
            default = 1, min = 1, max = max, required = true },
    })
    if not input then return nil end

    return input[1]
end

---@type table<string, {citizenid: string, startedAt: number, ready: boolean, secondsLeft: number, fraction: number}>
local batches = {}

local function refreshBatches()
    batches = lib.callback.await('srv_gunlab:server:getBatches', false) or {}
end

CreateThread(function()
    refreshBatches()

    while true do
        Wait(60000)
        refreshBatches()
    end
end)

---@param seconds number
---@return string
local function formatDuration(seconds)
    local minutes = math.ceil(seconds / 60)
    if minutes < 60 then return ('%s min'):format(minutes) end
    return ('%sh%02d'):format(minutes // 60, minutes % 60)
end

--- Same two-tier marker+[E] zone shape every farm in this project uses. Duplicated rather than
--- shared - FXServer gives each resource its own script environment with no way to import a local
--- from another one.
local function setupInteractionZone(coords, radius, innerRadius, getPrompt, onInteract)
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
                    local prompt, highlight = getPrompt()
                    if prompt then
                        lib.showTextUI(prompt, highlight and { style = READY_PROMPT_STYLE } or nil)
                    end
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
                DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5,
                    20, 246, 12, 200, false, false, 0, false, nil, nil, false)
            end
        end,
    })
end

local function process(stationKey)
    -- Servidor: same verified `anim@narcotics@trash`/`drop_front` the drug farms already use for
    -- this exact shape of action - not a new guess. Thematically a crouch-and-place motion, close
    -- enough for "feeding scrap into a bench" the same way it already stands in for planting.
    if not lib.progressCircle({
        duration = Config.processDuration,
        position = 'bottom',
        label = 'Trabalhando a peça...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'anim@narcotics@trash', clip = 'drop_front' },
    }) then
        return
    end

    local result = lib.callback.await('srv_gunlab:server:process', false, stationKey)

    if not result or not result.ok then
        local reasons = {
            notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
            occupied = 'Essa estação já está ocupada.',
            far = 'Chegue mais perto da estação.',
            nomaterial = 'Você não tem sucata suficiente.',
        }
        notify((result and reasons[result.reason]) or 'Não foi possível trabalhar a peça.', 'error')
        return
    end

    notify('Peça em produção. Volte em alguns minutos.', 'success')
    refreshBatches()
end

local function collect(stationKey)
    if not lib.progressCircle({
        duration = 2000,
        position = 'bottom',
        label = 'Coletando...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'anim@narcotics@trash', clip = 'drop_front' },
    }) then
        return
    end

    local result = lib.callback.await('srv_gunlab:server:collect', false, stationKey)

    if not result or not result.ok then
        local reasons = {
            notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
            empty = 'Essa estação está vazia.',
            far = 'Chegue mais perto da estação.',
            notready = 'Ainda não está pronto.',
        }
        notify((result and reasons[result.reason]) or 'Não foi possível coletar.', 'error')
        return
    end

    notify(('Coletou %s.'):format(counted(result.amount, 'peça de arma', 'peças de arma')), 'success')
    refreshBatches()
end

CreateThread(function()
    for i = 1, #Config.stations do
        local station = Config.stations[i]

        setupInteractionZone(station.coords.xyz, Config.stationDistance + 0.5, Config.stationDistance, function()
            local batch = batches[station.key]

            if not batch then return '[E] Trabalhar peça (4x sucata de metal).' end
            if batch.ready then return '[E] Coletar.', true end

            return ('Trabalhando... faltam %s.'):format(formatDuration(batch.secondsLeft))
        end, function()
            local batch = batches[station.key]

            if not batch then
                process(station.key)
                return
            end

            collect(station.key)
        end)
    end
end)

-- Same illegal-point convention as every other farm: `srv_lib`'s `CreateGangBlip` draws a coloured
-- circle in the owning gang's colour, named after the colour (ADR-134, ADR-137).


-- Servidor: the skull is shared, the COLOUR and NAME are the owning gang's - so the map shows whose
-- territory a site is without showing what is made there. Reverses the original
-- "Desconhecido everywhere" rule by request; ADR-133 records the trade-off that reverses.
--
-- Resolved HERE rather than at file scope: `srv_lib` is a separate resource, and nothing
-- guarantees it has started when this file is parsed. Inside the function the call is made long
-- after every resource is up. Falls back to the old grey / "Desconhecido" when a site has no
-- `ownerGang`.
local function addIllegalBlip(coords)
    exports.srv_lib:CreateGangBlip(coords, Config.ownerGang)
end

-- Servidor: the Gunrunning Bunker has no real walkable door of its own - same fix as
-- `srv_weedfarm`'s own ADR-059. Standing at the real street coordinate and pressing [E]
-- teleports straight to the real interior coordinate, and vice versa - plain `SetEntityCoords`,
-- no loading screen or fade, since the interior is already loaded (`bob74_ipl` keeps its IPL
-- active at all times).
CreateThread(function()
    addIllegalBlip(Config.entrance.outside.xyz)

    setupInteractionZone(Config.entrance.outside.xyz, Config.entrance.distance + 5.0, Config.entrance.distance,
        function() return '[E] Entrar no bunker.' end,
        function()
            -- Servidor: gang gate on the way IN only - never on the way out, or a player whose gang
            -- changed while inside would be sealed in. Fast path for UX; the server re-checks every
            -- action in here regardless (ADR-125).
            if not exports.srv_lib:IsInGang(Config.ownerGang) then
                notify(exports.srv_lib:GangDeniedMessage(Config.ownerGang), 'error')
                return
            end

            SetEntityCoords(cache.ped, Config.entrance.inside.x, Config.entrance.inside.y,
                Config.entrance.inside.z, false, false, false, false)
            SetEntityHeading(cache.ped, Config.entrance.inside.w)
            refreshBatches()
        end)

    setupInteractionZone(Config.entrance.inside.xyz, Config.entrance.distance + 5.0, Config.entrance.distance,
        function() return '[E] Sair do bunker.' end,
        function()
            SetEntityCoords(cache.ped, Config.entrance.outside.x, Config.entrance.outside.y,
                Config.entrance.outside.z, false, false, false, false)
            SetEntityHeading(cache.ped, Config.entrance.outside.w)
        end)
end)

local materialVendorPed
local vendor = Config.vendor

if vendor then
    CreateThread(function()
        lib.requestModel(Config.vendorPed, 10000)
        materialVendorPed = CreatePed(0, Config.vendorPed, vendor.x, vendor.y, vendor.z - 1.0, vendor.w, false, false)
        SetModelAsNoLongerNeeded(Config.vendorPed)
        SetEntityHeading(materialVendorPed, vendor.w)
        FreezeEntityPosition(materialVendorPed, true)
        SetEntityInvincible(materialVendorPed, true)
        SetBlockingOfNonTemporaryEvents(materialVendorPed, true)
        TaskStartScenarioInPlace(materialVendorPed, 'WORLD_HUMAN_HANG_OUT_STREET', 0, true)
    end)

    -- Servidor: a pin for the same reason as the buyer above (ADR-154).

    exports.srv_lib:CreateGangPointBlip(vendor.xyz, Config.ownerGang, 'Fornecedor')

    setupInteractionZone(vendor.xyz, Config.vendorDistance + 5.0, Config.vendorDistance, function()
        return '[E] Comprar sucata de metal.'
    end, function()
        local amount = askQuantity('Comprar sucata de metal',
            ('$%s a unidade - máximo de %s por compra.'):format(Config.materialPrice,
                Config.materialPurchaseCeiling),
            Config.materialPurchaseCeiling)
        if not amount then return end

        local result = lib.callback.await('srv_gunlab:server:buyMaterial', false, amount)

        if not result or not result.ok then
            local reasons = {
                notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
                far = 'Chegue mais perto do vendedor.',
                nomoney = 'Você não tem dinheiro suficiente.',
                toomany = ('Máximo de %s por compra.'):format(Config.materialPurchaseCeiling),
            }
            notify((result and reasons[result.reason]) or 'Não foi possível comprar.', 'error')
            return
        end

        notify(('Comprou %s por $%s.'):format(counted(result.count, 'unidade', 'unidades'), result.paid), 'success')
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= cache.resource then return end
        if materialVendorPed then exports.srv_lib:DeleteLocalEntity(materialVendorPed) end
    end)
end
