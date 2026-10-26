-- Servidor: this is a thin NUI bridge only - every callback here just forwards straight to
-- Renewed-Banking's own already-server-authoritative `lib.callback`s (transfer validates the
-- amount, checks funds, and logs the transaction exactly like the in-world ATM/teller flow
-- already does). No banking logic is duplicated here, so there's nothing in this app that
-- could get out of sync with the ATM's own rules.
--
-- Deposit and withdraw are deliberately NOT bridged: moving physical cash requires standing at
-- an ATM or teller, so the phone only ever moves money between accounts. Their NUI callbacks are
-- removed here rather than only hidden in the UI - a hidden button is not a rule, and an
-- unregistered NUI callback is the only thing that actually makes the action unreachable.

local function respond(bankData)
    if bankData then
        return { status = 'ok', data = bankData }
    end

    return { status = 'error' }
end

RegisterNUICallback('npwd_fleeca:getAccounts', function(_, cb)
    local bankData = lib.callback.await('renewed-banking:server:initalizeBanking', false)
    cb(respond(bankData or {}))
end)

RegisterNUICallback('npwd_fleeca:transfer', function(data, cb)
    local bankData = lib.callback.await('Renewed-Banking:server:transfer', false, {
        fromAccount = data.fromAccount,
        amount = data.amount,
        stateid = data.targetId,
        comment = data.comment,
    })
    cb(respond(bankData))
end)
