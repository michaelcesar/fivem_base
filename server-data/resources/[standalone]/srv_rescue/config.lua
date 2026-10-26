return {
    --- Servidor: what the police are told when a wanted player tries to call. Shaped like
    --- srv_wanted's own 'Procurado tentando usar loja' so both read as one alert system rather
    --- than two - a player learns the rule once and it holds everywhere.
    alert = 'Procurado chamando ambulância',

    --- What the NPC rescue costs. A character may owe this ONCE; while the debt stands, the service
    --- is refused and the only way up is another player.
    price = 10000,

    --- The transplant. Offered only once the bleed-out clock has run out, as the alternative to
    --- respawning and losing a life: the character was going to die anyway, so this is the last
    --- door out - expensive on purpose.
    transplant = {
        price = 20000,

        --- Flavour. One is picked at random so the same player hears a different story each time,
        --- which is the whole reason to name an organ instead of saying "you were operated on".
        organs = {
            'um rim', 'o baço', 'parte do fígado', 'um pulmão', 'parte do intestino',
            'a vesícula', 'parte do pâncreas',
        },

        --- Seconds of black screen standing in for the operation. GTA has no surgery cutscene a
        --- script can invoke - the medical scenes in the story mode are mission cutscenes and are
        --- not reusable - so the operation is time passing on a bed, which reads correctly without
        --- pretending to be something that does not exist.
        surgerySeconds = 12,
    },

    --- How long before a medic can be called again. The free option should not be one shot per
    --- knockdown: nobody may be on duty at the first press, and someone may come on two minutes
    --- later. Shaped like the ambulance attempts so both read as the same idea.
    medicCooldownSeconds = 120,

    --- Where a rescued player wakes: healed, on their feet, inside the hospital.
    ---
    --- Surveyed in the phxlsmc MLO. The player wakes LYING on this bed rather than standing
    --- beside it, which is what a hospital arrival looks like - and it matches how the check-in
    --- beds already behave.
    wakeCoords = vec4(346.63, -576.02, 29.50, 249.06),

    --- How long after the knockout the ambulance can still be sent. Past this the player has bled
    --- out and there is nobody to collect, so a paid rescue is delivered directly instead. Matches
    --- `qbx_medical`'s own `deathTime`.
    dispatchWindow = 300,

    ambulance = {
        model = `ambulance`,
        driver = `s_m_m_paramedic_01`,

        --- How far away the ambulance is created. Far enough that it is not conjured in front of
        --- the player, close enough that the NPC only has to drive a stretch it can actually handle
        --- - long-range GTA pathfinding is the least reliable part of this whole idea.
        --- Far enough that the ambulance is coming FROM somewhere rather than appearing around the
        --- corner. The cost is a longer drive, which is also more chance of the NPC getting stuck -
        --- acceptable because the player is not coupled to the vehicle and gets to hospital either
        --- way.
        --- Reduced from 400. The node search offsets randomly in BOTH axes, so 400 meant anywhere
        --- in an 800x800m box - sometimes 10m away, sometimes 565m diagonally, with the same clock
        --- either way. 250 keeps it clearly "coming from somewhere" without the far end of that
        --- spread being unreachable in the time given.
        spawnDistance = 250.0,

        -- Emergency speed. The driving style already skips traffic lights (786603 has no
        -- stop-at-lights flag), so the siren, the aggression and this number agree with each
        -- other instead of one of them quietly holding the others back.
        driveSpeed = 45.0,

        --- Emergency driving. Flags, written out because a bare number here is unmaintainable:
        ---
        ---       4  avoid vehicles          (steer around, do not stop)
        ---       8  avoid empty vehicles
        ---      16  avoid peds
        ---      32  avoid objects
        ---  262144  take the shortest path
        ---  ------
        ---  262204
        ---
        --- What is deliberately ABSENT is 1 and 2 - stop before vehicles, stop before peds. The
        --- previous value (786603) carried both, and while it never had the stop-at-lights flag,
        --- queueing behind the traffic already stopped at a red light looks exactly like obeying
        --- it. An ambulance with its siren on should go around them.
        drivingStyle = 262204,

        --- How many ambulances will be sent before the call is given up on, and how long each one
        --- gets to arrive. Failure is a real outcome here rather than an error to hide: an
        --- ambulance that cannot reach the player is left to fail, and the player is told, instead
        --- of the vehicle being teleported into place in front of everyone watching.
        attempts = 3,
        --- 3 x 100 = 300s, which is exactly the bleed-out window. The attempts now span the
        --- whole time the player has rather than finishing early and leaving him watching a
        --- dead panel - and the transplant is what waits at the end of it.
        attemptSeconds = 100,

        --- Seconds the player rides before the fade. Bystanders need long enough to watch the
        --- ambulance pull away; the passenger does not need to see the trip.
        rideSeconds = 15,

        --- Cleanup. The vehicle is removed once no player is within `keepAliveRadius`, or after
        --- `maxLifetime` regardless - a wreck stuck in an alley nobody visits would otherwise live
        --- forever. Anything the server creates has to be reclaimable (CLAUDE.md rule 3).
        keepAliveRadius = 150.0,
        maxLifetime = 240,
    },
}
