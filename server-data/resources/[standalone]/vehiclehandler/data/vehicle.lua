return {
    units = 'mph' ,             -- (mph, kmh)
    breaktire = true,           -- Enable/Disable breaking off vehicle wheel on impact
    threshold = {
        health = 50.0,          -- Health difference needed to break off wheel (LastHealth - CurrentHealth)
        speed  = 50.0,          -- Speed difference needed to break off wheel (LastSpeed - CurrentSpeed)
        heavy  = 90.0,          -- Speed difference needed to disable vehicle instantly (LastSpeed - CurrentSpeed)
    },
    -- Servidor: reduced from the vendored default of 20.0, then again from a first pass at 5.0 - a
    -- single 10-point body hit used to cost ~200 engine points (globalmultiplier * classmultiplier,
    -- both applied to the SAME body-damage delta), killing a car's engine after a handful of
    -- scrapes. 1.5 keeps the "body damage bleeds into engine damage" mechanic intact, just far
    -- less punishing - that same 10-point hit now costs 15 engine points instead of 200. Tune
    -- further from here if it still feels too fragile or too tanky once played.
    globalmultiplier = 1.5,     -- Base damage multiplier for all vehicles (lower value = less damage)
    classmultiplier = {         -- Add-on damage multiplier for vehicle classes
        [0] =   1.0,            -- 0: Compacts
                1.0,            -- 1: Sedans
                1.0,	        -- 2: SUVs
                0.95,	        -- 3: Coupes
                1.0,	        -- 4: Muscle
                0.95,           -- 5: Sports Classics
                0.95,	        -- 6: Sports
                0.95,	        -- 7: Super
                0.47,	        -- 8: Motorcycles
                0.7,	        -- 9: Off-road
                0.25,	        -- 10: Industrial
                0.35,	        -- 11: Utility
                0.85,	        -- 12: Vans
                1.0,	        -- 13: Bicycles
                0.4,	        -- 14: Boats
                0.7,	        -- 15: Helicopters
                0.7,	        -- 16: Planes
                0.75,	        -- 17: Service
                0.35,	        -- 18: Emergency
                0.27,	        -- 19: Military
                0.43,	        -- 20: Commercial
                0.1,	        -- 21: Trains
                1.0,	        -- 22: Open Wheel
    },
    regulated = {               -- Prevent controls for vehicle class while flipped/airborne
        [0] =   true,           -- 0: Compacts
                true,           -- 1: Sedans
                true,           -- 2: SUVs
                true,           -- 3: Coupes
                true,           -- 4: Muscle
                true,           -- 5: Sports Classics
                true,           -- 6: Sports
                true,           -- 7: Super
                false,          -- 8: Motorcycles
                true,           -- 9: Off-road
                true,           -- 10: Industrial
                true,           -- 11: Utility
                true,           -- 12: Vans
                false,          -- 13: Bicycles
                false,          -- 14: Boats
                false,          -- 15: Helicopters
                false,          -- 16: Planes
                true,           -- 17: Service
                true,           -- 18: Emergency
                false,          -- 19: Military
                true,           -- 20: Commercial
                false,          -- 21: Trains
                true,           -- 22: Open Wheel
    },
    exclusions = {              -- Prevent rotation controls for these specific models, even if their class is regulated
        [`deluxo`] = true,
        [`scramjet`] = true,
        [`vigilante`] = true,
    },
    backengine = {
        [`ninef`] = true,
        [`adder`] = true,
        [`vagner`] = true,
        [`t20`] = true,
        [`infernus`] = true,
        [`zentorno`] = true,
        [`reaper`] = true,
        [`comet2`] = true,
        [`jester`] = true,
        [`jester2`] = true,
        [`cheetah`] = true,
        [`cheetah2`] = true,
        [`prototipo`] = true,
        [`turismor`] = true,
        [`pfister811`] = true,
        [`ardent`] = true,
        [`nero`] = true,
        [`nero2`] = true,
        [`tempesta`] = true,
        [`vacca`] = true,
        [`bullet`] = true,
        [`osiris`] = true,
        [`entityxf`] = true,
        [`turismo2`] = true,
        [`fmj`] = true,
        [`re7b`] = true,
        [`tyrus`] = true,
        [`italigtb`] = true,
        [`penetrator`] = true,
        [`monroe`] = true,
        [`ninef2`] = true,
        [`stingergt`] = true,
        [`surfer`] = true,
        [`surfer2`] = true,
        [`comet3`] = true,
    }
}