return {
    ['testburger'] = {
        label = 'Hambúrguer de Teste',
        allowArmed = true,
        weight = 220,
        degrade = 60,
        client = {
            image = 'burger_chicken.png',
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            export = 'ox_inventory_examples.testburger'
        },
        server = {
            export = 'ox_inventory_examples.testburger',
            test = 'what an amazingly delicious burger, amirite?'
        },
        buttons = {
            {
                label = 'Lick it',
                action = function(slot)
                    print('You licked the burger')
                end
            },
            {
                label = 'Squeeze it',
                action = function(slot)
                    print('You squeezed the burger :(')
                end
            },
            {
                label = 'What do you call a vegan burger?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('A misteak.')
                end
            },
            {
                label = 'What do frogs like to eat with their hamburgers?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('French flies.')
                end
            },
            {
                label = 'Why were the burger and fries running?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('Because they\'re fast food.')
                end
            }
        },
        consume = 0.3
    },

    ['bandage'] = {
        label = 'Bandagem',
        allowArmed = true,
        weight = 115,
        client = { image = 'bandage.png' },
    },

    ['burger'] = {
        label = 'Hambúrguer',
        allowArmed = true,
        weight = 220,
        client = {
            image = 'burger.png',
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            notification = 'Você comeu um hambúrguer delicioso.'
        },
    },

    ['sprunk'] = {
        label = 'Sprunk',
        allowArmed = true,
        weight = 350,
        client = {
            image = 'sprunk.png',
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'Você matou a sede com uma Sprunk.'
        }
    },

    ['parachute'] = {
        label = 'Paraquedas',
        weight = 8000,
        stack = false,
        client = {
            image = 'parachute.png',
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 1500
        }
    },

    ['garbage'] = {
        label = 'Lixo',
        client = { image = 'garbage.png' },
    },

    ['paperbag'] = {
        label = 'Saco de Papel',
        weight = 1,
        stack = false,
        close = false,
        consume = 0,
        client = { image = 'paperbag.png' },
    },

    ['panties'] = {
        label = 'Calcinha',
        allowArmed = true,
        weight = 10,
        consume = 0,
        client = {
            image = 'panties.png',
            status = { thirst = -100000, stress = -25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
            usetime = 2500,
        }
    },

    ['lockpick'] = {
        -- Servidor: 'Chave Mestra', not 'Gazua', by request. Changed here rather than only in the
        -- messages that mention it - the item label is what the inventory slot itself shows, so
        -- leaving it would have the inventory say one word while every notification said another.
        label = 'Chave Mestra',
        weight = 160,
        client = { image = 'lockpick.png' },
    },

    ['phone'] = {
        label = 'Celular',
        weight = 190,
        stack = false,
        consume = 0,
        client = {
            image = 'phone.png',
            add = function(total)
                if total > 0 then
                    pcall(function() return exports.npwd:setPhoneDisabled(false) end)
                end
            end,

            remove = function(total)
                if total < 1 then
                    pcall(function() return exports.npwd:setPhoneDisabled(true) end)
                end
            end
        }
    },

    ['mustard'] = {
        label = 'Mostarda',
        allowArmed = true,
        weight = 500,
        client = {
            image = 'mustard.png',
            status = { hunger = 25000, thirst = 25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
            usetime = 2500,
            notification = 'Você... bebeu mostarda.'
        }
    },

    ['water'] = {
        label = 'Água',
        allowArmed = true,
        weight = 500,
        client = {
            image = 'water.png',
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            cancel = true,
            notification = 'Você bebeu uma água geladinha.'
        }
    },

    ['armour'] = {
        label = 'Colete à Prova de Balas',
        weight = 3000,
        stack = false,
        client = {
            image = 'armour.png',
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500
        }
    },

    ['clothing'] = {
        label = 'Roupa',
        consume = 0,
        client = { image = 'clothing.png' },
    },

    ['money'] = {
        label = 'Dinheiro',
        client = { image = 'money.png' },
    },

    ['black_money'] = {
        label = 'Dinheiro Sujo',
        client = { image = 'black_money.png' },
    },

    -- Servidor: none of these four had a client.image, so ox_inventory had nothing to show
    -- and the slot rendered blank. card_id.png already exists in web/images and fits all
    -- four - they're all wallet-card documents.
    -- Servidor: `police:server:SeizeCash` hands the officer a `moneybag` carrying the seized amount
    -- in metadata, and that item did not exist in this catalog - so `AddItem` failed silently and
    -- the money was taken off the target and given to nobody. Found while wiring the ALT menu.
    -- See ADR-101.
    ['moneybag'] = {
        label = 'Malote',
        weight = 100,
        stack = false,
        client = {
            image = 'money.png'
        },
    },

    ['id_card'] = {
        label = 'RG',
        client = { image = 'card_id.png' },
    },

    ['driver_license'] = {
        label = 'CNH',
        client = { image = 'card_id.png' },
    },

    ['weaponlicense'] = {
        label = 'Porte de Arma',
        client = { image = 'card_id.png' },
    },

    ['lawyerpass'] = {
        label = 'Carteira de Advogado',
        client = { image = 'card_id.png' },
    },

    ['radio'] = {
        label = 'Rádio',
        weight = 1000,
        allowArmed = true,
        consume = 0,
        client = {
            image = 'radio.png',
            event = 'qbx_radio:client:use'
        }
    },

    ['jammer'] = {
        label = 'Bloqueador de Sinal',
        weight = 10000,
        allowArmed = true,
        client = {
            image = 'jammer.png',
            event = 'mm_radio:client:usejammer'
        }
    },

    ['radiocell'] = {
        label = 'Pilhas AAA',
        weight = 1000,
        stack = true,
        allowArmed = true,
        client = {
            image = 'radiocell.png',
            event = 'mm_radio:client:recharge'
        }
    },

    ['advancedlockpick'] = {
        label = 'Lockpick Avançada',
        weight = 500,
        client = { image = 'advancedlockpick.png' },
    },

    ['screwdriverset'] = {
        label = 'Jogo de Chaves de Fenda',
        weight = 500,
        client = { image = 'screwdriverset.png' },
    },

    ['electronickit'] = {
        label = 'Kit Eletrônico',
        weight = 500,
        client = { image = 'electronickit.png' },
    },

    -- Servidor: labels translated (rule 1) now that `YouTool` actually sells these three - real
    -- `vehiclehandler` `usingItem` exports (basic wash / small fix / big fix), not stubs.
    --
    -- `server.export` is what actually connects them. These three entries are ox_inventory's own
    -- stock definitions, which are label/weight/image only - they never carried the export, so
    -- using one did literally nothing: no notification, no error, no server log line, because
    -- ox_inventory had nothing to call. `vehiclehandler`'s README documents this wiring as a
    -- required install step and it had simply never been done here. Reported three times as "the
    -- repair kit isn't working"; the two earlier fixes (the front/back-engine notification and
    -- `includePlayerVehicle`) were real bugs in code this missing line meant was never reached at
    -- all. See ADR-122.
    ['cleaningkit'] = {
        label = 'Kit de Limpeza',
        weight = 500,
        client = { image = 'cleaningkit.png' },
        server = { export = 'vehiclehandler.cleaningkit' },
    },

    ['repairkit'] = {
        label = 'Kit de Reparo',
        weight = 2500,
        client = { image = 'repairkit.png' },
        server = { export = 'vehiclehandler.repairkit' },
    },

    -- Servidor: this project's own item, not part of ox_inventory's stock catalog - the panel-work
    -- counterpart to `repairkit`'s engine work, requested as a separate purchase so the two halves
    -- of vehicle damage are repaired separately. Icon is `bumper.png` from the same TILP `[garage]`
    -- set `repairkit.png` and `cleaningkit.png` themselves come from (verified byte-identical), so
    -- the three read as one family in the inventory. See ADR-124.
    ['bodykit'] = {
        label = 'Kit de Lataria',
        weight = 2500,
        client = { image = 'bodykit.png' },
        server = { export = 'vehiclehandler.bodykit' },
    },

    ['advancedrepairkit'] = {
        label = 'Kit de Reparo Avançado',
        weight = 4000,
        client = { image = 'advancedrepairkit.png' },
        server = { export = 'vehiclehandler.advancedrepairkit' },
    },

    -- Servidor: the four - pt-BR labels and images, from the same user-provided TILP pack used
    -- throughout `data/items.lua` (Downloads/TILP FREE FiveM Icons/fivem icons, the non-outlined
    -- set - matched byte-for-byte against `coca_leaf.png` to confirm this project already uses
    -- that variant). None of the four had a client.image before, so every slot rendered blank; none
    -- were reachable in any gameplay system before `srv_robbery`'s story-house loot.
    ['diamond_ring'] = {
        label = 'Anel de Diamante',
        weight = 1500,
        client = { image = 'diamond_ring.png' },
    },

    ['rolex'] = {
        label = 'Relógio de Ouro',
        weight = 1500,
        client = { image = 'rolex.png' },
    },

    ['goldbar'] = {
        label = 'Barra de Ouro',
        weight = 1500,
        client = { image = 'goldbar.png' },
    },

    ['goldchain'] = {
        label = 'Corrente de Ouro',
        weight = 1500,
        client = { image = 'goldchain.png' },
    },

    -- Servidor: four more, new items rather than reused ones - requested variety for the
    -- story-house loot table, ~7-8 pieces rather than the same 4 repeated. Icons from the same
    -- TILP pack's `[jewelry]` and `[crime]` folders (the latter has `stolentv.png`/
    -- `stolenstereo.png` literally themed for this). Item keys are ours to invent (unlike a ped or
    -- prop model, a table key here is never checked against external game data, so there is no
    -- silent-failure risk in choosing one - CLAUDE.md rule 4 does not apply to these).
    ['diamond_necklace'] = {
        label = 'Colar de Diamante',
        weight = 1500,
        client = { image = 'diamond_necklace.png' },
    },

    ['bearer_bond'] = {
        label = 'Título ao Portador',
        weight = 50,
        client = { image = 'bearer_bond.png' },
    },

    -- Servidor: the escape valve for `srv_wanted`'s "procurado" mark - using it clears the mark and
    -- puts on a random one of the player's own saved outfits, the one legitimate way to change
    -- clothes while every shop that would normally do that is refusing to open. Stacks, so buying
    -- several at once is how a player carries more than one use. See `srv_wanted/server.lua`.
    ['wardrobe_pass'] = {
        label = 'Kit de Disfarce',
        weight = 300,
        client = { image = 'wardrobe_pass.png' },
    },

    -- Servidor: `srv_wardrobe`'s reusable outfit-switcher - opens a menu of the player's own saved
    -- outfits from anywhere, no shop needed. Never consumed. See `srv_wardrobe/server.lua`.
    ['clothes_bundle'] = {
        label = 'Trouxa de Roupas',
        weight = 1000,
        client = { image = 'clothes_bundle.png' },
    },

    -- Servidor: the intermediate step for both new illegal farms - `srv_gunlab`'s stations turn 4x
    -- `metalscrap` into one of these, and `srv_gunlab_press` (ox_inventory crafting bench, same
    -- ADR-069 pattern the drug farms use) turns 4x of these into one of the 10 real weapons. Icon
    -- from the same TILP pack, `[crafting]/snspistol_part_1.png` - a real gun-part photo, not a
    -- generic placeholder, even though the part itself is meant to read as "for any of the ten".
    ['weapon_part'] = {
        label = 'Peça de Arma',
        weight = 400,
        client = { image = 'weapon_part.png' },
    },

    -- Servidor: `srv_ammolab`'s own intermediate - 4x `copper` becomes one of these at a station,
    -- and `srv_ammolab_press` turns 4x of these into one of the 6 real ammo types. Icon from the
    -- user-provided `icons-main` pack, `police/BulletCasings.png`.
    ['ammo_part'] = {
        label = 'Peça de Munição',
        weight = 150,
        client = { image = 'ammo_part.png' },
    },

    ['stolen_tv'] = {
        label = 'TV Roubada',
        weight = 8000,
        client = { image = 'stolen_tv.png' },
    },

    ['stolen_stereo'] = {
        label = 'Som Roubado',
        weight = 5000,
        client = { image = 'stolen_stereo.png' },
    },

    -- Servidor: the crack chain. `crack_baggy` already existed in the default catalog with a real,
    -- tested effect in `qbx_consumables` (1.3x sprint, the heaviest ragdoll of the three, the
    -- Michael screen filter, `widepupils`) and no way at all to obtain it - the exact inverse of a
    -- dead catalog entry. `srv_cracklab` gives it an origin; only its label and image change here.
    --
    -- The others are new, mirroring every other farm exactly: raw -> processed -> pressed -> retail,
    -- with the raw bought from the lab's own NPC. An earlier version fed the lab `cocaine_paste` from
    -- `srv_cocainelab` instead - dropped, because a farm that depends on another farm's output is a
    -- farm with a supply bottleneck by construction. See ADR-095.
    ['crack_baggy'] = {
        label = 'Pedra de Crack',
        allowArmed = true,
        weight = 100,
        client = {
            image = 'crack_baggy.png'
        },
    },

    ['crack_ammonia'] = {
        label = 'Amônia',
        weight = 500,
        client = {
            image = 'crack_ammonia.png'
        },
    },

    ['crack_base'] = {
        label = 'Base de Cocaína',
        weight = 200,
        client = {
            image = 'crack_base.png'
        },
    },

    ['crack_rock'] = {
        label = 'Crack Bruto',
        weight = 200,
        client = {
            image = 'crack_rock.png'
        },
    },

    ['crack_brick'] = {
        label = 'Tijolo de Crack',
        weight = 2000,
        client = {
            image = 'crack_brick.png'
        },
    },

    ['crack_bag'] = {
        label = 'Saquinho de Crack',
        weight = 200,
        client = {
            image = 'crack_bag.png'
        },
    },

    ['cokebaggy'] = {
        label = 'Papelote de Cocaína',
        allowArmed = true,
        weight = 100,
        client = {
            image = 'cokebaggy.png'
        },
    },

    -- Servidor: meth's consumer form, and the one that had to be created. There was no ready-made
    -- meth consumable to reuse: `crack_baggy` is a cocaine derivative and `xtcbaggy` is ecstasy,
    -- and `meth` itself is the press ingredient - selling that back would rebuild ADR-073's exact
    -- money printer. Rather than leave meth as the one drug without a consumer tier (the three
    -- farms are deliberately symmetrical), this item is new.
    --
    -- Its *effect* is still not new: `qbx_consumables` exports the meth effect as
    -- `exports.qbx_smallresources:MethBagEffect()`, so `srv_methlab` drives the same tested
    -- behaviour without a single edit to that third-party resource.
    --
    -- Named for what the art actually shows: the icon pack has no pipe, so the item is a prepared
    -- dose rather than a name with no matching image.
    ['meth_dose'] = {
        label = 'Dose de Metanfetamina',
        allowArmed = true,
        weight = 100,
        client = {
            image = 'meth_dose.png'
        },
    },

    ['coke_brick'] = {
        label = 'Tijolo de Coca Bruta',
        weight = 2000,
        client = { image = 'coke_brick.png' },
    },

    ['coke_small_brick'] = {
        label = 'Pacote de Coca Bruta',
        weight = 1000,
        client = { image = 'coke_small_brick.png' },
    },

    ['xtcbaggy'] = {
        label = 'Papelote de Ecstasy',
        allowArmed = true,
        weight = 100,
        client = { image = 'xtcbaggy.png' },
    },

    -- Servidor: `meth_crystal.png` (loose rock), NOT ox_inventory's own bundled `meth.png` - that
    -- one is a *bagged* baggie, which made the processed product and the retail `meth_bag` look
    -- like the same thing, exactly the confusion ADR-073's item split was meant to end. The
    -- bundled file is left untouched under its own name rather than overwritten.
    -- Servidor: 'Metanfetamina Bruta', not 'Metanfetamina'. This is the press INGREDIENT - the
    -- chain is meth_precursor -> meth -> meth_brick -> meth_bag, and the press eats five of these
    -- per brick. It is deliberately NOT usable; the consumable is `meth_dose`.
    --
    -- Renamed because the two read as the same thing in a give-item list ('Metanfetamina' beside
    -- 'Dose de Metanfetamina') and the ingredient was tried as a drug. 'Bruta' matches `crack_rock`
    -- ('Crack Bruto'), which is the same role in the crack chain. See ADR-163.
    ['meth'] = {
        label = 'Metanfetamina Bruta',
        weight = 100,
        client = {
            image = 'meth_crystal.png'
        },
    },

    ['meth_precursor'] = {
        label = 'Metilamina',
        weight = 50,
        client = {
            image = 'meth_precursor.png'
        },
    },

    ['meth_brick'] = {
        label = 'Tijolo de Metanfetamina',
        weight = 2000,
        client = {
            image = 'meth_brick.png'
        },
    },

    -- Servidor: the retail end of each drug's chain - what a dealer NPC sells back out of the
    -- stock a sold brick restocked, and what `srv_jobs`' street-dealing shift consumes per
    -- delivery. Deliberately NOT the same item the press consumes: sharing one item between
    -- "raw material" and "retail baggie" let a player buy baggies, press them straight into a
    -- brick, and sell it back for more than they paid, with no farming at all. See ADR-073.
    ['weed_bag'] = {
        label = 'Saquinho de Maconha',
        weight = 200,
        client = {
            image = 'weed_bag.png'
        },
    },

    ['cocaine_bag'] = {
        label = 'Saquinho de Cocaína',
        weight = 200,
        client = {
            image = 'cocaine_bag.png'
        },
    },

    ['meth_bag'] = {
        label = 'Saquinho de Metanfetamina',
        weight = 200,
        client = {
            image = 'meth_bag.png'
        },
    },

    ['oxy'] = {
        label = 'Oxicodona',
        allowArmed = true,
        weight = 100,
        client = { image = 'oxy.png' },
    },

    ['weed_ak47'] = {
        label = 'AK47 2g',
        weight = 200,
        client = { image = 'weed_ak47.png' },
    },

    ['weed_ak47_seed'] = {
        label = 'Semente de AK47',
        weight = 1,
        client = { image = 'weed_seed.png' },
    },

    ['weed_skunk'] = {
        label = 'Skunk 2g',
        weight = 200,
        client = {
            image = 'weed_skunk.png'
        },
    },

    ['weed_skunk_seed'] = {
        label = 'Semente de Skunk',
        weight = 1,
        client = {
            image = 'weed_skunk_seed.png'
        },
    },

    ['weed_amnesia'] = {
        label = 'Amnesia 2g',
        weight = 200,
        client = { image = 'weed_amnesia.png' },
    },

    ['weed_amnesia_seed'] = {
        label = 'Semente de Amnesia',
        weight = 1,
        client = { image = 'weed_seed.png' },
    },

    ['weed_og-kush'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_og-kush_seed'] = {
        label = 'OGKush Seed',
        weight = 1,
    },

    ['weed_white-widow'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_white-widow_seed'] = {
        label = 'White Widow Seed',
        weight = 1,
    },

    ['weed_purple-haze'] = {
        label = 'Purple Haze 2g',
        weight = 200,
    },

    ['weed_purple-haze_seed'] = {
        label = 'Purple Haze Seed',
        weight = 1,
    },

    ['weed_brick'] = {
        label = 'Tijolo de Maconha',
        weight = 2000,
        client = {
            image = 'weed_brick.png'
        },
    },

    ['coca_leaf'] = {
        label = 'Folha de Coca',
        weight = 1,
        client = {
            image = 'coca_leaf.png'
        },
    },

    ['cocaine_paste'] = {
        label = 'Pasta de Cocaína',
        weight = 200,
        client = {
            image = 'cocaine.png'
        },
    },

    ['cocaine_brick'] = {
        label = 'Tijolo de Cocaína',
        weight = 2000,
        client = {
            image = 'cocaine_brick.png'
        },
    },

    -- Servidor: the three production accelerators, one per farm - each one applied to an occupied,
    -- still-running plot/station cuts a fixed slice off its remaining time (see each farm's own
    -- `boost*` config). Sold together by `srv_chemist`, never produced. See ADR-082.
    --
    -- `weed_nutrition` already existed in ox_inventory's own default catalog, unused and with no
    -- image and an English label; it is reused rather than replaced by a new key, and only its
    -- label (rule 1 - player-visible text is pt-BR), weight and image are corrected here. The
    -- other two are new.
    --
    -- All three images are existing base ox_inventory art reused rather than invented: a real
    -- fertilizer can, an acid package (sulfuric acid is genuinely how coca paste is extracted) and
    -- a gas canister. Worth replacing with dedicated art eventually - nothing depends on them.
    ['weed_nutrition'] = {
        label = 'Fertilizante',
        weight = 500,
        client = {
            image = 'WEAPON_FERTILIZERCAN.png'
        },
    },

    ['cocaine_solvent'] = {
        label = 'Solvente Químico',
        weight = 500,
        client = {
            image = 'WEAPON_ACIDPACKAGE.png'
        },
    },

    ['meth_catalyst'] = {
        label = 'Catalisador',
        weight = 500,
        client = {
            image = 'WEAPON_BZGAS.png'
        },
    },

    -- Servidor: the three consumer forms - the retail tier that actually does something when used,
    -- sold by each farm's own dealer alongside the plain `_bag` from the same stock pool. See
    -- ADR-084.
    --
    -- `joint` and `cokebaggy` already existed in ox_inventory's default catalog and are already
    -- wired to real, tested effects by `qbx_consumables` (animation, sprint multiplier, ragdoll,
    -- and the `evidence:client:SetStatus` hooks police forensics reads). Nothing about those
    -- effects is touched here - only the label (rule 1 - player-visible text is pt-BR) and an
    -- image, since neither had one and both were about to become obtainable for the first time.
    ['joint'] = {
        label = 'Baseado',
        allowArmed = true,
        weight = 200,
        client = {
            image = 'joint.png'
        },
    },

    ['rolling_paper'] = {
        label = 'Seda',
        weight = 0,
        client = { image = 'rolling_paper.png' },
    },

    ['empty_weed_bag'] = {
        label = 'Saquinho Vazio',
        weight = 0,
        client = { image = 'empty_weed_bag.png' },
    },

    ['firstaid'] = {
        label = 'Kit de Primeiros Socorros',
        weight = 2500,
        client = {
            image = 'medikit.png'
        },
    },

    ['painkillers'] = {
        label = 'Analgésicos',
        allowArmed = true,
        weight = 400,
        client = { image = 'painkillers.png' },
    },

    ['firework1'] = {
        label = '2Brothers',
        weight = 1000,
        client = { image = 'firework1.png' },
    },

    ['firework2'] = {
        label = 'Poppelers',
        weight = 1000,
        client = { image = 'firework2.png' },
    },

    ['firework3'] = {
        label = 'WipeOut',
        weight = 1000,
        client = { image = 'firework3.png' },
    },

    ['firework4'] = {
        label = 'Weeping Willow',
        weight = 1000,
        client = { image = 'firework4.png' },
    },

    ['steel'] = {
        label = 'Aço',
        weight = 100,
        client = { image = 'steel.png' },
    },

    ['rubber'] = {
        label = 'Borracha',
        weight = 100,
        client = { image = 'rubber.png' },
    },

    -- Servidor: the raw material for `srv_gunlab`'s weapon farm - reused, not invented. Shipped as
    -- an unused, English, iconless stub, the same shape `weed_nutrition`/`meth`/`crack_baggy` were
    -- each found in before being wired to a real gameplay system. Icon from the same TILP pack used
    -- throughout this file, whose `[crafting]/metalscrap.png` matches the item key exactly.
    ['metalscrap'] = {
        label = 'Sucata de Metal',
        weight = 100,
        client = { image = 'metalscrap.png' },
    },

    ['iron'] = {
        label = 'Ferro',
        weight = 100,
        client = { image = 'iron.png' },
    },

    -- Servidor: the raw material for `srv_ammolab`'s ammo farm - same reuse as `metalscrap` above,
    -- same pack's `[crafting]/copper.png`.
    ['copper'] = {
        label = 'Cobre',
        weight = 100,
        client = { image = 'copper.png' },
    },

    ['aluminum'] = {
        label = 'Alumínio',
        weight = 100,
        client = { image = 'aluminum.png' },
    },

    ['plastic'] = {
        label = 'Plástico',
        weight = 100,
        client = { image = 'plastic.png' },
    },

    ['glass'] = {
        label = 'Vidro',
        weight = 100,
        client = { image = 'glass.png' },
    },

    ['gatecrack'] = {
        label = 'Gatecrack',
        weight = 1000,
        client = { image = 'gatecrack.png' },
    },

    ['cryptostick'] = {
        label = 'Pendrive Cripto',
        weight = 100,
        client = { image = 'cryptostick.png' },
    },

    ['trojan_usb'] = {
        label = 'Trojan USB',
        weight = 100,
        client = { image = 'trojan_usb.png' },
    },

    ['toaster'] = {
        label = 'Torradeira',
        weight = 5000,
        client = {
            image = 'toaster.png',
        },
    },

    ['small_tv'] = {
        label = 'TV Pequena',
        weight = 100,
        client = { image = 'small_tv.png' },
    },

    ['security_card_01'] = {
        label = 'Cartão de Segurança A',
        weight = 100,
        client = { image = 'security_card_01.png' },
    },

    ['security_card_02'] = {
        label = 'Cartão de Segurança B',
        weight = 100,
        client = { image = 'security_card_02.png' },
    },

    ['drill'] = {
        label = 'Furadeira',
        weight = 5000,
        client = { image = 'drill.png' },
    },

    ['thermite'] = {
        label = 'Termite',
        weight = 1000,
        client = { image = 'thermite.png' },
    },

    ['diving_gear'] = {
        label = 'Equipamento de Mergulho',
        weight = 30000,
        client = { image = 'diving_gear.png' },
    },

    ['diving_fill'] = {
        label = 'Cilindro de Mergulho',
        weight = 3000,
        client = { image = 'diving_fill.png' },
    },

    ['antipatharia_coral'] = {
        label = 'Antipatharia',
        weight = 1000,
        client = { image = 'antipatharia_coral.png' },
    },

    ['dendrogyra_coral'] = {
        label = 'Dendrogyra',
        weight = 1000,
        client = { image = 'dendrogyra_coral.png' },
    },

    ['jerry_can'] = {
        label = 'Galão de Gasolina',
        weight = 3000,
        client = { image = 'jerry_can.png' },
    },

    ['nitrous'] = {
        label = 'Nitro',
        weight = 1000,
        client = { image = 'nitrous.png' },
    },

    ['wine'] = {
        label = 'Vinho',
        allowArmed = true,
        weight = 500,
        client = {
            image = 'wine.png',
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            notification = 'Você bebeu um vinho.'
        },
    },

    ['grape'] = {
        label = 'Uva',
        weight = 10,
        client = { image = 'grape.png' },
    },

    ['grapejuice'] = {
        label = 'Suco de Uva',
        allowArmed = true,
        weight = 200,
        client = {
            image = 'grapejuice.png',
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            notification = 'Você bebeu um suco de uva.'
        },
    },

    ['coffee'] = {
        label = 'Café',
        allowArmed = true,
        weight = 200,
        client = {
            image = 'coffee.png',
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
            notification = 'Você bebeu um café.'
        },
    },

    ['vodka'] = {
        label = 'Vodca',
        allowArmed = true,
        weight = 500,
        client = {
            image = 'vodka.png',
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            notification = 'Você bebeu vodca.'
        },
    },

    ['whiskey'] = {
        label = 'Whisky',
        allowArmed = true,
        weight = 200,
        client = {
            image = 'whiskey.png',
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            notification = 'Você bebeu whisky.'
        },
    },

    ['beer'] = {
        label = 'Cerveja',
        allowArmed = true,
        weight = 200,
        client = {
            image = 'beer.png',
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'Você bebeu uma cerveja.'
        },
    },

    ['sandwich'] = {
        label = 'Sanduíche',
        allowArmed = true,
        weight = 200,
        client = {
            image = 'burger.png',
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            notification = 'Você comeu um sanduíche.'
        },
    },

    ['walking_stick'] = {
        label = 'Bengala',
        weight = 1000,
        client = { image = 'walking_stick.png' },
    },

    ['lighter'] = {
        label = 'Isqueiro',
        weight = 200,
        client = { image = 'lighter.png' },
    },

    ['binoculars'] = {
        label = 'Binóculo',
        weight = 800,
        client = { image = 'binoculars.png' },
    },

    ['stickynote'] = {
        label = 'Bilhete',
        weight = 0,
        client = { image = 'stickynote.png' },
    },

    ['empty_evidence_bag'] = {
        label = 'Saco de Evidência Vazio',
        weight = 200,
        client = { image = 'empty_evidence_bag.png' },
    },

    ['filled_evidence_bag'] = {
        label = 'Saco de Evidência',
        weight = 200,
        client = { image = 'filled_evidence_bag.png' },
    },

    ['harness'] = {
        label = 'Cinto de Competição',
        weight = 200,
        client = { image = 'harness.png' },
    },

    -- Servidor: label translated (rule 1) and given an icon - it had neither, and it went from an
    -- item nothing sold to one `srv_interactions` depends on. See ADR-101.
    ['handcuffs'] = {
        label = 'Algemas',
        weight = 200,
        client = {
            image = 'WEAPON_HANDCUFFS.png'
        },
    },

    -- Servidor: a second, weaker restrain item - reuses the exact same cuff mechanic `handcuffs`
    -- already has (`srv_interactions`' cuff action, `qbx_police`'s server-side gate), rather than
    -- a new mechanic of its own. See the patches.md rows for `srv_interactions`/`qbx_police`.
    ['rope'] = {
        label = 'Corda',
        weight = 300,
        client = {
            image = 'rope.png',
        },
    },
}
