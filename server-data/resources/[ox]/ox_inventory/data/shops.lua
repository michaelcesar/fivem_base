return {
	-- Servidor: the handcuff vendor. `handcuffs` already existed in the catalog and `qbx_police`
	-- already reads it as the item cuffing requires, but nothing anywhere sold or handed one out - so
	-- "anyone carrying handcuffs may cuff" (ADR-101) meant nobody. This is that origin.
	--
	-- Open to everyone, not job-gated, because the permission it feeds is deliberately not
	-- police-only. A real /coords up in Grapeseed, deliberately away from the city.
	PoliceSupply = {
		name = 'Equipamento Policial',

		-- Servidor: a PERSON, not a counter - so `srv_interactions` owns the point and draws the disc
		-- this project uses for people, rather than the cone ox_inventory draws for shops. It also
		-- spawns the ped, which ox_inventory only does on the target-mode path.
		srvExternalInteraction = 'srv_interactions',
		blip = {
			id = 110, colour = 38, scale = 0.7
		}, inventory = {
			{ name = 'handcuffs', price = 500 },
		}, locations = {
			vec3(1852.80, 3689.65, 34.27)
		}
	},

	General = {
		name = 'Loja Geral',
		-- Servidor: srv_robbery owns the counter interaction here - one [E] point offering both
		-- "open shop" and "rob the till" in one menu, instead of a shop target and a robbery
		-- prompt fighting over the same spot. Only the client-side zone is skipped; this data is
		-- still what the server builds the shop from. See ADR-100.
		srvExternalInteraction = 'srv_robbery',
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'burger', price = 10 },
			{ name = 'water', price = 10 },
			{ name = 'sprunk', price = 10 },
			{ name = 'sandwich', price = 15 },
			{ name = 'radio', price = 150 },
			{ name = 'phone', price = 500 },
		}, locations = {
			vec3(25.7, -1347.3, 29.49),
			vec3(-3038.71, 585.9, 7.9),
			vec3(-3241.47, 1001.14, 12.83),
			vec3(1728.66, 6414.16, 35.03),
			vec3(1697.99, 4924.4, 42.06),
			vec3(1961.48, 3739.96, 32.34),
			vec3(547.79, 2671.79, 42.15),
			vec3(2679.25, 3280.12, 55.24),
			vec3(2557.94, 382.05, 108.62),
			vec3(373.55, 325.56, 103.56),
		}, targets = {
			{ loc = vec3(25.06, -1347.32, 29.5), length = 0.7, width = 0.5, heading = 0.0, minZ = 29.5, maxZ = 29.9, distance = 1.5 },
			{ loc = vec3(-3039.18, 585.13, 7.91), length = 0.6, width = 0.5, heading = 15.0, minZ = 7.91, maxZ = 8.31, distance = 1.5 },
			{ loc = vec3(-3242.2, 1000.58, 12.83), length = 0.6, width = 0.6, heading = 175.0, minZ = 12.83, maxZ = 13.23, distance = 1.5 },
			{ loc = vec3(1728.39, 6414.95, 35.04), length = 0.6, width = 0.6, heading = 65.0, minZ = 35.04, maxZ = 35.44, distance = 1.5 },
			{ loc = vec3(1698.37, 4923.43, 42.06), length = 0.5, width = 0.5, heading = 235.0, minZ = 42.06, maxZ = 42.46, distance = 1.5 },
			{ loc = vec3(1960.54, 3740.28, 32.34), length = 0.6, width = 0.5, heading = 120.0, minZ = 32.34, maxZ = 32.74, distance = 1.5 },
			{ loc = vec3(548.5, 2671.25, 42.16), length = 0.6, width = 0.5, heading = 10.0, minZ = 42.16, maxZ = 42.56, distance = 1.5 },
			{ loc = vec3(2678.29, 3279.94, 55.24), length = 0.6, width = 0.5, heading = 330.0, minZ = 55.24, maxZ = 55.64, distance = 1.5 },
			{ loc = vec3(2557.19, 381.4, 108.62), length = 0.6, width = 0.5, heading = 0.0, minZ = 108.62, maxZ = 109.02, distance = 1.5 },
			{ loc = vec3(373.13, 326.29, 103.57), length = 0.6, width = 0.5, heading = 345.0, minZ = 103.57, maxZ = 103.97, distance = 1.5 },
		}
	},

	Liquor = {
		name = 'Loja de Bebidas',
		-- Servidor: srv_robbery owns the counter interaction here - one [E] point offering both
		-- "open shop" and "rob the till" in one menu, instead of a shop target and a robbery
		-- prompt fighting over the same spot. Only the client-side zone is skipped; this data is
		-- still what the server builds the shop from. See ADR-100.
		srvExternalInteraction = 'srv_robbery',
		blip = {
			id = 93, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'water', price = 10 },
			{ name = 'sprunk', price = 10 },
			{ name = 'burger', price = 15 },
		}, locations = {
			vec3(1135.808, -982.281, 46.415),
			vec3(-1222.915, -906.983, 12.326),
			vec3(-1487.553, -379.107, 40.163),
			vec3(-2968.243, 390.910, 15.043),
			vec3(1166.024, 2708.930, 38.157),
			vec3(1392.562, 3604.684, 34.980),
			vec3(-1393.409, -606.624, 30.319)
		}, targets = {
			{ loc = vec3(1134.9, -982.34, 46.41), length = 0.5, width = 0.5, heading = 96.0, minZ = 46.4, maxZ = 46.8, distance = 1.5 },
			{ loc = vec3(-1222.33, -907.82, 12.43), length = 0.6, width = 0.5, heading = 32.7, minZ = 12.3, maxZ = 12.7, distance = 1.5 },
			{ loc = vec3(-1486.67, -378.46, 40.26), length = 0.6, width = 0.5, heading = 133.77, minZ = 40.1, maxZ = 40.5, distance = 1.5 },
			{ loc = vec3(-2967.0, 390.9, 15.14), length = 0.7, width = 0.5, heading = 85.23, minZ = 15.0, maxZ = 15.4, distance = 1.5 },
			{ loc = vec3(1165.95, 2710.20, 38.26), length = 0.6, width = 0.5, heading = 178.84, minZ = 38.1, maxZ = 38.5, distance = 1.5 },
			{ loc = vec3(1393.0, 3605.95, 35.11), length = 0.6, width = 0.6, heading = 200.0, minZ = 35.0, maxZ = 35.4, distance = 1.5 }
		}
	},

	-- Servidor: the table KEY stays `YouTool` - an internal identifier, not player-facing text, and
	-- nothing outside this row reads it as a display string. Only `name` below is what a player
	-- ever sees (the blip label and shop menu title), and that is now pt-BR.
	YouTool = {
		name = 'Loja de Ferramentas',
		blip = {
			id = 402, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'lockpick', price = 10 },
			-- Servidor: `srv_wanted`'s escape valve, sold here rather than at the two convenience
			-- stores - those are exactly what a "procurado" mark blocks, so selling it there would
			-- put it out of reach at the one moment it matters. YouTool isn't gated by the mark
			-- (see srv_robbery's own note on what's robbable/blockable), so it stays buyable mid-
			-- spree, and it already reads as "tools for a criminal" next to the lockpick.
			{ name = 'wardrobe_pass', price = 500 },
			-- Servidor: `srv_wardrobe`'s reusable outfit-switcher - priced well above the
			-- single-use `wardrobe_pass` since one purchase covers unlimited future uses.
			{ name = 'clothes_bundle', price = 3000 },
			-- Servidor: `handcuffs` already sold at `PoliceSupply` (ADR-101) - added here too so
			-- they're not police-exclusive to buy, same price to avoid an arbitrage between the
			-- two shops.
			{ name = 'handcuffs', price = 500 },
			-- Servidor: `rope` - a second, cheaper restrain item reusing `handcuffs`' exact same
			-- cuff mechanic (see `srv_interactions`/`qbx_police` patch rows). Priced below
			-- handcuffs, not because it's mechanically weaker (it isn't - same action, same
			-- result), but because it's meant to read as the improvised/backup option.
			{ name = 'rope', price = 350 },
			-- Servidor: `vehiclehandler`'s consumable kits - real, working `usingItem` exports
			-- (basic wash / small fix), had never been sold anywhere until now. The same "a
			-- working mechanic with no purchase path" gap ADR-101 found and fixed for handcuffs.
			-- `advancedrepairkit` deliberately left out - it repairs engine AND body in one go,
			-- which is exactly the combined tier this project replaced with two separate items;
			-- it stays reachable in the catalog (`data/items.lua`) but unsold, same as `tirekit`.
			--
			-- The three sold here cover one kind of damage each, and nothing overlaps: `repairkit`
			-- the engine, `bodykit` the panels, `cleaningkit` the dirt. Priced the same as
			-- `repairkit` since neither half of the damage is harder to cause than the other.
			-- See ADR-124.
			{ name = 'cleaningkit', price = 150 },
			{ name = 'repairkit', price = 800 },
			{ name = 'bodykit', price = 800 }
		}, locations = {
			vec3(2748.0, 3473.0, 55.67),
			vec3(342.99, -1298.26, 32.51)
		}, targets = {
			{ loc = vec3(2746.8, 3473.13, 55.67), length = 0.6, width = 3.0, heading = 65.0, minZ = 55.0, maxZ = 56.8, distance = 3.0 }
		}
	},

	Ammunation = {
		name = 'Ammunation',
		blip = {
			id = 110, colour = 69, scale = 0.8
		}, inventory = {
			-- Melee: free to everyone, no licence, no permit - matches how a hardware
			-- store would sell a knife or a bat.
			{ name = 'WEAPON_KNIFE', price = 200 },
			{ name = 'WEAPON_SWITCHBLADE', price = 250 },
			{ name = 'WEAPON_DAGGER', price = 300 },
			{ name = 'WEAPON_BAT', price = 100 },

			-- Tier 1 - Pistol course (licence 'weapon'). Also the entry point: this is
			-- the only tier where the weaponlicense permit alone is enough.
			{ name = 'WEAPON_PISTOL', price = 1000, metadata = { registered = true }, license = 'weapon' },
			{ name = 'WEAPON_COMBATPISTOL', price = 2500, metadata = { registered = true }, license = 'weapon' },
			{ name = 'WEAPON_APPISTOL', price = 4000, metadata = { registered = true }, license = 'weapon' },
			{ name = 'WEAPON_PISTOL_MK2', price = 6000, metadata = { registered = true }, license = 'weapon' },
			{ name = 'WEAPON_STUNGUN', price = 2000, metadata = { registered = true }, license = 'weapon' },
			{ name = 'ammo-9', price = 5, },

			-- Tier 2 - Escopeta course (licence 'weaponshotgun').
			{ name = 'WEAPON_SAWNOFFSHOTGUN', price = 7000, metadata = { registered = true }, license = 'weaponshotgun' },
			{ name = 'WEAPON_PUMPSHOTGUN', price = 9000, metadata = { registered = true }, license = 'weaponshotgun' },
			{ name = 'WEAPON_COMBATSHOTGUN', price = 16000, metadata = { registered = true }, license = 'weaponshotgun' },
			{ name = 'ammo-shotgun', price = 8 },

			-- Tier 3 - Rifle course (licence 'weaponrifle'): SMGs, MGs and rifles all
			-- share this certificate, same as srv_crosshair's weapon-group mapping.
			{ name = 'WEAPON_MICROSMG', price = 8000, metadata = { registered = true }, license = 'weaponrifle' },
			{ name = 'WEAPON_SMG', price = 10000, metadata = { registered = true }, license = 'weaponrifle' },
			{ name = 'WEAPON_ASSAULTRIFLE', price = 15000, metadata = { registered = true }, license = 'weaponrifle' },
			{ name = 'WEAPON_CARBINERIFLE', price = 18000, metadata = { registered = true }, license = 'weaponrifle' },
			{ name = 'WEAPON_COMBATMG', price = 25000, metadata = { registered = true }, license = 'weaponrifle' },
			{ name = 'ammo-45', price = 6 },
			{ name = 'ammo-rifle', price = 10 },
			{ name = 'ammo-rifle2', price = 10 },

			-- Tier 4 - Especialista course (licence 'weaponexpert'): snipers, heavy and
			-- thrown, the same catch-all tier that unlocks every crosshair class.
			{ name = 'WEAPON_SNIPERRIFLE', price = 22000, metadata = { registered = true }, license = 'weaponexpert' },
			{ name = 'WEAPON_HEAVYSNIPER', price = 35000, metadata = { registered = true }, license = 'weaponexpert' },
			{ name = 'WEAPON_GRENADE', price = 3000, metadata = { registered = true }, license = 'weaponexpert' },
			{ name = 'WEAPON_RPG', price = 50000, metadata = { registered = true }, license = 'weaponexpert' },
			{ name = 'ammo-sniper', price = 15 },
			{ name = 'ammo-heavysniper', price = 20 },
			{ name = 'ammo-rocket', price = 100 },
		}, locations = {
			vec3(-662.180, -934.961, 21.829),
			vec3(810.25, -2157.60, 29.62),
			vec3(1693.44, 3760.16, 34.71),
			vec3(-330.24, 6083.88, 31.45),
			vec3(252.63, -50.00, 69.94),
			vec3(22.56, -1109.89, 29.80),
			vec3(2567.69, 294.38, 108.73),
			vec3(-1117.58, 2698.61, 18.55),
		}, targets = {
			{ loc = vec3(-660.92, -934.10, 21.94), length = 0.6, width = 0.5, heading = 180.0, minZ = 21.8, maxZ = 22.2, distance = 2.0 },
			{ loc = vec3(808.86, -2158.50, 29.73), length = 0.6, width = 0.5, heading = 360.0, minZ = 29.6, maxZ = 30.0, distance = 2.0 },
			{ loc = vec3(1693.57, 3761.60, 34.82), length = 0.6, width = 0.5, heading = 227.39, minZ = 34.7, maxZ = 35.1, distance = 2.0 },
			{ loc = vec3(-330.29, 6085.54, 31.57), length = 0.6, width = 0.5, heading = 225.0, minZ = 31.4, maxZ = 31.8, distance = 2.0 },
			{ loc = vec3(252.85, -51.62, 70.0), length = 0.6, width = 0.5, heading = 70.0, minZ = 69.9, maxZ = 70.3, distance = 2.0 },
			{ loc = vec3(23.68, -1106.46, 29.91), length = 0.6, width = 0.5, heading = 160.0, minZ = 29.8, maxZ = 30.2, distance = 2.0 },
			{ loc = vec3(2566.59, 293.13, 108.85), length = 0.6, width = 0.5, heading = 360.0, minZ = 108.7, maxZ = 109.1, distance = 2.0 },
			{ loc = vec3(-1117.61, 2700.26, 18.67), length = 0.6, width = 0.5, heading = 221.82, minZ = 18.5, maxZ = 18.9, distance = 2.0 },
		}
	},

	AmmunationGear = {
		name = 'Ammunation - Equipamentos',
		blip = {
			id = 110, colour = 47, scale = 0.8
		}, inventory = {
			-- Servidor: a single Ammunation location dedicated to non-weapon gear, split
			-- off from the main catalog. No licence required - none of this is a firearm.
			{ name = 'armour', price = 500 },
			{ name = 'parachute', price = 300 },
			{ name = 'radio', price = 150 },
		}, locations = {
			vec3(842.44, -1033.42, 28.19)
		}, targets = {
			{ loc = vec3(841.05, -1034.76, 28.31), length = 0.6, width = 0.5, heading = 360.0, minZ = 28.2, maxZ = 28.6, distance = 2.0 }
		}
	},

	PoliceArmoury = {
		name = 'Police Armoury',
		groups = shared.police,
		blip = {
			id = 110, colour = 84, scale = 0.8
		}, inventory = {
			{ name = 'ammo-9', price = 5, },
			{ name = 'ammo-rifle', price = 5, },
			{ name = 'WEAPON_FLASHLIGHT', price = 200 },
			{ name = 'WEAPON_NIGHTSTICK', price = 100 },
			{ name = 'WEAPON_PISTOL', price = 500, metadata = { registered = true, serial = 'POL' }, license = 'weapon' },
			{ name = 'WEAPON_CARBINERIFLE', price = 1000, metadata = { registered = true, serial = 'POL' }, license = 'weapon', grade = 3 },
			{ name = 'WEAPON_STUNGUN', price = 500, metadata = { registered = true, serial = 'POL'} }
		}, locations = {
			vec3(451.51, -979.44, 30.68)
		}, targets = {
			{ loc = vec3(453.21, -980.03, 30.68), length = 0.5, width = 3.0, heading = 270.0, minZ = 30.5, maxZ = 32.0, distance = 6 }
		}
	},

	Medicine = {
		name = 'Armário Médico',
		groups = {
			['ambulance'] = 0
		},
		blip = {
			id = 403, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'firstaid', price = 26 },
			{ name = 'bandage', price = 5 }
		}, locations = {
			vec3(306.3687, -601.5139, 43.28406)
		}, targets = {

		}
	},

	BlackMarketArms = {
		name = 'Black Market (Arms)',
		inventory = {
			{ name = 'WEAPON_DAGGER', price = 5000, metadata = { registered = false	}, currency = 'black_money' },
			{ name = 'WEAPON_CERAMICPISTOL', price = 50000, metadata = { registered = false }, currency = 'black_money' },
			{ name = 'at_suppressor_light', price = 50000, currency = 'black_money' },
			{ name = 'ammo-rifle', price = 1000, currency = 'black_money' },
			{ name = 'ammo-rifle2', price = 1000, currency = 'black_money' }
		}, locations = {
			vec3(309.09, -913.75, 56.46)
		}, targets = {

		}
	},

	VendingMachineDrinks = {
		name = 'Vending Machine',
		inventory = {
			{ name = 'water', price = 10 },
			{ name = 'sprunk', price = 10 },
		},
		model = {
			`prop_vend_soda_02`, `prop_vend_fridge01`, `prop_vend_water_01`, `prop_vend_soda_01`
		}
	}
}
