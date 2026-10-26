-- Servidor: reloading with R instead of opening the inventory and clicking an ammo box.
--
-- **This adds no reload logic of its own.** `ox_inventory` already reloads exactly the way an FPS
-- does - `client.lua`'s ammo branch computes `missingAmmo = clipSize - currentAmmo` and then
-- `addAmmo = math.min(resp.count, missingAmmo)`, so one round in the inventory loads one round,
-- five load five, and a full box fills the magazine. That was never the problem.
--
-- See ADR-160.
--
-- The problem was the TRIGGER: the only way to run it was to open the inventory and use the ammo
-- item, which is not something anyone does mid-fight. All this resource does is press that button
-- for you when you press R. Every rule about what may be loaded, how much, and whether you are
-- allowed to at all stays inside `ox_inventory` and is unchanged.

Config = {
    -- `INPUT_RELOAD`. The game's own reload control, so this binds to whatever key the player has
    -- mapped rather than assuming a physical R.
    --
    -- GTA already consumes this key: with ammo in reserve the engine reloads by itself, and this
    -- never runs because the magazine is not the thing that is empty. It matters only in the case
    -- the engine has nothing to do - reserve empty, ammo sitting in the inventory instead.
    reloadControl = 45,

    -- How long to wait after a reload before another can start, in ms.
    --
    -- Not a balance number: it exists because holding R fires the control every frame, and each
    -- press is a server round trip through `ox_inventory:useItem`. Without it, holding the key
    -- would queue dozens of them. Slightly longer than the round trip so a held key reloads at a
    -- sane rate rather than flooding.
    cooldown = 900,

    -- Whether to say why nothing happened when a reload cannot run.
    --
    -- On by default, and deliberately so: silence is what made the lockpick and the repair kit each
    -- get reported as broken three times over (CLAUDE.md rule 5 in spirit - a feature that fails
    -- without saying so looks identical to one that is not installed).
    notify = true,
}
