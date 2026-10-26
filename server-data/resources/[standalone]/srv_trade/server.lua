-- Servidor: the trade authority. Everything that decides whether a trade may happen, what is in each
-- offer, and when items actually move, is here.
--
-- The whole file is written around one failure: a trade that moves items between two inventories can
-- duplicate them if any step is trusted, retried, or interleaved with another. The defences, in the
-- order they matter:
--
--   1. An offer stores a REFERENCE (slot, name, count, metadata hash), never the item. At swap time
--      every reference is re-read from the live inventory and must still match exactly. An item sold,
--      dropped, used or moved between the offer and the confirm invalidates the trade.
--   2. Both sides must confirm, and ANY change to either offer clears both confirmations. Otherwise
--      a player confirms, then swaps their offer for something worthless before the other confirms.
--   3. The swap is guarded by a flag on the session. A second `confirm` arriving while one is in
--      flight is dropped rather than queued - two concurrent swaps of the same session is exactly
--      how duplication happens.
--   4. Capacity is checked for BOTH sides before anything is removed, then everything is removed
--      from both, then added. A failure after the removes puts every item back where it came from.
--
-- None of this is verified in game.

---@class TradeOffer
---@field slot number the slot in the owner's inventory
---@field name string
---@field count number
---@field metadata table?

---@class TradeSession
---@field a number source
---@field b number source
---@field offers table<number, table<number, TradeOffer>> keyed by source, then by offer index
---@field confirmed table<number, boolean>
---@field swapping boolean

---@type table<number, TradeSession>  keyed by BOTH sources, pointing at the same table
local sessions = {}

---@type table<number, { from: number, expires: number }>
local invites = {}

local function getPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end

--- Servidor: someone dead, downed or handcuffed is not in a position to agree to anything - a trade
--- with them is either a bug or a robbery wearing a trade's clothes, and `srv_interactions` already
--- has a robbery that costs the robber something. The same three metadata keys `qbx_police` gates
--- escorting and searching on.
---@param src number
---@return boolean
local function canTrade(src)
    local player = getPlayer(src)
    if not player then return false end

    local metadata = player.PlayerData.metadata
    return not (metadata.isdead or metadata.inlaststand or metadata.ishandcuffed)
end

---@return boolean
local function isNear(a, b)
    local pa, pb = GetPlayerPed(a), GetPlayerPed(b)
    if pa == 0 or pb == 0 then return false end
    return #(GetEntityCoords(pa) - GetEntityCoords(pb)) <= Config.maxDistance
end

--- Servidor: turns a slot or an offer into what the screen needs to draw it. The client is never
--- given the raw metadata table - it gets a label, a count, a weight and the two metadata keys that
--- decide which picture a slot shows, and nothing else that would let a modified client learn what
--- is inside the other inventory.
---
--- The picture itself is NOT resolved here. `ox_inventory` strips `item.client` on the server
--- (modules/items/shared.lua), so a server-side lookup can never see an item's custom image and
--- would silently fall back to the item name for every one of them. The client does that lookup,
--- where the data exists.
---@param entry { slot: number, name: string, count: number, metadata: table?, weight: number? }
local function describe(entry)
    local item = exports.ox_inventory:Items(entry.name)
    local metadata = entry.metadata

    return {
        slot = entry.slot,
        name = entry.name,
        count = entry.count,
        label = (metadata and metadata.label) or (item and item.label) or entry.name,
        weight = entry.weight or ((item and item.weight or 0) * entry.count),
        image = metadata and metadata.image or nil,
        imageurl = metadata and metadata.imageurl or nil,
    }
end

---@param offers table<number, TradeOffer>
local function describeOffers(offers)
    local out = {}
    for index, offer in pairs(offers) do
        out[tostring(index)] = describe(offer)
    end
    return out
end

--- Pushes the current state of both offers to both clients. Sent to both on every change, because
--- the entire premise is that each side sees what the other is offering as it happens.
---@param session TradeSession
local function broadcast(session)
    for _, src in ipairs({ session.a, session.b }) do
        local other = session.a == src and session.b or session.a
        TriggerClientEvent('srv_trade:client:update', src, {
            mine = describeOffers(session.offers[src]),
            theirs = describeOffers(session.offers[other]),
            iConfirmed = session.confirmed[src] or false,
            theyConfirmed = session.confirmed[other] or false,
        })
    end
end

--- Servidor: the bottom-left panel. Read fresh every time rather than cached at open, because the
--- player can still be given items while the trade is up - the offer references a slot, so a stale
--- picture of the inventory would let them offer a slot that has since become something else. The
--- swap re-reads anyway, but showing the truth is cheaper than explaining a refusal.
lib.callback.register('srv_trade:server:snapshot', function(source)
    local inventory = exports.ox_inventory:GetInventory(source)
    local out = {}

    for _, slot in pairs(inventory and inventory.items or {}) do
        if slot and slot.name then out[#out + 1] = describe(slot) end
    end

    table.sort(out, function(a, b) return a.slot < b.slot end)

    -- Servidor: the weight bar is the real one, on the same scale ox_inventory draws. Sending only
    -- the items and letting the screen invent a maximum would produce a bar that is wrong in a way
    -- nobody could see.
    return {
        items = out,
        weight = inventory and inventory.weight or 0,
        maxWeight = inventory and inventory.maxWeight or 0,
    }
end)

--- Ends a trade for both sides without moving anything.
---@param src number either participant
---@param reason string
local function endTrade(src, reason)
    local session = sessions[src]
    if not session then return end

    sessions[session.a] = nil
    sessions[session.b] = nil

    TriggerClientEvent('srv_trade:client:closed', session.a, reason)
    TriggerClientEvent('srv_trade:client:closed', session.b, reason)
end

--- Servidor: metadata is compared by its encoded form rather than field by field. Two items are only
--- interchangeable if their metadata is identical, and a durability or a serial buried three levels
--- down still has to match - a shallow compare is how a pristine weapon becomes a broken one between
--- the offer and the swap.
---@param a table?
---@param b table?
---@return boolean
local function sameMetadata(a, b)
    if a == nil and b == nil then return true end
    return json.encode(a or {}) == json.encode(b or {})
end

--- Whether an offer still describes what is really in that player's inventory, right now.
---@param src number
---@param offer TradeOffer
---@return boolean
local function offerStillValid(src, offer)
    local slot = exports.ox_inventory:GetSlot(src, offer.slot)
    if not slot then return false end
    if slot.name ~= offer.name then return false end
    if slot.count < offer.count then return false end
    return sameMetadata(slot.metadata, offer.metadata)
end

lib.callback.register('srv_trade:server:invite', function(source, targetSrc)
    local src = source

    if src == targetSrc then return { ok = false } end
    if not getPlayer(src) or not getPlayer(targetSrc) then return { ok = false } end
    if sessions[src] or sessions[targetSrc] then return { ok = false, reason = 'busy' } end
    if not canTrade(src) or not canTrade(targetSrc) then return { ok = false, reason = 'incapable' } end
    if not isNear(src, targetSrc) then return { ok = false, reason = 'far' } end

    invites[targetSrc] = { from = src, expires = os.time() + Config.inviteSeconds }

    local player = getPlayer(src).PlayerData.charinfo
    TriggerClientEvent('srv_trade:client:invited', targetSrc, src,
        ('%s %s'):format(player.firstname, player.lastname))

    return { ok = true }
end)

lib.callback.register('srv_trade:server:accept', function(source, fromSrc)
    local src = source

    local invite = invites[src]
    if not invite or invite.from ~= fromSrc then return { ok = false } end

    invites[src] = nil

    -- Servidor: everything is re-checked at accept, not carried over from the invite. Twenty seconds
    -- is long enough for either of them to have walked away, died, or started another trade.
    if os.time() > invite.expires then return { ok = false, reason = 'expired' } end
    if sessions[src] or sessions[fromSrc] then return { ok = false, reason = 'busy' } end
    if not getPlayer(fromSrc) then return { ok = false, reason = 'gone' } end
    if not canTrade(src) or not canTrade(fromSrc) then return { ok = false, reason = 'incapable' } end
    if not isNear(src, fromSrc) then return { ok = false, reason = 'far' } end

    local session = {
        a = fromSrc,
        b = src,
        offers = { [fromSrc] = {}, [src] = {} },
        confirmed = { [fromSrc] = false, [src] = false },
        swapping = false,
    }

    sessions[fromSrc] = session
    sessions[src] = session

    TriggerClientEvent('srv_trade:client:open', fromSrc, src)
    TriggerClientEvent('srv_trade:client:open', src, fromSrc)
    broadcast(session)

    return { ok = true }
end)

--- Puts an item into, or takes it out of, this player's own offer.
---
--- `index` is a position in the offer grid, not an inventory slot - the client draws a fixed number
--- of offer slots and says which one it is filling.
lib.callback.register('srv_trade:server:setOffer', function(source, index, invSlot, count)
    local src = source

    local session = sessions[src]
    if not session then return { ok = false } end
    if session.swapping then return { ok = false } end

    if type(index) ~= 'number' or index < 1 or index > Config.offerSlots then return { ok = false } end

    -- Servidor: any change clears BOTH confirmations, always, before anything else. A player who
    -- confirms and then watches the other swap a diamond for a sandwich is the classic trade scam,
    -- and it is prevented here rather than in the interface.
    session.confirmed[session.a] = false
    session.confirmed[session.b] = false

    if invSlot == nil then
        session.offers[src][index] = nil
        broadcast(session)
        return { ok = true }
    end

    local slot = exports.ox_inventory:GetSlot(src, invSlot)
    if not slot then return { ok = false } end

    if type(count) ~= 'number' or count ~= math.floor(count) or count < 1 or count > slot.count then
        return { ok = false }
    end

    -- Servidor: the same inventory slot cannot fill two offer positions, or the swap would try to move
    -- it twice and the second move would come from nothing.
    for i, existing in pairs(session.offers[src]) do
        if i ~= index and existing.slot == invSlot then return { ok = false, reason = 'duplicate' } end
    end

    session.offers[src][index] = {
        slot = invSlot,
        name = slot.name,
        count = count,
        metadata = slot.metadata,
    }

    broadcast(session)
    return { ok = true }
end)

lib.callback.register('srv_trade:server:confirm', function(source, confirmed)
    local src = source

    local session = sessions[src]
    if not session then return { ok = false } end
    if session.swapping then return { ok = false } end

    session.confirmed[src] = confirmed == true
    broadcast(session)

    if not (session.confirmed[session.a] and session.confirmed[session.b]) then
        return { ok = true, swapped = false }
    end

    -- Servidor: from here the session is closed to any further change. A second confirm arriving while
    -- this runs is refused above rather than queued - two swaps of one session is how items are
    -- duplicated.
    session.swapping = true

    local a, b = session.a, session.b

    if not getPlayer(a) or not getPlayer(b) or not isNear(a, b) then
        endTrade(src, 'far')
        return { ok = false, reason = 'far' }
    end

    -- Servidor: re-checked at the swap and not only at the invite. Someone can be shot, downed or
    -- cuffed with the screen still open, and the confirmation they gave a minute ago is not consent
    -- given now.
    if not canTrade(a) or not canTrade(b) then
        endTrade(src, 'incapable')
        return { ok = false, reason = 'incapable' }
    end

    -- Servidor: every offer is re-read from the live inventory. What was offered ten seconds ago is
    -- not evidence that it is still there.
    for _, owner in ipairs({ a, b }) do
        for _, offer in pairs(session.offers[owner]) do
            if not offerStillValid(owner, offer) then
                endTrade(src, 'changed')
                return { ok = false, reason = 'changed' }
            end
        end
    end

    -- Servidor: capacity for BOTH sides before anything moves. Removing first and discovering the
    -- other side is full leaves items in limbo.
    for _, pair in ipairs({ { from = a, to = b }, { from = b, to = a } }) do
        for _, offer in pairs(session.offers[pair.from]) do
            if not exports.ox_inventory:CanCarryItem(pair.to, offer.name, offer.count, offer.metadata) then
                endTrade(src, 'space')
                return { ok = false, reason = 'space' }
            end
        end
    end

    -- Servidor: remove everything from both sides first, remembering exactly what came out, so a
    -- failure below can put it back where it was. Nothing is added until every removal succeeded.
    local removed = {}

    for _, owner in ipairs({ a, b }) do
        for _, offer in pairs(session.offers[owner]) do
            if not exports.ox_inventory:RemoveItem(owner, offer.name, offer.count, offer.metadata, offer.slot) then
                for _, back in ipairs(removed) do
                    exports.ox_inventory:AddItem(back.owner, back.name, back.count, back.metadata)
                end
                endTrade(src, 'failed')
                return { ok = false }
            end

            removed[#removed + 1] = {
                owner = owner,
                to = owner == a and b or a,
                name = offer.name,
                count = offer.count,
                metadata = offer.metadata,
            }
        end
    end

    for _, moved in ipairs(removed) do
        if not exports.ox_inventory:AddItem(moved.to, moved.name, moved.count, moved.metadata) then
            -- Servidor: capacity was checked above, so this should be unreachable. If it happens
            -- anyway the item goes back to whoever offered it - never dropped, never duplicated.
            exports.ox_inventory:AddItem(moved.owner, moved.name, moved.count, moved.metadata)
        end
    end

    endTrade(src, 'done')
    return { ok = true, swapped = true }
end)

lib.callback.register('srv_trade:server:cancel', function(source)
    if not sessions[source] then return { ok = true } end
    endTrade(source, 'cancelled')
    return { ok = true }
end)

-- Servidor: a trade whose participants walk away, die or disconnect has to close itself. Without this
-- a session survives until a restart, and both players are locked out of trading with anyone else -
-- `invite` refuses when either side already has one.
CreateThread(function()
    while true do
        Wait(Config.watchInterval)

        local seen = {}

        for src, session in pairs(sessions) do
            if not seen[session] then
                seen[session] = true

                if session.swapping then goto continue end

                if not getPlayer(session.a) or not getPlayer(session.b) then
                    endTrade(src, 'gone')
                elseif not canTrade(session.a) or not canTrade(session.b) then
                    endTrade(src, 'incapable')
                elseif not isNear(session.a, session.b) then
                    endTrade(src, 'far')
                end
            end

            ::continue::
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if sessions[src] then endTrade(src, 'gone') end
    invites[src] = nil

    for target, invite in pairs(invites) do
        if invite.from == src then invites[target] = nil end
    end
end)
