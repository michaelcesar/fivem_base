local config = require 'config'

--- Servidor: the medic side of paid treatment, and the patient's confirmation.
---
--- Everything here is presentation. The job check, the bed check, the distance and the money all
--- happen on the server; this file can be lied to and the worst outcome is a dialog nobody asked
--- for (CLAUDE.md rule 2).

--- Whether qbx_ambulancejob currently has this player lying on a hospital bed. That resource
--- exposes the state as a global on its own client, which is the only place it exists.
lib.callback.register('srv_medic:client:isOnBed', function()
    return IsInHospitalBed == true
end)

--- The patient's side: a medic has offered, and the money does not move until this returns true.
lib.callback.register('srv_medic:client:confirm', function(offer)
    local answer = lib.alertDialog({
        header = 'Tratamento médico',
        content = ('**%s** quer cobrar **$%s** para tratar seus ferimentos.\n\nAceitar?'):format(
            offer.medic, offer.price),
        centered = true,
        cancel = true,
        labels = { confirm = 'Aceitar e pagar', cancel = 'Recusar' },
    })

    return answer == 'confirm'
end)

--- The medic's side, reached from the [E] interaction menu that srv_interactions owns.
---
--- Registered as an EVENT rather than as an ox_target option of its own, because every action
--- aimed at a person in this project is reached the same way: stand in front of them, press E,
--- pick from one list. A second route to the same action is a second thing to discover.
RegisterNetEvent('srv_medic:client:offerTreatment', function(targetSrc)
    local input = lib.inputDialog('Cobrar tratamento', {
        {
            type = 'number',
            label = 'Valor',
            description = ('Entre $%s e $%s.'):format(config.minPrice, config.maxPrice),
            default = config.defaultPrice,
            min = config.minPrice,
            max = config.maxPrice,
            required = true,
        },
    })

    if not input then return end

    local ok, message = lib.callback.await('srv_medic:server:offer', false, targetSrc, input[1])

    lib.notify({
        title = 'Tratamento',
        description = message,
        type = ok and 'success' or 'error',
    })
end)
