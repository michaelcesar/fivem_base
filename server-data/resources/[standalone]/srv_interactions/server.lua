-- Servidor: the two actions that had no implementation anywhere - handing money over, and showing
-- identification. Everything else in the ALT menu routes to `qbx_police`'s or `qbx_ambulancejob`'s
-- own server events, which already take a target id and already do their own checks.
--
-- Both callbacks here re-derive everything from the server's own state. The client sends who it
-- wants to act on and how much; it is never trusted for whether it may, for how much anyone has, or
-- for how far apart they are.

--- True if the two players are close enough to interact. Mirrors the distance `qbx_police`'s own
--- events enforce, kept here rather than shared since resources cannot share a local.
---@param src number
---@param targetSrc number
---@return boolean
local function isNear(src, targetSrc)
    local a = GetEntityCoords(GetPlayerPed(src))
    local b = GetEntityCoords(GetPlayerPed(targetSrc))
    return #(a - b) <= Config.maxDistance + 1.0
end

lib.callback.register('srv_interactions:server:giveMoney', function(source, targetSrc, amount)
    local src = source

    -- Servidor: a player handing money to themselves would otherwise be a no-op that still notifies,
    -- which reads as a bug the first time someone tries it.
    if src == targetSrc then return { ok = false } end

    local payer = exports.qbx_core:GetPlayer(src)
    local receiver = exports.qbx_core:GetPlayer(targetSrc)
    if not payer or not receiver then return { ok = false } end

    if not isNear(src, targetSrc) then return { ok = false, reason = 'far' } end

    -- Servidor: the same shape check every quantity callback in this project starts with - rules out
    -- fractional, negative, zero and absurd before any real limit is looked at.
    if type(amount) ~= 'number' or amount ~= math.floor(amount) or amount < 1 or amount > Config.maxGiveAmount then
        return { ok = false }
    end

    -- Servidor: docs/security.md's paid-action ordering - take first, then give. If the credit fails
    -- the money goes back, so it can never be duplicated or destroyed by a failure between the two.
    if not exports.qbx_core:RemoveMoney(src, 'cash', amount, 'srv_interactions:give') then
        return { ok = false, reason = 'nomoney' }
    end

    if not exports.qbx_core:AddMoney(targetSrc, 'cash', amount, 'srv_interactions:give') then
        exports.qbx_core:AddMoney(src, 'cash', amount, 'srv_interactions:give:refund')
        return { ok = false }
    end

    local payerName = ('%s %s'):format(payer.PlayerData.charinfo.firstname, payer.PlayerData.charinfo.lastname)
    TriggerClientEvent('srv_interactions:client:received', targetSrc, payerName, amount)

    return { ok = true, amount = amount }
end)

--- What a citizen's ID actually says. Read from the server's own copy of the target - a client
--- asking "who is this" must not be answered by that same client's idea of the answer.
lib.callback.register('srv_interactions:server:showId', function(source, targetSrc)
    local src = source

    local target = exports.qbx_core:GetPlayer(targetSrc)
    if not target then return nil end

    if not isNear(src, targetSrc) then return nil end

    local info = target.PlayerData.charinfo

    -- Servidor: name, birth and nationality only - the same three fields a physical ID card carries.
    -- Deliberately NOT the job, the gang, the phone number or the citizen id: showing someone your
    -- documents should not hand over your record.
    return {
        name = ('%s %s'):format(info.firstname, info.lastname),
        birthdate = info.birthdate,
        nationality = info.nationality,
    }
end)
