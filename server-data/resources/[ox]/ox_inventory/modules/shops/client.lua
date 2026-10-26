if not lib then return end

local shopTypes = {}
local shops = {}
local createBlip = require 'modules.utils.client'.CreateBlip

for shopType, shopData in pairs(lib.load('data.shops') or {} --[[@as table<string, OxShop>]]) do
	local shop = {
		name = shopData.name,
		groups = shopData.groups or shopData.jobs,
		blip = shopData.blip,
		label = shopData.label,
        icon = shopData.icon,

		-- Servidor: carried across because this is a COPY, not the shop table itself - a field left
		-- out here is silently nil everywhere downstream, which is exactly how the first version of
		-- this flag did nothing at all. See ADR-100.
		srvExternalInteraction = shopData.srvExternalInteraction,
	}

	if shared.target then
		shop.model = shopData.model
		shop.targets = shopData.targets
	else
		shop.locations = shopData.locations
	end

	shopTypes[shopType] = shop
	local blip = shop.blip

	if blip then
		blip.name = ('ox_shop_%s'):format(shopType)
		AddTextEntry(blip.name, shop.name or shopType)
	end
end

---@param point CPoint
local function onEnterShop(point)
	if not point.entity then
		local model = lib.requestModel(point.ped)

		if not model then return end

		local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z, point.heading, false, true)

		if point.scenario then TaskStartScenarioInPlace(entity, point.scenario, 0, true) end

		SetModelAsNoLongerNeeded(model)
		FreezeEntityPosition(entity, true)
		SetEntityInvincible(entity, true)
		SetBlockingOfNonTemporaryEvents(entity, true)

		exports.ox_target:addLocalEntity(entity, {
            {
                icon = point.icon or 'fas fa-shopping-basket',
                label = point.label,
                groups = point.groups,
                onSelect = function()
                    client.openInventory('shop', { id = point.invId, type = point.type })
                end,
                iconColor = point.iconColor,
                distance = point.shopDistance or 2.0
            }
		})

		point.entity = entity
	end
end

local Utils = require 'modules.utils.client'

local function onExitShop(point)
	local entity = point.entity

	if not entity then return end

	exports.ox_target:removeLocalEntity(entity)
	Utils.DeleteEntity(entity)

	point.entity = nil
end

local function hasShopAccess(shop)
	return not shop.groups or client.hasGroup(shop.groups)
end

local function wipeShops()
	for i = 1, #shops do
		local shop = shops[i]

		if shop.zoneId then
            exports.ox_target:removeZone(shop.zoneId)
            shop.zoneId = nil
		end

		if shop.remove then
			if shop.entity then onExitShop(shop) end

			shop:remove()
		end

		if shop.blip then
			RemoveBlip(shop.blip)
		end
	end

	table.wipe(shops)
end

local function refreshShops()
	wipeShops()

	local id = 0

	for type, shop in pairs(shopTypes) do
		local blip = shop.blip
		local label = shop.label or locale('open_label', shop.name)

		if shared.target then
			if shop.model then
				if not hasShopAccess(shop) then goto skipLoop end

				exports.ox_target:removeModel(shop.model, shop.name)
				exports.ox_target:addModel(shop.model, {
                    {
                        name = shop.name,
                        icon = shop.icon or 'fas fa-shopping-basket',
                        label = label,
                        onSelect = function()
                            client.openInventory('shop', { type = type })
                        end,
                        distance = 2
                    },
				})
			elseif shop.targets then
				for i = 1, #shop.targets do
					local target = shop.targets[i]
					local shopid = ('%s-%s'):format(type, i)

					if target.ped then
						id += 1

						shops[id] = lib.points.new({
							coords = target.loc,
							heading = target.heading,
							distance = 60,
							inv = 'shop',
							invId = i,
							type = type,
							blip = blip and hasShopAccess(shop) and createBlip(blip, target.loc),
							ped = target.ped,
							scenario = target.scenario,
							label = label,
							groups = shop.groups,
							icon = shop.icon or 'fas fa-shopping-basket',
							iconColor = target.iconColor,
							onEnter = onEnterShop,
							onExit = onExitShop,
							shopDistance = target.distance,
						})
					else
						if not hasShopAccess(shop) then goto nextShop end

						id += 1

						shops[id] = {
							zoneId = Utils.CreateBoxZone(target, {
                                {
                                    name = shopid,
                                    icon = shop.icon or 'fas fa-shopping-basket',
                                    label = label,
                                    groups = shop.groups,
                                    onSelect = function()
                                        client.openInventory('shop', { id = i, type = type })
                                    end,
                                    iconColor = target.iconColor,
                                    distance = target.distance
                                }
                            }),
							blip = blip and createBlip(blip, target.coords)
						}
					end

					::nextShop::
				end
			end
		elseif shop.locations then
			if not hasShopAccess(shop) then goto skipLoop end
            local shopPrompt = { icon = 'fas fa-shopping-basket' }

			for i = 1, #shop.locations do
				local coords = shop.locations[i]
				id += 1

				-- Servidor: a shop flagged `srvExternalInteraction` contributes its blip and nothing
				-- else here - another resource owns the point. `srv_robbery` puts a single [E] on the
				-- counter offering both "open shop" and "rob the till" in one menu, and two [E] points
				-- 0.6m apart is exactly what that was meant to stop.
				--
				-- This is the branch that runs here: `inventory:target` is false in ox.cfg, so
				-- `shared.target` is false and the target block above never executes on this server.
				-- The flag is deliberately NOT honoured there as well: that copy could never be run or
				-- tested from here, and every line of patch in a vendored resource has to be reapplied
				-- by hand after an update. A server that turns target mode on has to add it back.
				--
				-- The flag holds the NAME of the resource taking over, and is conditional on it actually
				-- running - so a resource that fails to start cannot take its shops down with it, and
				-- more than one resource can claim different shops. See ADR-100.
				if shop.srvExternalInteraction and GetResourceState(shop.srvExternalInteraction) == 'started' then
					shops[id] = { blip = blip and createBlip(blip, coords) }
					goto nextLocation
				end

				shops[id] = lib.points.new(coords, 16, {
					coords = coords,
					distance = 16,
					inv = 'shop',
					invId = i,
					type = type,
                    marker = client.shopmarker,
                    -- Servidor: same "[E] Label" prompt format as qbx_garages/srv_shootingrange,
                    -- instead of the stock "**Label**\nInteract with [icon]" phrasing.
                    prompt = {
                        options = shop.icon and { icon = shop.icon } or shopPrompt,
                        message = ('[E] %s.'):format(label)
                    },
					nearby = Utils.nearbyMarker,
					blip = blip and createBlip(blip, coords)
				})

				::nextLocation::
			end
		end

		::skipLoop::
	end
end

return {
	refreshShops = refreshShops,
	wipeShops = wipeShops,
}
