local config = CourseConfig
local courseCoords = config.coords

-- Servidor: FiveM control ID for the "E" key (INPUT_CONTEXT) - named for the same reason
-- srv_jobs names it, just scoped to this resource since Lua locals don't cross resources.
local INTERACT_CONTROL = 38

CreateThread(function()
    local blip = AddBlipForCoord(courseCoords.x, courseCoords.y, courseCoords.z)
    SetBlipSprite(blip, 84) -- Shooting Range
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Curso de Artilharia')
    EndTextCommandSetBlipName(blip)
end)

---@param licence string
---@return boolean
local function hasLicence(licence)
    return QBX.PlayerData.metadata?.licences?[licence] == true
end

---@param course table
local function spawnTargets(course)
    lib.requestModel(config.targetModel)

    local targets = {}
    for i = 1, course.targets do
        local pos = courseCoords + config.targetOffsets[i] + vec3(course.lateral, course.distance, 0.0)

        -- Local objects (not networked): nobody else on the server needs to receive or
        -- render 18 practice targets, and they go away if this client leaves.
        local obj = CreateObject(config.targetModel, pos.x, pos.y, pos.z, false, false, false)

        SetEntityHeading(obj, config.targetHeading)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
        ClearEntityLastWeaponDamage(obj)

        targets[i] = obj
    end

    SetModelAsNoLongerNeeded(config.targetModel)
    return targets
end

--- Tracked at module scope so a resource restart mid-course can't leave targets behind.
local activeTargets = {}

local function removeTargets(targets)
    exports.srv_lib:DeleteLocalEntities(targets)

    if targets == activeTargets then activeTargets = {} end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    removeTargets(activeTargets)
end)

--- Counts targets knocked down so far. Each one soaks several impacts the way a person
--- would, so the damage flag is cleared after every hit to let the next one register.
--- A downed target is removed: with 18 of them and seconds on the clock, whatever is
--- still standing is the player's progress indicator.
local function countHits(targets, hitState, hitCount, hitsToDown)
    local hits = 0

    for i = 1, #targets do
        if not hitState[i] and HasEntityBeenDamagedByWeapon(targets[i], 0, 2) then
            ClearEntityLastWeaponDamage(targets[i])

            hitCount[i] = (hitCount[i] or 0) + 1

            if hitCount[i] >= hitsToDown then
                hitState[i] = true
                exports.srv_lib:DeleteLocalEntity(targets[i])
            end
        end

        if hitState[i] then
            hits += 1
        end
    end

    return hits
end

--- Guards against starting a second course on top of a running one, which would spawn a
--- duplicate set of targets. The server enforces this too - this is just the fast path.
local courseActive = false

--- Set when the server ends the course early (currently: walking off the range). The
--- server has already taken the weapon back by then; this just tears down the run here.
local courseAborted = false

RegisterNetEvent('srv_shootingrange:client:abort', function()
    if courseActive then courseAborted = true end
end)

---@param course table
local function runAttempt(course)
    local slot = lib.callback.await('srv_shootingrange:server:startCourse', false, course.id)
    if not slot then
        exports.qbx_core:Notify('Não foi possível iniciar o curso. Tente novamente.', 'error')
        return
    end

    exports.ox_inventory:useSlot(slot)
    exports.qbx_core:Notify(('%s: acerte os %s alvos antes do tempo acabar!'):format(course.label, course.targets), 'inform', 5000)

    -- Clear anything a previous run left behind before spawning: an interrupted run must
    -- never leave targets standing for the next one to inherit.
    removeTargets(activeTargets)

    local targets = spawnTargets(course)
    activeTargets = targets

    local hitState = {}
    local hitCount = {}
    local hitsToDown = course.hitsToDown or config.hitsToDown
    local weaponHash = joaat(course.weapon)
    local endTime = GetGameTimer() + course.time
    local success = false

    -- Polled every frame: the damage flag is a boolean, not a counter, so a slower poll
    -- would merge bursts from an automatic weapon into a single registered hit.
    while GetGameTimer() < endTime and not courseAborted do
        -- Ammo is a range supply, not part of the test: the course grades marksmanship
        -- against the clock, and the player carries no ammo items to reload from. Topping
        -- the weapon back up keeps ox_inventory's own accounting happy, since it only ever
        -- syncs metadata downwards when the ped's ammo drops.
        if GetAmmoInPedWeapon(cache.ped, weaponHash) < config.ammoRefillThreshold then
            SetPedAmmo(cache.ped, weaponHash, course.ammo)
        end

        if countHits(targets, hitState, hitCount, hitsToDown) >= #targets then
            success = true
            break
        end
        Wait(0)
    end

    if courseAborted then
        removeTargets(targets)

        exports.qbx_core:Notify('Você saiu da área do curso. Treino encerrado e arma recolhida.', 'error', 5000)
        return
    end

    removeTargets(targets)
    TriggerServerEvent('srv_shootingrange:server:cleanup')

    if not success then
        exports.qbx_core:Notify('Você não acertou todos os alvos a tempo. Tente novamente.', 'error')
        return
    end

    local granted = lib.callback.await('srv_shootingrange:server:complete', false, course.id)
    if granted then
        exports.qbx_core:Notify(('Parabéns, você concluiu o %s!'):format(course.label), 'success', 5000)
    else
        exports.qbx_core:Notify('Não foi possível confirmar o curso. Tente novamente.', 'error')
    end
end

--- Runs one attempt with the in-progress guard held. srv_lib's GuardedRun releases the
--- guard and clears targets on every path, and reports any error to the server log: an
--- error inside the attempt used to leave the guard set forever, locking the player out of
--- the range entirely, and silently, since client errors never reach the server log.
---@param course table
local function runCourse(course)
    if courseActive then return end

    courseActive = true
    courseAborted = false

    local ok = exports.srv_lib:GuardedRun(
        ('srv_shootingrange:%s'):format(course.id),
        function() runAttempt(course) end,
        function()
            courseActive = false
            removeTargets(activeTargets)
        end
    )

    if not ok then
        TriggerServerEvent('srv_shootingrange:server:cleanup')
        exports.qbx_core:Notify('O curso falhou por um erro. Tente novamente.', 'error')
    end
end

---@param amount number
---@return string
local function formatMoney(amount)
    local formatted = tostring(amount)

    while true do
        local replacements
        formatted, replacements = formatted:gsub('^(%d+)(%d%d%d)', '%1.%2')

        if replacements == 0 then break end
    end

    return '$' .. formatted
end

local function openCourseMenu()
    if courseActive then
        exports.qbx_core:Notify('Você já está fazendo um curso. Termine antes de começar outro.', 'error')
        return
    end

    local options = {}
    local completed = 0

    for i = 1, #config.courses do
        local course = config.courses[i]
        local done = hasLicence(course.licence)
        local locked = course.requires and not hasLicence(course.requires)

        if done then
            completed += 1

            options[i] = {
                title = course.label,
                description = ('Certificado concluído. Libera %s.'):format(course.unlocks),
                icon = course.icon,
                iconColor = '#3ecf7e',
                readOnly = true,
                colorScheme = 'green',
            }
        elseif locked then
            local required = config.getByLicence(course.requires)

            options[i] = {
                title = course.label,
                description = ('Requer o %s.'):format(required and required.label or 'curso anterior'),
                icon = 'lock',
                iconColor = '#6b6b6b',
                readOnly = true,
            }
        else
            options[i] = {
                title = ('%s — %s'):format(course.label, formatMoney(course.price)),
                description = ('Libera %s · %s alvos em %ss · Treino com %s.'):format(
                    course.unlocks,
                    course.targets,
                    course.time // 1000,
                    course.weaponLabel
                ),
                icon = course.icon,
                onSelect = function() runCourse(course) end,
            }
        end
    end

    lib.registerContext({
        id = 'srv_shootingrange_menu',
        title = 'Curso de Artilharia',
        description = ('%s de %s certificados · cobrança por tentativa, sem reembolso.'):format(completed, #config.courses),
        options = options,
    })

    lib.showContext('srv_shootingrange_menu')
end

-- Same interaction pattern as qbx_garages: outer zone draws the ground marker,
-- inner zone shows the "[E]" prompt and reads the key via IsControlJustReleased.
CreateThread(function()
    local interactionZone

    lib.zones.sphere({
        coords = courseCoords,
        radius = 10,
        onEnter = function()
            interactionZone = lib.zones.sphere({
                coords = courseCoords,
                radius = 1.5,
                onEnter = function()
                    lib.showTextUI('[E] Curso de artilharia.')
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = function()
                    if IsControlJustReleased(0, INTERACT_CONTROL) then
                        openCourseMenu()
                    end
                end,
            })
        end,
        onExit = function()
            if interactionZone then
                interactionZone:remove()
                interactionZone = nil
            end
        end,
        inside = function()
            DrawMarker(0, courseCoords.x, courseCoords.y, courseCoords.z - 2.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 20, 246, 12, 255, false, false, 0, false, nil, nil, false)
        end,
    })
end)
