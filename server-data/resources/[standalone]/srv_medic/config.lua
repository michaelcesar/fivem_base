return {
    --- Bounds on what a medic may charge. Not a fixed price: what the treatment is worth is a
    --- roleplay decision between two people, and pricing it centrally removes that. The bounds exist
    --- so the number cannot be an accident or an abuse - a zero is confusing and a million is a scam
    --- dressed as medicine.
    minPrice = 100,
    maxPrice = 25000,

    --- Suggested to the medic as the starting value in the dialog, so the common case is one press.
    defaultPrice = 2500,

    --- How close the medic must be. Checked on the server, because the client asking is the one
    --- being paid.
    maxDistance = 3.0,
}
