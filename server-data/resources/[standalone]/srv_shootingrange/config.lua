-- Servidor artillery courses. Each course trains one weapon class and grants the
-- licence that makes the crosshair show for that class (see srv_crosshair).
-- Courses are sequential: each one requires the previous course's licence.
CourseConfig = {
    coords = vec3(13.11, -1098.97, 29.80),
    maxDistance = 15.0,

    -- Walking beyond this from the firing line ends the course and takes the weapon back,
    -- so a course can't be used as a way to carry a live rifle around town. Kept the same
    -- as maxDistance: if you are too far to start a course, you are too far to still be in
    -- one. The player shoots from the line, so this never needs to reach the targets.
    leashDistance = 15.0,

    -- How often the leash is checked, in ms. At one second a player could get clear of the
    -- range and open fire before the weapon was taken back.
    leashCheckInterval = 250,

    targetModel = `prop_range_target_01`,
    targetHeading = 180.0, -- targets sit past the firing line, so they face back toward it
    hitsToDown = 3, -- impacts a target soaks before going down; a course can override it

    -- Rounds left in the weapon below which the course tops it back up to the course's
    -- `ammo`. Running dry is not part of the test - the player carries no ammo items and
    -- so could never reload, which silently ended runs on the higher levels.
    ammoRefillThreshold = 60,

    -- Ped spawn spots relative to `coords`; each course uses the first N of these, and
    -- the course's own `distance` pushes the whole set further back. Ordered so the
    -- early entries form the near firing line and later ones fan out wider and deeper.
    targetOffsets = {
        vec3(-0.5, 6.0, 0.0),
        vec3(1.0, 6.5, 0.0),
        vec3(2.5, 7.0, 0.0),
        vec3(4.0, 6.5, 0.0),
        vec3(5.5, 6.0, 0.0),
        vec3(-2.0, 5.0, 0.0),
        vec3(7.0, 5.0, 0.0),
        vec3(0.0, 9.5, 0.0),
        vec3(2.5, 10.0, 0.0),
        vec3(5.0, 9.5, 0.0),
        vec3(-1.5, 8.5, 0.0),
        vec3(6.5, 8.5, 0.0),
        vec3(1.0, 12.5, 0.0),
        vec3(3.5, 13.0, 0.0),
        vec3(6.0, 12.5, 0.0),
        vec3(5.0, 15.0, 0.0), -- was (-2.5, 11.0): sat behind cover at the expert level
        vec3(7.5, 11.0, 0.0),
        vec3(2.5, 15.0, 0.0),
    },

    -- `licence` is the key written to qbx_core's metadata.licences table.
    -- `requires` is the licence key that must already be held to start.
    -- `distance` pushes every target further from the firing line, so each level is
    -- a longer shot than the last; `lateral` slides the whole set sideways (positive =
    -- right) to keep them clear of nearby walls. `price` is charged per attempt and is
    -- never refunded, including on failure. `unlocks`/`weaponLabel` are shown to the player.
    courses = {
        {
            id = 'pistol',
            label = 'Nível 1 - Pistola',
            icon = 'gun',
            licence = 'weapon',
            requires = nil,
            weapon = 'WEAPON_PISTOL',
            weaponLabel = 'Pistola',
            unlocks = 'pistolas e taser',
            price = 30000,
            ammo = 250,
            targets = 5,
            distance = 0.0,
            lateral = 0.0,
            time = 30000,
        },
        {
            id = 'shotgun',
            label = 'Nível 2 - Escopeta',
            icon = 'burst',
            licence = 'weaponshotgun',
            requires = 'weapon',
            weapon = 'WEAPON_PUMPSHOTGUN',
            weaponLabel = 'Escopeta',
            unlocks = 'escopetas',
            price = 70000,
            ammo = 250,
            targets = 6,
            distance = 4.0,
            lateral = 0.0,
            time = 30000,
        },
        {
            id = 'rifle',
            label = 'Nível 3 - Rifle',
            icon = 'person-rifle',
            licence = 'weaponrifle',
            requires = 'weaponshotgun',
            weapon = 'WEAPON_ASSAULTRIFLE',
            weaponLabel = 'Rifle de Assalto',
            unlocks = 'rifles, submetralhadoras e metralhadoras',
            price = 100000,
            ammo = 250,
            targets = 6,
            distance = 8.0,
            lateral = 0.0,
            time = 30000,
        },
        {
            id = 'expert',
            label = 'Nível 4 - Especialista',
            icon = 'medal',
            licence = 'weaponexpert',
            requires = 'weaponrifle',
            weapon = 'WEAPON_CARBINERIFLE',
            weaponLabel = 'Carabina',
            unlocks = 'todas as classes, incluindo snipers e armas pesadas',
            price = 150000,
            ammo = 250,
            targets = 18,
            distance = 10.0,
            lateral = 3.0,
            hitsToDown = 10,
            -- 18 targets x 10 hits = 180 hits. A Carbine fires ~9 rounds/second, so this
            -- needs ~20s of continuous, fully accurate fire; 30s leaves room to aim and
            -- reposition. At 10s it was mathematically unwinnable (only ~90 rounds fit).
            time = 30000,
        },
    },
}

--- Shared linear search behind `getByLicence`/`getById` - both just look up a course by a
--- different field, so the loop itself exists once.
---@param field string
---@param value string
---@return table? course
local function findCourseBy(field, value)
    for i = 1, #CourseConfig.courses do
        if CourseConfig.courses[i][field] == value then
            return CourseConfig.courses[i]
        end
    end
end

---@param licence string
---@return table? course
function CourseConfig.getByLicence(licence)
    return findCourseBy('licence', licence)
end

---@param id string
---@return table? course
function CourseConfig.getById(id)
    return findCourseBy('id', id)
end
