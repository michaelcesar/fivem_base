local config = require 'config'

--- Servidor: the character's remaining lives, and the permanent block when they run out.
---
--- State lives in its own `srv_lives` table rather than in character metadata, for one reason that
--- decides the design: the block has to be enforced at CHARACTER SELECTION, before the player is
--- loaded, and metadata is not readable until after the load it is meant to prevent. A table keyed
--- by citizenid can be asked at any moment, including for a character nobody is playing.
---
--- Everything here is server-side. A client never sends a life count, only reads one.

--- Servidor: oxmysql hands TINYINT(1) back as a BOOLEAN, not as 1. Comparing it with == 1 is
--- false for a column that is set, and the guard built on it silently never fires - which is how
--- a paid rescue was charged twice and how a blocked character would have kept logging in.
--- Accepting both shapes is the only comparison that survives the driver deciding either way.
---@param value any
---@return boolean
local function toBool(value)
    return value == true or value == 1
end
---@param citizenid string
---@return { lives: integer, blocked: boolean, sinceFree: integer? }
local function getRecord(citizenid)
    local row = MySQL.single.await(
        'SELECT lives, blocked, TIMESTAMPDIFF(DAY, free_claimed_at, CURRENT_TIMESTAMP) AS since_free'
        .. ' FROM srv_lives WHERE citizenid = ?', { citizenid })

    -- A character with no row has never lost a life. It is created lazily rather than on character
    -- creation, so existing characters need no migration.
    if not row then
        MySQL.insert.await('INSERT IGNORE INTO srv_lives (citizenid, lives) VALUES (?, ?)', {
            citizenid, config.maxLives,
        })

        return { lives = config.maxLives, blocked = false, sinceFree = nil }
    end

    -- `sinceFree` is nil for a character that has never claimed, which reads as "eligible" -
    -- deliberately, so a new character is not made to wait a month before its first one.
    return { lives = row.lives, blocked = toBool(row.blocked), sinceFree = row.since_free }
end

exports('GetRecord', getRecord)

---@param citizenid string
---@return boolean
local function isBlocked(citizenid)
    return getRecord(citizenid).blocked
end

exports('IsBlocked', isBlocked)

--- Takes one life. Returns the record AFTER the loss, so the caller can tell the player where they
--- now stand without a second query.
---
--- Deliberately does NOT decide *when* a life is lost - that belongs to the death flow, which knows
--- whether anyone rescued the player. This only performs the loss it is told to perform.
---@param citizenid string
---@return { lives: integer, blocked: boolean }
local function loseLife(citizenid)
    local record = getRecord(citizenid)

    if record.blocked then return record end

    local remaining = record.lives - 1

    if remaining > 0 then
        MySQL.update.await('UPDATE srv_lives SET lives = ? WHERE citizenid = ?', { remaining, citizenid })

        return { lives = remaining, blocked = false }
    end

    -- The last one. The character is blocked here and not by a separate call, so there is no window
    -- in which a character sits at zero lives and is still playable.
    MySQL.update.await(
        'UPDATE srv_lives SET lives = 0, blocked = 1, blocked_at = CURRENT_TIMESTAMP WHERE citizenid = ?',
        { citizenid }
    )

    lib.print.warn(('character %s lost its last life and is now blocked'):format(citizenid))

    return { lives = 0, blocked = true }
end

exports('LoseLife', loseLife)

--- Grants lives and lifts the block if any were granted. Clamped to `maxLives` so neither an admin
--- typo nor a future purchase can put a character above the ceiling.
---@param citizenid string
---@param amount integer
---@return { lives: integer, blocked: boolean }
local function addLives(citizenid, amount)
    local record = getRecord(citizenid)
    local total = math.min(record.lives + amount, config.maxLives)

    if total < 0 then total = 0 end

    local blocked = total <= 0

    MySQL.update.await(
        'UPDATE srv_lives SET lives = ?, blocked = ?, blocked_at = ? WHERE citizenid = ?',
        { total, blocked and 1 or 0, blocked and os.date('%Y-%m-%d %H:%M:%S') or nil, citizenid }
    )

    return { lives = total, blocked = blocked }
end

exports('AddLives', addLives)

--- Sets an exact number, used by the admin tooling where "give 3" and "make it 3" are different
--- intentions and confusing them loses characters.
---@param citizenid string
---@param amount integer
---@return { lives: integer, blocked: boolean }
local function setLives(citizenid, amount)
    local total = math.max(0, math.min(amount, config.maxLives))
    local blocked = total <= 0

    getRecord(citizenid) -- ensures the row exists

    MySQL.update.await(
        'UPDATE srv_lives SET lives = ?, blocked = ?, blocked_at = ? WHERE citizenid = ?',
        { total, blocked and 1 or 0, blocked and os.date('%Y-%m-%d %H:%M:%S') or nil, citizenid }
    )

    return { lives = total, blocked = blocked }
end

exports('SetLives', setLives)

--- The block is enforced at selection by a patch in `qbx_core/server/character.lua`, which asks
--- this before calling `Login`. See docs/patches.md.
lib.callback.register('srv_lives:server:isBlocked', function(_, citizenid)
    return isBlocked(citizenid)
end)

--- Admin recovery.
---
--- This exists because a permanent death caused by a bug is the worst outcome this system can
--- produce, and the only defence is being able to hand the character back. ACE-restricted to
--- `group.admin` on top of whatever the command list shows.
---
--- `resolve` accepts either a server id (a player online right now) or a citizenid (a character
--- that cannot be online, which is the whole point when it is blocked).
---@param arg string
---@return string? citizenid, string? label
local function resolve(arg)
    local serverId = tonumber(arg)

    if serverId then
        local player = exports.qbx_core:GetPlayer(serverId)

        if player then
            return player.PlayerData.citizenid, GetPlayerName(serverId)
        end
    end

    -- Not an online id, so treat it as a citizenid. Confirmed against `players` rather than trusted,
    -- so a typo reports instead of silently creating a row for a character that does not exist.
    local row = MySQL.single.await('SELECT citizenid, charinfo FROM players WHERE citizenid = ?', { arg })

    if not row then return nil, nil end

    local info = json.decode(row.charinfo or '{}')

    return row.citizenid, ('%s %s'):format(info.firstname or '?', info.lastname or '?')
end

local function report(src, message)
    if src > 0 then
        exports.qbx_core:Notify(src, message, 'inform')
    else
        lib.print.info(message)
    end
end

lib.addCommand('lives', {
    help = 'Consulta as vidas de um personagem.',
    params = {
        { name = 'alvo', help = 'ID do jogador online ou citizenid', type = 'string' },
    },
    restricted = 'group.admin',
}, function(source, args)
    local citizenid, label = resolve(args.alvo)

    if not citizenid then
        return report(source, ('Nenhum personagem encontrado para "%s".'):format(args.alvo))
    end

    local record = exports.srv_lives:GetRecord(citizenid)

    report(source, ('%s (%s): %s de %s %s.%s'):format(
        label, citizenid, record.lives, config.maxLives, config.label.plural,
        record.blocked and ' PERSONAGEM BLOQUEADO.' or ''))
end)

lib.addCommand('setlives', {
    help = 'Define exatamente quantas vidas um personagem tem. Zero bloqueia o personagem.',
    params = {
        { name = 'alvo', help = 'ID do jogador online ou citizenid', type = 'string' },
        { name = 'quantidade', help = 'Número exato de vidas', type = 'number' },
    },
    restricted = 'group.admin',
}, function(source, args)
    local citizenid, label = resolve(args.alvo)

    if not citizenid then
        return report(source, ('Nenhum personagem encontrado para "%s".'):format(args.alvo))
    end

    local record = exports.srv_lives:SetLives(citizenid, args.quantidade)

    lib.print.info(('admin %s set lives of %s to %s'):format(source, citizenid, record.lives))

    report(source, ('%s agora tem %s de %s %s.%s'):format(
        label, record.lives, config.maxLives, config.label.plural,
        record.blocked and ' Continua BLOQUEADO.' or ' Liberado.'))
end)

lib.addCommand('unblock', {
    help = 'Desbloqueia um personagem morto permanentemente, devolvendo N vidas.',
    params = {
        { name = 'citizenid', help = 'Citizenid do personagem bloqueado', type = 'string' },
        { name = 'quantidade', help = 'Quantas vidas devolver (1 ate o maximo)', type = 'number' },
    },
    restricted = 'group.admin',
}, function(source, args)
    local citizenid, label = resolve(args.citizenid)

    if not citizenid then
        return report(source, ('Nenhum personagem encontrado para "%s".'):format(args.citizenid))
    end

    -- Refused rather than clamped: "unblock with 0" is always a mistake, and silently turning it
    -- into 1 hides the mistake instead of correcting it.
    if args.quantidade < 1 then
        return report(source, 'Para desbloquear é preciso devolver ao menos 1 vida.')
    end

    local record = exports.srv_lives:SetLives(citizenid, args.quantidade)

    lib.print.info(('admin %s unblocked %s with %s lives'):format(source, citizenid, record.lives))

    report(source, ('%s desbloqueado com %s de %s %s.'):format(
        label, record.lives, config.maxLives, config.label.plural))
end)

--- The loss.
---
--- `qbx_medical:server:playerRespawned` fires only when a player gives up and respawns - being
--- revived fires `playerRevived` instead. So this hook already means exactly "nobody saved him",
--- which is the rule, and neither a medic nor the paid NPC rescue costs a life because neither
--- takes this path.
AddEventHandler('qbx_medical:server:playerRespawned', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local record = loseLife(player.PlayerData.citizenid)

    if record.blocked then
        exports.qbx_core:Notify(source,
            'Você perdeu sua última vida. Este personagem morreu permanentemente.', 'error', 10000)

        -- Dropped rather than left walking around: the character is blocked at selection from now
        -- on, and letting it keep playing until the next reconnect would make the death look
        -- optional. The delay is only so the message can be read.
        SetTimeout(8000, function()
            if GetPlayerName(source) then
                DropPlayer(source, 'Seu personagem morreu permanentemente. Fale com a administração para recuperá-lo.')
            end
        end)

        return
    end

    -- Placed at the hospital, on the morgue side. qbx_medical revives without choosing a
    -- position, so this is the only thing that decides where giving up leaves you.
    TriggerClientEvent('srv_lives:client:respawnAt', source, config.respawnCoords)

    local remaining = ('%s %s restantes.'):format(record.lives, config.label.plural)

    -- Warned near the end, because losing a character without knowing you were close to the edge is
    -- frustration rather than roleplay.
    if record.lives <= config.warnAtOrBelow then
        exports.qbx_core:Notify(source,
            ('ATENÇÃO: %s Ao chegar a zero, o personagem morre para sempre.'):format(remaining), 'error', 8000)
    else
        exports.qbx_core:Notify(source, ('Você perdeu uma vida. %s'):format(remaining), 'inform')
    end
end)

--- Everything the character-state panel shows, in one round trip. The debt is read from
--- srv_rescue rather than duplicated here: two systems owning the same number is how they start
--- disagreeing.
lib.callback.register('srv_lives:client:status', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return nil end

    local record = getRecord(player.PlayerData.citizenid)
    local rescue = GetResourceState('srv_rescue') == 'started'
        and exports.srv_rescue:GetRecord(player.PlayerData.citizenid)
        or { debt = 0 }

    return {
        lives = record.lives,
        blocked = record.blocked,
        max = config.maxLives,
        debt = rescue.debt,
    }
end)
--- Buying a life back. Only reachable from the hospital counter, and every rule is checked here
--- rather than there: the client can invoke this callback from anywhere, so the counter is where
--- a player FINDS the option, never what authorises it (CLAUDE.md rule 2).
lib.callback.register('srv_lives:server:buy', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false, 'Personagem não encontrado.' end

    -- Distance is verified server-side too. Without it the counter is decoration and the
    -- purchase is available from the other side of the map.
    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - config.counter) > 5.0 then
        return false, 'Você precisa estar no balcão do hospital.'
    end

    local record = getRecord(player.PlayerData.citizenid)

    if record.lives >= config.maxLives then
        return false, ('Você já tem as %s %s.'):format(config.maxLives, config.label.plural)
    end

    if not player.Functions.RemoveMoney('cash', config.lifePrice, 'srv_lives:buy')
        and not player.Functions.RemoveMoney('bank', config.lifePrice, 'srv_lives:buy') then
        return false, ('Você precisa de $%s.'):format(config.lifePrice)
    end

    local after = addLives(player.PlayerData.citizenid, 1)

    return true, ('Tratamento pago. Agora você tem %s de %s %s.'):format(
        after.lives, config.maxLives, config.label.plural)
end)
--- How many free lives have piled up.
---
--- They ACCRUE rather than expire: a month nobody claimed is still owed, so someone who has not
--- visited the hospital since February arrives with several waiting. Capped at maxLives because
--- a character who was away for a year cannot hold twelve of anything.
---@param record { sinceFree: integer? }
---@return integer
local function freeOwed(record)
    if record.sinceFree == nil then return 1 end

    return math.min(math.floor(record.sinceFree / config.freeEveryDays), config.maxLives)
end

--- What the counter menu needs to draw itself.
lib.callback.register('srv_lives:server:counter', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return nil end

    local record = getRecord(player.PlayerData.citizenid)

    return {
        lives = record.lives,
        max = config.maxLives,
        price = config.lifePrice,
        freeOwed = freeOwed(record),

        -- Days until the NEXT one, counted within the current period rather than from the last
        -- claim: with accrual those are different numbers, and showing the wrong one would tell
        -- a player who is owed two that they have to wait.
        daysLeft = record.sinceFree
            and (config.freeEveryDays - (record.sinceFree % config.freeEveryDays))
            or config.freeEveryDays,
    }
end)

--- The monthly claim. Free, and therefore rate-limited by the date rather than by money - which
--- means the date is the only thing standing between a player and unlimited lives, so it is
--- checked and written in the same statement a claim happens in.
lib.callback.register('srv_lives:server:claimFree', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false, 'Personagem não encontrado.' end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - config.counter) > 5.0 then
        return false, 'Você precisa estar no balcão do hospital.'
    end

    local citizenid = player.PlayerData.citizenid
    local record = getRecord(citizenid)

    if record.lives >= config.maxLives then
        return false, ('Você já tem as %s %s.'):format(config.maxLives, config.label.plural)
    end

    local owed = freeOwed(record)

    if owed < 1 then
        return false, ('O próximo atendimento gratuito sai em %s dias.'):format(
            config.freeEveryDays - (record.sinceFree % config.freeEveryDays))
    end

    -- The clock ADVANCES by one period; it does not reset to now. Resetting would throw away the
    -- part of the current period already served, so claiming on day 59 would silently cost the
    -- player 29 days of progress toward the next one.
    --
    -- A row that has never claimed has no date to advance from, so it starts one period back:
    -- that is what makes the first free life available immediately.
    if record.sinceFree == nil then
        MySQL.update.await(
            'UPDATE srv_lives SET free_claimed_at = CURRENT_TIMESTAMP WHERE citizenid = ?', { citizenid })
    else
        MySQL.update.await(
            'UPDATE srv_lives SET free_claimed_at = free_claimed_at + INTERVAL ? DAY WHERE citizenid = ?',
            { config.freeEveryDays, citizenid })
    end

    local after = addLives(citizenid, 1)

    return true, ('Atendimento gratuito realizado. Agora você tem %s de %s %s.'):format(
        after.lives, config.maxLives, config.label.plural)
end)