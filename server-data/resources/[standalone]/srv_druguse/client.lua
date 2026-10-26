-- Servidor: tracks which drug effects are running, and shows them. See config.lua for why this
-- listens rather than patching `qbx_consumables`.

--- Every effect currently running, keyed by `Config.effects[event].key`.
---
--- Keyed rather than a list, and this is the whole reason combos work now: the previous version
--- kept ONE effect and overwrote it, so taking cocaine while crack was running erased the crack.
--- That was defensible when the only consumer was a single HUD slot; it is not, once the player is
--- being shown what he is actually on.
---
--- Keying by the drug also gives the right behaviour for a second dose of the SAME drug for free:
--- it refreshes the expiry instead of stacking, which is exactly what `stimulant` does upstream.
---@type table<string, {label: string, icon: string, speed: number, stamina: number, expires: number}>
local running = {}

--- Drops whatever has expired.
---@return boolean changed
local function prune()
    local now = GetGameTimer()
    local changed = false

    for key, effect in pairs(running) do
        if now >= effect.expires then
            running[key] = nil
            changed = true
        end
    end

    return changed
end

--- What is running, as a sorted list plus the combined figures.
---
--- Sorted by expiry so the panel does not reshuffle its rows every tick - `pairs` over a table has
--- no order, and rows that swap places while being read are unreadable.
---@return table effects, number speed, number stamina, boolean capped
local function snapshot()
    local now = GetGameTimer()
    local effects = {}

    -- The product, mirroring applySprint. Multiplying is what upstream does, so two 1.1s are 1.21
    -- rather than 1.2 - close enough that guessing would have looked right and been wrong.
    local speed = 1.0

    -- Stamina chances are independent rolls, one per drug per second, so the combined chance of at
    -- least one landing is 1 - the product of them all missing. Adding the percentages would put
    -- ecstasy plus anything over 100% and claim a certainty the game does not deliver.
    local missAll = 1.0

    for _, effect in pairs(running) do
        effects[#effects + 1] = {
            label = effect.label,
            icon = effect.icon,
            remaining = math.max(0, effect.expires - now),
        }

        speed = speed * effect.speed
        missAll = missAll * (1.0 - effect.stamina / 100)
    end

    table.sort(effects, function(a, b) return a.remaining < b.remaining end)

    local capped = speed > Config.speedCap
    if capped then speed = Config.speedCap end

    return effects, speed, (1.0 - missAll) * 100, capped
end

--- The effect to show in `qbx_hud`'s status column, or `nil`.
---
--- Read by `qbx_hud` every tick, so it answers rather than notifies - a HUD that has to be told
--- when something ENDS needs the sender to be right about the end, and this way the expiry is
--- checked by whoever is asking.
---@return {label: string, icon: string}?
exports('Current', function()
    prune()

    local count = 0
    local single

    for _, effect in pairs(running) do
        count += 1
        single = effect
    end

    if count == 0 then return end

    -- Two or more and the column shows the combo mark instead. Picking one of them would have to
    -- pick by something - most recent, longest left - and every choice states something false
    -- about the other one still being in him.
    if count > 1 then
        return { label = Config.combo.label, icon = Config.combo.icon }
    end

    return { label = single.label, icon = single.icon }
end)

for event, effect in pairs(Config.effects) do
    RegisterNetEvent(event, function()
        -- Note this fires when the effect is REQUESTED, not when it is confirmed - the consumable
        -- can still be cancelled during its progress bar, in which case the panel shows an effect
        -- for its duration with nothing behind it. Accepted: the alternative is duplicating the
        -- callback that authorises the item, which would mean asking the server twice for one use.
        running[effect.key] = {
            label = effect.label,
            icon = effect.icon,
            speed = effect.speed,
            stamina = effect.stamina,
            expires = GetGameTimer() + effect.duration + Config.grace,
        }
    end)
end

--- The panel. Only runs while something is active, and only sends when a rendered value changed.
CreateThread(function()
    local visible = false
    local lastPayload

    while true do
        prune()

        local effects, speed, stamina, capped = snapshot()

        if #effects == 0 then
            if visible then
                visible = false
                lastPayload = nil
                SendNUIMessage({ action = 'hide' })
            end

            -- Nothing to draw and nothing to count down: this thread costs nothing until the
            -- next joint. A 250ms tick while sober would be a timer running for its own sake.
            Wait(500)
            goto continue
        end

        do
            -- Compared as a string rather than by value so the rows, the numbers and the count
            -- are all covered by one check. Seconds, not milliseconds - the panel only renders to
            -- the second, so a redraw four times a second would send four identical frames.
            local parts = {}

            for _, effect in ipairs(effects) do
                parts[#parts + 1] = ('%s:%d'):format(effect.label, math.ceil(effect.remaining / 1000))
            end

            local payload = ('%s|%.2f|%d|%s'):format(
                table.concat(parts, ','), speed, math.floor(stamina), tostring(capped))

            if payload ~= lastPayload then
                lastPayload = payload
                visible = true

                SendNUIMessage({
                    action = 'show',
                    effects = effects,
                    speed = speed,
                    stamina = stamina,
                    capped = capped,
                })
            end
        end

        Wait(250)
        ::continue::
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    running = {}
    SendNUIMessage({ action = 'hide' })
end)
