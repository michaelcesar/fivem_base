return {
    autoRespawn = true, -- True == auto respawn cars that are outside into your garage on script restart, false == does not put them into your garage and players have to go to the impound
    -- Servidor: on, by request - taking a vehicle out now puts you in the driver's seat rather than
    -- leaving you standing beside it. Reported as "o carro spawna comigo fora". Upstream ships this
    -- off; nothing in this project ever chose that, it was simply the default.
    warpInVehicle = true,
    doorsLocked = true, -- If true, the doors will be locked upon taking the vehicle out.
    distanceCheck = 5.0, -- The distance that needs to bee clear to let the vehicle spawn, this prevents vehicles stacking on top of each other
    ---calculates the automatic impound fee.
    ---@param vehicleId integer
    ---@param modelName string
    ---@return integer fee
    calculateImpoundFee = function(vehicleId, modelName)
        local vehCost = VEHICLES[modelName].price
        return qbx.math.round(vehCost * 0.02) or 0
    end,

    ---calculates the fee charged when retrieving a vehicle from a garage other than the one it's stored in.
    ---@param vehicleId integer
    ---@param modelName string
    ---@return integer fee
    calculateTransportFee = function(vehicleId, modelName)
        local vehCost = VEHICLES[modelName].price
        return qbx.math.round(vehCost * 0.01) or 0
    end,

    ---@class GarageBlip
    ---@field name? string -- Name of the blip. Defaults to garage label.
    ---@field sprite? number -- Sprite for the blip. Defaults to 357
    ---@field color? number -- Color for the blip. Defaults to 3.

    ---The place where the player can access the garage and spawn a car
    ---@class AccessPoint
    ---@field coords vector4 where the garage menu can be accessed from
    ---@field blip? GarageBlip
    ---@field spawn? vector4 where the vehicle will spawn. Defaults to coords
    ---@field dropPoint? vector3 where a vehicle can be stored, Defaults to spawn or coords

    ---@class GarageConfig
    ---@field label string -- Label for the garage
    ---@field type? GarageType -- Optional special type of garage. Currently only used to mark DEPOT garages.
    ---@field vehicleType VehicleType -- Vehicle type
    ---@field groups? string | string[] | table<string, number> job/gangs that can access the garage
    ---@field shared? boolean defaults to false. Shared garages give all players with access to the garage access to all vehicles in it. If shared is off, the garage will only give access to player's vehicles which they own.
    ---@field states? VehicleState | VehicleState[] if set, only vehicles in the given states will be retrievable from the garage. Defaults to GARAGED.
    ---@field skipGarageCheck? boolean if true, returns vehicles for retrieval regardless of if that vehicle's garage matches this garage's name
    ---@field canAccess? fun(source: number): boolean checks access as an additional guard clause. Other filter fields still need to pass in addition to this function.
    ---@field accessPoints AccessPoint[]

    ---@type table<string, GarageConfig>
    garages = {
        -- Public Garages
        motelgarage = {
            label = 'Estacionamento do Motel',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(275.58, -344.74, 45.17, 70.0),
                    spawn = vec4(271.26, -342.32, 44.7, 159.97),
                }
            },
        },
        sapcounsel = {
            label = 'Estacionamento San Andreas',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(-330.67, -781.12, 33.96, 40.46),
                    spawn = vec4(-337.11, -775.34, 33.56, 132.09),
                }
            },
        },
        spanishave = {
            label = 'Estacionamento Avenida Espanhola',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(-1160.46, -741.04, 19.95, 41.26),
                    spawn = vec4(-1165.38, -747.65, 18.94, 40.45),
                }
            },
        },
        caears24 = {
            label = 'Estacionamento Caears 24',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(68.08, 13.15, 69.21, 160.44),
                    spawn = vec4(72.61, 11.72, 68.47, 157.59),
                },
            },
        },
        littleseoul = {
            label = 'Estacionamento Pequena Seul',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(-463.51, -808.2, 30.54, 0.0),
                    spawn = vec4(-472.24, -813.61, 30.3, 179.88),
                }
            },
        },
        lagunapi = {
            label = 'Estacionamento Laguna',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(363.85, 297.97, 103.5, 341.39),
                    spawn = vec4(367.41, 297.02, 103.2, 341.08),
                }
            },
        },
        airportp = {
            label = 'Estacionamento do Aeroporto',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(-796.07, -2023.26, 9.17, 55.18),
                    spawn = vec4(-793.35, -2020.62, 8.51, 58.42),
                }
            },
        },
        beachp = {
            label = 'Estacionamento da Praia',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(-1184.21, -1509.65, 4.65, 303.72),
                    spawn = vec4(-1184.4, -1501.88, 4.39, 214.7),
                }
            },
        },
        themotorhotel = {
            label = 'Estacionamento do Motor Hotel',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(1137.77, 2663.54, 37.9, 0.0),
                    spawn = vec4(1137.56, 2674.19, 38.17, 359.95),
                }
            },
        },
        liqourparking = {
            label = 'Estacionamento da Loja de Bebidas',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(960.68, 3609.32, 32.98, 268.97),
                    spawn = vec4(960.48, 3605.71, 32.98, 87.09),
                }
            },
        },
        shoreparking = {
            label = 'Estacionamento da Costa',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(1726.9, 3710.38, 34.26, 22.54),
                    spawn = vec4(1728.65, 3714.85, 34.18, 21.26),
                }
            },
        },
        haanparking = {
            label = 'Estacionamento Bell Farms',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(78.34, 6418.74, 31.28, 0),
                    spawn = vec4(70.71, 6425.16, 30.92, 68.5),
                }
            },
        },
        dumbogarage = {
            label = 'Estacionamento Privado Dumbo',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(157.26, -3240.00, 7.00, 0),
                    spawn = vec4(165.32, -3236.10, 5.93, 268.5),
                }
            },
        },
        pillboxgarage = {
            label = 'Estacionamento Garagem Pillbox',
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Estacionamento Público',
                        sprite = 357,
                        color = 3,
                    },
                    coords = vec4(218.66, -804.08, 30.75, 65.69),
                    spawn = vec4(229.33, -805.01, 30.54, 156.79),
                }
            },
        },
        intairport = {
            label = 'Hangar do Aeroporto',
            vehicleType = VehicleType.AIR,
            accessPoints = {
                {
                    blip = {
                        name = 'Hangar',
                        sprite = 360,
                        color = 3,
                    },
                    coords = vec4(-1025.34, -3017.0, 13.95, 331.99),
                    spawn = vec4(-979.2, -2995.51, 13.95, 52.19),
                }
            },
        },
        higginsheli = {
            label = 'Higgins Helitours',
            vehicleType = VehicleType.AIR,
            accessPoints = {
                {
                    blip = {
                        name = 'Hangar',
                        sprite = 360,
                        color = 3,
                    },
                    coords = vec4(-722.12, -1472.74, 5.0, 140.0),
                    spawn = vec4(-724.83, -1443.89, 5.0, 140.0),
                }
            },
        },
        airsshores = {
            label = 'Hangar Costas Arenosas',
            vehicleType = VehicleType.AIR,
            accessPoints = {
                {
                    blip = {
                        name = 'Hangar',
                        sprite = 360,
                        color = 3,
                    },
                    coords = vec4(1757.74, 3296.13, 41.15, 142.6),
                    spawn = vec4(1740.88, 3278.99, 41.09, 189.46),
                }
            },
        },
        lsymc = {
            label = 'Casa de Barcos LSYMC',
            vehicleType = VehicleType.SEA,
            accessPoints = {
                {
                    blip = {
                        name = 'Casa de Barcos',
                        sprite = 356,
                        color = 3,
                    },
                    coords = vec4(-794.64, -1510.89, 1.6, 201.55),
                    spawn = vec4(-793.58, -1501.4, 0.12, 111.5),
                }
            },
        },
        paleto = {
            label = 'Casa de Barcos Paleto',
            vehicleType = VehicleType.SEA,
            accessPoints = {
                {
                    blip = {
                        name = 'Casa de Barcos',
                        sprite = 356,
                        color = 3,
                    },
                    coords = vec4(-277.4, 6637.01, 7.5, 40.51),
                    spawn = vec4(-289.2, 6637.96, 1.01, 45.5),
                }
            },
        },
        millars = {
            label = 'Casa de Barcos Millars',
            vehicleType = VehicleType.SEA,
            accessPoints = {
                {
                    blip = {
                        name = 'Casa de Barcos',
                        sprite = 356,
                        color = 3,
                    },
                    coords = vec4(1299.02, 4216.42, 33.91, 166.8),
                    spawn = vec4(1296.78, 4203.76, 30.12, 169.03),
                }
            },
        },

        -- Job Garages
        police = {
            label = 'Police',
            vehicleType = VehicleType.CAR,
            groups = 'police',
            accessPoints = {
                {
                    coords = vec4(454.6, -1017.4, 28.4, 0),
                    spawn = vec4(438.4, -1018.3, 27.7, 90.0),
                }
            },
        },

        -- Gang Garages
        --
        -- Servidor: these six deliberately have NO `blip` table, and that absence is what takes them
        -- off the map. `client/main.lua` gates its own `createCircleBlip` on `accessPoint.blip`
        -- being set, so a single blip entry here was drawing THREE marks - the garage sprite, a
        -- green pickup circle and a red drop circle - all within 15-48m of the base circle that
        -- `srv_gangs` already draws. Four overlapping marks per gang, across six gangs.
        --
        -- The base circle covers the garage, which sits inside it. Reverses the map half of
        -- ADR-140; the member-only rule it established still applies to every other group garage.
        -- See ADR-154.
        ballas = {
            label = 'Roxos',
            vehicleType = VehicleType.CAR,
            groups = 'ballas',
            accessPoints = {
                {
                    -- Servidor: re-surveyed 2026-08-20 alongside the Ballas base. Was a single
                    -- point with no `dropPoint` (so the return spot fell back to `spawn` and one
                    -- point did both jobs) and heading 0 on `coords`, the same defect the Lost MC
                    -- garage had.
                    --
                    -- The two points are 23.82m apart, which is fine now and would NOT have been
                    -- before: the outer sphere that creates the drop zone derives its radius from
                    -- this distance rather than the upstream flat 15.
                    coords = vec4(116.12, -1948.22, 20.67, 35.95),
                    spawn = vec4(116.12, -1948.22, 20.67, 35.95),
                    dropPoint = vec4(95.32, -1959.82, 20.75, 140.79),
                }
            },
        },
        families = {
            label = 'Verdes',
            vehicleType = VehicleType.CAR,
            groups = 'families',
            accessPoints = {
                {
                    -- Servidor: moved 2026-08-20 to the Freakshop door, where the Families base now
                    -- is. The old spot (-811.65, 187.49) was 1547m from it and predated the gang
                    -- having a base at all.
                    --
                    -- It also had the two defects the Ballas garage had: no `dropPoint`, so the
                    -- return spot fell back to `spawn`, and heading `0` on `coords`. It was the
                    -- only garage where `coords` and `spawn` were 7.24m apart, so the marker you
                    -- pressed and the place the car appeared were different spots.
                    --
                    -- Take-out and park are 24.90m apart, which widens the drop-zone sphere to
                    -- 29.90m. Both sit outdoors near the street door; the base itself is 95.7m
                    -- straight down with no road to it.
                    coords = vec4(603.78, -426.53, 24.74, 170.07),
                    spawn = vec4(603.78, -426.53, 24.74, 170.07),
                    dropPoint = vec4(598.10, -402.29, 25.18, 167.26),
                }
            },
        },
        lostmc = {
            label = 'Brancos',
            vehicleType = VehicleType.CAR,
            groups = 'lostmc',
            accessPoints = {
                {
                    -- Servidor: surveyed properly, and shaped like every other garage on this
                    -- server - the vehicle appears where you take it out (`coords`/`spawn`, the
                    -- same spot), and `dropPoint` is the separate bay ~18m away where you park it
                    -- to store it.
                    --
                    -- What was actually wrong before was not `coords == spawn`: it was that
                    -- `dropPoint` did not exist, so the return spot defaulted to `spawn` and the
                    -- garage had one point doing both jobs. The heading was also 0, which is why
                    -- the car came out facing the wrong way.
                    coords = vec4(957.44, -129.52, 74.30, 175.28),
                    spawn = vec4(957.44, -129.52, 74.30, 175.28),
                    dropPoint = vec4(973.06, -138.60, 74.19, 237.94),
                }
            },
        },
        cartel = {
            label = 'Laranjas',
            vehicleType = VehicleType.CAR,
            groups = 'cartel',
            accessPoints = {
                {
                    -- Servidor: moved 2026-08-20 to the Tuners-garage door, where the Cartel base
                    -- now is. The old spot (1407.18, 1118.04) predated the gang having a base, and
                    -- carried the same two defects the other gang garages did: no `dropPoint`, so
                    -- the return spot fell back to `spawn` and one point did both jobs, and heading
                    -- `0` on `coords`.
                    --
                    -- This was the LAST garage on the server with that defect.
                    --
                    -- Take-out and park are 18.06m apart, widening the drop-zone sphere to 23.06m.
                    coords = vec4(-1483.86, -199.90, 50.40, 38.15),
                    spawn = vec4(-1483.86, -199.90, 50.40, 38.15),
                    dropPoint = vec4(-1498.42, -189.22, 50.40, 307.40),
                }
            },
        },
        triads = {
            label = 'Vermelhos',
            vehicleType = VehicleType.CAR,
            groups = 'triads',
            accessPoints = {
                {
                    -- Servidor: the Triads had NO garage at all - the only gang without one, since
                    -- upstream never shipped them an entry.
                    --
                    -- Surveyed twice on 2026-08-20. The first pair sat at the foot of the Maze Bank
                    -- tower; the base then moved to the bail office (ADR-152) and this followed it.
                    -- For a few hours in between only the take-out half of the new pair existed,
                    -- and it was deliberately NOT applied alone: the drop-zone sphere takes its
                    -- radius from the distance between take-out and park, so a take-out here paired
                    -- with the old park point at Maze Bank would have built a sphere ~1800m wide.
                    -- Both points move together or neither does.
                    --
                    -- Take-out and park are 24.35m apart, widening the drop-zone sphere to 29.35m.
                    coords = vec4(926.35, -2308.51, 30.51, 352.43),
                    spawn = vec4(926.35, -2308.51, 30.51, 352.43),
                    dropPoint = vec4(928.79, -2284.28, 30.51, 359.23),
                }
            },
        },
        vagos = {
            label = 'Amarelos',
            vehicleType = VehicleType.CAR,
            groups = 'vagos',
            accessPoints = {
                {
                    -- Servidor: surveyed 2026-08-20, shaped like the Lost MC one above - the vehicle
                    -- comes out where you take it out (`coords`/`spawn`, the same spot), and
                    -- `dropPoint` is the separate bay you park in to store it.
                    --
                    -- The two are 10.6m apart. That matters: the drop zone only exists once the
                    -- player is inside a 15m sphere centred on `coords`, so a `dropPoint` further
                    -- away than that can never be reached at all. Checked rather than assumed.
                    --
                    -- Both points are OUTSIDE at the Rancho lot, next to the base door - the base
                    -- itself is in an interior with no road to it.
                    coords = vec4(331.38, -2044.83, 20.78, 301.21),
                    spawn = vec4(331.38, -2044.83, 20.78, 301.21),
                    dropPoint = vec4(338.00, -2036.56, 21.37, 50.24),
                }
            },
        },

        -- Impound Lots
        impoundlot = {
            label = 'Pátio de Apreensão',
            type = GarageType.DEPOT,
            states = {VehicleState.OUT, VehicleState.IMPOUNDED},
            skipGarageCheck = true,
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    blip = {
                        name = 'Pátio de Apreensão',
                        sprite = 68,
                        color = 3,
                    },
                    coords = vec4(400.45, -1630.87, 29.29, 228.88),
                    spawn = vec4(407.2, -1645.58, 29.31, 228.28),
                }
            },
        },
        airdepot = {
            label = 'Depósito Aéreo',
            type = GarageType.DEPOT,
            states = {VehicleState.OUT, VehicleState.IMPOUNDED},
            skipGarageCheck = true,
            vehicleType = VehicleType.AIR,
            accessPoints = {
                {
                    blip = {
                        name = 'Depósito Aéreo',
                        sprite = 359,
                        color = 3,
                    },
                    coords = vec4(-1244.35, -3391.39, 13.94, 59.26),
                    spawn = vec4(-1269.03, -3376.7, 13.94, 330.32),
                }
            },
        },
        seadepot = {
            label = 'Depósito LSYMC',
            type = GarageType.DEPOT,
            states = {VehicleState.OUT, VehicleState.IMPOUNDED},
            skipGarageCheck = true,
            vehicleType = VehicleType.SEA,
            accessPoints = {
                {
                    blip = {
                        name = 'Depósito LSYMC',
                        sprite = 356,
                        color = 3,
                    },
                    coords = vec4(-772.71, -1431.11, 1.6, 48.03),
                    spawn = vec4(-729.77, -1355.49, 1.19, 142.5),
                }
            },
        },
    },
}
