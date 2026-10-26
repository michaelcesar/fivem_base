-- Servidor: the chemist's one server-side authority - selling an accelerator. No persistent state
-- of any kind here (no tables, no stock, no daily cap): this vendor has unlimited supply by
-- design, since the real limit on accelerating a farm is each farm's own per-batch boost cap, not
-- how many items a player can hoard. See ADR-082.

-- Servidor: the item name arrives from the client, so it has to resolve to one of this shop's own
-- real products before any money moves - the same rule srv_weedfarm's `buySeed` applies to seed
-- names. Built once here rather than looped on every call.
local productByItem = {}
for i = 1, #Config.products do
    productByItem[Config.products[i].item] = Config.products[i]
end

-- Servidor: same sanity ceiling and shape check every other purchase callback in this project uses
-- - rules out a fractional, negative, zero or absurd quantity before the real limit below.
local SANE_AMOUNT_CEILING = 9999

local function isValidAmount(amount)
    return type(amount) == 'number' and amount == math.floor(amount) and amount >= 1 and amount <= SANE_AMOUNT_CEILING
end

--- Same shape as every farm's own `isPlayerWithin` - duplicated rather than shared, since
--- resources can't share a local across FXServer's per-resource script environments.
local function isPlayerWithin(source, coords, maxDist)
    return #(GetEntityCoords(GetPlayerPed(source)) - coords) <= maxDist
end

--- Tries cash then bank - same fallback order every paid action in this project uses, so a player
--- isn't blocked just because their cash on hand is short.
local function charge(source, amount)
    return exports.qbx_core:RemoveMoney(source, 'cash', amount, 'srv_chemist:buy')
        or exports.qbx_core:RemoveMoney(source, 'bank', amount, 'srv_chemist:buy')
end

lib.callback.register('srv_chemist:server:buy', function(source, item, amount)
    if not Config.vendor then return { ok = false } end
    if not isPlayerWithin(source, Config.vendor.xyz, Config.vendorDistance) then
        return { ok = false, reason = 'far' }
    end

    local product = productByItem[item]
    if not product then return { ok = false } end

    if not isValidAmount(amount) then return { ok = false } end
    if amount > Config.purchaseCeiling then return { ok = false, reason = 'toomany' } end

    local pay = amount * product.price

    if not charge(source, pay) then
        return { ok = false, reason = 'nomoney' }
    end

    -- Servidor: docs/security.md's paid-action ordering, inverted for a purchase - the money is
    -- taken first, and refunded in full if the item can't actually be added (a full inventory is
    -- the real case), so a player never pays for nothing.
    if not exports.ox_inventory:AddItem(source, item, amount) then
        exports.qbx_core:AddMoney(source, 'cash', pay, 'srv_chemist:buy:refund')
        return { ok = false, reason = 'noroom' }
    end

    return { ok = true, count = amount, paid = pay }
end)
