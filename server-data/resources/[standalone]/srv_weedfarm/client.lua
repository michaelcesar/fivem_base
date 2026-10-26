-- Servidor: client-side display only - every action below is re-validated server-side
-- (server.lua), this file just decides what prompt to show, asks for confirmation, and drives
-- the farm's real growth-stage props. See config.lua for why persistent, real-time growth was
-- chosen over a srv_jobs-style session.

local INTERACT_CONTROL = 38
local INTERIOR_ID = Config.farm.interiorId

-- Same dark panel look as the rest of the HUD (see dev/ox_lib-src/web/src/theme/index.ts's
-- `gfx` palette), tinted with `gfx.green` instead of the default near-black - used to highlight
-- a ready-to-harvest prompt without touching the shared textui component.
local READY_PROMPT_STYLE = {
    backgroundColor = 'rgba(62, 207, 126, 0.18)',
    border = '1px solid #3ecf7e',
}

local function notify(description, notifyType)
    lib.notify({ title = 'Plantação', description = description, type = notifyType or 'inform' })
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

--- The standard quantity-input shape used everywhere a player picks how many of something to
--- trade - one number field, minimum 1, required. `description` carries the price/context so
--- the dialog itself explains what's being asked. Shared by the dealer's sell/buy and the seed
--- vendor, rather than each defining its own copy. `max`, when given, is shown in the field and
--- enforced by the dialog itself - a display convenience only, since the server re-checks its own
--- real limit regardless (which may be lower still, e.g. `sell` against however many bricks are
--- actually owned right now).
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

---@type table<string, {citizenid: string, strain: string, plantedAt: number, ready: boolean, secondsLeft: number, fraction: number, boosts: number, boostsLeft: number}>
local plants = {}

--- Toggles one plot's real bob74_ipl props (weed_growth<letter>_stage1/2/3, its grow light
--- and hose) - the exact entity-set names read from bob74_ipl/dlc_bikers/weed.lua, not guessed.
--- Doesn't call RefreshInterior itself - `refreshVisuals` batches all 9 into one refresh, the
--- same way bob74_ipl's own `LoadDefault` does.
local function setEntitySet(name, active)
    if active then
        if not IsInteriorEntitySetActive(INTERIOR_ID, name) then
            ActivateInteriorEntitySet(INTERIOR_ID, name)
        end
    elseif IsInteriorEntitySetActive(INTERIOR_ID, name) then
        DeactivateInteriorEntitySet(INTERIOR_ID, name)
    end
end

---@param letter string
---@param plant {fraction: number}?
local function applyPlotVisual(letter, plant)
    local stage1, stage2, stage3 = ('weed_growth%s_stage1'):format(letter), ('weed_growth%s_stage2'):format(letter),
        ('weed_growth%s_stage3'):format(letter)
    local light = ('light_growth%s_stage23_standard'):format(letter)
    local hose = ('weed_hose%s'):format(letter)

    if not plant then
        setEntitySet(stage1, false)
        setEntitySet(stage2, false)
        setEntitySet(stage3, false)
        setEntitySet(light, false)
        setEntitySet(hose, false)
        return
    end

    -- Servidor: three real growth-stage props standing in for "just planted / halfway / ready" -
    -- `plant.fraction` is computed server-side (client.lua never calls os.time() - see
    -- server.lua's `withGrowthState`, os doesn't exist client-side in FiveM at all). The "full"
    -- stage lines up exactly with when harvest is actually allowed (fraction >= 1), so the plant
    -- never looks ready before the server agrees it is.
    local fraction = plant.fraction

    setEntitySet(stage1, fraction < 0.5)
    setEntitySet(stage2, fraction >= 0.5 and fraction < 1.0)
    setEntitySet(stage3, fraction >= 1.0)
    setEntitySet(light, true)
    setEntitySet(hose, true)
end

local function refreshVisuals()
    for i = 1, #Config.plots do
        local plot = Config.plots[i]
        applyPlotVisual(plot.propLetter, plants[plot.key])
    end

    RefreshInterior(INTERIOR_ID)
end

local function refreshPlants()
    plants = lib.callback.await('srv_weedfarm:server:getPlants', false) or {}
    refreshVisuals()
end

--- Refreshed once on start, again right after this client's own plant/harvest (so its own
--- action shows up immediately), and every 60s otherwise - a shared farm means another
--- player's plant or harvest only ever shows up here on the next refresh. See server.lua's own
--- comment on why that staleness is only ever cosmetic, never a security gap.
CreateThread(function()
    refreshPlants()

    while true do
        Wait(60000)
        refreshPlants()
    end
end)

---@param seconds number
---@return string
local function formatDuration(seconds)
    local minutes = math.ceil(seconds / 60)
    if minutes < 60 then return ('%s min'):format(minutes) end
    return ('%sh%02d'):format(minutes // 60, minutes % 60)
end

local strainLabels = {}
for i = 1, #Config.strains do
    strainLabels[Config.strains[i].plant] = Config.strains[i].label
end

--- Same two-tier marker+[E] zone shape as srv_jobs' `setupInteractionZone` - duplicated rather
--- than shared, since FXServer gives each resource its own script environment with no way to
--- import a local from another one. `getPrompt` may return a second value, `highlight`, to draw
--- the prompt in `READY_PROMPT_STYLE` instead of the default panel look.
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

local function harvest(plotKey)
    -- Servidor: same verified `anim@narcotics@trash`/`drop_front` planting and fertilizing already
    -- use in this file - not a new guess. Harvest had no animation of its own until requested;
    -- 2000ms matches every other "quick grab" in this project (house loot, store robbery payout).
    if not lib.progressCircle({
        duration = 2000,
        position = 'bottom',
        label = 'Colhendo...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'anim@narcotics@trash', clip = 'drop_front' },
    }) then
        return
    end

    local result = lib.callback.await('srv_weedfarm:server:harvest', false, plotKey)

    if not result or not result.ok then
        local reasons = {
            notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
            empty = 'Esse vaso está vazio.',
            far = 'Chegue mais perto do vaso.',
            notready = 'Ainda não está pronta.',
        }
        notify((result and reasons[result.reason]) or 'Não foi possível colher.', 'error')
        return
    end

    notify(('Colheu %s de %s.'):format(counted(result.amount, 'unidade', 'unidades'),
        strainLabels[result.strain] or result.strain), 'success')
    refreshPlants()
end

--- Applying fertilizer to a growing plant. Deliberately a plain [E] rather than a context menu:
--- there is exactly one thing to do here and one item that does it, so a menu with a single entry
--- would only add a click. The plot prompt already says what pressing [E] will do.
---@param plotKey string
local function fertilize(plotKey)
    -- Servidor: same `anim@narcotics@trash`/`drop_front` already verified present in this codebase
    -- and used by planting above - a crouch-and-place motion, the closest real fit for tipping
    -- fertilizer into a pot. Not a new, unverified animation guess.
    if not lib.progressCircle({
        duration = Config.boostDuration,
        position = 'bottom',
        label = 'Adubando...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'anim@narcotics@trash', clip = 'drop_front' },
    }) then
        return
    end

    local result = lib.callback.await('srv_weedfarm:server:boost', false, plotKey)

    if not result or not result.ok then
        local reasons = {
            notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
            empty = 'Esse vaso está vazio.',
            far = 'Chegue mais perto do vaso.',
            ready = 'Essa planta já está pronta.',
            maxed = 'Essa planta já recebeu todo o fertilizante que aguenta.',
            noitem = ('Você não tem %s.'):format(Config.boostLabel),
        }
        notify((result and reasons[result.reason]) or 'Não foi possível adubar.', 'error')
        return
    end

    if result.ready then
        notify('Adubada - a planta ficou pronta.', 'success')
    else
        notify(('Adubada - faltam %s. Restam %s nessa planta.'):format(
            formatDuration(result.secondsLeft), counted(result.boostsLeft, 'aplicação', 'aplicações')), 'success')
    end

    refreshPlants()
end

---@param plotKey string
---@param plotLabel string
local function openPlantMenu(plotKey, plotLabel)
    local options = {}

    for i = 1, #Config.strains do
        local strain = Config.strains[i]
        options[i] = {
            title = strain.label,
            description = 'Plantar semente de ' .. strain.label .. '.',
            icon = 'cannabis',
            onSelect = function()
                -- Servidor: `anim@narcotics@trash`/`drop_front` - already verified present and used
                -- in this exact codebase (qbx_police's own narcotics-object placement), not a new,
                -- unverified animation guess. A crouch-and-place motion, the closest real fit for
                -- pressing a seed into a pot.
                if not lib.progressCircle({
                    duration = Config.plantDuration,
                    position = 'bottom',
                    label = 'Plantando...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, car = true, combat = true },
                    anim = { dict = 'anim@narcotics@trash', clip = 'drop_front' },
                }) then
                    return
                end

                local result = lib.callback.await('srv_weedfarm:server:plant', false, plotKey, strain.seed)

                if not result or not result.ok then
                    local reasons = {
                        notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
                        occupied = 'Esse vaso já está ocupado.',
                        far = 'Chegue mais perto do vaso.',
                        noseed = ('Você não tem uma semente de %s.'):format(strain.label),
                    }
                    notify((result and reasons[result.reason]) or 'Não foi possível plantar.', 'error')
                    return
                end

                notify(('%s plantada em %s. Volte em algumas horas.'):format(strain.label, plotLabel), 'success')
                refreshPlants()
            end,
        }
    end

    lib.registerContext({ id = 'srv_weedfarm_plant', title = 'Plantar em ' .. plotLabel, options = options })
    lib.showContext('srv_weedfarm_plant')
end

CreateThread(function()
    for i = 1, #Config.plots do
        local plot = Config.plots[i]

        -- Servidor: `+ 0.75`, not the `+ 5.0` every outdoor job point uses - the 9 plots sit only
        -- 4.32m apart at their closest (see config.lua) and a wider outer radius here would
        -- overlap into the neighboring plot's zone. See ADR-067.
        setupInteractionZone(plot.coords.xyz, Config.plotDistance + 0.75, Config.plotDistance, function()
            local plant = plants[plot.key]

            if not plant then return '[E] Plantar semente.' end

            -- Servidor: harvest is open to anyone at the plot, not just whoever planted it (ADR-057,
            -- supersedes ADR-056's original ownership check) - so the prompt doesn't distinguish
            -- "mine" from "someone else's".
            if plant.ready then return '[E] Colher.', true end

            -- Servidor: while it is still growing, [E] applies fertilizer - but only while this
            -- plant still has applications left, otherwise the prompt goes back to being a plain
            -- read-out with nothing to press. The server enforces the same cap regardless.
            if plant.boostsLeft > 0 then
                return ('[E] Adubar - faltam %s.'):format(formatDuration(plant.secondsLeft))
            end

            return ('Crescendo... faltam %s.'):format(formatDuration(plant.secondsLeft))
        end, function()
            local plant = plants[plot.key]

            if not plant then
                openPlantMenu(plot.key, plot.label)
                return
            end

            if not plant.ready then
                fertilize(plot.key)
                return
            end

            harvest(plot.key)
        end)
    end
end)

-- Servidor: every illegal point of interest in this resource (farm entrance, dealer, seed vendor)
-- is drawn by `srv_lib`'s own `CreateGangBlip` - a coloured CIRCLE in the owning gang's colour,
-- matching the style qbx_garages already uses for its areas, and named after the colour rather
-- than the gang (ADR-134, ADR-137).


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

CreateThread(function()
    addIllegalBlip(Config.entrance.outside.xyz)
end)

-- Servidor: the interior has no walkable door of its own (ADR-059) - this is the fix. Standing at
-- the real street coordinate and pressing [E] teleports straight to the real interior coordinate,
-- and vice versa. The same plain SetEntityCoords already proven by /tp - no loading screen or
-- fade, since the interior is already loaded (bob74_ipl keeps its IPL active at all times).
CreateThread(function()
    setupInteractionZone(Config.entrance.outside.xyz, Config.entrance.distance + 5.0, Config.entrance.distance,
        function() return '[E] Entrar na plantação.' end,
        function()
            -- Servidor: gang gate on the way IN only - never on the way out, or a player whose gang
            -- changed while inside would be sealed in. Fast path for UX; the server re-checks every
            -- action in here regardless (ADR-125).
            if not exports.srv_lib:IsInGang(Config.ownerGang) then
                notify(exports.srv_lib:GangDeniedMessage(Config.ownerGang), 'error')
                return
            end

            SetEntityCoords(cache.ped, Config.entrance.inside.x, Config.entrance.inside.y, Config.entrance.inside.z,
                false, false, false, false)
            SetEntityHeading(cache.ped, Config.entrance.inside.w)

            -- Servidor: re-apply this farm's real state on the way in, every time. `bob74_ipl`
            -- stamps a hardcoded decorative pattern over all 9 plants at client start
            -- (`BikerWeedFarm.LoadDefault` sets them medium/full/medium/full/... regardless of what
            -- this resource's database says), and both that thread and this file's own first
            -- `refreshPlants` run at start - ours behind a `lib.callback.await` round trip, theirs
            -- as straight local work. Whichever lands last wins, which is a race nothing here
            -- controls. Losing it left the interior showing bob74_ipl's decoration until the next
            -- 60s tick: plants that read "[E] Colher" while the prop beside them was still a small
            -- one. Refreshing on entry makes the state correct at the only moment a player can
            -- actually see it - the interior has no walkable door (ADR-059), so this teleport is
            -- the only way in. The 60s loop stays for everyone already inside. See ADR-083.
            refreshPlants()
        end)

    setupInteractionZone(Config.entrance.inside.xyz, Config.entrance.distance + 5.0, Config.entrance.distance,
        function() return '[E] Sair da plantação.' end,
        function()
            SetEntityCoords(cache.ped, Config.entrance.outside.x, Config.entrance.outside.y, Config.entrance.outside.z,
                false, false, false, false)
            SetEntityHeading(cache.ped, Config.entrance.outside.w)
        end)
end)

-- Servidor: pressing used to be a custom zone + ox_lib context menu here - by request, replaced
-- entirely with ox_inventory's own real crafting bench (`srv_weedfarm_press`, defined in its own
-- `data/crafting.lua`, reusing this farm's real `processStation` coordinate). That gives the
-- actual slotted "open inventory, drag ingredients in, press craft" interface this project's own
-- design calls for, instead of a plain [E] a player could flood - and it owns its own zone/prompt
-- entirely, so nothing here needs to set one up. See ADR-069.

local dealerPed
local dealer = Config.dealer

-- Servidor: the dealer only ever starts up once a real coordinate exists (see config.lua) - same
-- "not playable until mapped" rule every srv_jobs job already follows, rather than crashing on
-- a nil vec4. Read into a local right after the check, not re-read as `Config.dealer` inside the
-- closures below - the type checker narrows a local's type through a closure boundary, but not a
-- table field's, so re-reading the field there would report it as possibly nil despite the guard
-- right here.
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

        local result = lib.callback.await('srv_weedfarm:server:sell', false, amount, form)

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

        local result = lib.callback.await('srv_weedfarm:server:buyRetail', false, item, amount)

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
        local state = lib.callback.await('srv_weedfarm:server:getDealerState', false)
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
            id = 'srv_weedfarm_dealer_sell',
            title = 'Vender tijolos',
            description = 'Escolha no que os tijolos vão virar.',
            menu = 'srv_weedfarm_dealer',
            options = {
                {
                    title = 'Virar saquinhos para revenda',
                    description = ('Restam %s hoje.'):format(counted(bagBricksLeft, 'tijolo', 'tijolos')),
                    icon = 'cannabis',
                    iconColor = bagBricksLeft > 0 and '#3ecf7e' or '#e03131',
                    progress = usedPercent(bagBricksSold, brickLimit),
                    disabled = bagBricksLeft <= 0,
                    onSelect = function() sellBricks('bag', 'saquinhos', bagBricksLeft) end,
                    metadata = {
                        { label = 'Cada tijolo vira', value = counted(Config.bagsPerBrick, 'unidade', 'unidades') },
                        { label = 'Serve para', value = 'revender na rua' },
                        { label = 'Hoje', value = ('%s de %s tijolos'):format(bagBricksSold, brickLimit) },
                    },
                },
                {
                    title = ('Virar %s'):format(Config.consumerLabelPlural),
                    description = ('Restam %s hoje.'):format(counted(consumerBricksLeft, 'tijolo', 'tijolos')),
                    icon = 'smoking',
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
            id = 'srv_weedfarm_dealer',
            title = 'Traficante',
            options = {
                quantityCard('cannabis', 'Saquinho', bagStock),
                quantityCard('smoking', Config.consumerCardLabel, consumerStock),
                {
                    title = 'Vender tijolos',
                    description = ('$%s por tijolo - você escolhe no que vira.'):format(Config.brickPrice),
                    icon = 'sack-dollar',
                    menu = 'srv_weedfarm_dealer_sell',
                },
                {
                    title = 'Comprar saquinhos',
                    description = ('$%s cada - restam %s de %s hoje.'):format(Config.bagPrice, bagBuyLeft, buyLimit),
                    icon = 'cannabis',
                    iconColor = (bagStock > 0 and bagBuyLeft > 0) and '#3ecf7e' or '#e03131',
                    progress = usedPercent(bagBought, buyLimit),
                    disabled = bagStock <= 0 or bagBuyLeft <= 0,
                    onSelect = function()
                        buyRetail(Config.bagItem, 'saquinho', 'saquinhos', Config.bagPrice,
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
                    icon = 'smoking',
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
        lib.showContext('srv_weedfarm_dealer')
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= cache.resource then return end
        if dealerPed then exports.srv_lib:DeleteLocalEntity(dealerPed) end
    end)
end

local seedVendorPed
local seedVendor = Config.seedVendor

-- Servidor: same "not playable until mapped" guard as the dealer above - the seed vendor is a
-- separate ped, elsewhere on the map, since that's how the user wanted seeds sold rather than
-- folding it into the brick dealer.
if seedVendor then
    CreateThread(function()
        lib.requestModel(Config.seedVendorPed, 10000)
        seedVendorPed = CreatePed(0, Config.seedVendorPed, seedVendor.x, seedVendor.y, seedVendor.z - 1.0,
            seedVendor.w, false, false)
        SetModelAsNoLongerNeeded(Config.seedVendorPed)
        SetEntityHeading(seedVendorPed, seedVendor.w)
        FreezeEntityPosition(seedVendorPed, true)
        SetEntityInvincible(seedVendorPed, true)
        SetBlockingOfNonTemporaryEvents(seedVendorPed, true)
        TaskStartScenarioInPlace(seedVendorPed, 'WORLD_HUMAN_HANG_OUT_STREET', 0, true)
    end)

    -- Servidor: a pin for the same reason as the buyer above (ADR-154).

    exports.srv_lib:CreateGangPointBlip(seedVendor.xyz, Config.ownerGang, 'Fornecedor')

    -- Servidor: same two-tier marker+[E] shape as the dealer above - see ADR-066.
    setupInteractionZone(seedVendor.xyz, Config.seedVendorDistance + 5.0, Config.seedVendorDistance, function()
        return '[E] Comprar sementes.'
    end, function()
        local options = {}

        for i = 1, #Config.strains do
            local strain = Config.strains[i]
            options[i] = {
                title = strain.label,
                description = ('$%s a semente.'):format(Config.seedPrice),
                icon = 'cannabis',
                onSelect = function()
                    local amount = askQuantity(('Comprar sementes de %s'):format(strain.label),
                                    ('$%s a semente - máximo de %s por compra.'):format(Config.seedPrice,
                            counted(Config.seedPurchaseCeiling, 'semente', 'sementes')),
                        Config.seedPurchaseCeiling)
                    if not amount then return end

                    local result = lib.callback.await('srv_weedfarm:server:buySeed', false, strain.seed, amount)

                    if not result or not result.ok then
                        local reasons = {
                            notgang = exports.srv_lib:GangDeniedMessage(Config.ownerGang),
                            far = 'Chegue mais perto do vendedor.',
                            nomoney = 'Você não tem dinheiro suficiente.',
                            toomany = ('Máximo de %s por compra.'):format(
                                counted(Config.seedPurchaseCeiling, 'semente', 'sementes')),
                        }
                        notify((result and reasons[result.reason]) or 'Não foi possível comprar.', 'error')
                        return
                    end

                    notify(('Comprou %s de %s por $%s.'):format(
                        counted(result.count, 'semente', 'sementes'), strain.label, result.paid), 'success')
                end,
            }
        end

        lib.registerContext({ id = 'srv_weedfarm_seeds', title = 'Comprar sementes', options = options })
        lib.showContext('srv_weedfarm_seeds')
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= cache.resource then return end
        if seedVendorPed then exports.srv_lib:DeleteLocalEntity(seedVendorPed) end
    end)
end
