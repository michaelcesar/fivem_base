-- Servidor: the six gang LABELS are colour names, not the gangs' own. The keys are untouched -
-- `families`, `ballas`, `vagos`, `triads`, `cartel`, `lostmc` - so every config, every
-- `groups` entry and every database row that already names a gang keeps working. Only what a
-- player reads changed.
--
-- This is the single source for that name: `/gang`, the boss menu, the admin menu and
-- `srv_lib`'s own `GangDeniedMessage` all read `label` from here, so translating it once here
-- is what makes the whole server say the same thing.
--
-- The form is a PLURAL MASCULINE NOUN ("Verdes"), which is not the form the map blips use - those
-- need a feminine singular adjective for "Área verde" and store it separately in `srv_lib`. Two
-- forms, stored as the sentence needs them rather than transformed at the call site, which is
-- ADR-138's rule. See ADR-155.
--
-- **This is a framework data file: a `qbx_core` update overwrites it.**
---Gang names must be lower case (top level table key)
---@type table<string, Gang>
return {
    ['none'] = {
        label = 'Sem Gangue',
        grades = {
            [0] = {
                name = 'Sem Filiação'
            },
        },
    },
    ['lostmc'] = {
        label = 'Brancos',
        grades = {
            [0] = {
                name = 'Recruta'
            },
            [1] = {
                name = 'Executor'
            },
            [2] = {
                name = 'Chefia'
            },
            [3] = {
                name = 'Chefe',
                isboss = true,
                bankAuth = true
            },
        },
    },
    ['ballas'] = {
        label = 'Roxos',
        grades = {
            [0] = {
                name = 'Recruta'
            },
            [1] = {
                name = 'Executor'
            },
            [2] = {
                name = 'Chefia'
            },
            [3] = {
                name = 'Chefe',
                isboss = true,
                bankAuth = true
            },
        },
    },
    ['vagos'] = {
        label = 'Amarelos',
        grades = {
            [0] = {
                name = 'Recruta'
            },
            [1] = {
                name = 'Executor'
            },
            [2] = {
                name = 'Chefia'
            },
            [3] = {
                name = 'Chefe',
                isboss = true,
                bankAuth = true
            },
        },
    },
    ['cartel'] = {
        label = 'Laranjas',
        grades = {
            [0] = {
                name = 'Recruta'
            },
            [1] = {
                name = 'Executor'
            },
            [2] = {
                name = 'Chefia'
            },
            [3] = {
                name = 'Chefe',
                isboss = true,
                bankAuth = true
            },
        },
    },
    ['families'] = {
        label = 'Verdes',
        grades = {
            [0] = {
                name = 'Recruta'
            },
            [1] = {
                name = 'Executor'
            },
            [2] = {
                name = 'Chefia'
            },
            [3] = {
                name = 'Chefe',
                isboss = true,
                bankAuth = true
            },
        },
    },
    ['triads'] = {
        label = 'Vermelhos',
        grades = {
            [0] = {
                name = 'Recruta'
            },
            [1] = {
                name = 'Executor'
            },
            [2] = {
                name = 'Chefia'
            },
            [3] = {
                name = 'Chefe',
                isboss = true,
                bankAuth = true
            },
        },
    }
}
