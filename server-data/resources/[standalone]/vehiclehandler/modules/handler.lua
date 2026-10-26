local Progress <const> = lib.load('data.progress')
local Settings <const> = lib.load('data.vehicle')

local BONES <const> = {
    [0] =   'wheel_lf',
            'wheel_rf',
            'wheel_lm',
            'wheel_rm',
            'wheel_lr',
            'wheel_rr'
}

---@class privateHandlerData
---@field active boolean
---@field limited boolean
---@field control boolean
---@field oxfuel boolean
---@field electric boolean
---@field class number | false
---@field model number | false
---@field data table

---@class Handler : OxClass
---@field private private privateHandlerData
---@diagnostic disable-next-line: assign-type-mismatch
local Handler = lib.class('vehiclehandler')

function Handler:constructor()
    self:setActive(false)
    self:setLimited(false)
    self:setControl(true)
    self.private.oxfuel = GetResourceState('ox_fuel') == 'started' and true or false
end

---@return boolean active
function Handler:isActive() return self.private.active end

---@return boolean limited
function Handler:isLimited() return self.private.limited end

---@return boolean control
function Handler:canControl() return self.private.control end

---@return boolean oxfuel
function Handler:isFuelOx() return self.private.oxfuel end

---@return boolean electric
function Handler:isElectric() return self.private.electric end

---@return number | false class
function Handler:getClass() return self.private.class end

---@return number | false class
function Handler:getModel() return self.private.model end

---@param state string
---@return number | nil
function Handler:getData(state)
    if not state or type(state) ~= 'string' then return end

    return self.private.data[state]
end

---@return boolean isValid
function Handler:isValid()
    if not cache.ped then return false end
    if cache.vehicle or self.private.class == 16 then return true end

    return false
end

---@param vehicle number
---@param coords vector3
---@return boolean isTireBroken
function Handler:isTireBroken(vehicle, coords)
    if not vehicle or not coords then return false end

    for k,v in pairs(BONES) do
        local bone = GetEntityBoneIndexByName(vehicle, v)
        if bone == -1 then goto skip end

        if IsVehicleTyreBurst(vehicle, k, true) then
            local pos = GetWorldPositionOfEntityBone(vehicle, bone)

            if #(coords - pos) < 2.5 then
                return true
            end
        end

        ::skip::
    end

    return false
end

---@param state boolean
function Handler:setActive(state)
    if state ~= nil and type(state) == 'boolean' then
        self.private.active = state

        if state then
            self.private.class = GetVehicleClass(cache.vehicle) or false
            self.private.model = GetEntityModel(cache.vehicle)
            self.private.electric = GetIsVehicleElectric(self.private.model)
        else
            self.private.class = false
            self.private.model = false
            self.private.electric = false
            self.private.data = {['engine'] = 0, ['body'] = 0, ['speed'] = 0}
        end
    end
end

---@param state boolean
function Handler:setLimited(state)
    if state ~= nil and type(state) == 'boolean' then
        self.private.limited = state
    end
end

---@param state boolean
function Handler:setControl(state)
    if state ~= nil and type(state) == 'boolean' then
        self.private.control = state
    end
end

---@class handlerData
---@field engine number
---@field body number

---@param data handlerData
---@return number | nil engine
---@return number |nil body
---@return number | nil speed
function Handler:setData(data)
    if data == nil or type(data) ~= 'table' then return end

    self.private.data = data

    return data['engine'], data['body'], data['speed']
end

---@param vehicle number
---@return boolean | nil backengine
---@return vector3 | nil offset
---@return number | nil index
---@return number | nil engine
function Handler:getFixData(vehicle)
    if not vehicle or vehicle == 0 then return end

    local backengine = Settings.backengine[GetEntityModel(vehicle)]
    local distance = backengine and -2.5 or 2.5
    local index = backengine and 5 or 4
    local offset = GetOffsetFromEntityInWorldCoords(vehicle, 0, distance, 0)
    local engine = GetVehicleEngineHealth(vehicle)

    return backengine, offset, index, engine
end

---@param vehicle number
---@param index number
function Handler:breakTire(vehicle, index)
    if vehicle == nil or type(vehicle) ~= 'number' then return end
    if index == nil or type(index) ~= 'number' then return end

    local bone = GetEntityBoneIndexByName(vehicle, BONES[index])
    if bone == -1 then return end

    if not IsVehicleTyreBurst(vehicle, index, true) then

        lib.callback('vehiclehandler:sync', false, function()
            SetVehicleTyreBurst(vehicle, index, true, 1000.0)
            BreakOffVehicleWheel(vehicle, index, false, true, true, false)
        end)
    end
end

---@param vehicle number
---@param coords vector3
---@return boolean success
function Handler:fixTire(vehicle, coords)
    local found = self:isTireBroken(vehicle, coords)
    if not found then return false end

    local lastengine = GetVehicleEngineHealth(vehicle)
    local lastbody = GetVehicleBodyHealth(vehicle)
    local lastdirt = GetVehicleDirtLevel(vehicle)
    local success = false

    if lib.progressCircle(Progress['tirekit']) then
        success = true

        lib.callback('vehiclehandler:sync', false, function()
            SetVehicleFixed(vehicle)
            SetVehicleEngineHealth(vehicle, lastengine)
            SetVehicleBodyHealth(vehicle, lastbody)
            SetVehicleDirtLevel(vehicle, lastdirt)
        end)
    end

    return success
end

---@param vehicle number
---@param coords vector3
---@param fixtype string
---@return boolean success
function Handler:fixVehicle(vehicle, coords, fixtype)
    local backengine, offset, hoodindex, engine = self:getFixData(vehicle)
    local success = false

    -- Servidor: `bodykit` is panel work - it happens all the way around a vehicle, not at the engine
    -- bay, so the stand-near-the-hood requirement and the hood-opening animation below are both
    -- skipped for it. `lib.getClosestVehicle`'s own 3m search in `basicfix` is the proximity check
    -- that already applies. See ADR-124.
    local atengine = fixtype ~= 'bodykit'

    -- Servidor: this used to only notify for a rear-engine car (`backengine` true) and fail
    -- completely silently for every other vehicle - which is most of them. Reported as "the
    -- repair kit isn't working": the player was standing somewhere reasonable near the car, just
    -- not within 2m of the front, and got zero feedback either way. Now fires the matching
    -- message either way.
    if atengine and #(coords - offset) >= 2.0 then
        lib.notify({ title = locale(backengine and 'notify.backEngine' or 'notify.frontEngine'), type = 'error' })

        return success
    end

    -- Servidor: this gate used to read `smallkit and engine >= 500 or bigkit and engine >= 1000`,
    -- which only ever looked at ENGINE health and ignored the body entirely (ADR-123). Each kit now
    -- refuses on exactly the value it actually restores, so a car with a perfect engine and a
    -- wrecked body accepts a `bodykit` and refuses a `repairkit`, rather than one answer covering
    -- both. See ADR-124.
    local body = GetVehicleBodyHealth(vehicle)
    local nothingtodo =
        fixtype == 'smallkit' and engine >= 1000.0
        or fixtype == 'bodykit' and body >= 1000.0
        or fixtype == 'bigkit' and engine >= 1000.0 and body >= 1000.0

    if nothingtodo then
        lib.notify({ title = locale('notify.cannotRepair'), type = 'error' })
        return success
    end

    if atengine and hoodindex then
        lib.callback('vehiclehandler:sync', false, function()
            SetVehicleDoorOpen(vehicle, hoodindex, false, false)
        end)
    end

    if lib.progressCircle(Progress[fixtype]) then
        success = true
    end

    if atengine and hoodindex then
        lib.callback('vehiclehandler:sync', false, function()
            SetVehicleDoorShut(vehicle, hoodindex, false)
        end)

        repeat Wait(100)
        until not IsVehicleDoorFullyOpen(vehicle, hoodindex)
    end

    if success then
        lib.callback('vehiclehandler:sync', false, function()
            -- Servidor: each kit now restores its own value to full and touches nothing else, by
            -- request - `repairkit` is the engine, `bodykit` is the panels, and the two are bought
            -- and used separately. `smallkit` was a flat `SetVehicleEngineHealth(vehicle, 500.0)`,
            -- a half repair that was also a DOWNGRADE on any engine above 500, which is the only
            -- reason its old refusal threshold had to exist at all.
            if fixtype == 'smallkit' then
                SetVehicleEngineHealth(vehicle, 1000.0)
            elseif fixtype == 'bodykit' then
                SetVehicleBodyHealth(vehicle, 1000.0)
            elseif fixtype == 'bigkit' then
                SetVehicleFixed(vehicle)
            end

            SetVehicleUndriveable(vehicle, false)
        end)
    end

    return success
end

-- Servidor: `lib.getClosestVehicle`'s own third argument, `includePlayerVehicle`, defaults every
-- caller here to `false` - meaning the ONE vehicle a player is actually sitting on/in is the ONE
-- vehicle these two functions could never find, since ox_lib excludes it from the search entirely
-- when that flag is off. With a car this mostly went unnoticed (people tend to get out before
-- fixing/washing one anyway), but a motorcycle is small enough that staying seated to use an item
-- is completely natural - reported as "the repair kit isn't working" on a bike, and confirmed the
-- cleaning kit failed identically, which is what pointed at this shared root cause rather than the
-- front/back-engine distance check fixed separately above. `true` now, in both places, plus a real
-- notification when nothing is found at all - previously silent either way. See ADR-121.

---@param fixtype string
---@return boolean | nil success
function Handler:basicfix(fixtype)
    if not cache.ped then return false end
    if not fixtype or type(fixtype) ~= 'string' then return false end

    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords, 3.0, true)
	if vehicle == nil or vehicle == 0 then
        lib.notify({ title = locale('notify.noVehicle'), type = 'error' })
        return false
    end

    if fixtype == 'tirekit' then
        return self:fixTire(vehicle, coords)
    elseif fixtype == 'smallkit' or fixtype == 'bigkit' or fixtype == 'bodykit' then
        return self:fixVehicle(vehicle, coords, fixtype)
    end
end

---@return boolean success
function Handler:basicwash()
    if not cache.ped then return false end

    local pos = GetEntityCoords(cache.ped)
    local vehicle, vehpos = lib.getClosestVehicle(pos, 3.0, true)
	if vehicle == nil or vehicle == 0 then
        lib.notify({ title = locale('notify.noVehicle'), type = 'error' })
        return false
    end

    -- Servidor: this refusal existed before, but with `includePlayerVehicle` off above, the
    -- player's own vehicle could never reach it - `vehicle == nil` always fired first when it was
    -- the only one nearby, so this line was effectively dead code. Now reachable, and worded.
    if cache.vehicle then
        lib.notify({ title = locale('notify.leaveVehicle'), type = 'error' })
        return false
    end

    if #(pos - vehpos) > 3.0 then return false end

    local success = false
    TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_MAID_CLEAN", 0, true)

    if lib.progressCircle(Progress['cleankit']) then
        success = true

        lib.callback('vehiclehandler:sync', false, function()
            SetVehicleDirtLevel(vehicle, 0.0)
            WashDecalsFromVehicle(vehicle, 1.0)
        end)
    end

    ClearAllPedProps(cache.ped)
    ClearPedTasks(cache.ped)

    return success
end

---@return boolean success
function Handler:adminfix()
    if not self:isValid() then return false end

    local success = lib.callback.await('ox_lib:checkPlayerAce', false, 'command.fix')

    if success then
        lib.callback('vehiclehandler:sync', false, function()
            SetVehicleFixed(cache.vehicle)
            ResetVehicleWheels(cache.vehicle, true)

            if self:isFuelOx() then
                Entity(cache.vehicle).state.fuel = 100.0
            end

            SetVehicleFuelLevel(cache.vehicle, 100.0)
            DecorSetFloat(cache.vehicle, '_FUEL_LEVEL', GetVehicleFuelLevel(cache.vehicle))

            SetVehicleUndriveable(cache.vehicle, false)
            SetVehicleEngineOn(cache.vehicle, true, true, true)
        end)
    end

    return success
end

---@return boolean success
function Handler:adminwash()
    if not self:isValid() then return false end

    local success = lib.callback.await('ox_lib:checkPlayerAce', false, 'command.wash')

    if success then
        lib.callback('vehiclehandler:sync', false, function()
            SetVehicleDirtLevel(cache.vehicle, 0.0)
            WashDecalsFromVehicle(cache.vehicle, 1.0)
        end)
    end

    return success
end

---@param newlevel number
---@return boolean success
function Handler:adminfuel(newlevel)
    if not self:isValid() then return false end
    if not newlevel then return false end

    local success = lib.callback.await('ox_lib:checkPlayerAce', false, 'command.setfuel')

    if success then
        newlevel = lib.math.clamp(newlevel, 0.0, 100.0) + 0.0

        lib.callback('vehiclehandler:sync', false, function()
            if self:isFuelOx() then
                Entity(cache.vehicle).state.fuel = newlevel
            end

            SetVehicleFuelLevel(cache.vehicle, newlevel)
            DecorSetFloat(cache.vehicle, '_FUEL_LEVEL', GetVehicleFuelLevel(cache.vehicle))

            SetVehicleUndriveable(cache.vehicle, false)
            SetVehicleEngineOn(cache.vehicle, true, true, true)
        end)
    end

    return success
end

return Handler