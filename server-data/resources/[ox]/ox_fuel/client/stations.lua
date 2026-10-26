local config = require 'config'
local state = require 'client.state'
local utils = require 'client.utils'
local stations = lib.load 'data.stations'

if config.showBlips == 2 then
	for station in pairs(stations) do utils.createBlip(station) end
end

if config.ox_target and config.showBlips ~= 1 then return end

---@param point CPoint
local function onEnterStation(point)
	if config.showBlips == 1 and not point.blip then
		point.blip = utils.createBlip(point.coords)
	end
end

-- Servidor: this project's own `[E] <ação>.` text UI, not GTA's native yellow help-text tooltip -
-- every other interactive point in this project (srv_robbery, srv_jobs, srv_vehiclelocks) uses
-- `lib.showTextUI`, and the fuel pump was the one left on the stock look. The three messages below
-- are the same three `DisplayHelpTextThisFrame` calls this replaced, just without the
-- `~INPUT_C2939D45~` glyph syntax that only the native renderer understands - "E" is hardcoded
-- instead, matching how every other prompt in this project names its own key literally rather than
-- reading the live binding (`startfueling` is bound to `e` by `RegisterKeyMapping` in `init.lua`
-- and has been since before this patch; nothing about which key triggers fueling changed here).
local LEAVE_VEHICLE_TEXT = 'Saia do veículo para abastecer.'
local FUEL_TEXT = '[E] Abastecer.'
local PETROLCAN_TEXT = '[E] Comprar ou reabastecer o galão.'

---@param point CPoint
local function nearbyStation(point)
	if point.currentDistance > 15 then return end

	local pumps = point.pumps
	local pumpDistance

	for i = 1, #pumps do
		local pump = pumps[i]
		pumpDistance = #(cache.coords - pump)

		if pumpDistance <= 3 then
			state.nearestPump = pump

			-- Servidor: `lib.showTextUI` is a persistent overlay, not a per-frame draw call like
			-- `DisplayHelpTextThisFrame` was - it has to be told to change, not re-told the same
			-- thing every tick. `shownText` is what was last displayed, so this only calls
			-- `showTextUI`/`hideTextUI` on an actual change instead of once per frame.
			local shownText

			repeat
				local playerCoords = GetEntityCoords(cache.ped)
				pumpDistance = #(GetEntityCoords(cache.ped) - pump)

				local wantedText

				if cache.vehicle then
					wantedText = LEAVE_VEHICLE_TEXT
				elseif not state.isFueling then
					local vehicleInRange = state.lastVehicle ~= 0 and
						#(GetEntityCoords(state.lastVehicle) - playerCoords) <= 3

					if vehicleInRange then
						wantedText = FUEL_TEXT
					elseif config.petrolCan.enabled then
						wantedText = PETROLCAN_TEXT
					end
				end

				if wantedText ~= shownText then
					if wantedText then
						lib.showTextUI(wantedText)
					else
						lib.hideTextUI()
					end
					shownText = wantedText
				end

				Wait(0)
			until pumpDistance > 3

			if shownText then
				lib.hideTextUI()
			end

			state.nearestPump = nil

			return
		end
	end
end

---@param point CPoint
local function onExitStation(point)
	if point.blip then
		point.blip = RemoveBlip(point.blip)
	end
end

for station, pumps in pairs(stations) do
	lib.points.new({
		coords = station,
		distance = 60,
		onEnter = onEnterStation,
		onExit = onExitStation,
		nearby = nearbyStation,
		pumps = pumps,
	})
end
