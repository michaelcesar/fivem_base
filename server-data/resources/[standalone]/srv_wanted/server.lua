-- Servidor: the authority for the "procurado" mark. Nothing here is decided by the client - every
-- resource that wants someone marked calls `MarkWanted`, every shop that wants to know whether to
-- refuse calls `IsWanted`, and the only client involvement is wearing the backpack it is told to
-- wear.

-- Servidor: in-memory, deliberately not persisted. A restart clearing every mark is the same choice
-- `srv_robbery`'s own `attempts` table already made for the same reason - a 10-minute mark is not
-- worth a table, and a mark that outlived a restart with no visible backpack to match it (since the
-- client would need to be told again anyway) would be worse than losing it.
---@type table<string, { source: number, expiresAt: number }>
local wanted = {}

local function getCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

---@param source number
---@return boolean
local function isOnDutyLeo(source)
    local player = exports.qbx_core:GetPlayer(source)
    local job = player and player.PlayerData.job
    return job ~= nil and job.type == 'leo' and job.onduty == true
end

---@param source number
---@return boolean
local function IsWanted(source)
    local cid = getCitizenId(source)
    local entry = cid and wanted[cid]
    return entry ~= nil and entry.expiresAt > os.time()
end
exports('IsWanted', IsWanted)

---@param source number
local function ClearWanted(source)
    local cid = getCitizenId(source)
    if not cid or not wanted[cid] then return end

    wanted[cid] = nil
    TriggerClientEvent('srv_wanted:client:setMarked', source, false)
end
exports('ClearWanted', ClearWanted)

--- Marks `source` wanted for `Config.durationMinutes` from now, refreshing the timer if they
--- already were - a second robbery while marked extends the mark rather than stacking a separate
--- one, since there is only one backpack to wear either way.
---
--- Servidor: the client event fires on every call now, not just the first - the on-screen countdown
--- HUD has to restart at the full duration on a refresh too, or it would hit zero and hide itself
--- while the player is still genuinely marked. `os.time()` does not exist client-side in FiveM
--- (see `srv_weedfarm/client.lua`'s own note on this), so the client gets a relative
--- `secondsLeft`, always the full `Config.durationMinutes * 60`, and ticks it down locally with
--- `GetGameTimer()` rather than being sent an epoch it could never use.
---@param source number
local function MarkWanted(source)
    local cid = getCitizenId(source)
    if not cid then return end

    wanted[cid] = { source = source, expiresAt = os.time() + Config.durationMinutes * 60 }
    TriggerClientEvent('srv_wanted:client:setMarked', source, true, Config.durationMinutes * 60)
end
exports('MarkWanted', MarkWanted)

-- Servidor: expiry is swept rather than scheduled per-mark - simpler, and 10 real minutes gives a
-- 15s sweep interval no meaningful lateness. Removed entries are told to drop the backpack the same
-- way a manual clear does, so the visual and the state can never drift apart.
CreateThread(function()
    while true do
        Wait(15000)

        local now = os.time()
        for cid, entry in pairs(wanted) do
            if entry.expiresAt <= now then
                wanted[cid] = nil
                if GetPlayerName(entry.source) then
                    TriggerClientEvent('srv_wanted:client:setMarked', entry.source, false)
                end
            end
        end
    end
end)

-- Servidor: the generic gate any shop can call before opening - `illenium-appearance`'s clothing
-- store uses this directly (see its own patched `client/zones.lua`); `srv_robbery`'s convenience
-- stores use their own `canOpenStore`/`start` instead, since those already had their own
-- proximity/cooldown callbacks to fold the check into. Both end up firing the same kind of alert.
lib.callback.register('srv_wanted:server:checkShopAccess', function(source)
    if not IsWanted(source) then return { ok = true } end

    TriggerEvent('police:server:policeAlert', Config.alert, nil, source)
    return { ok = false }
end)

-- Servidor: the only way out that does not simply wait it out or get arrested. Gated on the same
-- on-duty check every other police-only action in this project uses (`srv_robbery`'s
-- `onDutyPolice`, `srv_interactions`' `isPolice`) - re-checked here rather than trusted from
-- `srv_interactions`, which only decides which menu option to SHOW, never what the server allows.
lib.callback.register('srv_wanted:server:policeClear', function(source, targetSrc)
    if not isOnDutyLeo(source) then return { ok = false } end
    if not IsWanted(targetSrc) then return { ok = false, reason = 'notwanted' } end

    ClearWanted(targetSrc)
    return { ok = true }
end)

-- Servidor: the escape valve - use the item, lose the mark, and the client puts on a random one of
-- the player's own saved outfits (see client.lua) rather than opening the full editor - a disguise
-- is meant to be instant, not a wardrobe browsing session. Registered here rather than in
-- `illenium-appearance`, since this item exists FOR this feature and nothing else; keeping it here
-- means the whole "procurado" system lives in one resource instead of a third-party fork carrying a
-- patch that only this feature needs. Stacks rather than carrying a use counter - by request, "10x
-- apenas" means buying/holding 10 units, each good for one use, the same as every other consumable
-- in this project.
exports.qbx_core:CreateUseableItem(Config.wardrobeItem, function(source)
    if not IsWanted(source) then
        exports.qbx_core:Notify(source, 'Você não está procurado.', 'error')
        return
    end

    exports.ox_inventory:RemoveItem(source, Config.wardrobeItem, 1)
    ClearWanted(source)
    TriggerClientEvent('srv_wanted:client:disguise', source)
end)

AddEventHandler('playerDropped', function()
    local cid = getCitizenId(source)
    if cid then wanted[cid] = nil end
end)
