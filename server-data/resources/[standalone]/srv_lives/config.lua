return {
    --- How many lives a character starts with, and the ceiling any purchase or admin grant is
    --- clamped to. Losing the last one blocks the character permanently until an admin restores it.
    maxLives = 10,

    --- Servidor: the player-facing word for a life, in ONE place because the name is not settled.
    --- Every notification builds its text from these two, so renaming the mechanic later is a
    --- two-line change rather than a sweep - and a sweep across player-facing strings is exactly
    --- what this project has already paid for three times (see ADR-167).
    ---
    --- Candidates discussed: "vidas", "reanimações", "fôlego", "quadro clínico".
    label = {
        singular = 'vida',
        plural = 'vidas',
    },

    --- Where a character wakes after giving up: the morgue side of the hospital, not the bed a
    --- rescued player gets. Losing a life should not look like being rescued.
    respawnCoords = vec4(312.26, -567.55, 28.79, 158.46),

    --- What buying a life back costs, at the hospital counter and nowhere else.
    ---
    --- 50000, set deliberately high: two and a half times the transplant, five times the ambulance.
    --- Surviving must always be far cheaper than recovering, or the cheap options stop mattering -
    --- a player who can casually rebuy lives has no reason to pay 10k to avoid losing one.
    lifePrice = 50000,

    --- One life may be claimed for nothing every this many days. It exists so a character is never
    --- permanently stuck behind a price a new player cannot reach - the paid option is for people
    --- in a hurry, this one is for people who simply keep playing.
    freeEveryDays = 30,

    --- The counter itself, surveyed inside the phxlsmc MLO.
    counter = vec3(324.68, -594.34, 28.79),

    --- Below this many remaining, the player is warned every time they get back up. Existing so a
    --- character is never lost by someone who did not know they were close to the edge.
    warnAtOrBelow = 3,
}
