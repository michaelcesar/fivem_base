-- Servidor: same master switch as server.lua - see the longer note there. With
-- `srv_tools:enabled` unset, none of the commands below are registered, so a production client
-- has no /tp, /placecar or /coords at all rather than having them present-but-refused.
--
-- Honest scope note: these are client-side commands, and a client-side permission check is not a
-- security boundary - anyone able to abuse /tp can already do it with a mod menu, and this
-- resource never had server authority over any of it. The switch is about not shipping dev
-- tooling, per CLAUDE.md rule 6; the real enforcement for anything that grants items or changes
-- state is the ACE restriction on the server commands in server.lua.
if GetConvar('srv_tools:enabled', '0') ~= '1' then return end

--- Preview entities are created local (non-networked); srv_lib owns the correct way to
--- delete those, since getting the ownership claim wrong makes DeleteEntity a silent no-op.
---@param entity number?
local function deleteLocalEntity(entity)
    exports.srv_lib:DeleteLocalEntity(entity)
end

local ERROR_COLOUR = { 224, 49, 49 }
local INFO_COLOUR = { 42, 161, 201 }

--- The one shape every dev-tool chat line here uses - exists once so the colour/tag
--- convention can't drift between commands.
local function chatMessage(colour, tag, text)
    TriggerEvent('chat:addMessage', { color = colour, args = { tag, text } })
end

local function srvError(text) chatMessage(ERROR_COLOUR, 'Servidor', text) end
local function srvInfo(text) chatMessage(INFO_COLOUR, 'Servidor', text) end

-- Lite dev tools: every command in this file registers through here, so the load marker at the
-- bottom reports a count that cannot drift. It used to be a hardcoded literal and had already
-- fallen three behind the real number. In a diagnostic whose whole job is to say whether the file
-- parsed to the end, a number nobody updates is worse than no number - it reads as confirmation.
local commandCount = 0

---@param name string
---@param handler function
---@param restricted boolean? defaults to false, matching every call site in this file
local function devCommand(name, handler, restricted)
    commandCount += 1
    RegisterCommand(name, handler, restricted or false)
end
local function coordsInfo(text) chatMessage(INFO_COLOUR, 'Coords', text) end

--- The `vec4(...)` string every coordinate-picking command prints - `/coords` and `/lockcar`
--- both build the same shape from a position and a heading.
local function formatVec4(coords, heading)
    return ('vec4(%.2f, %.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z, heading)
end

-- Servidor: the playable-map rectangle both /dumpzones and /dumpstreets sweep - one set of
-- bounds means the two can't quietly drift apart. `onPoint(x, y)` runs at every grid point;
-- `onRowEnd`, if given, runs once per completed row - only /dumpstreets needs it, to `Wait(0)`
-- between rows so its much finer grid doesn't freeze the game thread.
local MAP_MIN_X, MAP_MAX_X = -4300.0, 4500.0
local MAP_MIN_Y, MAP_MAX_Y = -4300.0, 8300.0

local function sweepMap(step, onPoint, onRowEnd)
    local x = MAP_MIN_X
    while x <= MAP_MAX_X do
        local y = MAP_MIN_Y
        while y <= MAP_MAX_Y do
            onPoint(x, y)
            y += step
        end
        x += step
        if onRowEnd then onRowEnd() end
    end
end

-- Lite dev tools: GTA's native zone names (shown on the map and by any "current area" HUD)
-- can't be enumerated from outside the game either. /dumpzones sweeps the whole playable
-- map in a grid, calling GetNameOfZone at each point, and logs every distinct GXT key
-- actually found server-side - so translations only ever target keys confirmed to exist.
devCommand('dumpzones', function()
    local found = {}

    sweepMap(150.0, function(x, y)
        local zone = GetNameOfZone(x, y, 30.0)
        if zone and zone ~= '' then found[zone] = true end
    end)

    local codes = {}
    for zone in pairs(found) do codes[#codes + 1] = zone end
    table.sort(codes)

    -- GetLabelText reads the real English string straight from the game's own string
    -- table for this GXT key, so the English name is confirmed too, not guessed.
    local list = {}
    for i = 1, #codes do
        list[i] = ('%s=%s'):format(codes[i], GetLabelText(codes[i]))
    end

    TriggerServerEvent('srv_tools:server:log', 'dumpzones', list)
    srvInfo(('%s zonas encontradas. Lista enviada ao console do servidor.'):format(#list))
end, false)

-- Lite dev tools: street names work like zones but are keyed by hash, not a known GXT
-- string - GetStreetNameAtCoord only gives back a hash, never the original key text, so
-- there is nothing to guess. /dumpstreets sweeps the map the same way /dumpzones does,
-- resolves each hash's real English text via GetStreetNameFromHashKey, and logs the pairs
-- so a translation can target AddTextEntryByHash with a hash confirmed to exist.
devCommand('dumpstreets', function()
    local found = {}

    CreateThread(function()
        -- Streets are much shorter than zones, so the 150m grid /dumpzones uses skips real
        -- ones - 40m catches short streets. That's ~14x the sample count, so `onRowEnd`
        -- yields every row instead of running as a single uninterrupted loop.
        sweepMap(40.0, function(x, y)
            local street, crossing = GetStreetNameAtCoord(x, y, 30.0)
            if street and street ~= 0 then found[street] = true end
            if crossing and crossing ~= 0 then found[crossing] = true end
        end, function() Wait(0) end)

        local hashes = {}
        for hash in pairs(found) do hashes[#hashes + 1] = hash end
        table.sort(hashes)

        local list = {}
        for i = 1, #hashes do
            local name = GetStreetNameFromHashKey(hashes[i])
            if name and name ~= '' then
                list[#list + 1] = ('%s=%s'):format(hashes[i], name)
            end
        end

        TriggerServerEvent('srv_tools:server:log', 'dumpstreets', list)
        srvInfo(('%s ruas encontradas. Lista enviada ao console do servidor.'):format(#list))
    end)
end, false)

-- Lite dev tools: model names for props/peds can't be verified from outside the game, so
-- scan a batch of candidates and report which ones actually exist. /findtargets logs the
-- valid ones to the server console; /testprop <model> spawns one in front of you to look at.
local targetCandidates = {
    -- shooting-range / training target guesses
    'prop_target_dummy_01', 'prop_bs_target_01', 'prop_shooting_target', 'prop_range_target_01',
    'p_range_target_01', 'prop_gun_target_01', 'prop_target_01', 'prop_target_stand',
    'prop_archery_target_01', 'prop_paper_target', 'prop_wooden_target', 'prop_bhole_target',
    -- mannequin / dummy guesses
    'prop_cs_dummy_01', 'prop_dummy_01', 'prop_mannequin_01', 'prop_ld_dummy_01',
    'prop_fib_3b_dummy', 'prop_dummy_plane', 'prop_shop_mannequin',
    -- known-good controls, to prove the scan itself works
    'prop_cs_cardbox_01', 'prop_barrel_02a',
}

devCommand('findtargets', function()
    local valid = {}

    for i = 1, #targetCandidates do
        if IsModelInCdimage(joaat(targetCandidates[i])) then
            valid[#valid + 1] = targetCandidates[i]
        end
    end

    TriggerServerEvent('srv_tools:server:log', 'findtargets', valid)
    srvInfo(('%s de %s modelos existem. Lista enviada ao console do servidor.'):format(#valid, #targetCandidates))
end, false)

local previewProp

devCommand('testprop', function(_, args)
    local model = args[1]
    if not model then
        srvError('Uso: /testprop <model>')
        return
    end

    local hash = joaat(model)
    if not IsModelInCdimage(hash) then
        srvError('Modelo inexistente: ' .. model .. '.')
        return
    end

    deleteLocalEntity(previewProp)

    lib.requestModel(hash)

    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local pos = coords + forward * 3.0

    previewProp = CreateObject(hash, pos.x, pos.y, pos.z - 1.0, false, false, false)
    PlaceObjectOnGroundProperly(previewProp)

    srvInfo('Prop criado: ' .. model .. ' (/removeprop para apagar).')
end, false)

devCommand('removeprop', function()
    deleteLocalEntity(previewProp)
    previewProp = nil
end, false)

local previewPed

-- Lite dev tools: same shape as /testprop, for peds - checking a model exists before committing to
-- it is the same rule (CLAUDE.md rule 4), but no existing command here spawns a ped to look at.
-- Added for picking the armed-guard model for `srv_robbery`'s story-house tier: this project's
-- only two custom ped models so far (`g_m_y_lost_01`, `s_m_y_cop_01`) don't fit "private security",
-- and a wrong hash for 20 guards across 4 houses would fail completely silently.
devCommand('testped', function(_, args)
    local model = args[1]
    if not model then
        srvError('Uso: /testped <model>')
        return
    end

    local hash = joaat(model)
    if not IsModelInCdimage(hash) or not IsModelAPed(hash) then
        srvError('Modelo de ped inexistente: ' .. model .. '.')
        return
    end

    deleteLocalEntity(previewPed)

    lib.requestModel(hash)

    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local pos = coords + forward * 3.0

    previewPed = CreatePed(4, hash, pos.x, pos.y, pos.z - 1.0, GetEntityHeading(ped) + 180.0, false, false)
    SetModelAsNoLongerNeeded(hash)
    FreezeEntityPosition(previewPed, true)
    SetEntityInvincible(previewPed, true)
    SetBlockingOfNonTemporaryEvents(previewPed, true)

    srvInfo('Ped criado: ' .. model .. ' (/removeped para apagar).')
end, false)

devCommand('removeped', function()
    deleteLocalEntity(previewPed)
    previewPed = nil
end, false)

-- Lite dev tools: cycles component 5 ("bags" - confirmed against `illenium-appearance`'s own
-- `componentBlacklistMap`) on YOUR OWN ped, for finding the black backpack drawable index
-- `srv_wanted` needs. Nothing else in this project verifies clothing drawables, since nothing
-- else needed to force one onto a player rather than let them pick from the shop UI - GetEntityModel
-- itself already tells you the drawable count is right or wrong the moment you look, no natives
-- like IsModelInCdimage apply here at all (drawables are indices into the ped model's own data, not
-- separate assets to load).
devCommand('testbag', function(_, args)
    local drawable = tonumber(args[1])
    local texture = tonumber(args[2]) or 0

    if not drawable then
        srvError('Uso: /testbag <drawable> [texture]')
        return
    end

    SetPedComponentVariation(cache.ped, 5, drawable, texture, 0)
    srvInfo(('Componente 5 (mochila) definido: drawable %s, textura %s. /removebag para tirar.'):format(drawable, texture))
end, false)

devCommand('removebag', function()
    SetPedComponentVariation(cache.ped, 5, 0, 0, 0)
    srvInfo('Mochila removida.')
end, false)

-- Lite dev tools: EVERY interior `bob74_ipl` defines an id for - all 143 of them, generated
-- straight from that resource's own source (`grep -r "interiorId ="`) rather than typed by hand,
-- so this list cannot silently disagree with what is actually installed. Labels are the defining
-- file's own path, with `#n` appended where one file defines several near-identical variants (the
-- executive/finance/import families differ by decor, not by shape). A real world position for any
-- of them comes from `GetInteriorPosition` at run time - the CLAUDE.md rule that world positions
-- come from the game, applied to interiors.
--
-- Regenerate after a bob74_ipl update. A stale id here reports as INDISPONIVEL rather than as a
-- wrong coordinate, which is the intended way for it to fail.
local INTERIORS = {
    { id = 271617, label = 'dlc_afterhours/nightclubs' },
    { id = 297729, label = 'dlc_agents/factory' },
    { id = 297985, label = 'dlc_agents/office' },
    { id = 246273, label = 'dlc_bikers/clubhouse1' },
    { id = 246529, label = 'dlc_bikers/clubhouse2' },
    { id = 247553, label = 'dlc_bikers/cocaine' },
    { id = 247809, label = 'dlc_bikers/counterfeit_cash' },
    { id = 246785, label = 'dlc_bikers/document_forgery' },
    { id = 247041, label = 'dlc_bikers/meth' },
    { id = 247297, label = 'dlc_bikers/weed' },
    { id = 295425, label = 'dlc_bounties/office' },
    { id = 278273, label = 'dlc_casino/arcade' },
    { id = 278529, label = 'dlc_casino/arcade_basement' },
    { id = 274689, label = 'dlc_casino/penthouse' },
    { id = 281089, label = 'dlc_cayoperico/nightclub' },
    { id = 281345, label = 'dlc_cayoperico/submarine' },
    { id = 293633, label = 'dlc_chopshop/cartel_garage' },
    { id = 293377, label = 'dlc_chopshop/salvage' },
    { id = 269313, label = 'dlc_doomsday/facility' },
    { id = 290817, label = 'dlc_drugwars/freakshop' },
    { id = 290561, label = 'dlc_drugwars/garage' },
    { id = 290305, label = 'dlc_drugwars/lab' },
    { id = 227329, label = 'dlc_executive/apartment1 #1' },
    { id = 228097, label = 'dlc_executive/apartment1 #2' },
    { id = 228865, label = 'dlc_executive/apartment1 #3' },
    { id = 229633, label = 'dlc_executive/apartment1 #4' },
    { id = 230401, label = 'dlc_executive/apartment1 #5' },
    { id = 231169, label = 'dlc_executive/apartment1 #6' },
    { id = 231937, label = 'dlc_executive/apartment1 #7' },
    { id = 232705, label = 'dlc_executive/apartment1 #8' },
    { id = 227585, label = 'dlc_executive/apartment2 #1' },
    { id = 228353, label = 'dlc_executive/apartment2 #2' },
    { id = 229121, label = 'dlc_executive/apartment2 #3' },
    { id = 229889, label = 'dlc_executive/apartment2 #4' },
    { id = 230657, label = 'dlc_executive/apartment2 #5' },
    { id = 231425, label = 'dlc_executive/apartment2 #6' },
    { id = 232193, label = 'dlc_executive/apartment2 #7' },
    { id = 232961, label = 'dlc_executive/apartment2 #8' },
    { id = 227841, label = 'dlc_executive/apartment3 #1' },
    { id = 228609, label = 'dlc_executive/apartment3 #2' },
    { id = 229377, label = 'dlc_executive/apartment3 #3' },
    { id = 230145, label = 'dlc_executive/apartment3 #4' },
    { id = 230913, label = 'dlc_executive/apartment3 #5' },
    { id = 231681, label = 'dlc_executive/apartment3 #6' },
    { id = 232449, label = 'dlc_executive/apartment3 #7' },
    { id = 233217, label = 'dlc_executive/apartment3 #8' },
    { id = 236289, label = 'dlc_finance/office1 #1' },
    { id = 236545, label = 'dlc_finance/office1 #2' },
    { id = 236801, label = 'dlc_finance/office1 #3' },
    { id = 237057, label = 'dlc_finance/office1 #4' },
    { id = 237313, label = 'dlc_finance/office1 #5' },
    { id = 237569, label = 'dlc_finance/office1 #6' },
    { id = 237825, label = 'dlc_finance/office1 #7' },
    { id = 238081, label = 'dlc_finance/office1 #8' },
    { id = 238337, label = 'dlc_finance/office1 #9' },
    { id = 238593, label = 'dlc_finance/office2 #1' },
    { id = 238849, label = 'dlc_finance/office2 #2' },
    { id = 239105, label = 'dlc_finance/office2 #3' },
    { id = 239361, label = 'dlc_finance/office2 #4' },
    { id = 239617, label = 'dlc_finance/office2 #5' },
    { id = 239873, label = 'dlc_finance/office2 #6' },
    { id = 240129, label = 'dlc_finance/office2 #7' },
    { id = 240385, label = 'dlc_finance/office2 #8' },
    { id = 240641, label = 'dlc_finance/office2 #9' },
    { id = 240897, label = 'dlc_finance/office3 #1' },
    { id = 241153, label = 'dlc_finance/office3 #2' },
    { id = 241409, label = 'dlc_finance/office3 #3' },
    { id = 241665, label = 'dlc_finance/office3 #4' },
    { id = 241921, label = 'dlc_finance/office3 #5' },
    { id = 242177, label = 'dlc_finance/office3 #6' },
    { id = 242433, label = 'dlc_finance/office3 #7' },
    { id = 242689, label = 'dlc_finance/office3 #8' },
    { id = 242945, label = 'dlc_finance/office3 #9' },
    { id = 243201, label = 'dlc_finance/office4 #1' },
    { id = 243457, label = 'dlc_finance/office4 #2' },
    { id = 243713, label = 'dlc_finance/office4 #3' },
    { id = 243969, label = 'dlc_finance/office4 #4' },
    { id = 244225, label = 'dlc_finance/office4 #5' },
    { id = 244481, label = 'dlc_finance/office4 #6' },
    { id = 244737, label = 'dlc_finance/office4 #7' },
    { id = 244993, label = 'dlc_finance/office4 #8' },
    { id = 245249, label = 'dlc_finance/office4 #9' },
    { id = 258561, label = 'dlc_gunrunning/bunkers' },
    { id = 145921, label = 'dlc_high_life/apartment1' },
    { id = 146177, label = 'dlc_high_life/apartment2' },
    { id = 146689, label = 'dlc_high_life/apartment3' },
    { id = 146945, label = 'dlc_high_life/apartment4' },
    { id = 147201, label = 'dlc_high_life/apartment5' },
    { id = 147457, label = 'dlc_high_life/apartment6' },
    { id = 253441, label = 'dlc_import/garage1 #1' },
    { id = 253697, label = 'dlc_import/garage1 #2' },
    { id = 253953, label = 'dlc_import/garage1 #3' },
    { id = 254209, label = 'dlc_import/garage1 #4' },
    { id = 254465, label = 'dlc_import/garage2 #1' },
    { id = 254721, label = 'dlc_import/garage2 #2' },
    { id = 254977, label = 'dlc_import/garage2 #3' },
    { id = 255233, label = 'dlc_import/garage2 #4' },
    { id = 255489, label = 'dlc_import/garage3 #1' },
    { id = 255745, label = 'dlc_import/garage3 #2' },
    { id = 256001, label = 'dlc_import/garage3 #3' },
    { id = 256257, label = 'dlc_import/garage3 #4' },
    { id = 256513, label = 'dlc_import/garage4 #1' },
    { id = 256769, label = 'dlc_import/garage4 #2' },
    { id = 257025, label = 'dlc_import/garage4 #3' },
    { id = 257281, label = 'dlc_import/garage4 #4' },
    { id = 252673, label = 'dlc_import/vehicle_warehouse #1' },
    { id = 253185, label = 'dlc_import/vehicle_warehouse #2' },
    { id = 306177, label = 'dlc_kortz/basement' },
    { id = 305921, label = 'dlc_kortz/exhibition' },
    { id = 305409, label = 'dlc_kortz/loadingbay' },
    { id = 306433, label = 'dlc_kortz/mansion_workshop' },
    { id = 305665, label = 'dlc_kortz/sewers' },
    { id = 304385, label = 'dlc_mansions/mansion1' },
    { id = 302593, label = 'dlc_mansions/mansion2' },
    { id = 303617, label = 'dlc_mansions/mansion3' },
    { id = 304641, label = 'dlc_mansions/mansion_basement1' },
    { id = 303105, label = 'dlc_mansions/mansion_basement2' },
    { id = 303873, label = 'dlc_mansions/mansion_basement3' },
    { id = 291841, label = 'dlc_mercenaries/club' },
    { id = 292097, label = 'dlc_mercenaries/lab' },
    { id = 298497, label = 'dlc_money/carwash' },
    { id = 298753, label = 'dlc_money/office' },
    { id = 260353, label = 'dlc_smuggler/hangar' },
    { id = 141313, label = 'gta_online/apartment_hi_1' },
    { id = 145665, label = 'gta_online/apartment_hi_2' },
    { id = 207105, label = 'gta_online/house_hi_1' },
    { id = 206081, label = 'gta_online/house_hi_2' },
    { id = 206337, label = 'gta_online/house_hi_3' },
    { id = 208129, label = 'gta_online/house_hi_4' },
    { id = 207617, label = 'gta_online/house_hi_5' },
    { id = 207361, label = 'gta_online/house_hi_6' },
    { id = 206593, label = 'gta_online/house_hi_7' },
    { id = 208385, label = 'gta_online/house_hi_8' },
    { id = 149761, label = 'gta_online/house_low_1' },
    { id = 148225, label = 'gta_online/house_mid_1' },
    { id = 171777, label = 'gtav/floyd' },
    { id = 206849, label = 'gtav/franklin' },
    { id = 197889, label = 'gtav/franklin_aunt' },
    { id = 92674, label = 'gtav/lester_factory' },
    { id = 166657, label = 'gtav/michael' },
    { id = 7170, label = 'gtav/simeon' },
    { id = 197121, label = 'gtav/stripclub' },
    { id = 2562, label = 'gtav/trevors_trailer' },
}

--- Lite dev tools: prints a real world position for each interior above, straight from
--- `GetInteriorPosition` - the game's own answer, not a remembered coordinate.
--- `/interiors <filtro>` narrows by label substring.
---
--- Output goes to BOTH the F8 console (`print`, so it can be read on the spot without alt-tabbing)
--- and the server log (so a whole sweep can be read at once afterwards). The server copy alone was
--- the first shape of this and it was the wrong call: the list is meant to be scrolled while
--- standing in game deciding where to build, which is exactly what F8 is for.
devCommand('interiors', function(_, args)
    local filter = args[1] and args[1]:lower() or nil
    local found = {}

    for i = 1, #INTERIORS do
        local entry = INTERIORS[i]

        if not filter or entry.label:lower():find(filter, 1, true) then
            local x, y, z = GetInteriorPosition(entry.id)

            -- Servidor: an interior id the running game does not know returns 0,0,0 rather than
            -- failing, so it is reported as unavailable instead of as a coordinate at the map
            -- origin - exactly the silent-wrong-answer shape CLAUDE.md rule 5 warns about.
            --
            -- A COORDINATE IS NOT ENOUGH, and this cost a long round of teleporting into nothing.
            -- `GetInteriorPosition` answers "is this interior defined in the game files", which is
            -- true for every DLC interior whether or not its IPL was ever loaded into the world.
            -- Several - the carwash, the salvage yard, the freakshop - returned perfectly good
            -- coordinates and teleporting there put the player on a street, because there is no
            -- geometry at that point in this build. `IsValidInterior` is the question that actually
            -- matters: whether the running game has it. Reported per entry now, so the list can be
            -- read for "where can I actually build" instead of "what exists on paper".
            local usable = IsValidInterior(entry.id)

            local line = (x == 0.0 and y == 0.0 and z == 0.0)
                and ('%s [%s] INDISPONIVEL'):format(entry.label, entry.id)
                or ('%s [%s] %s vec3(%.2f, %.2f, %.2f)'):format(
                    entry.label, entry.id, usable and 'OK' or 'NAO CARREGADO', x, y, z)

            found[#found + 1] = line
            print(('[interiors] %s'):format(line))
        end
    end

    if #found == 0 then
        srvError('Nenhum interior bate com esse filtro.')
        return
    end

    TriggerServerEvent('srv_tools:server:log', 'interiors', found)
    srvInfo(('%s interiores listados no F8 (e enviados ao log do servidor).'):format(#found))
end, false)

--- Lite dev tools: measure how far each nearby vehicle sits above or below the real floor, so a
--- floating showroom car can be corrected with a measured number instead of a guessed one.
---
--- Measures by PROXIMITY, not by number plate. The first version of this filtered on the `BUY ME`
--- plate `qbx_vehicleshop` writes onto its display cars, and it matched nothing at all while
--- standing in the middle of six of them - so the plate is not a usable handle here and the
--- filter was removed rather than patched again. The plate is printed instead, quoted, so what
--- these cars actually carry is visible rather than assumed.
---
--- `delta` is what to ADD to a car's configured z to seat it on the floor. `qbx_vehicleshop`
--- freezes its display cars, so a wrong z is permanent - the car never falls and never corrects.
devCommand('showroom', function()
    local pedCoords = GetEntityCoords(cache.ped)
    local pool = GetGamePool('CVehicle')
    local nearby = {}

    -- Servidor: printed before anything is decided, so the command always leaves a trace in F8 even
    -- when it finds nothing. A chat-only message reads as "the command does not exist" to someone
    -- watching the console, which is exactly how this tool wasted a round already.
    print(('[showroom] verificando %s veiculos no pool...'):format(#pool))

    for i = 1, #pool do
        local veh = pool[i]
        local coords = GetEntityCoords(veh)
        local distance = #(pedCoords - coords)

        if distance <= 40.0 then
            nearby[#nearby + 1] = { veh = veh, coords = coords, distance = distance }
        end
    end

    table.sort(nearby, function(a, b) return a.distance < b.distance end)

    if #nearby == 0 then
        local msg = 'Nenhum veiculo num raio de 40m.'
        print(('[showroom] %s'):format(msg))
        srvError(msg)
        return
    end

    for i = 1, #nearby do
        local entry = nearby[i]
        local coords = entry.coords
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(entry.veh)) or '?'
        local plate = GetVehicleNumberPlateText(entry.veh) or ''

        -- Servidor: the ray starts at the car's OWN height. Starting it a few metres higher was the
        -- first version and it silently measured the wrong surface: at the `luxo` showroom three of
        -- six cars sit under a mezzanine, so a probe from z+3 hit the mezzanine's underside and
        -- reported a +2.9 delta - a car apparently floating BELOW its floor. A showroom car is above
        -- its floor and never below it, so its own z is the correct place to cast from.
        local ok, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)

        -- Servidor: `frozen` is the giveaway for a showroom car even without a usable plate -
        -- `qbx_vehicleshop` freezes every display vehicle and nothing else in traffic is frozen.
        local marker = IsEntityStatic(entry.veh) and ' [CONGELADO]' or ''

        local line = ok
            and ('%.1fm %s placa="%s" z=%.2f | chao=%.2f | delta %+.2f%s'):format(
                entry.distance, model:lower(), plate, coords.z, groundZ, groundZ - coords.z, marker)
            or ('%.1fm %s placa="%s" z=%.2f | chao NAO ENCONTRADO%s'):format(
                entry.distance, model:lower(), plate, coords.z, marker)

        print(('[showroom] %s'):format(line))
    end

    srvInfo(('%s veículos medidos num raio de 40m — veja o F8.'):format(#nearby))
end, false)


--- Lite dev tools: report every input `srv_vehiclelocks` decides its `[E]` prompt from, for the
--- vehicle nearest to you. Added after that prompt failed to appear on a box truck: the cause was a
--- proximity radius measured to the vehicle's ORIGIN, which on a long vehicle sits metres behind the
--- driver's door, and nothing on screen said so. The per-bone distances below are what makes that
--- kind of mismatch visible instead of guessable - stand where the prompt should appear and run it.
devCommand('lockinfo', function()
    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords, 20.0, false)

    if not vehicle or vehicle == 0 then
        srvError('Nenhum veículo num raio de 20m.')
        return
    end

    srvInfo(('Veículo: %s | centro a %.2fm | trava %s | assento livre: %s'):format(
        GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),
        #(coords - GetEntityCoords(vehicle)),
        GetVehicleDoorLockStatus(vehicle),
        tostring(IsVehicleSeatFree(vehicle, -1))
    ))

    local bones = { 'door_dside_f', 'door_dside_r', 'door_pside_f', 'door_pside_r' }
    for i = 1, #bones do
        local boneIndex = GetEntityBoneIndexByName(vehicle, bones[i])
        if boneIndex == -1 then
            srvInfo(('  %s: não existe nesse modelo.'):format(bones[i]))
        else
            srvInfo(('  %s: %.2fm'):format(bones[i], #(coords - GetWorldPositionOfEntityBone(vehicle, boneIndex))))
        end
    end

    -- Servidor: pcall'd for the same reason `srv_vehiclelocks` pcalls it - `HasKeys` yields on the
    -- owned-vehicle branch, and a diagnostic that dies mid-report is worse than one that says it
    -- could not read the value.
    local ok, hasKeys = pcall(function()
        return exports.qbx_vehiclekeys:HasKeys(vehicle)
    end)
    srvInfo(('  HasKeys: %s'):format(ok and tostring(hasKeys) or 'ERRO ao consultar'))
end, false)

-- Lite dev tools: diagnose a "black wall" blocking a doorway - reported at the GTAOHouseHi front
-- doors, where the interior beyond renders fine once you clip past it, so it isn't the interior
-- itself failing to stream (that would leave the whole room empty, not just a thin plane at the
-- threshold). The leading suspect is the door PROP's own collision: many GTA door objects have a
-- static "looks open" resting pose that is purely visual, while the actual collidable door stays
-- in its GTA_DOOR_SYSTEM's default locked/closed state until something calls
-- `DoorSystemSetDoorState` - nothing in `bob74_ipl` does that for these houses.
--
-- Rather than guess the door prop's model hash (the exact trap CLAUDE.md rule 4 warns about - a
-- wrong hash here fails silently), this scans every real object within 2m of you and reports each
-- one's model hash, then checks whether GTA's own door system recognises any of them as a
-- registered door and if so, what state it's in. Stand right at the black wall and run it.
-- Lite dev tools: `/doorinfo [raio]`, default 5m.
--
-- Was a fixed 2m and came back empty at the Pillbox entrance, which reads as "this door is not an
-- object" - but a double door's origin can sit further than 2m from where you stand at one leaf, so
-- an empty result at 2m proved nothing. The radius is now an argument, and the report says how far
-- each object was, so an empty list at 5m means something and an empty list at 2m no longer has to
-- be interpreted.
devCommand('doorinfo', function(_, args)
    local radius = tonumber(args[1]) or 5.0
    local coords = GetEntityCoords(cache.ped)
    local pool = GetGamePool('CObject')
    local found = {}

    for i = 1, #pool do
        local object = pool[i]
        local objCoords = GetEntityCoords(object)
        local distance = #(coords - objCoords)

        if distance <= radius then
            local model = GetEntityModel(object)
            local exists, doorHash = DoorSystemFindExistingDoor(objCoords.x, objCoords.y, objCoords.z, model)

            found[#found + 1] = {
                model = model,
                distance = ('%.2f'):format(distance),
                coords = ('%.2f, %.2f, %.2f'):format(objCoords.x, objCoords.y, objCoords.z),
                registeredDoor = exists,
                doorState = exists and DoorSystemGetDoorState(doorHash) or nil,
                openRatio = exists and DoorSystemGetOpenRatio(doorHash) or nil,
            }
        end
    end

    table.sort(found, function(a, b) return tonumber(a.distance) < tonumber(b.distance) end)

    TriggerServerEvent('srv_tools:server:log', 'doorinfo', { radius = radius, objects = found })
    srvInfo(('%s objetos em %.1fm. Detalhes no console do servidor.'):format(#found, radius))
end, false)

-- Lite dev tools: a causal test, not another guess. `/doorinfo` found two nearby objects at the
-- GTAOHouseHi black wall, neither registered in GTA's door system - so `DoorSystemSetDoorState`
-- has nothing to act on, and guessing their model *names* to look up a "known" fix turned up no
-- match against a list of plausible GTA Online door prop names. Rather than keep guessing names,
-- this disables collision on every object within 2m, live, so walking through (or not) right after
-- running it tells us directly whether one of those two objects is the actual blocker - no model
-- name required either way, since a fix only needs the model *hash*, which `/doorinfo` already
-- printed to the server console.
devCommand('doortest', function()
    local coords = GetEntityCoords(cache.ped)
    local pool = GetGamePool('CObject')
    local affected = 0

    for i = 1, #pool do
        local object = pool[i]
        if #(coords - GetEntityCoords(object)) <= 2.0 then
            SetEntityCollision(object, false, false)
            affected = affected + 1
        end
    end

    srvInfo(('Colisão desligada em %s objeto(s) próximos. Tente atravessar agora, sem noclip.'):format(affected))
end, false)

-- Lite dev tools: `/doortest` ruled out a loose object - collision stayed solid with every nearby
-- CObject's collision off, so whatever is blocking the GTAOHouseHi doorway is baked into the
-- building itself (static collision, not an entity `SetEntityCollision` can touch). That points
-- back at the interior - specifically, whether `bob74_ipl/client.lua`'s `CapInterior`/
-- `PinInteriorInMemory` fix (see patches.md) is actually taking effect, rather than another guess
-- about what else might be involved. This reports the real, current state instead of assuming it.
-- Lite dev tools: how far you are from every configured `srv_robbery` house, in metres. Added
-- after the door-freeze fix in that resource produced no log output at all at House 8 - which
-- means its 15m zone never fired, and the leading suspect is that `Config.houses`' coordinates are
-- `bob74_ipl` INTERIOR reference points, not front doors, so the real door can sit well outside
-- the zone drawn around them. This measures it directly instead of assuming either way.
devCommand('housedist', function()
    local coords = GetEntityCoords(cache.ped)
    local houses = exports.srv_robbery:GetHouseCoords()
    local out = {}

    for i = 1, #houses do
        out[#out + 1] = ('%s=%.1fm'):format(houses[i].key, #(coords - houses[i].coords))
    end

    TriggerServerEvent('srv_tools:server:log', 'housedist', {
        you = ('%.2f, %.2f, %.2f'):format(coords.x, coords.y, coords.z),
        distances = out,
    })
    coordsInfo('Distâncias enviadas ao console do servidor.')
end, false)

devCommand('interiorstate', function()
    local coords = GetEntityCoords(cache.ped)
    local fromEntity = GetInteriorFromEntity(cache.ped)
    local fromCoords = GetInteriorAtCoords(coords.x, coords.y, coords.z)

    local function describe(id)
        if id == 0 then return { interiorId = 0 } end
        return {
            interiorId = id,
            valid = IsValidInterior(id),
            capped = IsInteriorCapped(id),
            ready = IsInteriorReady(id),
            disabled = IsInteriorDisabled(id),
        }
    end

    TriggerServerEvent('srv_tools:server:log', 'interiorstate', {
        fromEntity = describe(fromEntity),
        fromCoords = describe(fromCoords),
    })
    srvInfo('Estado do interior enviado ao console do servidor.')
end, false)

-- Lite dev tools: prints your current position so we can pick real spawn/blip coords.
devCommand('coords', function()
    local ped = cache.ped
    local formatted = formatVec4(GetEntityCoords(ped), GetEntityHeading(ped))

    print(('[coords] %s'):format(formatted))
    coordsInfo(formatted)
end, false)

-- Servidor: default-bound to F9 (unclaimed - checked every RegisterKeyMapping/defaultKey in the
-- repo first) so grabbing a job route's coordinates is one press instead of typing /coords each
-- time. Binding the command's own name - FiveM auto-runs whatever command a keymapping names, no
-- separate handler needed - and it still shows up in Settings > Key Bindings > FiveM if anyone
-- wants to rebind it.
RegisterKeyMapping('coords', 'Lite dev: imprime as coordenadas atuais (/coords)', 'keyboard', 'F9')

-- Lite dev tools: teleports straight to a coordinate, bypassing whatever road/door exists (or
-- doesn't) to reach it - the only way to check whether an interior actually renders at a given
-- address without a real walkable entrance nearby.
devCommand('tp', function(_, args)
    local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
    if not x or not y or not z then
        srvError('Uso: /tp <x> <y> <z>')
        return
    end

    -- Servidor: a bare `SetEntityCoords` was not enough and cost real time to work out. Teleporting
    -- into a cell the client has not streamed - which is every underground DLC interior, and most
    -- of the map from far enough away - drops the ped somewhere with no collision, and the engine
    -- either falls them through or puts them back. Reported as "/tp diz que teleportou e nada
    -- acontece", and earlier as landing in limbo while scouting interiors for `srv_ammolab`.
    --
    -- The fix is the standard one: freeze, ask for collision AT the destination, wait for it, then
    -- release. The freeze is what stops the fall during the wait; without it the ped is already
    -- gone by the time the ground arrives.
    --
    -- 5s ceiling so a genuinely unreachable coordinate reports instead of hanging the command
    -- forever - and it says which happened, rather than claiming success either way.
    CreateThread(function()
        local ped = cache.ped

        -- Where to put the player back if the destination turns out to have no floor. Captured
        -- before the move, because after  it is gone.
        local origin = GetEntityCoords(ped)

        FreezeEntityPosition(ped, true)
        SetEntityCoords(ped, x, y, z, false, false, false, false)

        local deadline = GetGameTimer() + 5000

        -- Servidor: the INTERIOR is a second thing to wait for, and it cost a limbo at the Pillbox
        -- check-in to find out. `HasCollisionLoadedAroundEntity` answers for world collision only,
        -- so it returns true over the building's exterior ground while the interior the
        -- destination actually sits inside is still not ready - and the ped drops through the floor
        -- that has not arrived. Every coordinate inside an IPL has this problem; the gang bases did
        -- not hit it because their interiors are already streamed by the time anyone teleports.
        local interior = GetInteriorAtCoords(x, y, z)

        if interior ~= 0 then LoadInterior(interior) end

        local function ready()
            return HasCollisionLoadedAroundEntity(ped)
                and (interior == 0 or IsInteriorReady(interior))
        end

        while not ready() and GetGameTimer() < deadline do
            RequestCollisionAtCoord(x, y, z)
            Wait(0)
        end

        FreezeEntityPosition(ped, false)

        if ready() then
            -- The destination streamed, but that does not mean it has a floor. Pillbox is the case
            -- that proved it: the interior reports valid and ready while the only solid surface is
            -- the metro tunnel 26m below, so the ped was released into a shaft. A teleport that
            -- lands nobody anywhere is a failure, and it should say so from where the player still
            -- is - not from the bottom of a hole they now have to climb out of.
            local foundGround, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
            local drop = foundGround and (z - groundZ) or nil

            if not foundGround or drop > 3.0 then
                SetEntityCoords(ped, origin.x, origin.y, origin.z, false, false, false, false)

                TriggerServerEvent('srv_tools:server:log', 'tp', {
                    requested = ('%.2f, %.2f, %.2f'):format(x, y, z),
                    result = 'RECUSADO - sem piso',
                    groundZ = foundGround and ('%.2f'):format(groundZ) or nil,
                    fallDistance = drop and ('%.2f'):format(drop) or nil,
                    interior = interior,
                })

                return srvError(foundGround
                    and ('Sem piso em z=%.2f (o chão está em %.2f, %.1fm abaixo). Você NÃO foi movido.'):format(z, groundZ, drop)
                    or ('Sem chão nenhum em %.2f, %.2f. Você NÃO foi movido.'):format(x, y))
            end

            TriggerServerEvent('srv_tools:server:log', 'tp', {
                requested = ('%.2f, %.2f, %.2f'):format(x, y, z),
                result = 'OK',
                groundZ = ('%.2f'):format(groundZ),
                interior = interior,
            })

            srvInfo(('Teleportado para %s.'):format(formatVec4(vec3(x, y, z), GetEntityHeading(ped))))
        else
            -- Names WHICH of the two failed. A single 'collision did not load' message was wrong
            -- half the time once interiors were waited for as well, and a diagnostic that blames
            -- the wrong subsystem sends the next person looking in the wrong place.
            local reason = not HasCollisionLoadedAroundEntity(ped) and 'a colisão do mundo'
                or ('o interior %s'):format(interior)

            TriggerServerEvent('srv_tools:server:log', 'tp', {
                requested = ('%.2f, %.2f, %.2f'):format(x, y, z),
                result = 'TIMEOUT - ' .. reason,
                interior = interior,
            })

            srvError(('%s não carregou em %.2f, %.2f, %.2f — você FOI movido, mas o chão pode não estar lá. Saia com outro /tp.'):format(reason, x, y, z))
        end
    end)
end, false)

-- Lite dev tools: drops a GPS route waypoint on the map, for scouting a location on foot/by car
-- instead of /tp'ing straight there - needed when the point being checked is exactly "does a real
-- walkable entrance exist here" (SetNewWaypoint only takes x/y; z is irrelevant to GPS routing).
devCommand('wp', function(_, args)
    local x, y = tonumber(args[1]), tonumber(args[2])
    if not x or not y then
        srvError('Uso: /wp <x> <y>')
        return
    end

    SetNewWaypoint(x, y)
    srvInfo(('Waypoint marcado em %.2f, %.2f.'):format(x, y))
end, false)

-- Ghost preview vehicle that follows the player so showroom/spawn spots can be placed by eye.
-- /placecar <model> to spawn+follow, /lockcar to freeze it and print its vec4, /removecar to delete.
local previewVeh

local function deletePreview()
    deleteLocalEntity(previewVeh)
    previewVeh = nil
end

devCommand('placecar', function(_, args)
    local model = args[1]
    if not model then
        srvError('Uso: /placecar <model>')
        return
    end

    local hash = joaat(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        srvError('Modelo inválido: ' .. model .. '.')
        return
    end

    deletePreview()

    lib.requestModel(hash)
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    previewVeh = CreateVehicle(hash, coords.x, coords.y, coords.z, GetEntityHeading(ped), false, false)
    SetEntityAlpha(previewVeh, 200, false)
    SetEntityCollision(previewVeh, false, false)
    FreezeEntityPosition(previewVeh, false)

    CreateThread(function()
        while previewVeh and DoesEntityExist(previewVeh) do
            local p = GetEntityCoords(cache.ped)
            SetEntityCoords(previewVeh, p.x, p.y, p.z, false, false, false, false)
            SetEntityHeading(previewVeh, GetEntityHeading(cache.ped))
            Wait(0)
        end
    end)

    srvInfo('Carro fantasma seguindo você. Ande até a vaga e use /lockcar quando estiver certo.')
end, false)

devCommand('lockcar', function()
    if not previewVeh or not DoesEntityExist(previewVeh) then
        srvError('Nenhum carro fantasma ativo. Use /placecar primeiro.')
        return
    end

    local formatted = formatVec4(GetEntityCoords(previewVeh), GetEntityHeading(previewVeh))

    print(('[placecar] %s'):format(formatted))
    coordsInfo(formatted)
end, false)

devCommand('removecar', function()
    deletePreview()
    srvInfo('Carro fantasma removido.')
end, false)

-- Servidor: the tier-2 house candidates that used to live here as a toggleable `/scouthouses` blip
-- set moved into `srv_robbery`'s own `Config.houses` and are now permanent, player-facing blips -
-- the scouting tool's job ended the moment the list became real content. See srv_robbery/client.lua.

-- Lite dev tools: proof-of-load marker, reported to the SERVER log so it can be read without the
-- player copying anything out of F8.
--
-- This exists because "the command does nothing at all" and "the file failed to parse and no
-- command after the error was ever registered" look identical from in game, and a client-side Lua
-- error never reaches the server log (CLAUDE.md rule 7's own caveat). If this line is missing from
-- the boot log after a player connects, the file did not finish loading and every command below the
-- break is silently absent - which is the single most useful thing to know first.
CreateThread(function()
    -- Servidor: the resource starts before the player is in the session, so the marker would be sent
    -- to nobody. Wait for the session to actually be live before reporting.
    while not NetworkIsSessionStarted() do Wait(500) end

    TriggerServerEvent('srv_tools:server:log', 'clientload', {
        'client.lua carregou por completo',
        ('comandos no arquivo: %s'):format(commandCount),
    })
end)

-- Lite dev tools: `/aimdoor` - the full picture of what the crosshair is on.
--
-- Reports the surface MATERIAL as well as the entity, because that is what separates the two
-- explanations that survive: a door leaf reads as glass or metal, a sealed facade reads as
-- concrete. `lib.raycast.fromCoords` returns the material as its fifth value and `lib.raycast.cam`
-- passes it straight through - nothing extra is needed to obtain it.
--
-- The ped's own position and heading are included so the aim can be reproduced exactly. Every
-- earlier probe reported where the RAY landed and never where the player was standing, which left
-- no way to tell a wall from a door seen from the wrong side.
--
-- Unknown material hashes are reported raw rather than dropped. The lookup below is a convenience
-- for the common cases, not a filter.
local MATERIALS = {
    [`concrete`] = 'concrete',
    [`concrete_pothole`] = 'concrete_pothole',
    [`brick`] = 'brick',
    [`marble`] = 'marble',
    [`metal_solid_small`] = 'metal_solid_small',
    [`metal_solid_medium`] = 'metal_solid_medium',
    [`metal_solid_large`] = 'metal_solid_large',
    [`metal_garage_door`] = 'metal_garage_door',
    [`metal_manhole`] = 'metal_manhole',
    [`glass_shoot_through`] = 'glass_shoot_through',
    [`glass_bulletproof`] = 'glass_bulletproof',
    [`glass_opaque`] = 'glass_opaque',
    [`car_glass_weak`] = 'car_glass_weak',
    [`wood_solid_small`] = 'wood_solid_small',
    [`wood_solid_medium`] = 'wood_solid_medium',
    [`wood_solid_large`] = 'wood_solid_large',
    [`plastic`] = 'plastic',
    [`rubber`] = 'rubber',
    [`plaster_solid`] = 'plaster_solid',
}

devCommand('aimdoor', function()
    local pedCoords = GetEntityCoords(cache.ped)
    local hit, entity, endCoords, _, material = lib.raycast.cam(1 | 16)

    local report = {
        pedCoords = ('%.2f, %.2f, %.2f'):format(pedCoords.x, pedCoords.y, pedCoords.z),
        pedHeading = math.floor(GetEntityHeading(cache.ped) + 0.5),
        hit = hit,
        entityType = entity and entity > 0 and GetEntityType(entity) or 0,
        hitCoords = endCoords and ('%.2f, %.2f, %.2f'):format(endCoords.x, endCoords.y, endCoords.z) or nil,
        material = material,
        materialName = MATERIALS[material] or 'DESCONHECIDO',
        distanceToHit = endCoords and ('%.2f'):format(#(pedCoords - endCoords)) or nil,
    }

    if report.entityType == 3 then
        local objCoords = GetEntityCoords(entity)

        report.model = GetEntityModel(entity)
        report.objectCoords = ('%.4f, %.4f, %.4f'):format(objCoords.x, objCoords.y, objCoords.z)
        report.heading = math.floor(GetEntityHeading(entity) + 0.5)
    end

    TriggerServerEvent('srv_tools:server:log', 'aimdoor', report)
    srvInfo(('Material: %s. Tipo: %s. Detalhes no log.'):format(report.materialName, report.entityType))
end, false)


-- Lite dev tools: `/finddoor [raio]` - finds a MAP door, which `/doorinfo` structurally cannot.
--
-- `/doorinfo` walks `GetGamePool('CObject')`. That pool holds script objects only, so a door baked
-- into the map is never in it - the empty result there was not evidence that the door does not
-- exist, only that the wrong pool was being searched.
--
-- `ox_doorlock` does not need an entity: `AddDoorToSystem(hash, model, x, y, z, ...)` builds the
-- door from a model hash and a coordinate. So all that is missing is those three values.
--
-- The raycast is run as a MATRIX because `ox_doorlock` casts `lib.raycast.cam(1|16)`, which leaves
-- ox_lib's `ignore` at its default of 4 (NO_COLLISION) - glass is NOT ignored. A glass door would
-- stop that ray on the pane, report world geometry, and never outline. Varying `ignore` and the
-- distance separates "there is no door" from "the ray never reached the door".
local RAYCASTS = {
    { label = 'ox_doorlock (1|16, ignore 4, 10m)', flags = 1 | 16, ignore = 4, distance = 10 },
    { label = 'sem vidro (1|16, ignore 7, 10m)',   flags = 1 | 16, ignore = 7, distance = 10 },
    { label = 'so objetos (16, ignore 7, 25m)',    flags = 16,     ignore = 7, distance = 25 },
    { label = 'tudo (511, ignore 7, 25m)',         flags = 511,    ignore = 7, distance = 25 },
}

devCommand('finddoor', function(_, args)
    local radius = tonumber(args[1]) or 10.0
    local pedCoords = GetEntityCoords(cache.ped)

    local report = { radius = radius, near = {}, raycasts = {} }

    -- Control first. A door of our own is injected at the ped's feet, so if the walk below cannot
    -- even find THAT, the native or this iteration is at fault and a count of zero says nothing
    -- about the map. Without this, a broken instrument reads exactly like an empty door system.
    AddDoorToSystem(`litecontrol`, `prop_gate_prison_01`, pedCoords.x, pedCoords.y, pedCoords.z, false, false, false)

    local active = DoorSystemGetActive()
    local total, controlSeen = 0, false

    for key, value in pairs(active or {}) do
        total += 1

        local handle = tonumber(value) or tonumber(key)
        local coords = handle and GetEntityCoords(handle)

        if coords then
            local distance = #(pedCoords - coords)

            if distance <= radius then
                report.near[#report.near + 1] = {
                    doorHash = tostring(key),
                    model = GetEntityModel(handle),
                    coords = ('%.4f, %.4f, %.4f'):format(coords.x, coords.y, coords.z),
                    heading = math.floor(GetEntityHeading(handle) + 0.5),
                    distance = ('%.2f'):format(distance),
                }
            end
        end

        if tostring(key) == tostring(`litecontrol`) or tostring(value) == tostring(`litecontrol`) then
            controlSeen = true
        end
    end

    RemoveDoorFromSystem(`litecontrol`)

    report.doorSystemTotal = total
    report.controlSeen = controlSeen
    report.activeType = type(active)

    for i = 1, #RAYCASTS do
        local test = RAYCASTS[i]
        local hit, entity = lib.raycast.cam(test.flags, test.ignore, test.distance)
        local entityType = entity and entity > 0 and GetEntityType(entity) or 0
        local line = { test = test.label, hit = hit, entityType = entityType }

        if entityType == 3 then
            local coords = GetEntityCoords(entity)

            line.model = GetEntityModel(entity)
            line.coords = ('%.4f, %.4f, %.4f'):format(coords.x, coords.y, coords.z)
            line.heading = math.floor(GetEntityHeading(entity) + 0.5)
        end

        report.raycasts[i] = line
    end

    TriggerServerEvent('srv_tools:server:log', 'finddoor', report)
    srvInfo(('%s portas no raio (%s no sistema, controle=%s). Detalhes no log.'):format(
        #report.near, total, tostring(controlSeen)))
end, false)

-- Lite dev tools: `/groundz <x> <y> <z>` - is there a floor at this coordinate?
--
-- Built after `/tp` dropped the player through the Pillbox check-in twice. `/tp` is a destructive
-- way to ask that question: if the answer is no, you find out by falling into the metro tunnel and
-- have to teleport back out. This asks the engine directly and moves nobody.
--
-- `GetGroundZFor_3dCoord` is the answer. It reports the height of the first solid surface below the
-- point, so `z - groundZ` is exactly how far a teleported ped would fall - and a `false` return
-- means there is no floor beneath that point at all.
--
-- These natives only answer for geometry the client has STREAMED, so an unstreamed cell reports
-- "no ground" for a place that has plenty. The distance to the ped is reported for that reason: an
-- answer from 500m away is not evidence, and this says so rather than letting a false negative
-- read as a finding.
devCommand('groundz', function(_, args)
    local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])

    if not x or not y or not z then
        return srvError('Uso: /groundz <x> <y> <z>')
    end

    CreateThread(function()
        -- Force the game to stream the target instead of requiring the player to stand next to it.
        -- `RequestCollisionAtCoord` alone only helps for a cell already near the player, which made
        -- this command useless for exactly the question it was built to answer: a place with no
        -- floor cannot be walked to, so "get within 15m" is impossible whenever the answer is the
        -- interesting one. `NewLoadSceneStartSphere` loads a remote sphere for real - it is what the
        -- engine uses to prepare a cutscene at a distant location.
        local deadline = GetGameTimer() + 8000
        local sceneLoaded = false

        NewLoadSceneStop()
        NewLoadSceneStartSphere(x, y, z, 100.0, 0)

        while GetGameTimer() < deadline do
            RequestCollisionAtCoord(x, y, z)

            if IsNewLoadSceneLoaded() then
                sceneLoaded = true
                break
            end

            Wait(0)
        end

        -- Let collision settle inside the freshly loaded sphere before measuring.
        Wait(500)

        local target = vec3(x, y, z)
        local distance = #(GetEntityCoords(cache.ped) - target)
        local interior = GetInteriorAtCoords(x, y, z)
        local foundGround, groundZ = GetGroundZFor_3dCoord(x, y, z, false)

        local report = {
            requested = ('%.2f, %.2f, %.2f'):format(x, y, z),
            distanceFromPed = ('%.1f'):format(distance),
            -- Two different thresholds, because the two answers stream at very different ranges.
            -- World collision reaches hundreds of metres; INTERIOR collision does not - an
            -- interior can report valid and ready while its floor is not loaded for a player
            -- standing outside the building, and `GetGroundZFor_3dCoord` then answers false for a
            -- floor that is really there. A single 200m rule marked exactly that reading as
            -- trustworthy and it was not.
            trustworthy = interior ~= 0 and distance < 15.0 or interior == 0 and distance < 200.0,
            interior = interior,
            interiorValid = interior ~= 0 and IsValidInterior(interior) or false,
            interiorReady = interior ~= 0 and IsInteriorReady(interior) or false,
            groundFound = foundGround,
            groundZ = foundGround and ('%.2f'):format(groundZ) or nil,
            fallDistance = foundGround and ('%.2f'):format(z - groundZ) or nil,
        }

        TriggerServerEvent('srv_tools:server:log', 'groundz', report)

        if not report.trustworthy then
            local limit = interior ~= 0 and 15 or 200

            srvError(('A %.0fm, e o limite útil aqui é %dm (%s) — a resposta NÃO vale. Chegue mais perto.'):format(
                distance, limit, interior ~= 0 and 'há interior, a colisão transmite perto' or 'so mundo'))
        elseif foundGround then
            srvInfo(('Chão em z=%.2f. Você cairia %.2fm. Interior: %s.'):format(groundZ, z - groundZ, interior))
        else
            srvError(('SEM CHÃO em %.2f, %.2f. Interior: %s.'):format(x, y, interior))
        end
    end)
end, false)

-- Servidor dev tools: `/whichdoor` - which registered doorlock am I standing at?
--
-- `ox_doorlock`'s own prompt says only "Trancar porta" / "Destrancar porta". It never shows the
-- door's name or id, so a room full of identical fire doors is impossible to edit: you can see that
-- a door is locked and still have no idea which row in the table it is.
--
-- Reads the resource's own `getClosestDoor` export rather than re-deriving proximity here, so this
-- always agrees with the door the [E] prompt is actually offering - a second, independent "nearest"
-- calculation would drift from it at exactly the boundaries where the answer matters.
devCommand('whichdoor', function()
    local door = exports.ox_doorlock:getClosestDoor()

    if not door then
        return srvError('Nenhuma porta registrada por perto. Chegue mais perto de uma.')
    end

    local groups = {}

    for name, grade in pairs(door.groups or {}) do
        groups[#groups + 1] = ('%s:%s'):format(name, grade)
    end

    local report = {
        id = door.id,
        name = door.name,
        state = door.state == 1 and 'TRANCADA' or 'destrancada',
        groups = #groups > 0 and table.concat(groups, ', ') or 'nenhum (qualquer um abre)',
        double = door.doors ~= nil,
        maxDistance = door.maxDistance,
        lockpick = door.lockpick or false,
    }

    TriggerServerEvent('srv_tools:server:log', 'whichdoor', report)
    srvInfo(('#%s "%s" — %s — grupos: %s'):format(report.id, report.name, report.state, report.groups))
end, false)

-- Servidor dev tools: `/medstate` - what the medical system thinks is happening.
--
-- Added when the downed panel did not appear and neither its key nor qbx_ambulancejob's own G did
-- anything. Two independent systems failing together points at the STATE both read rather than at
-- either one's code, and this reports that state instead of guessing at it.
devCommand('medstate', function()
    local report = {
        isDead = exports.qbx_medical:IsDead(),
        isLaststand = exports.qbx_medical:IsLaststand(),
        deathTime = exports.qbx_medical:GetDeathTime(),
        laststandTime = exports.qbx_medical:GetLaststandTime(),
        pedHealth = GetEntityHealth(cache.ped),
        pedDead = IsEntityDead(cache.ped),
        -- The panel's own gate, reported separately so a mismatch between the two is visible.
        rescueResourceState = GetResourceState('srv_rescue'),
    }

    TriggerServerEvent('srv_tools:server:log', 'medstate', report)
    srvInfo(('morto=%s laststand=%s vida=%s'):format(
        tostring(report.isDead), tostring(report.isLaststand), report.pedHealth))
end, false)
