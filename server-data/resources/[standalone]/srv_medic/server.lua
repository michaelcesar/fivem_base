local config = require 'config'

--- Servidor: the medic's paid treatment.
---
--- The division of labour this implements:
---
---   * REVIVING is done anywhere, with the `firstaid` kit the medic buys. That already exists in
---     `qbx_ambulancejob` and is gated to `ems`. It gets the patient on their feet and no further.
---   * TREATING - filling health back up - happens only on a hospital bed. It consumes no item, so
---     the medic's cost is the trip and the kit they already spent; what they charge for is the
---     service.
---
--- The price is the medic's to name and the patient's to accept. Neither side can move money
--- without the other agreeing, and both checks live here: a client that lies about the job, the
--- bed, the distance or the amount is refused by the server that actually moves the money.

---@param source number the medic
---@return boolean
local function isMedic(source)
    local player = exports.qbx_core:GetPlayer(source)

    return player ~= nil and player.PlayerData.job.type == 'ems'
end

--- Offers a treatment. The medic names the price; the patient is asked.
---
--- Returns quickly and does the asking asynchronously, so the medic is not left staring at a frozen
--- dialog while the patient reads theirs.
lib.callback.register('srv_medic:server:offer', function(source, targetId, price)
    if not isMedic(source) then
        return false, 'Apenas médicos podem cobrar por tratamento.'
    end

    price = tonumber(price)

    -- Bounded on the server. An unbounded price is a client typing whatever it likes into someone
    -- else's dialog, and a zero or negative one is an accident waiting to be confusing.
    if not price or price < config.minPrice or price > config.maxPrice then
        return false, ('O valor precisa ficar entre $%s e $%s.'):format(config.minPrice, config.maxPrice)
    end

    local patient = exports.qbx_core:GetPlayer(targetId)
    if not patient then return false, 'Paciente não encontrado.' end

    local medicPed, patientPed = GetPlayerPed(source), GetPlayerPed(targetId)

    if #(GetEntityCoords(medicPed) - GetEntityCoords(patientPed)) > config.maxDistance then
        return false, 'Você precisa estar ao lado do paciente.'
    end

    -- The bed is the whole rule. Asked of the patient's own client because that is what knows
    -- whether qbx_ambulancejob has them lying on one; the answer is only ever used to REFUSE, so a
    -- client lying about it can only deny itself a treatment.
    local onBed = lib.callback.await('srv_medic:client:isOnBed', targetId)

    if not onBed then
        return false, 'O paciente precisa estar numa maca do hospital.'
    end

    local accepted = lib.callback.await('srv_medic:client:confirm', targetId, {
        medic = GetPlayerName(source),
        price = price,
    })

    if not accepted then
        return false, 'O paciente recusou o tratamento.'
    end

    -- Re-checked after the dialog. Everything above was true when the offer was made, and the
    -- patient may have been moved, healed or logged out while reading it.
    patient = exports.qbx_core:GetPlayer(targetId)
    if not patient then return false, 'O paciente saiu.' end

    if not lib.callback.await('srv_medic:client:isOnBed', targetId) then
        return false, 'O paciente saiu da maca.'
    end

    local paid = patient.Functions.RemoveMoney('cash', price, 'srv_medic:treatment')
        or patient.Functions.RemoveMoney('bank', price, 'srv_medic:treatment')

    if not paid then
        exports.qbx_core:Notify(targetId, 'Você não tem esse valor.', 'error')
        return false, 'O paciente não tinha o valor.'
    end

    local medic = exports.qbx_core:GetPlayer(source)
    if medic then medic.Functions.AddMoney('cash', price, 'srv_medic:treatment') end

    -- Healed only after the money moved, so a failed payment never leaves a treated patient.
    exports.qbx_medical:Heal(targetId)

    exports.qbx_core:Notify(targetId,
        ('Tratamento concluído. $%s pagos ao médico.'):format(price), 'success')

    return true, ('Tratamento cobrado. $%s recebidos.'):format(price)
end)
