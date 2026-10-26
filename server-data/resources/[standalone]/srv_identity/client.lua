-- Servidor: the character's own document - identification, occupation and licences.
--
-- Opened from the radial's Meu Personagem group and by /documento.
--
-- This is the ONE screen on the server that deliberately does not use the project's monochrome GFX
-- layout. It is a NUI page styled as paper: an object the character is holding, not a menu the
-- player is operating. Requested that way, and it is the reason this resource carries a `web/`
-- folder when `srv_tutorial` next door pointedly does not. See ADR-132.
--
-- Not `qbx_idcard`, which is the physical card you SHOW someone by using the item - that is an
-- interaction with another player. This is your own record.

--- `QBX` comes from the `@qbx_core/modules/playerdata.lua` shim in `fxmanifest.lua`. Read without
--- a nil guard on purpose - see docs/conventions.md, "QBX is not a shared global", and CLAUDE.md
--- rule 5. A `nil` here means the shim is missing and must fail loudly.

local GENDERS <const> = { [0] = 'Masculino', [1] = 'Feminino' }

--- The licence keys, in display order, with their player-facing names. Mirrors the table in
--- `docs/architecture.md` § `PlayerData.metadata.licences` - kept in sync by hand, since neither
--- is generated from the other. A licence added there and not here simply never appears.
local LICENCES <const> = {
    { key = 'id', label = 'RG' },
    { key = 'driver', label = 'Habilitação' },
    { key = 'weapon', label = 'Porte - Pistola' },
    { key = 'weaponshotgun', label = 'Porte - Escopeta' },
    { key = 'weaponrifle', label = 'Porte - Rifle' },
    { key = 'weaponexpert', label = 'Porte - Especialista' },
}

local isOpen = false

local function closeDocument()
    if not isOpen then return end

    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

function OpenDocument()
    if isOpen then return closeDocument() end

    local data = QBX.PlayerData
    local info = data.charinfo
    local job = data.job
    local gang = data.gang
    local licences = data.metadata.licences or {}

    local held = {}
    for i = 1, #LICENCES do
        if licences[LICENCES[i].key] then
            held[#held + 1] = LICENCES[i].label
        end
    end

    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        payload = {
            firstname = info.firstname,
            lastname = info.lastname,
            birthdate = info.birthdate,
            gender = GENDERS[info.gender] or 'Não informado',
            nationality = info.nationality,
            phone = info.phone,
            citizenid = data.citizenid,
            job = job.label,
            grade = job.grade.name,
            duty = job.onduty and 'Em serviço' or 'Fora de serviço',
            -- `false` rather than nil: nil would be dropped from the JSON object entirely, and the
            -- page tests for the key's truthiness to decide whether to render the two gang rows.
            gang = gang.name ~= 'none' and gang.label or false,
            gangGrade = gang.name ~= 'none' and gang.grade.name or false,
            licences = held,
        },
    })
end

RegisterNUICallback('close', function(_, cb)
    closeDocument()
    cb('ok')
end)

RegisterNetEvent('srv_identity:client:open', OpenDocument)

-- Plain `RegisterCommand`: `lib.addCommand` is server-only in ox_lib, and this reads nothing the
-- client does not already hold. Same reasoning as `srv_tutorial`.
for _, name in ipairs({ 'documento', 'doc' }) do
    RegisterCommand(name, OpenDocument, false)
    TriggerEvent('chat:addSuggestion', ('/%s'):format(name), 'Mostra seu documento e situação.')
end

-- Losing NUI focus without the page telling us would leave the player unable to move. Clearing on
-- resource stop is the one case the page cannot report itself.
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
