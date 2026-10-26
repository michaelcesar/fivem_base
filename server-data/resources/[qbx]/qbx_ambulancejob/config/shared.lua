return {
    checkInCost = 2000, -- Price for using the hospital check-in system
    minForCheckIn = 2, -- Minimum number of people with the ambulance job to prevent the check-in system from being used

    locations = { -- Various interaction points
        duty = {
            vec3(311.18, -599.25, 43.29),
            vec3(-254.88, 6324.5, 32.58),
        },
        vehicle = {
            vec4(294.578, -574.761, 43.179, 35.79),
            vec4(-234.28, 6329.16, 32.15, 222.5),
        },
        helicopter = {
            vec4(351.58, -587.45, 74.16, 160.5),
            vec4(-475.43, 5988.353, 31.716, 31.34),
        },
        armory = {
            {
                shopType = 'AmbulanceArmory',
                name = 'Armory',
                groups = { ambulance = 0 },
                inventory = {
                    { name = 'radio', price = 0 },
                    { name = 'bandage', price = 0 },
                    { name = 'painkillers', price = 0 },
                    { name = 'firstaid', price = 0 },
                    { name = 'weapon_flashlight', price = 0 },
                    { name = 'weapon_fireextinguisher', price = 0 },
                },
                locations = {
                    vec3(309.93, -602.94, 43.29)
                }
            }
        },
        roof = {
            vec3(338.54, -583.88, 74.17),
        },
        main = {
            vec3(298.62, -599.66, 43.29),
        },
        stash = {
            {
                name = 'ambulanceStash',
                label = 'Personal stash',
                weight = 100000,
                slots = 30,
                groups = { ambulance = 0 },
                owner = true, -- Set to false for group stash
                location = vec3(309.78, -596.6, 43.29)
            }
        },

        ---@class Bed
        ---@field coords vector4
        ---@field model number

        ---@type table<string, {coords: vector3, checkIn?: vector3|vector3[], beds: Bed[]}>
        hospitals = {
            pillbox = {
                -- Servidor: every coordinate below was surveyed inside the phxlsmc MLO with
                -- /doorinfo, which reports the BED OBJECT rather than where the player stood.
                -- That distinction is load-bearing: hospital.lua looks for the bed with
                -- GetClosestObjectOfType(..., 1.0, model, ...), a one-metre radius, and a player
                -- standing on the mattress reads 1.36m from the object it is standing on. Using
                -- the standing position finds no bed, freezes nothing, and reports no error.
                --
                -- Stock QBox put all of this at z~43, where the vanilla game has no floor at all -
                -- the first solid surface under Pillbox is the metro tunnel 26m down. See ADR-165.
                coords = vec3(358.78, -567.48, 28.36),
                checkIn = vec3(308.19, -595.35, 43.29),
                beds = {
                    -- Ward 1. Heading 153.73 is MEASURED (/coords beside the first bed).
                    {coords = vec4(361.12, -564.54, 28.36, 153.73), model = 1631638868},
                    {coords = vec4(357.73, -563.30, 28.36, 153.73), model = 1631638868},
                    {coords = vec4(354.33, -562.06, 28.36, 153.73), model = 1631638868},
                    -- Ward 2, a parallel row ~6m away. Heading INHERITED from the stock config for
                    -- this same bed model, not measured - it is ~180 degrees from ward 1, which is
                    -- what two rows facing each other look like. Verify by lying down.
                    {coords = vec4(351.83, -568.71, 28.36, 336.32), model = 2117668672},
                    {coords = vec4(355.25, -569.95, 28.36, 336.32), model = 2117668672},
                    {coords = vec4(358.57, -571.16, 28.36, 336.32), model = 2117668672},
                    -- Two isolated beds - nothing else within 3m of either, unlike the six above.
                    -- Headings MEASURED after the inherited 152.08 laid the ped across the mattress
                    -- instead of along it. The correction was -90 degrees, not the 180 that a
                    -- back-to-front body would need: inheriting a heading from another layout gets
                    -- the axis wrong as easily as the direction, and only lying down shows which.
                    {coords = vec4(364.98, -572.01, 28.36, 69.63), model = -1091386327},
                    {coords = vec4(366.41, -568.10, 28.36, 65.67), model = -1091386327},
                },
            },
            paleto = {
                coords = vec3(-250, 6315, 32),
                checkIn = vec3(-254.54, 6331.78, 32.43),
                beds = {
                    {coords = vec4(-252.43, 6312.25, 32.34, 313.48), model = 2117668672},
                    {coords = vec4(-247.04, 6317.95, 32.34, 134.64), model = 2117668672},
                    {coords = vec4(-255.98, 6315.67, 32.34, 313.91), model = 2117668672},
                },
            },
            jail = {
                coords = vec3(1761, 2600, 46),
                beds = {
                    {coords = vec4(1761.96, 2597.74, 45.66, 270.14), model = 2117668672},
                    {coords = vec4(1761.96, 2591.51, 45.66, 269.8), model = 2117668672},
                    {coords = vec4(1771.8, 2598.02, 45.66, 89.05), model = 2117668672},
                    {coords = vec4(1771.85, 2591.85, 45.66, 91.51), model = 2117668672},
                },
            },
        },

        stations = {
            {label = 'Pillbox Hospital', coords = vec4(304.27, -600.33, 43.28, 272.249)},
        }
    },
}