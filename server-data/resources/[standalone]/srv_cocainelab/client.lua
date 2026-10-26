-- Servidor: client-side display only - every action below is re-validated server-side
-- (server.lua), this file just decides what prompt to show and asks for confirmation. Mirrors
-- srv_weedfarm's client.lua structure, but there is no growth-stage prop to swap here (see
-- config.lua) - a station's [E] prompt text is the only feedback a player gets.

local INTERACT_CONTROL = 38

-- Same dark panel look as the rest of the HUD, tinted with gfx.green - used to highlight a
-- ready-to-collect prompt without touching the shared textui component. Mirrors srv_weedfarm's
-- own `READY_PROMPT_STYLE` exactly.
local READY_PROMPT_STYLE = {
    backgroundColor = 'rgba(62, 207, 126, 0.18)',
    border = '1px solid #3ecf7e',
}

local function notify(description, notifyType)
    lib.notify({ title = 'Laboratório', description = description, type = notifyType or 'inform' })
end

--- Servidor: "3x" is shorthand; "3 unidades" is language. Requested across every message these
--- resources show, so a count and its noun are always built together rather than glued to an "x".
--- Both plural forms are passed in rather than derived - Portuguese plurals are irregular enough
--- (unidade/unidades, aplicação/aplicações, porção/porções) that deriving them would be wrong more
--- often than right. See ADR-088.
---@param count number
---@param one string singular form, used when count is exactly 1
---@param many string plural form
---@return string
local function counted(count, one, many)
    return ('%s %s'):format(count, count == 1 and one or many)
end

--- Same standard quantity-input shape as srv_weedfarm's own `askQuantity` - one number field,
--- minimum 1, required.
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

---@type table<string, {citizenid: string, startedAt: number, ready: boolean, secondsLeft: number, fraction: number, boosts: number, boostsLeft: number}>
local batches = {}

local function refreshBatches()
    batches = lib.callback.await('srv_cocainelab:server:getBatches', false) or {}
end

--- Refreshed once on start, again right after this client's own process/collect, and every 60s
--- otherwise - mirrors srv_weedfarm's own `refreshPlants` cadence exactly.
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

--- Same two-tier marker+[E] zone shape as srv_weedfarm's own `setupInteractionZone` - duplicated
--- rather than shared, since FXServer gives each resource its own script environment with no way
--- to import a local from another one. `getPrompt` may return a second value, `highlight`, to
--- draw the prompt in `READY_PROMPT_STYLE` instead of the default panel look.
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
    -- Servidor: same verified animation srv_weedfarm's own planting uses
    -- (`anim@narcotics@trash`/`drop_front`, already confirmed present and used elsewhere in this
    -- exact codebase - qbx_police's narcotics-object placement) - reused rather than guessing a
    -- new dict/clip for "processing", per CLAUDE.md's rule against guessing asset names. Mirrors
    -- srv_weedfarm's `plantDuration` progress circle exactly.
    if not lib.progressCircle({
        duration = Config.processDuration,
        position = 'bottom',
        label = 'Processando...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'anim@narcotics@trash', clip = 'drop_front' },
    }) then
        return
    end

    local result = lib.callback.await('srv_cocainelab:server:process', false, stationKey)

    if not result or not result.ok then
        local reasons = {
            notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
            occupied = 'Essa estação já está ocupada.',
            far = 'Chegue mais perto da estação.',
            noleaf = 'Você não tem folha de coca.',
        }
        notify((result and reasons[result.reason]) or 'Não foi possível processar.', 'error')
        return
    end

    notify('Processamento iniciado. Volte em algumas horas.', 'success')
    refreshBatches()
end

local function collect(stationKey)
    -- Servidor: same verified `anim@narcotics@trash`/`drop_front` processing and accelerating
    -- already use in this file - not a new guess. Collecting had no animation of its own until
    -- requested; 2000ms matches every other "quick grab" in this project.
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

    local result = lib.callback.await('srv_cocainelab:server:collect', false, stationKey)

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

    notify(('Coletou %s de pasta de cocaína.'):format(counted(result.amount, 'unidade', 'unidades')), 'success')
    refreshBatches()
end

--- Applying the accelerator to a running batch. Deliberately a plain [E] rather than a context
--- menu: there is exactly one thing to do here and one item that does it, so a menu with a
--- single entry would only add a click. Mirrors srv_weedfarm's own `fertilize`.
---@param stationKey string
local function accelerate(stationKey)
    -- Servidor: the same verified `anim@narcotics@trash`/`drop_front` already used by processing
    -- above - not a new, unverified animation guess.
    if not lib.progressCircle({
        duration = Config.boostDuration,
        position = 'bottom',
        label = ('Aplicando %s...'):format(Config.boostLabel),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'anim@narcotics@trash', clip = 'drop_front' },
    }) then
        return
    end

    local result = lib.callback.await('srv_cocainelab:server:boost', false, stationKey)

    if not result or not result.ok then
        local reasons = {
            notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
            empty = 'Essa estação está vazia.',
            far = 'Chegue mais perto da estação.',
            ready = 'Esse lote já está pronto.',
            maxed = 'Esse lote já recebeu tudo o que aguenta.',
            noitem = ('Você não tem %s.'):format(Config.boostLabel),
        }
        notify((result and reasons[result.reason]) or 'Não foi possível acelerar.', 'error')
        return
    end

    if result.ready then
        notify('Acelerado - o lote ficou pronto.', 'success')
    else
        notify(('Acelerado - faltam %s. Restam %s nesse lote.'):format(
            formatDuration(result.secondsLeft), counted(result.boostsLeft, 'aplicação', 'aplicações')), 'success')
    end

    refreshBatches()
end

CreateThread(function()
    for i = 1, #Config.stations do
        local station = Config.stations[i]

        setupInteractionZone(station.coords.xyz, Config.stationDistance + 0.5, Config.stationDistance, function()
            local batch = batches[station.key]

            if not batch then return '[E] Processar folha de coca.' end

            -- Servidor: collecting is open to anyone at the station, not just whoever started it -
            -- same open-access rule as srv_weedfarm's harvest (ADR-057).
            if batch.ready then return '[E] Coletar.', true end
            -- Servidor: while the batch is still running, [E] applies the accelerator - but only
            -- while this batch still has applications left, otherwise the prompt goes back to
            -- being a plain read-out with nothing to press. The server enforces the same cap.
            if batch.boostsLeft > 0 then
                return ('[E] Aplicar %s - faltam %s.'):format(Config.boostLabel, formatDuration(batch.secondsLeft))
            end

            return ('Processando... faltam %s.'):format(formatDuration(batch.secondsLeft))
        end, function()
            local batch = batches[station.key]

            if not batch then
                process(station.key)
                return
            end

            if not batch.ready then
                accelerate(station.key)
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

-- Servidor: the `[E]` teleport pair, matching the other five sites (ADR-059). This site used to
-- have only a blip here, on the belief that its interior had a real walkable door; it did not -
-- what looked like a door was an ungated teleport shipped by `qbx_smallresources/qbx_teleports`,
-- which let anyone at all walk into the Cartel's lab. That teleport is deleted and this replaces
-- it. See ADR-153.
CreateThread(function()
    addIllegalBlip(Config.entrance.outside.xyz)

    setupInteractionZone(Config.entrance.outside.xyz, Config.entrance.distance + 5.0, Config.entrance.distance,
        function() return '[E] Entrar no laboratório.' end,
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
        end)

    setupInteractionZone(Config.entrance.inside.xyz, Config.entrance.distance + 5.0, Config.entrance.distance,
        function() return '[E] Sair do laboratório.' end,
        function()
            SetEntityCoords(cache.ped, Config.entrance.outside.x, Config.entrance.outside.y,
                Config.entrance.outside.z, false, false, false, false)
            SetEntityHeading(cache.ped, Config.entrance.outside.w)
        end)
end)

local dealerPed
local dealer = Config.dealer

-- Servidor: same "not playable until mapped" guard as srv_weedfarm's own dealer - starts up only
-- once a real coordinate exists, rather than crashing on a nil vec4.
if dealer then
    CreateThread(function()
        lib.requestModel(Config.dealerPed, 10000)
        dealerPed = CreatePed(0, Config.dealerPed, dealer.x, dealer.y, dealer.z - 1.0, dealer.w, false, false)
        SetModelAsNoLongerNeeded(Config.dealerPed)
        SetEntityHeading(dealerPed, dealer.w)
        FreezeEntityPosition(dealerPed, true)
        SetEntityInvincible(dealerPed, true)
        SetBlockingOfNonTemporaryEvents(dealerPed, true)
        TaskStartScenarioInPlace(dealerPed, 'WORLD_HUMAN_HANG_OUT_STREET', 0, true)
    end)

    -- Servidor: a PIN, not an area circle. A buyer is a person you drive to, not ground the gang

    -- holds - drawing it the same as a territory is what put five identical circles of one colour

    -- across the whole map. Named for the role, never the product (ADR-133). See ADR-154.

    exports.srv_lib:CreateGangPointBlip(dealer.xyz, Config.ownerGang, 'Comprador')

    --- Selling bricks into ONE retail form. The form is the whole point of the choice: a brick
    --- becomes ten units of whichever the seller picked, and each form has its own daily brick
    --- allowance - so three bricks can all become the consumable without touching that day's resale
    --- allowance. Re-validated server-side. See ADR-089.
    ---@param form 'bag'|'consumer'
    ---@param label string what the bricks will turn into, for the dialog and the confirmation
    ---@param bricksLeft number bricks of THIS form the player may still convert today
    local function sellBricks(form, label, bricksLeft)
        if bricksLeft <= 0 then
            notify(('Você já converteu todos os tijolos em %s que podia hoje.'):format(label), 'error')
            return
        end

        local amount = askQuantity(('Vender tijolos para virar %s'):format(label),
            ('$%s por tijolo - vira %s - restam %s hoje.'):format(Config.brickPrice,
                counted(Config.bagsPerBrick, 'unidade', 'unidades'),
                counted(bricksLeft, 'tijolo', 'tijolos')),
            bricksLeft)
        if not amount then return end

        local result = lib.callback.await('srv_cocainelab:server:sell', false, amount, form)

        if not result or not result.ok then
            local reasons = {
                notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
                far = 'Chegue mais perto do traficante.',
                nobricks = 'Você não tem tijolos para vender.',
                notenough = 'Você não tem tijolos suficientes.',
                dailylimit = 'Isso passaria do seu limite de tijolos de hoje.',
            }
            notify((result and reasons[result.reason]) or 'Não foi possível vender.', 'error')
            return
        end

        notify(('Vendeu %s por $%s. Virou %s de %s.'):format(
            counted(result.count, 'tijolo', 'tijolos'), result.paid,
            counted(result.units, 'unidade', 'unidades'), label), 'success')
    end

    --- One retail purchase. Two independent limits apply and they mean different things: `available`
    --- is how much of that form the dealer has at all, `dailyLeft` is how much of it THIS player may
    --- still buy today. Both are re-checked server-side; the dialog just refuses to offer a number
    --- that either would reject. See ADR-090.
    ---@param item string
    ---@param one string
    ---@param many string
    ---@param price number
    ---@param available number units of this form in stock
    ---@param dailyLeft number units of this form this player may still buy today
    local function buyRetail(item, one, many, price, available, dailyLeft)
        if available <= 0 then
            notify(('O traficante não tem %s em estoque agora.'):format(many), 'error')
            return
        end

        if dailyLeft <= 0 then
            notify(('Você já comprou %s demais hoje.'):format(many), 'error')
            return
        end

        local amount = askQuantity(('Comprar %s'):format(many),
            ('$%s cada - %s em estoque - restam %s hoje.'):format(price,
                counted(available, 'unidade', 'unidades'), dailyLeft),
            math.min(available, dailyLeft))
        if not amount then return end

        local result = lib.callback.await('srv_cocainelab:server:buyRetail', false, item, amount)

        if not result or not result.ok then
            local reasons = {
                notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
                far = 'Chegue mais perto do traficante.',
                nostock = ('Sem %s suficientes em estoque agora.'):format(many),
                dailylimit = 'Isso passaria do seu limite de compras de hoje.',
                nomoney = 'Você não tem dinheiro suficiente.',
            }
            notify((result and reasons[result.reason]) or 'Não foi possível comprar.', 'error')
            return
        end

        notify(('Comprou %s por $%s. Restam %s hoje.'):format(
            counted(result.count, one, many), result.paid, result.dailyLeft), 'success')
    end

    setupInteractionZone(dealer.xyz, Config.dealerDistance + 5.0, Config.dealerDistance, function()
        return '[E] Negociar com o traficante.'
    end, function()
        local state = lib.callback.await('srv_cocainelab:server:getDealerState', false)
        local bagStock = state and state.bagStock or 0
        local consumerStock = state and state.consumerStock or 0
        local brickLimit = state and state.brickLimit or 0
        local bagBricksSold = state and state.bagBricksSold or 0
        local consumerBricksSold = state and state.consumerBricksSold or 0
        local bagBricksLeft = state and state.bagBricksLeft or 0
        local consumerBricksLeft = state and state.consumerBricksLeft or 0
        local buyLimit = state and state.buyLimit or 0
        local bagBought = state and state.bagBought or 0
        local consumerBought = state and state.consumerBought or 0
        local bagBuyLeft = state and state.bagBuyLeft or 0
        local consumerBuyLeft = state and state.consumerBuyLeft or 0

        --- Percentage of a limit already used, for a row's progress bar. Guarded against a zero
        --- limit rather than assuming one: both limits are config, and a typo of 0 would otherwise
        --- divide by zero on every menu open.
        ---@param used number
        ---@param limit number
        local function usedPercent(used, limit)
            if limit <= 0 then return 0 end
            return math.floor(used / limit * 100)
        end

        --- One quantity card, sized for half a row (`inline`, ADR-088). It reports that form's real
        --- stock and nothing else - the two per-player limits are shown on the rows that spend them
        --- (bricks in the sell submenu, units on the buy rows), so each number sits where its own
        --- decision is made. See ADR-090.
        ---@param icon string
        ---@param title string
        ---@param stock number
        local function quantityCard(icon, title, stock)
            return {
                title = title,
                description = stock > 0 and ('%s em estoque.'):format(counted(stock, 'unidade', 'unidades'))
                    or 'Sem estoque agora.',
                icon = icon,
                iconColor = stock > 0 and '#3ecf7e' or '#e03131',
                readOnly = true,
                inline = true,
            }
        end

        -- Servidor: selling opens a submenu rather than acting directly, because a brick sale is two
        -- decisions - how many, and into what. See ADR-089.
        lib.registerContext({
            id = 'srv_cocainelab_dealer_sell',
            title = 'Vender tijolos',
            description = 'Escolha no que os tijolos vão virar.',
            menu = 'srv_cocainelab_dealer',
            options = {
                {
                    title = 'Virar porções para revenda',
                    description = ('Restam %s hoje.'):format(counted(bagBricksLeft, 'tijolo', 'tijolos')),
                    icon = 'flask',
                    iconColor = bagBricksLeft > 0 and '#3ecf7e' or '#e03131',
                    progress = usedPercent(bagBricksSold, brickLimit),
                    disabled = bagBricksLeft <= 0,
                    onSelect = function() sellBricks('bag', 'porções', bagBricksLeft) end,
                    metadata = {
                        { label = 'Cada tijolo vira', value = counted(Config.bagsPerBrick, 'unidade', 'unidades') },
                        { label = 'Serve para', value = 'revender na rua' },
                        { label = 'Hoje', value = ('%s de %s tijolos'):format(bagBricksSold, brickLimit) },
                    },
                },
                {
                    title = ('Virar %s'):format(Config.consumerLabelPlural),
                    description = ('Restam %s hoje.'):format(counted(consumerBricksLeft, 'tijolo', 'tijolos')),
                    icon = 'snowflake',
                    iconColor = consumerBricksLeft > 0 and '#3ecf7e' or '#e03131',
                    progress = usedPercent(consumerBricksSold, brickLimit),
                    disabled = consumerBricksLeft <= 0,
                    onSelect = function()
                        sellBricks('consumer', Config.consumerLabelPlural, consumerBricksLeft)
                    end,
                    metadata = {
                        { label = 'Cada tijolo vira', value = counted(Config.bagsPerBrick, 'unidade', 'unidades') },
                        { label = 'Serve para', value = 'uso próprio' },
                        { label = 'Efeito ao usar', value = Config.consumerEffect },
                        { label = 'Hoje', value = ('%s de %s tijolos'):format(consumerBricksSold, brickLimit) },
                    },
                },
            },
        })

        lib.registerContext({
            id = 'srv_cocainelab_dealer',
            title = 'Traficante',
            options = {
                quantityCard('flask', 'Porção', bagStock),
                quantityCard('snowflake', Config.consumerCardLabel, consumerStock),
                {
                    title = 'Vender tijolos',
                    description = ('$%s por tijolo - você escolhe no que vira.'):format(Config.brickPrice),
                    icon = 'sack-dollar',
                    menu = 'srv_cocainelab_dealer_sell',
                },
                {
                    title = 'Comprar porções',
                    description = ('$%s cada - restam %s de %s hoje.'):format(Config.bagPrice, bagBuyLeft, buyLimit),
                    icon = 'flask',
                    iconColor = (bagStock > 0 and bagBuyLeft > 0) and '#3ecf7e' or '#e03131',
                    progress = usedPercent(bagBought, buyLimit),
                    disabled = bagStock <= 0 or bagBuyLeft <= 0,
                    onSelect = function()
                        buyRetail(Config.bagItem, 'porção', 'porções', Config.bagPrice,
                            bagStock, bagBuyLeft)
                    end,
                    metadata = {
                        { label = 'Preço', value = ('$%s cada'):format(Config.bagPrice) },
                        { label = 'Serve para', value = 'revender na rua' },
                        { label = 'Efeito ao usar', value = 'nenhum' },
                        { label = 'Em estoque', value = counted(bagStock, 'unidade', 'unidades') },
                        { label = 'Hoje', value = ('%s de %s unidades'):format(bagBought, buyLimit) },
                    },
                },
                {
                    title = ('Comprar %s'):format(Config.consumerLabelPlural),
                    description = ('$%s cada - restam %s de %s hoje.'):format(Config.consumerPrice,
                        consumerBuyLeft, buyLimit),
                    icon = 'snowflake',
                    iconColor = (consumerStock > 0 and consumerBuyLeft > 0) and '#3ecf7e' or '#e03131',
                    progress = usedPercent(consumerBought, buyLimit),
                    disabled = consumerStock <= 0 or consumerBuyLeft <= 0,
                    onSelect = function()
                        buyRetail(Config.consumerItem, Config.consumerLabel, Config.consumerLabelPlural,
                            Config.consumerPrice, consumerStock, consumerBuyLeft)
                    end,
                    metadata = {
                        { label = 'Preço', value = ('$%s cada'):format(Config.consumerPrice) },
                        { label = 'Serve para', value = 'uso próprio' },
                        { label = 'Efeito ao usar', value = Config.consumerEffect },
                        { label = 'Em estoque', value = counted(consumerStock, 'unidade', 'unidades') },
                        { label = 'Hoje', value = ('%s de %s unidades'):format(consumerBought, buyLimit) },
                    },
                },
            },
        })
        lib.showContext('srv_cocainelab_dealer')
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= cache.resource then return end
        if dealerPed then exports.srv_lib:DeleteLocalEntity(dealerPed) end
    end)
end

local leafVendorPed
local leafVendor = Config.leafVendor

if leafVendor then
    CreateThread(function()
        lib.requestModel(Config.leafVendorPed, 10000)
        leafVendorPed = CreatePed(0, Config.leafVendorPed, leafVendor.x, leafVendor.y, leafVendor.z - 1.0,
            leafVendor.w, false, false)
        SetModelAsNoLongerNeeded(Config.leafVendorPed)
        SetEntityHeading(leafVendorPed, leafVendor.w)
        FreezeEntityPosition(leafVendorPed, true)
        SetEntityInvincible(leafVendorPed, true)
        SetBlockingOfNonTemporaryEvents(leafVendorPed, true)
        TaskStartScenarioInPlace(leafVendorPed, 'WORLD_HUMAN_HANG_OUT_STREET', 0, true)
    end)

    -- Servidor: a pin for the same reason as the buyer above (ADR-154).

    exports.srv_lib:CreateGangPointBlip(leafVendor.xyz, Config.ownerGang, 'Fornecedor')

    setupInteractionZone(leafVendor.xyz, Config.leafVendorDistance + 5.0, Config.leafVendorDistance, function()
        return '[E] Comprar folha de coca.'
    end, function()
        local amount = askQuantity('Comprar folha de coca',
            ('$%s a folha - máximo de %s por compra.'):format(Config.leafPrice,
                counted(Config.leafPurchaseCeiling, 'folha', 'folhas')),
            Config.leafPurchaseCeiling)
        if not amount then return end

        local result = lib.callback.await('srv_cocainelab:server:buyLeaf', false, amount)

        if not result or not result.ok then
            local reasons = {
                notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
                far = 'Chegue mais perto do vendedor.',
                nomoney = 'Você não tem dinheiro suficiente.',
                toomany = ('Máximo de %s por compra.'):format(
                    counted(Config.leafPurchaseCeiling, 'folha', 'folhas')),
            }
            notify((result and reasons[result.reason]) or 'Não foi possível comprar.', 'error')
            return
        end

        notify(('Comprou %s de coca por $%s.'):format(counted(result.count, 'folha', 'folhas'), result.paid), 'success')
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= cache.resource then return end
        if leafVendorPed then exports.srv_lib:DeleteLocalEntity(leafVendorPed) end
    end)
end
