---Job names must be lower case (top level table key)
---@type table<string, Job>
return {
    ['unemployed'] = {
        label = 'Civil',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Autônomo',
                payment = 10
            },
        },
    },
    ['police'] = {
        label = 'LSPD',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruta',
                payment = 50
            },
            [1] = {
                name = 'Oficial',
                payment = 75
            },
            [2] = {
                name = 'Sargento',
                payment = 100
            },
            [3] = {
                name = 'Tenente',
                payment = 125
            },
            [4] = {
                name = 'Comandante',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['bcso'] = {
        label = 'BCSO',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruta',
                payment = 50
            },
            [1] = {
                name = 'Oficial',
                payment = 75
            },
            [2] = {
                name = 'Sargento',
                payment = 100
            },
            [3] = {
                name = 'Tenente',
                payment = 125
            },
            [4] = {
                name = 'Comandante',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['sasp'] = {
        label = 'SASP',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruta',
                payment = 50
            },
            [1] = {
                name = 'Oficial',
                payment = 75
            },
            [2] = {
                name = 'Sargento',
                payment = 100
            },
            [3] = {
                name = 'Tenente',
                payment = 125
            },
            [4] = {
                name = 'Comandante',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['ambulance'] = {
        label = 'EMS',
        type = 'ems',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruta',
                payment = 50
            },
            [1] = {
                name = 'Paramédico',
                payment = 75
            },
            [2] = {
                name = 'Médico',
                payment = 100
            },
            [3] = {
                name = 'Cirurgião',
                payment = 125
            },
            [4] = {
                name = 'Comandante',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['realestate'] = {
        label = 'Imobiliária',
        type = 'realestate',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruta',
                payment = 50
            },
            [1] = {
                name = 'Vendas de Imóveis',
                payment = 75
            },
            [2] = {
                name = 'Vendas Comerciais',
                payment = 100
            },
            [3] = {
                name = 'Corretor',
                payment = 125
            },
            [4] = {
                name = 'Gerente',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['taxi'] = {
        label = 'Táxi',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruta',
                payment = 50
            },
            [1] = {
                name = 'Motorista',
                payment = 75
            },
            [2] = {
                name = 'Motorista de Eventos',
                payment = 100
            },
            [3] = {
                name = 'Vendas',
                payment = 125
            },
            [4] = {
                name = 'Gerente',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['bus'] = {
        label = 'Ônibus',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Motorista',
                payment = 50
            },
        },
    },
    ['cardealer'] = {
        label = 'Concessionária',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruta',
                payment = 50
            },
            [1] = {
                name = 'Vendas de Showroom',
                payment = 75
            },
            [2] = {
                name = 'Vendas Comerciais',
                payment = 100
            },
            [3] = {
                name = 'Financeiro',
                payment = 125
            },
            [4] = {
                name = 'Gerente',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['mechanic'] = {
        label = 'Mecânica',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruta',
                payment = 50
            },
            [1] = {
                name = 'Iniciante',
                payment = 75
            },
            [2] = {
                name = 'Experiente',
                payment = 100
            },
            [3] = {
                name = 'Avançado',
                payment = 125
            },
            [4] = {
                name = 'Gerente',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['judge'] = {
        label = 'Honorário',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Juiz',
                payment = 100
            },
        },
    },
    ['lawyer'] = {
        label = 'Escritório de Advocacia',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Associado',
                payment = 50
            },
        },
    },
    ['reporter'] = {
        label = 'Jornalismo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Jornalista',
                payment = 50
            },
        },
    },
    ['trucker'] = {
        label = 'Transportadora',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Motorista',
                payment = 50
            },
        },
    },
    ['tow'] = {
        label = 'Guincho',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Motorista',
                payment = 50
            },
        },
    },
    ['garbage'] = {
        label = 'Limpeza Urbana',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Coletor',
                payment = 50
            },
        },
    },
    ['vineyard'] = {
        label = 'Vinícola',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Catador',
                payment = 50
            },
        },
    },
    ['hotdog'] = {
        label = 'Cachorro-Quente',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Vendas',
                payment = 50
            },
        },
    },
}
