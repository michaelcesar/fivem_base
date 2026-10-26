local bags = {[40] = true, [41] = true, [44] = true, [45] = true}

-- Servidor: `gangItems` below shipped as an empty table - the hook existed and nothing ever filled
-- it. Now that ADR-125 made gangs own the six production sites, this is the natural place for the
-- actions that come with owning one, and it costs no new menu: the radial already shows a "Gangue"
-- group automatically for any gang with entries here.
--
-- Every gang gets the same two actions, so they are declared once and shared rather than copied six
-- times. Both are `serverEvent` - the radial is a menu, not a permission, and `srv_gangs` re-checks
-- membership and position server-side on arrival (ADR-126).
local gangRadialItems = {
    {
        id = 'gangStash',
        icon = 'box-archive',
        label = 'Baú da Gangue',
        serverEvent = 'srv_gangs:server:openStash',
    },
    {
        id = 'gangVault',
        icon = 'vault',
        label = 'Cofre da Gangue',
        serverEvent = 'srv_gangs:server:openVault',
    },
    {
        id = 'gangAccount',
        icon = 'sack-dollar',
        label = 'Caixa da Gangue',
        serverEvent = 'srv_gangs:server:checkAccount',
    },
}

local gangItems = {}
for _, gang in ipairs({ 'families', 'cartel', 'lostmc', 'ballas', 'triads', 'vagos' }) do
    gangItems[gang] = gangRadialItems
end

-- Servidor: the roleplay half of the wheel. `scully_emotemenu` ships an enormous library - 1642
-- dances alone, plus 501 general and 374 prop emotes - which is exactly why this is a CURATED
-- selection and not a dump: a radial is a wheel, and the full catalogue is what `/em` is for.
-- What is here is the set worth reaching in one gesture mid-scene.
--
-- Every `Command` below was checked against `scully_emotemenu/shared/data/emotes/*.lua` before
-- being written down - a wrong name fails at the far end with "not a valid emote" and nothing else
-- (CLAUDE.md rule 4 in spirit: an animation name cannot be verified by reading this file).
--
-- Dispatch is the resource's own `scully_emotemenu:playEmoteByCommand` net event rather than
-- `ExecuteCommand('e ...')`, so nothing depends on the `e`/`emote`/`eplay` command aliases staying
-- as they are (they are convar-driven, `scully_emotemenu:emoteCommands`).
---@param id string
---@param label string
---@param command string
---@param icon string
local function emote(id, label, command, icon)
    return {
        id = id,
        icon = icon,
        label = label,
        event = 'scully_emotemenu:playEmoteByCommand',
        args = command,
    }
end

-- Servidor: the commands that had no radial equivalent, added so the wheel really is the whole
-- interface rather than half of it.
--
-- These five all need TYPED TEXT, which is why they were commands in the first place and why they
-- are `onSelect` closures with a `lib.inputDialog` rather than plain `event` rows - a wheel cannot
-- carry a sentence. The command still works for anyone who prefers typing; this is a second door
-- to the same room, not a replacement. See ADR-130.
--
-- `/job` and `/gang` are here too, as plain readouts. They need no input and were only ever
-- commands because there was nowhere else to put them.
local function inputCommand(id, label, icon, dialogTitle, fieldLabel, command)
    return {
        id = id,
        icon = icon,
        label = label,
        onSelect = function()
            local input = lib.inputDialog(dialogTitle, {
                { type = 'input', label = fieldLabel, required = true },
            })

            if not input or not input[1] or input[1] == '' then return end

            ExecuteCommand(('%s %s'):format(command, input[1]))
        end,
    }
end

local communicationGroup = {
    id = 'communication',
    icon = 'comments',
    label = 'Comunicação',
    items = {
        -- Servidor: 'Ação', not 'Ação (/me)'. The wheel exists so you do not have to type the
        -- command; printing the command inside it is telling you to do the thing you are avoiding.
        inputCommand('cmd_me', 'Ação', 'comment-dots',
            'Descrever uma ação', 'O que você faz', 'me'),
        -- Out-of-character speech is deliberately NOT here: it already has a key of its own, and a
        -- second way in only costs a row on a wheel that has to be read at a glance. See ADR-157.
        inputCommand('cmd_911p', 'Chamar Polícia', 'shield-halved',
            'Chamar a polícia', 'O que está acontecendo', '911p'),
        inputCommand('cmd_911e', 'Chamar Ambulância', 'truck-medical',
            'Chamar a ambulância', 'O que está acontecendo', '911e'),
        inputCommand('cmd_report', 'Falar com a Administração', 'flag',
            'Enviar denúncia', 'Mensagem', 'report'),
    },
}

local selfGroup = {
    id = 'self',
    icon = 'id-card',
    label = 'Meu Personagem',
    items = {
        -- Servidor: one document screen replaces what used to be two separate rows firing `/job`
        -- and `/gang`. Those were chat notifications - one line each, fired separately, gone as
        -- soon as anything else was said. `srv_identity` puts identification, occupation and
        -- licences on one screen that stays until closed. See ADR-131.
        {
            id = 'openDocument',
            icon = 'id-card',
            label = 'Documento',
            event = 'srv_identity:client:open',
        },
        {
            id = 'cmd_cancelprogress',
            icon = 'circle-stop',
            label = 'Cancelar Ação',
            command = 'cancelprogress',
            args = '',
        },
    },
}

local emoteGroup = {
    id = 'emotes',
    icon = 'masks-theater',
    label = 'Ações',
    items = {
        {
            id = 'dances',
            icon = 'music',
            label = 'Danças',
            items = {
                emote('dance1', 'Dançar', 'dance', 'music'),
                emote('dance2', 'Dançar 2', 'dance5', 'music'),
                emote('dance3', 'Dançar 3', 'dance12', 'music'),
                emote('dance4', 'Dançar 4', 'dance28', 'music'),
                emote('dance5', 'Dançar 5', 'dance44', 'music'),
                emote('dancebeach', 'Dança de Praia', 'dancebeach3', 'umbrella-beach'),
                emote('dancedrink', 'Dançar com Copo', 'dancedrink2', 'martini-glass'),
                emote('twerk', 'Twerk', 'twerk', 'music'),
            },
        },
        {
            id = 'greetings',
            icon = 'handshake',
            label = 'Cumprimentos',
            items = {
                emote('wave', 'Acenar', 'wave', 'hand'),
                emote('handshake', 'Aperto de Mão', 'handshake', 'handshake'),
                emote('salute', 'Continência', 'salute', 'hand'),
                emote('bow', 'Reverência', 'bow', 'person'),
                emote('hug', 'Abraçar', 'hug', 'people-arrows'),
                emote('clap', 'Aplaudir', 'clap', 'hands-clapping'),
            },
        },
        {
            id = 'reactions',
            icon = 'face-smile',
            label = 'Reações',
            items = {
                emote('thumbsup', 'Joinha', 'thumbsup', 'thumbs-up'),
                emote('facepalm', 'Facepalm', 'facepalm', 'face-palm'),
                emote('shrug', 'Dar de Ombros', 'shrug', 'person'),
                emote('point', 'Apontar', 'point', 'hand-point-right'),
                emote('no', 'Negar', 'no', 'xmark'),
                emote('noway', 'Sem Chance', 'noway', 'ban'),
                emote('argue', 'Discutir', 'argue', 'comments'),
                emote('think', 'Pensar', 'think', 'lightbulb'),
            },
        },
        {
            id = 'postures',
            icon = 'person',
            label = 'Posturas',
            items = {
                emote('sit', 'Sentar', 'sit', 'chair'),
                emote('kneel', 'Ajoelhar', 'kneel2', 'person-praying'),
                emote('lean', 'Encostar', 'lean', 'person'),
                emote('crossarms', 'Cruzar os Braços', 'crossarms', 'person'),
                emote('pockets', 'Mãos no Bolso', 'handsinpockets', 'person'),
                emote('sleep', 'Dormir', 'sleep', 'bed'),
                emote('idle', 'Descansar', 'idle', 'person'),
            },
        },
        {
            id = 'rpactions',
            icon = 'hands-bound',
            label = 'Situação',
            items = {
                emote('handsup', 'Mãos ao Alto', 'handsup', 'hands-bound'),
                emote('surrender', 'Render-se', 'surrender', 'flag'),
                emote('cuffed', 'Algemado', 'cuffed', 'handcuffs'),
                emote('notepad', 'Anotar', 'notepad', 'clipboard'),
                emote('type', 'Digitar', 'type', 'keyboard'),
                emote('phonecall', 'Ligação', 'phonecall', 'phone'),
                emote('selfie', 'Selfie', 'selfie', 'camera-retro'),
                emote('smoke', 'Fumar', 'smoke2', 'smoking'),
            },
        },
        {
            id = 'stopemote',
            icon = 'ban',
            label = 'Parar Animação',
            event = 'scully_emotemenu:cancelEmote',
        },
    },
}

return {
    enableExtraMenu = true,
    flipTime = 15000,

    menuItems = {
        {
            id = 'citizen',
            icon = 'user',
            label = 'Cidadão',
            items = {
                {
                    id = 'getintrunk',
                    icon = 'car',
                    label = 'Entrar no Porta-Malas',
                    event = 'qb-trunk:client:GetIn'
                },
                },
        },
        {
            id = 'general',
            icon = 'rectangle-list',
            label = 'Geral',
            items = {
                {
                    id = 'clothesMenu',
                    icon = 'shirt',
                    label = 'Roupas',
                    items = {
                        {
                            id = 'hair',
                            icon = 'user',
                            label = 'Cabelo',
                            event = 'qb-radialmenu:ToggleClothing',
                            args = {id = 'Hair'},
                        },
                        {
                            id = 'ear',
                            icon = 'ear-deaf',
                            label = 'Brincos',
                            event = 'qb-radialmenu:ToggleProps',
                            args = 'Ear',
                        },
                        {
                            id = 'neck',
                            icon = 'user-tie',
                            label = 'Pescoço',
                            event = 'qb-radialmenu:ToggleClothing',
                            args = {id = 'Neck'},
                        },
                        {
                            id = 'top',
                            icon = 'shirt',
                            label = 'Blusa',
                            event = 'qb-radialmenu:ToggleClothing',
                            args = {id = 'Top'},
                        },
                        {
                            id = 'shirt',
                            icon = 'shirt',
                            label = 'Camisa',
                            event = 'qb-radialmenu:ToggleClothing',
                            args = {id = 'Shirt'},
                        },
                        {
                            id = 'pants',
                            icon = 'user',
                            label = 'Calça',
                            event = 'qb-radialmenu:ToggleClothing',
                            args = {id = 'Pants'},
                        },
                        {
                            id = 'shoes',
                            icon = 'shoe-prints',
                            label = 'Sapatos',
                            event = 'qb-radialmenu:ToggleClothing',
                            args = {id = 'Shoes'},
                        },
                        {
                            id = 'clothingExtras',
                            icon = 'plus',
                            label = 'Extras',
                            items = {
                                {
                                    id = 'hat',
                                    icon = 'hat-cowboy-side',
                                    label = 'Chapéu',
                                    event = 'qb-radialmenu:ToggleProps',
                                    args = 'Hat',
                                },
                                {
                                    id = 'glasses',
                                    icon = 'glasses',
                                    label = 'Óculos',
                                    event = 'qb-radialmenu:ToggleProps',
                                    args = 'Glasses',
                                },
                                {
                                    id = 'visor',
                                    icon = 'hat-cowboy-side',
                                    label = 'Viseira',
                                    event = 'qb-radialmenu:ToggleProps',
                                    args = 'Visor',
                                },
                                {
                                    id = 'mask',
                                    icon = 'masks-theater',
                                    label = 'Máscara',
                                    event = 'qb-radialmenu:ToggleClothing',
                                    args = {id = 'Mask'},
                                },
                                {
                                    id = 'vest',
                                    icon = 'vest',
                                    label = 'Colete',
                                    event = 'qb-radialmenu:ToggleClothing',
                                    args = {id = 'Vest'},
                                },
                                {
                                    id = 'bag',
                                    icon = 'bag',
                                    label = 'Mochila',
                                    event = 'qb-radialmenu:ToggleClothing',
                                    args = {id = 'Bag'},
                                },
                                {
                                    id = 'bracelet',
                                    icon = 'user',
                                    label = 'Pulseira',
                                    event = 'qb-radialmenu:ToggleProps',
                                    args = 'Bracelet',
                                },
                                {
                                    id = 'watch',
                                    icon = 'stopwatch',
                                    label = 'Relógio',
                                    event = 'qb-radialmenu:ToggleProps',
                                    args = 'Watch',
                                },
                                {
                                    id = 'gloves',
                                    icon = 'mitten',
                                    label = 'Luvas',
                                    event = 'qb-radialmenu:ToggleClothing',
                                    args = {id = 'Gloves'},
                                },
                            },
                        },
                    },
                },
            },
        },
        emoteGroup,
        communicationGroup,
        selfGroup,
    },

    jobItems = {
        police = {
            {
                id = 'emergencyButton',
                icon = 'bell',
                label = 'Botão de Emergência',
                event = 'police:client:SendPoliceEmergencyAlert',
            },
            {
                id = 'policeInteractions',
                icon = 'list-check',
                label = 'Interações Policiais',
                items = {
                    {
                        id = 'statusCheck',
                        icon = 'heart-pulse',
                        label = 'Verificar Estado de Saúde',
                        event = 'hospital:client:CheckStatus',
                    },
                    {
                        id = 'search',
                        icon = 'magnifying-glass',
                        label = 'Revistar',
                        event = 'police:client:SearchPlayer',
                    },
                    {
                        id = 'jail',
                        icon = 'user-lock',
                        label = 'Prender',
                        event = 'police:client:JailPlayer',
                    },
                },
            },
            {
                id = 'policeObjects',
                icon = 'road',
                label = 'Objetos Policiais',
                items = {
                    {
                        id = 'cone',
                        icon = 'triangle-exclamation',
                        label = 'Cone',
                        event = 'police:client:spawnPObj',
                        args = 'cone',
                    },
                    {
                        id = 'gate',
                        icon = 'torii-gate',
                        label = 'Portão',
                        event = 'police:client:spawnPObj',
                        args = 'barrier',
                    },
                    {
                        id = 'speedSign',
                        icon = 'sign-hanging',
                        label = 'Placa de Velocidade',
                        event = 'police:client:spawnPObj',
                        args = 'roadsign',
                    },
                    {
                        id = 'tent',
                        icon = 'campground',
                        label = 'Tenda',
                        event = 'police:client:spawnPObj',
                        args = 'tent',
                    },
                    {
                        id = 'lighting',
                        icon = 'lightbulb',
                        label = 'Iluminação',
                        event = 'police:client:spawnPObj',
                        args = 'light',
                    },
                    {
                        id = 'spikeStrip',
                        icon = 'caret-up',
                        label = 'Cerca de Pregos',
                        event = 'police:client:SpawnSpikeStrip',
                    },
                    {
                        id = 'deleteObject',
                        icon = 'trash',
                        label = 'Remover Objeto',
                        event = 'police:client:deleteObject',
                    },
                },
            },
        },
        ambulance = {
            {
                id = 'statusCheck',
                icon = 'heart-pulse',
                label = 'Verificar Estado de Saúde',
                event = 'hospital:client:CheckStatus',
            },
            {
                id = 'revive',
                icon = 'user-doctor',
                label = 'Reanimar',
                event = 'hospital:client:RevivePlayer',
            },
            {
                id = 'treatWounds',
                icon = 'bandage',
                label = 'Curar Ferimentos',
                event = 'hospital:client:TreatWounds',
            },
            {
                id = 'emergencyButton',
                icon = 'bell',
                label = 'Botão de Emergência',
                serverEvent = 'hospital:server:emergencyAlert',
            },
            },
        -- Servidor: `mechanic`, `taxi` and `tow` removed entirely rather than left as empty tables.
        -- The client only skips the job section when the key is ABSENT
        -- (`if not config.jobItems[job.name] ... then return end`) - an empty table is truthy in
        -- Lua, so a taxi driver would have got an "Emprego" wheel section with nothing inside it.
        -- `mechanic` was already empty upstream and already had that effect. Note the gang path
        -- next to it does guard for this (`and next(config.gangItems[...])`); the job path does
        -- not, which is why the key has to go rather than its contents. See ADR-127.
        --
        -- Everything these three held pointed at `qb-taxi`/`qb-tow`, which this server does not
        -- run. `srv_jobs` implements taxi and tow for real, but entirely through world `[E]`
        -- prompts - it exposes no event a radial item could call, so there was nothing to repoint
        -- them at.
    },

    gangItems = gangItems,

    vehicleDoors = {
        id = 'vehicleDoors',
        icon = 'car-side',
        label = 'Portas do Veículo',
        items = {
            {
                id = 'door0',
                icon = 'car-side',
                label = 'Porta do Motorista',
                event = 'qb-radialmenu:client:openDoor',
                args = 0,
            },
            {
                id = 'door1',
                icon = 'car-side',
                label = 'Porta do Passageiro',
                event = 'qb-radialmenu:client:openDoor',
                args = 1,
            },
            {
                id = 'door2',
                icon = 'car-side',
                label = 'Porta Traseira Esquerda',
                event = 'qb-radialmenu:client:openDoor',
                args = 2,
            },
            {
                id = 'door3',
                icon = 'car-side',
                label = 'Porta Traseira Direita',
                event = 'qb-radialmenu:client:openDoor',
                args = 3,
            },
            {
                id = 'door4',
                icon = 'car-side',
                label = 'Capô',
                event = 'qb-radialmenu:client:openDoor',
                args = 4,
            },
            {
                id = 'door5',
                icon = 'car-side',
                label = 'Porta-Malas',
                event = 'qb-radialmenu:client:openDoor',
                args = 5,
            },
        },
    },

    vehicleWindows = {
        id = 'vehicleWindows',
        icon = 'car-side',
        label = 'Janelas do Veículo',
        items = {
            {
                id = 'window0',
                icon = 'car-side',
                label = 'Janela do Motorista',
                event = 'qbx_radialmenu:client:toggleWindows',
                args = 0,
            },
            {
                id = 'window1',
                icon = 'car-side',
                label = 'Janela do Passageiro',
                event = 'qbx_radialmenu:client:toggleWindows',
                args = 1,
            },
            {
                id = 'window2',
                icon = 'car-side',
                label = 'Janela Traseira Esquerda',
                event = 'qbx_radialmenu:client:toggleWindows',
                args = 2,
            },
            {
                id = 'window3',
                icon = 'car-side',
                label = 'Janela Traseira Direita',
                event = 'qbx_radialmenu:client:toggleWindows',
                args = 3,
            },
        },
    },

    vehicleSeats = {
        id = 'vehicleSeats',
        icon = 'chair',
        label = 'Bancos do Veículo',
        menu = 'vehicleSeatsMenu'
    },

    vehicleExtras = {
        id = 'vehicleExtras',
        icon = 'plus',
        label = 'Extras do Veículo',
        items = {
            {
                id = 'extra1',
                icon = 'box-open',
                label = 'Extra 1',
                event = 'radialmenu:client:setExtra',
                args = 1,
            },
            {
                id = 'extra2',
                icon = 'box-open',
                label = 'Extra 2',
                event = 'radialmenu:client:setExtra',
                args = 2,
            },
            {
                id = 'extra3',
                icon = 'box-open',
                label = 'Extra 3',
                event = 'radialmenu:client:setExtra',
                args = 3,
            },
            {
                id = 'extra4',
                icon = 'box-open',
                label = 'Extra 4',
                event = 'radialmenu:client:setExtra',
                args = 4,
            },
            {
                id = 'extra5',
                icon = 'box-open',
                label = 'Extra 5',
                event = 'radialmenu:client:setExtra',
                args = 5,
            },
            {
                id = 'extra6',
                icon = 'box-open',
                label = 'Extra 6',
                event = 'radialmenu:client:setExtra',
                args = 6,
            },
            {
                id = 'extra7',
                icon = 'box-open',
                label = 'Extra 7',
                event = 'radialmenu:client:setExtra',
                args = 7,
            },
            {
                id = 'extra8',
                icon = 'box-open',
                label = 'Extra 8',
                event = 'radialmenu:client:setExtra',
                args = 8,
            },
            {
                id = 'extra9',
                icon = 'box-open',
                label = 'Extra 9',
                event = 'radialmenu:client:setExtra',
                args = 9,
            },
            {
                id = 'extra10',
                icon = 'box-open',
                label = 'Extra 10',
                event = 'radialmenu:client:setExtra',
                args = 10,
            },
            {
                id = 'extra11',
                icon = 'box-open',
                label = 'Extra 11',
                event = 'radialmenu:client:setExtra',
                args = 11,
            },
            {
                id = 'extra12',
                icon = 'box-open',
                label = 'Extra 12',
                event = 'radialmenu:client:setExtra',
                args = 12,
            },
            {
                id = 'extra13',
                icon = 'box-open',
                label = 'Extra 13',
                event = 'radialmenu:client:setExtra',
                args = 13,
            },
        },
    },

    trunkClasses = {
        [0] = {allowed = true, x = 0.0, y = -1.5, z = 0.0}, -- Coupes
        [1] = {allowed = true, x = 0.0, y = -2.0, z = 0.0}, -- Sedans
        [2] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- SUVs
        [3] = {allowed = true, x = 0.0, y = -1.5, z = 0.0}, -- Coupes
        [4] = {allowed = true, x = 0.0, y = -2.0, z = 0.0}, -- Muscle
        [5] = {allowed = true, x = 0.0, y = -2.0, z = 0.0}, -- Sports Classics
        [6] = {allowed = true, x = 0.0, y = -2.0, z = 0.0}, -- Sports
        [7] = {allowed = true, x = 0.0, y = -2.0, z = 0.0}, -- Super
        [8] = {allowed = false, x = 0.0, y = -1.0, z = 0.25}, -- Motorcycles
        [9] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Off-road
        [10] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Industrial
        [11] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Utility
        [12] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Vans
        [13] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Cycles
        [14] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Boats
        [15] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Helicopters
        [16] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Planes
        [17] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Service
        [18] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Emergency
        [19] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Military
        [20] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Commercial
        [21] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Trains
    },

    clothingCommands = {
        top = {
            Func = function() ToggleClothing({'Top'}) end,
            Sprite = 'top',
            Desc = 'Take your shirt off/on',
            Button = 1,
            Name = 'Torso',
        },
        gloves = {
            Func = function() ToggleClothing({'Gloves'}) end,
            Sprite = 'gloves',
            Desc = 'Take your gloves off/on',
            Button = 2,
            Name = 'Gloves',
        },
        visor = {
            Func = function() ToggleProps({'Visor'}) end,
            Sprite = 'visor',
            Desc = 'Toggle hat variation',
            Button = 3,
            Name = 'Visor',
        },
        bag = {
            Func = function() ToggleClothing({'Bag'}) end,
            Sprite = 'bag',
            Desc = 'Opens or closes your bag',
            Button = 8,
            Name = 'Bag',
        },
        shoes = {
            Func = function() ToggleClothing({'Shoes'}) end,
            Sprite = 'shoes',
            Desc = 'Take your shoes off/on',
            Button = 5,
            Name = 'Shoes',
        },
        vest = {
            Func = function() ToggleClothing({'Vest'}) end,
            Sprite = 'vest',
            Desc = 'Take your vest off/on',
            Button = 14,
            Name = 'Vest',
        },
        hair = {
            Func = function() ToggleClothing({'Hair'}) end,
            Sprite = 'hair',
            Desc = 'Put your hair up/down',
            Button = 7,
            Name = 'Hair',
        },
        hat = {
            Func = function() ToggleProps({'Hat'}) end,
            Sprite = 'hat',
            Desc = 'Take your hat off/on',
            Button = 4,
            Name = 'Hat',
        },
        glasses = {
            Func = function() ToggleProps({'Glasses'}) end,
            Sprite = 'glasses',
            Desc = 'Take your glasses off/on',
            Button = 9,
            Name = 'Glasses',
        },
        ear = {
            Func = function() ToggleProps({'Ear'}) end,
            Sprite = 'ear',
            Desc = 'Take your ear accessory off/on',
            Button = 10,
            Name = 'Ear',
        },
        neck = {
            Func = function() ToggleClothing({'Neck'}) end,
            Sprite = 'neck',
            Desc = 'Take your neck accessory off/on',
            Button = 11,
            Name = 'Neck',
        },
        watch = {
            Func = function() ToggleProps({'Watch'}) end,
            Sprite = 'watch',
            Desc = 'Take your watch off/on',
            Button = 12,
            Name = 'Watch',
            Rotation = 5.0,
        },
        bracelet = {
            Func = function() ToggleProps({'Bracelet'}) end,
            Sprite = 'bracelet',
            Desc = 'Take your bracelet off/on',
            Button = 13,
            Name = 'Bracelet',
        },
        mask = {
            Func = function() ToggleClothing({'Mask'}) end,
            Sprite = 'mask',
            Desc = 'Take your mask off/on',
            Button = 6,
            Name = 'Mask',
        },

        pants = {
            Func = function() ToggleClothing({'Pants', true}) end,
            Sprite = 'pants',
            Desc = 'Take your pants off/on',
            Name = 'Pants',
            OffsetX = -0.04,
            OffsetY = 0.0,
        },
        shirt = {
            Func = function() ToggleClothing({'Shirt', true}) end,
            Sprite = 'shirt',
            Desc = 'Take your shirt off/on',
            Name = 'shirt',
            OffsetX = 0.04,
            OffsetY = 0.0,
        },
        reset = {
            Func = function()
                if not ResetClothing(true) then
                    Notify('Nothing To Reset', 'error')
                end
            end,
            Sprite = 'reset',
            Desc = 'Revert everything back to normal',
            Name = 'reset',
            OffsetX = 0.12,
            OffsetY = 0.2,
            Rotate = true
        },
        bagoff = {
            Func = function() ToggleClothing({'Bagoff', true}) end,
            Sprite = 'bagoff',
            SpriteFunc = function()
                local Bag = GetPedDrawableVariation(cache.ped, 5)
                local BagOff = LastEquipped['Bagoff']
                if LastEquipped['Bagoff'] then
                    if bags[BagOff.Drawable] then
                        return 'bagoff'
                    else
                        return 'paraoff'
                    end
                end
                if Bag ~= 0 then
                    if bags[Bag] then
                        return 'bagoff'
                    else
                        return 'paraoff'
                    end
                else
                    return false
                end
            end,
            Desc = 'Take your bag off/on',
            Name = 'bagoff',
            OffsetX = -0.12,
            OffsetY = 0.2,
        }
    },
}
