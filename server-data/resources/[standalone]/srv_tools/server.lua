-- Servidor: CLAUDE.md hard rule 6 - dev tooling never ships. This resource is unrestricted by
-- design (that is the point of it during development), so the guard is a master switch rather
-- than per-command permissions: with `srv_tools:enabled` unset, nothing below is registered at
-- all - no commands, no net events, no attack surface to reason about. A production server
-- simply never sets it.
--
-- Deliberately opt-IN, not opt-out. An opt-out flag ships dangerous by default and relies on
-- someone remembering to add a line before going live, which is exactly the failure this rule
-- exists to prevent. `setr` (not `set`) because client.lua reads the same convar, and only
-- replicated convars reach the client.
--
-- The commands below are ALSO ACE-restricted, as defence in depth: if the switch is ever turned
-- on to debug something on a live server, /spawndrugs still must not be reachable by a player.
if GetConvar('srv_tools:enabled', '0') ~= '1' then return end

-- Deliberately loud, and deliberately permanent: the boot log is the one place someone always
-- looks, so a server that still has dev tooling on says so every single start. Silence here
-- means the switch is off, which is also how this file's gate gets verified without a debugger.
print('^1[srv_tools] DEV TOOLS ATIVOS^7 - comandos de desenvolvimento registrados (/tp, /placecar, /spawndrugs...). ^3Isto NAO pode ficar ligado num servidor com jogadores.^7')

-- Lite dev tools: lets client-side probes (e.g. /findtargets) report results here, where
-- they can be read straight from the server log instead of the in-game F8 console.
RegisterNetEvent('srv_tools:server:log', function(tag, data)
    print(('[%s] %s'):format(tag, json.encode(data)))
end)

-- Lite dev tools: wipes your artillery course certificates so the courses can be
-- replayed from scratch. Takes effect immediately - no reconnect, no server restart.
RegisterCommand('resetcourses', function(source)
    if source == 0 then return end -- ignore console usage, needs a real player

    if not exports.srv_shootingrange:ResetCourses(source) then return end

    TriggerClientEvent('chat:addMessage', source, {
        color = { 42, 161, 201 },
        args = { 'Servidor', 'Certificados de artilharia zerados. Pode refazer os cursos.' },
    })
end, true)

-- Lite dev tools: hands over the full four-step chain of all three drugs at once, so the
-- grow -> process -> press -> sell -> resell loop can be tested from any step without farming
-- up to it first. Twelve items, laid out in the same order the chain actually runs, so a
-- missing one is obvious at a glance. Kept as a list rather than reading the three resources'
-- own Config tables: those live in separate script environments (no shared globals across
-- resources), and hardcoding here means this command still works if one of them fails to start
-- - which is exactly when you want it. See ADR-073 for why each drug has four distinct items.
local DRUG_CHAIN = {
    -- weed:    seed              -> bud           -> brick        -> retail bag
    'weed_skunk_seed', 'weed_skunk', 'weed_brick', 'weed_bag',
    -- cocaine: leaf              -> paste         -> brick        -> retail bag
    'coca_leaf', 'cocaine_paste', 'cocaine_brick', 'cocaine_bag',
    -- meth:    precursor         -> crystal       -> brick        -> retail bag
    'meth_precursor', 'meth', 'meth_brick', 'meth_bag',
}

RegisterCommand('spawndrugs', function(source, args)
    if source == 0 then return end -- ignore console usage, needs a real player

    local count = tonumber(args[1]) or 10
    if count < 1 then count = 1 end

    local given, failed = 0, {}

    for i = 1, #DRUG_CHAIN do
        local item = DRUG_CHAIN[i]
        if exports.ox_inventory:AddItem(source, item, count) then
            given += 1
        else
            failed[#failed + 1] = item
        end
    end

    -- Live RP: report what actually landed, not just "done" - AddItem fails silently on a full
    -- inventory, and 12 items at once is exactly when that happens.
    if #failed > 0 then
        print(('[spawndrugs] %s: %s/%s given, failed: %s')
            :format(GetPlayerName(source), given, #DRUG_CHAIN, table.concat(failed, ', ')))
    end

    TriggerClientEvent('chat:addMessage', source, {
        color = { 42, 161, 201 },
        args = { 'Servidor', ('%sx de %s/%s itens de droga entregues.%s')
            :format(count, given, #DRUG_CHAIN,
                #failed > 0 and ' Faltou espaço pra: ' .. table.concat(failed, ', ') or '') },
    })
end, true)

-- Lite dev tools: prints the calling player's identifiers (steam/license/discord/etc),
-- e.g. to find the right one for add_principal in server.cfg.
RegisterCommand('myid', function(source)
    if source == 0 then return end -- ignore console usage, needs a real player

    local identifiers = GetPlayerIdentifiers(source)

    print(('[myid] %s (source %s):'):format(GetPlayerName(source), source))
    for i = 1, #identifiers do
        print(('[myid]   %s'):format(identifiers[i]))
    end

    TriggerClientEvent('chat:addMessage', source, {
        color = { 42, 161, 201 },
        args = { 'ID', 'Seus identificadores foram impressos no console do servidor.' },
    })
end, true)
