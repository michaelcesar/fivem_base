-- Servidor shared client primitives.
--
-- These exist so the patterns in docs/conventions.md are the path of least resistance
-- rather than something each resource has to remember to reimplement. Every one of them
-- comes from a bug that reached the live server.
--
-- Consume from another resource via exports, e.g.:
--   exports.srv_lib:DeleteLocalEntity(entity)

--- Deletes an entity that was created local (isNetwork = false).
---
--- `SetEntityAsMissionEntity`'s second argument must match how the entity was created.
--- Claiming a local entity as networked does not apply, and the DeleteEntity that follows
--- then does nothing at all - silently, with the entity still standing there. This left
--- shooting range targets in the world and stacked more on top with every attempt.
---@param entity number?
local function deleteLocalEntity(entity)
    if not entity or not DoesEntityExist(entity) then return end

    SetEntityAsMissionEntity(entity, false, true)
    DeleteEntity(entity)
end

exports('DeleteLocalEntity', deleteLocalEntity)

--- Deletes a list of local entities. Safe to call with a list holding stale handles.
---@param entities number[]?
local function deleteLocalEntities(entities)
    if not entities then return end

    for i = 1, #entities do
        deleteLocalEntity(entities[i])
    end
end

exports('DeleteLocalEntities', deleteLocalEntities)

--- Reports a client-side error to the server log.
---
--- Client errors surface only in the player's own F8 console, where nobody responsible for
--- the server ever sees them. A failure that is not on record is a failure that gets
--- reported later, vaguely, by whoever happened to be playing.
---@param context string what was running, e.g. 'srv_shootingrange:expert'
---@param err any
local function reportError(context, err)
    TriggerServerEvent('srv_lib:server:reportError', context, tostring(err))
end

exports('ReportError', reportError)

--- Runs `fn` while a guard flag is held, releasing it however the run ends.
---
--- The guard itself lives in the calling resource, because only it knows what the flag
--- means; this owns the part that is easy to get wrong. A flow that sets an in-progress
--- flag and clears it at the end of the work leaves the flag set forever if the work
--- errors - locking the player out of the feature permanently, with no message anywhere.
---
--- `onRelease` runs on every path (success, error, early return) and is where cleanup that
--- must always happen belongs - despawning entities, hiding UI.
---
--- This is containment, not a fix: it stops one bug from wedging a feature shut and puts
--- the error on record. The underlying bug still has to be found. The error is never
--- swallowed - a silent catch is the nil-guard mistake wearing a different hat.
---
---@param context string identifies the flow in the server log
---@param fn function the work to run
---@param onRelease function? cleanup that must run on every path
---@return boolean ok, any resultOrError
local function guardedRun(context, fn, onRelease)
    local ok, result = pcall(fn)

    if onRelease then
        local cleanupOk, cleanupErr = pcall(onRelease)

        if not cleanupOk then
            reportError(context .. ':cleanup', cleanupErr)
        end
    end

    if not ok then
        reportError(context, result)
    end

    return ok, result
end

exports('GuardedRun', guardedRun)

--- Client-side twin of `srv_lib`'s own server `IsInGang`, for showing a refusal before the
--- player commits to an action rather than after the round trip.
---
--- This is a FAST PATH, never the authority (CLAUDE.md rule 2). Every gated callback re-checks
--- server-side, and a client that lies about its gang gets nothing but a UI that looks different.
---
--- `QBX` here is this resource's own table, created by the `@qbx_core/modules/playerdata.lua`
--- shim listed in `fxmanifest.lua` - see docs/conventions.md, "QBX is not a shared global". It is
--- read WITHOUT a nil guard on purpose: if that shim is ever dropped from the manifest, this must
--- crash loudly rather than quietly return false forever and leave every farm looking closed to
--- everybody (CLAUDE.md rule 5, and the exact way the crosshair and course gating both broke).
---@param gangName string?
---@return boolean
local function isInGang(gangName)
    if not gangName or gangName == 'none' then return true end

    return QBX.PlayerData.gang.name == gangName
end

exports('IsInGang', isInGang)

--- The refusal message shown when a player tries to use a site their gang does not own.
---
--- Lives here rather than being written out in each farm's own `reasons` table so all six word it
--- identically and all six name the gang by its real label (`qbx_core`'s own `GetGangs`) instead of
--- the lowercase config key a player never sees.
---@param gangName string?
---@return string
local function gangDeniedMessage(gangName)
    local gangs = exports.qbx_core:GetGangs()
    local label = gangs[gangName] and gangs[gangName].label or gangName

    return ('Este local é território dos %s. Você não faz parte.'):format(label)
end

exports('GangDeniedMessage', gangDeniedMessage)

--- The player's gang `{ name, label }` if they are its boss, otherwise `nil`.
---
--- Exists so a resource can offer a boss-only entry point (the gang's bank account at a Fleeca
--- teller, for instance) without each one reaching into `QBX.PlayerData` itself and needing the
--- `playerdata.lua` shim in its own manifest.
---
--- `isboss` is `qbx_core`'s own flag, set from the gang grade's `isboss` in `shared/gangs.lua`.
--- Purely a UI fast path: whether the boss can actually DO anything with the account is decided by
--- `Renewed-Banking`'s own server-side `IsGangAuth`, which reads `bankAuth` on the same grade.
--- Returned as a table rather than two values: multiple returns across a FiveM export boundary are
--- not reliable, and the caller needs both halves - the label to show, and the name, which is also
--- the id `Renewed-Banking` stores the gang's account under.
---@return {name: string, label: string}?
local function gangBossLabel()
    local gang = QBX.PlayerData.gang

    if gang.name == 'none' or not gang.isboss then return end

    return { name = gang.name, label = gang.label }
end

exports('GangBossLabel', gangBossLabel)

-- Servidor: the map colour each gang's territory is drawn in. Follows GTA's own gang colours where
-- they exist - Families green, Ballas purple, Vagos yellow, Triads red - and picks the remaining
-- two to stay distinguishable at map scale rather than to mean anything.
--
-- 9 (the old shared grey) is the fallback, so a site with no `ownerGang` keeps exactly the look
-- every site used to have.
--
-- IMPORTANT: blip colour IDs cannot be checked from the repo the way a model name can with
-- `/testprop` - a wrong number is simply a different colour, never an error. These want one visual
-- pass in-game. See ADR-133.
-- The blip is NAMED after the colour, never after the gang - "Área roxa", not "Ballas". That keeps
-- the original rule this project shipped under (the map shows that ground is held, never by whom)
-- while still separating the six. Which colour belongs to which gang is learned in play, not read.
--
-- `name` is the adjective in the FEMININE, because every label it builds starts with a feminine
-- noun - "Área", "Base". Portuguese agreement is why this is an adjective rather than the plural
-- noun it used to be ("Roxos"): "Área roxos" is not a sentence. Same trap the injury messages hit
-- (ADR-132), avoided here by storing the form that actually gets used.
local GANG_BLIP_COLOURS <const> = {
    families = { colour = 2,  name = 'verde' },
    ballas   = { colour = 7,  name = 'roxa' },
    vagos    = { colour = 5,  name = 'amarela' },
    triads   = { colour = 1,  name = 'vermelha' },
    cartel   = { colour = 17, name = 'laranja' },
    lostmc   = { colour = 4,  name = 'branca' },
}

--- The colour a gang's territory is drawn in, and the plural colour name to label it with.
---
--- Deliberately does NOT consult `qbx_core:GetGangs()` - and the reason changed. It used to be that
--- the real label WAS the gang's name ("Ballas") and putting it on the map would have told every
--- player who holds what (ADR-134). That label is now a colour too (ADR-155), so the two no longer
--- disagree about what to say.
---
--- They still disagree about the FORM. This one is a feminine singular adjective, because it goes
--- into "Área %s" and "Base %s"; `gangs.lua` holds a plural masculine noun, because it goes into
--- "território dos %s". Storing each in the form its sentence needs is ADR-138's rule, and it is
--- why one table cannot serve both.
---
--- A table, not two return values - see `GangBossLabel` above for why: multiple returns across a
--- FiveM export boundary are not reliable.
---@param gangName string?
---@return {colour: number, label: string?}
local function gangBlipStyle(gangName)
    local style = gangName and GANG_BLIP_COLOURS[gangName]

    -- Unowned, or a gang with no colour assigned: exactly the old shared look.
    if not style then return { colour = 9 } end

    return { colour = style.colour, label = style.name }
end

exports('GangBlipStyle', gangBlipStyle)

--- Draws a gang territory/base marker as a coloured CIRCLE on the map, matching the style
--- `qbx_garages` already uses for its own areas (sprite 1 + display 4 + alpha 140).
---
--- Replaces the plain skull point every illegal site used to draw: a circle reads as an AREA, which
--- is what a territory is, and a point reads as a doorway, which it is not. Using the garages' own
--- numbers rather than inventing a look means the map stays one visual language. See ADR-137.
---
--- Labelled "Área <cor>" by default - "Área roxa", "Área verde". `labelFormat` overrides the noun
--- for a caller that wants a different one ('Base %s'); it must stay FEMININE, since the colour
--- name is a feminine adjective.
---@param coords vector3
---@param gangName string?
---@param labelFormat string? defaults to 'Área %s'
---@return number blip
local function createGangBlip(coords, gangName, labelFormat)
    local style = gangBlipStyle(gangName)
    local name = style.label or 'desconhecida'
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.4)
    SetBlipColour(blip, style.colour)
    SetBlipAlpha(blip, 140)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName((labelFormat or 'Área %s'):format(name))
    EndTextCommandSetBlipName(blip)

    return blip
end

exports('CreateGangBlip', createGangBlip)

--- A single POINT inside a gang's base, drawn as a smaller circle in the same visual language.
---
--- Same sprite, display and colour as `createGangBlip` above, deliberately - the map should read as
--- one system, and a base's contents belong to the same family as the area around them. Only the
--- scale and alpha differ: smaller so a handful of them inside one building do not merge into a
--- blob, and slightly more opaque so they stay legible at that size.
---
--- Takes a plain `label` rather than `createGangBlip`'s `labelFormat`, because these are named for
--- what they ARE ('Baú', 'Cofre') and not for the gang's colour. Passing a literal through
--- `labelFormat` would happen to work today and break the moment a label contains a `%`.
---@param coords vector3
---@param gangName string?
---@param label string
---@return number blip
local function createGangPointBlip(coords, gangName, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.22)
    SetBlipColour(blip, gangBlipStyle(gangName).colour)
    SetBlipAlpha(blip, 190)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(blip)

    return blip
end

exports('CreateGangPointBlip', createGangPointBlip)

--- The RGB a gang's ground markers are drawn in.
---
--- Separate from `GangBlipStyle` because the two take different things: a blip takes GTA's own
--- colour INDEX, `DrawMarker` takes raw RGB. Keeping one table of indices and a second of RGB is
--- what lets the map and the ground actually match - deriving one from the other is not possible,
--- GTA does not expose the palette.
---
--- Kept next to `GANG_BLIP_COLOURS` so the pair moves together. A colour changed in one and not the
--- other is a marker that disagrees with its own map circle, and nothing catches that.
local GANG_MARKER_RGB <const> = {
    families = { 60, 190, 90 },    -- green
    ballas   = { 150, 90, 200 },   -- violet
    vagos    = { 240, 200, 60 },   -- yellow
    triads   = { 220, 70, 70 },    -- red
    cartel   = { 240, 150, 60 },   -- orange
    lostmc   = { 230, 230, 230 },  -- white
}

--- Falls back to the same neutral grey an unowned site's blip uses.
---@param gangName string?
---@return number[] rgb
local function gangMarkerColour(gangName)
    return (gangName and GANG_MARKER_RGB[gangName]) or { 160, 160, 160 }
end

exports('GangMarkerColour', gangMarkerColour)
