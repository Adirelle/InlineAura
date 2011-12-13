--[[
Inline Aura - displays aura information inside action buttons
Copyright (C) 2009-2011 Adirelle (adirelle@tagada-team.net)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
--]]

------------------------------------------------------------------------------
-- Per class defaults
------------------------------------------------------------------------------

-- GLOBALS: InlineAura_LoadDefaults
function InlineAura_LoadDefaults()

  -- These functions are not really globals but I have to list them here
  -- to prevent my checking script from whinning
	-- GLOBALS: SharedAuras SpellsByClass SelfBuffs Spells class Aliases SelfTalentProc GroupBuffs GroupDebuffs PetBuffs ShowSpecial

	------------------------------------------------------------------------------
	-- Group (de)buffs
	------------------------------------------------------------------------------
	--[[
	Do not list the (de)buffs that are all auras, procs, passive or come with the normal combat rotation.

	Please also note that it is sometimes useful to list both the (de)buff and the spell that causes it
	so the former is properly displayed on the latter. It won't pollute the presets because they are
	created only for known and active spells.

	Fully passive (de)buffs:
	- Increased Damage (3%)
	- Increased Critical Chance (5%)
	- Increased Spell Power (10%)
	- Physical Damage Taken (4%)
	- Spell Crit Taken (5%)
	]]

	--- Buffs ---

	-- Increased Stats (5%)
	SharedAuras(
		"PALADIN", 20217, -- Blessing of Kings
		"DRUID",    1126, -- Mark of the Wild
		"HUNTER",  90363  -- Embrace of the Shale Spider (exotic pet ability)
	):OnSelf()

	-- Increased Attack Power (10%)
	SharedAuras(
		"PALADIN",     19740, -- Blessing of Might
		"DEATHKNIGHT", 53138, -- Abomination's Might (passive)
		"HUNTER",      19506, -- Trueshot Aura (passive)
		"SHAMAN",      30808  -- Unleashed Rage (passive)
	):OnSelf()

	-- Increased Spell Power (6%)
	SharedAuras(
		"MAGE",   1459, -- Arcane Brillance
		"SHAMAN", 8227  -- Flametongue Totem
	):OnSelf()

	-- Increased Physical Haste (10%)
	SharedAuras(
		"DEATHKNIGHT", 55610, -- Improved Icy Talons (passive)
		"HUNTER",      53290, -- Hunting Party (passive)
		"SHAMAN",       8512  -- Windfury Totem
	):OnSelf()

	-- Increased Spell Haste (5%)
	SharedAuras(
		"SHAMAN",  3738, -- Wrath of Air Totem
		"PRIEST", 49868, -- Mind Quickening (passive)
		"DRUID",  24907  -- Moonkin Aura (passive)
	):OnSelf()

	-- Burst Haste (30%)
	SharedAuras(
		"SHAMAN", (UnitFactionGroup("player") == "Horde" and 2825 or 32182), -- Bloodlust/Heroism
		"SHAMAN", 57724, -- Sated (Bloodlst/Heroism debuff),
		"MAGE",   80353, -- Time Warp
		"MAGE",   80354, -- Temporal Displacement (Time Warp debuff)
		"HUNTER", 90355, -- Ancient Hysteria (exotic pet ability)
		"HUNTER", 95809  -- Insanity (Ancient Hysteria debuff)
	):OnSelf()

	-- Agility & Strength bonuses
	SharedAuras(
		"WARRIOR",      6673, -- Battle Shout
		"SHAMAN",       8076, -- Strength of Earth (Totem)
		"DEATHKNIGHT", 57330, -- Horn of Winter
		"HUNTER",      93435  -- Roar of Courage (pet ability)
	):OnSelf()

	-- Stamina Bonus
	SharedAuras(
		"PRIEST",  21562, -- Power Word: Fortitude
		"WARRIOR",   469, -- Commanding Shout
		"WARLOCK",  6307, -- Blood Pact (imp ability)
		"HUNTER",  90364  -- Qiraji Fortitude (exotic pet ability)
	):OnSelf()

	-- Armor Bonus
	SharedAuras(
		"PALADIN",  465, -- Devotion Aura
		"SHAMAN",  8071  -- Stoneskin Totem
	):OnSelf()

	-- Mana Bonus
	SharedAuras(
		"MAGE",     1459, -- Arcane Brillance
		"WARLOCK", 54424  -- Fel Intelligence (felhunter ability)
	):OnSelf()

	-- Pushback Resistance
	SharedAuras(
		"PALADIN", 19746, -- Concentration Aura
		"SHAMAN",  87718  -- Totem of Tranquil Mind
	):OnSelf()

	-- Nature Resistance Auras
	SharedAuras(
		"HUNTER", 20043, -- Aspect of the Wild
		"SHAMAN",  8184  -- Elemental Resistance Totem
	):OnSelf()

	-- Shadow Resistance Auras
	SharedAuras(
		"PRIEST",  27683, -- Shadow Protection
		"PALADIN", 19891  -- Resistance Aura
	):OnSelf()

	--- Debuffs ---

	-- Spell Damage Taken (8%)
	SharedAuras(
		"WARLOCK",      1490, -- Curse of the Elements
		"WARLOCK",     85547, -- Jinx
		"ROGUE",       58410, -- Master Poisoner (passive)
		"DEATHKNIGHT", 51160, -- Ebon Plaguebringer (passive)
		"DRUID",       48506, -- Earth and Moon (passive)
		"HUNTER",      34889, -- Fire Breath (pet ability)
		"HUNTER",      24844  -- Lightning Breath (pet ability)
	)

	-- Bleed Damage Taken (30%)
	SharedAuras(
		"DRUID",   33878, -- Mangle (bear)
		"DRUID",   33876, -- Mangle (cat)
		"ROGUE",   16511, -- Hemorrhage
		"WARRIOR", 29836, -- Blood Frenzy (passive)
		"HUNTER",  50271, -- Tendon Ripe (pet ability)
		"HUNTER",  35290, -- Gore (pet ability)
		"HUNTER",  57386  -- Stampede (pet ability)
	)

	-- Reduced Casting Speed (30%)
	SharedAuras(
		"WARLOCK",      1714, -- Curse of Tongues
		"ROGUE",        5761, -- Mind-Numbing Poison
		"MAGE",        31589, -- Slow
		"DEATHKNIGHT", 73975, -- Necrotic Strike
		"HUNTER",      50274, -- Spore Cloud (pet ability)
		"HUNTER",      58604  -- Lava Breath (pet ability)
	)

	-- Reduced Armor (12%)
	SharedAuras(
		"WARRIOR",  7386, -- Sunder Armor
		"WARRIOR", 20243, -- Devastate
		"ROGUE",    8647, -- Expose Armor
		"DRUID",     770, -- Faerie Fire (balance)
		"DRUID",   16857, -- Faerie Fire (feral)
		"DRUID",   91565, -- Faerie Fire (the actual debuff)
		"HUNTER",  35387, -- Corrosive Spit (pet ability)
		"HUNTER",  50498  -- Tear Armor (pet ability)
	):WithStack()

	-- Reduced Healing (25%)
	SharedAuras(
		"WARRIOR", 12294, -- Mortal Strike
		"WARRIOR", 46910, -- Furious Attacks
		"PRIEST",  15313, -- Improved Mind Blast
		"ROGUE",   13219, -- Wound Poison
		"HUNTER",  82654, -- Widow Venom
		"WARLOCK", 30213, -- Legion Strike (felguard ability)
		"HUNTER",  54680  -- Monstrous Bite (exotic pet ability)
	)

	-- Physical Damage Done (10%)
	SharedAuras(
		"WARLOCK",       702, -- Curse of Weakness
		"DRUID",          99, -- Demoralizing Roar
		"HUNTER",      50256, -- Demoralizing Roar (pet ability)
		"WARRIOR",      1160, -- Demoralizing Shout
		"DEATHKNIGHT", 81130, -- Scarlet Fever
		"PALADIN",     26017  -- Vindication
	)

	-- Reduced Attack Speed (20%)
	SharedAuras(
		"WARRIOR",      6343, -- Thunder Clap
		"SHAMAN",       8042, -- Earth Shock
		"HUNTER",      54404, -- Dust Cloud (Tallstrider)
		"DEATHKNIGHT", 55095, -- Frost Fever
		"DRUID",       58180, -- Infected Wounds
		"DRUID",       42231, -- Hurricane
		"HUNTER",      90315  -- Tailspin (Fox)
	)

	-- Spell Crit Taken (5%)
	SharedAuras(
		"WARLOCK",   686, -- Shadow Bolt
		"WARLOCK", 17800, -- Shadow and Flame
		"MAGE",    22959, -- Critical Mass
		"MAGE",     2948  -- Scorch
	)

	-- CC and tactical debuffs --

	-- Crowd control (using Phanx's list)
	SharedAuras(
		"WARLOCK",   710, -- Banish
		"SHAMAN",  76780, -- Bind Elemental
		"DRUID",   33786, -- Cyclone
		"DRUID",     339, -- Entangling Roots
		"WARLOCK",  5782, -- Fear
		"HUNTER",   3355, -- Freezing Trap
		"SHAMAN",  51514, -- Hex
		"DRUID",    2637, -- Hibernate
		"MAGE",      118, -- Polymorph
		"MAGE",    61305, -- Polymorph (Black Cat)
		"MAGE",    28272, -- Polymorph (Pig)
		"MAGE",    61721, -- Polymorph (Rabbit)
		"MAGE",    61780, -- Polymorph (Turkey)
		"MAGE",    28271, -- Polymorph (Turtle)
		"PALADIN", 20066, -- Repentance
		"ROGUE",    6770, -- Sap
		"WARLOCK",  6358, -- Seduction
		"PRIEST",   9484, -- Shackle Undead
		"PALADIN", 10326, -- Turn Evil
		"HUNTER",  19386  -- Wyvern Sting
	)

	-- Disarm (contributed by Moozhe)
	SharedAuras(
		"WARRIOR",   676, -- Disarm
		"HUNTER",  50541, -- Clench (Scorpid)
		"ROGUE",   51722, -- Dismantle
		"PRIEST",  64058, -- Psychic Horror
		"HUNTER",  91644  -- Snatch (Bird of Prey)
	)

	-- Snares and anti-snares (contributed by Moozhe)
	-- Note that some of these are talent procs or passive effects.
	-- This is intended as they will show up on active spells anyway.
	SharedAuras(
		"*",            1604, -- Dazed,
		"DEATHKNIGHT", 45524, -- Chains of Ice
		"DEATHKNIGHT", 50434, -- Chilblains
		"DEATHKNIGHT", 58617, -- Glyph of Heart Strike
		"DEATHKNIGHT", 68766, -- Desecration
		"DRUID",       50259, -- Dazed (feral charge effect)
		"DRUID",       58180, -- Infected Wounds
		"DRUID",       61391, -- Typhoon
		"MAGE",        31589, -- Slow
		"MAGE",        44614, -- Frostfire Bolt
		"HUNTER",       2974, -- Wing Clip
		"HUNTER",       5116, -- Concussive Shot
		"HUNTER",      13810, -- Ice Trap
		"HUNTER",      35101, -- Concussive Barrage
		"HUNTER",      35346, -- Time Warp (Warp Stalker)
		"HUNTER",      50433, -- Ankle Crack (Crocolisk)
		"HUNTER",      54644, -- Frost Breath (Chimaera)
		"HUNTER",      61394, -- Frozen Wake (glyph)
		"MAGE",          116, -- Frostbolt
		"MAGE",          120, -- Cone of Cold
		"MAGE",         6136, -- Chilled
		"MAGE",         7321, -- Chilled (bis)
		"MAGE",        11113, -- Blast Wave
		"PALADIN",      1044, -- Hand of Freedom
		"ROGUE",        3409, -- Crippling Poison
		"ROGUE",       26679, -- Deadly Throw
		"ROGUE",       31126, -- Blade Twisting
		"ROGUE",       51693, -- Waylay
		"ROGUE",       51585, -- Blade Twisting
		"SHAMAN",       3600, -- Earthbind
		"SHAMAN",       8034, -- Frostbrand Attack
		"SHAMAN",       8056, -- Frost Shock
		"SHAMAN",       8178, -- Grounding Totem Effect
		"WARLOCK",     18118, -- Aftermath
		"WARLOCK",     18223, -- Curse of Exhaustion
		"WARIROR",      1715, -- Piercing Howl
		"WARRIOR",     12323  -- Hamstring
	)

	-- Stuns (contributed by Moozhe)
	SharedAuras(
		"*",           20549, -- War Stomp (Tauren racial)
		"DEATHKNIGHT", 91800, -- Gnaw (Ghoul)
		"DRUID",        5211, -- Bash
		"DRUID",        9005, -- Pounce
		"DRUID",       22570, -- Maim
		"HUNTER",      19577, -- Intimidation
		"HUNTER",      50519, -- Sonic Blast (Bat)
		"HUNTER",      56626, -- Sting (famous singer)
		"MAGE",        12355, -- Impact
		"MAGE",        44572, -- Deep Freeze
		"MAGE",        82691, -- Ring of Frost
		"PALADIN",       853, -- Hammer of Justice
		"PALADIN",      2812, -- Holy Wrath
		"PRIEST",      88625, -- Holy Word: Chastise
		"ROGUE",         408, -- Kidney Shot
		"ROGUE",        1833, -- Cheap Shot
		"WARLOCK",     30283, -- Shadowfury
		"WARLOCK",     89766, -- Axe Toss (Felguard)
		"WARRIOR",     12809, -- Concussion Blow
		"WARRIOR",     20253, -- Intercept
		"WARRIOR",     46968, -- Shockwave
		"WARRIOR",     85388  -- Throwdown
	)

	-- Roots
	SharedAuras(
		"DRUID",     339, -- Entangling Roots
		"HUNTER",   4167, -- Web (Spider)
		"HUNTER",  19306, -- Counterattack
		"HUNTER",  50245, -- Pin (Crab)
		"HUNTER",  54706, -- Venom Web Spray (Silithid)
		"HUNTER",  90327, -- Lock Jaw (Dog)
		"MAGE",      122, -- Frost Nova
		"MAGE",    33395, -- Freeze (elementals)
		"MAGE",    63685, -- Freeze
		"SHAMAN",  64695, -- Earthgrab
		"WARRIOR", 23694  -- Improved Hamstring
	)

	-- Interrupts
	SpellsByClass(
		"DEATHKNIGHT", 47528, -- Mind Freeze
		"DEATHKNIGHT", 47476, -- Strangulate
		"DEATHKNIGHT", 91802, -- Shambling Rush (Ghoul)
		"DRUID",       80964, -- Skull Bash (bear)
		"DRUID",       80965, -- Skull Bash (cat)
		"DRUID",       78675, -- Solar Beam
		"HUNTER",      34490, -- Silencing Shot
		"HUNTER",      50479, -- Nether Shock (Nether Ray)
		"HUNTER",      26090, -- Pummel (Gorilla)
		"HUNTER",      50318, -- Serenity Dust (Moth)
		"MAGE",         2139, -- Counterspell
		"PALADIN",     96231, -- Rebuke
		"PRIEST",      15487, -- Silence
		"ROGUE",        1766, -- Kick
		"SHAMAN",      57994, -- Wind Shear
		"WARLOCK",     19647, -- Spell Lock (Felhunter)
		"WARRIOR",      6552  -- Pummel
	):ShowSpecial('INTERRUPTIBLE'):Glowing()

	------------------------------------------------------------------------------
	-- Profession tracking
	------------------------------------------------------------------------------

	SelfBuffs(
		2383, -- Find Herbs
		2580  -- Find Minerals
	)

	------------------------------------------------------------------------------
	-- Alchemist Flask
	------------------------------------------------------------------------------

	-- Flask of Enhancement have 3 different effects depending on the enhanced stat
	Spells("item:58149"):Aliases(79639, 79640, 79638):OnSelf()

	------------------------------------------------------------------------------
	if class == 'HUNTER' then
	------------------------------------------------------------------------------

		Aliases( 1499,  3355) -- Freezing Trap => Freezing Trap Effect
		Aliases(13795, 13797) -- Immolation Trap => Immolation Trap Effect
		Aliases(13813, 13812) -- Explosive Trap => Explosive Trap Effect

		-- Aimed Shot => Ready, Set, Aim...
		SelfTalentProc(19434, 82925):WithStack():NoHighlight()

		-- Steady Shot => Improved Steady Shot
		SelfTalentProc(56641, 53224):NoStack():ColoredBorder()

		-- Kill Shot
		Spells(53351):Aliases('BELOW20'):Glowing()

		SelfBuffs(
			 5118, -- Aspect of the Cheetah
			13165, -- Aspect of the Hawk
			 1494, -- Track Beast
			19878, -- Track Demons
			19879, -- Track Dragonkin
			19880, -- Track Elementals
			19882, -- Track Giants
			19885, -- Track Hidden
			19883, -- Track Humanoids
			19884, -- Track Undead
			 3045, -- Rapid Fire
			19263, -- Deterrence
			 5384, -- Feign Death
			82692  -- Focus Fire
		)

		GroupBuffs(13159) -- Aspect of the Pack

		GroupDebuffs(1130, 53243) -- Hunter's Mark, Marked For Death

		Spells(19801):Aliases("DISPELLABLE") -- Tranquilizing Shot => foes' magic buffs

		PetBuffs(
				136, -- Mend Pet
			19574  -- Bestial Wrath
		)

	------------------------------------------------------------------------------
	elseif class == 'WARRIOR' then
	------------------------------------------------------------------------------

		-- Most settings contributed by Moozhe

		SelfBuffs(
			  871, -- Shield Wall
			 2565, -- Shield Block
			12292, -- Death Wish
			12328, -- Sweeping Strikes
			12975, -- Last Stand
			18499, -- Berserker Rage
			23920, -- Spell Reflection
			46924, -- Bladestorm
			55694, -- Enraged Regeneration
			85730  -- Deadly Calm
		)

		-- Execute
		Spells(5308):Aliases('BELOW20'):Glowing()

		SelfTalentProc(   78, 50685):Glowing() -- Heroic Strike => Incite
		SelfTalentProc( 1464, 46916):Glowing() -- Slam => Bloodsurge
		SelfTalentProc( 5308, 90806):WithStack() -- Execute => Executioner stacks
		SelfTalentProc( 7384, 60503):Glowing() -- Overpower => Taste For Blood
		SelfTalentProc(34428, 32216):Glowing() -- Victory Rush => Victorious

		-- Self Buffs with Stacks: Recklessness, Retaliation
		Spells(1719, 20230):OnSelf():WithStack()

		-- Cleave & Whirlwind => Meat Cleaver
		Spells(845, 1680):Aliases(85738):OnSelf():WithStack()

		-- Raging Blow => Death Wish, Berserker Rage, Enrage
		Spells(85288):Aliases(12292, 18499, 12880):OnSelf()

		-- Shattering Throw => Divine Shield, Hand of Protection
		Spells(64382):Aliases(642, 1022):Glowing()

		-- Shattering Throw => Divine Shield, Hand of Protection
		Spells(64382):Aliases(642, 1022):Glowing()

		-- Bloodthirst
		Spells(23881):OnSelf():NoCountdown()

		-- Heroic Fury => Roots on Self
		Spells(60970):Aliases(19306, 64695, 339, 63685, 33395, 122, 23694, 90327, 94358, 50245, 54706, 4167):OnSelf():ShowOthers():Glowing()

		-- Colossus Smash
		Spells(86346):OnlyMine()

	------------------------------------------------------------------------------
	elseif class == 'SHAMAN' then
	------------------------------------------------------------------------------
		-- Contributed by brotherhobbes

		SelfBuffs(
				324, -- Lightning Shield
			 2645, -- Ghost Wolf
			16188, -- Nature's Swiftness
			30823, -- Shamanistic Rage
			52127, -- Water Shield
			55198  -- Tidal Force
		)

		Spells(370, 51886):Aliases("DISPELLABLE") -- Purge and Cleanse Spirit

		-- Totems
		Spells(
			 8075, -- Strength of Earth Totem
			 3599, -- Searing Totem
			 8227, -- Flametongue Totem
			 2484, -- Earthbind Totem
			 5394, -- Healing Stream Totem
			 8512, -- Windfury Totem
			 8190, -- Magma Totem
			 8177, -- Grounding Totem
			 5675, -- Mana Spring Totem
			 3738, -- Wrath of Air Totem
			 8071, -- Stoneskin Totem
			 8143, -- Tremor Totem
			 2062, -- Earth Elemental Totem
			 5730, -- Stoneclaw Totem
			 8184, -- Elemental Resistance Totem
			 2894, -- Fire Elemental Totem
			87718, -- Totem of Tranquil Mind
			16190  -- Mana Tide Totem
		):Aliases("TOTEM"):OnSelf()

		-- Some totems grants a (de)buff with a different name
		Spells(8075):Aliases(8076) -- Strength of Earth Totem => Strength of Earth
		Spells(5675):Aliases(5677) -- Mana Spring Totem => Mana Spring
		Spells(16190):Aliases(16191) -- Mana Tide Totem => Mana Tide
		Spells(8177):Aliases(8178) -- Grounding Totem => Grounding Totem Effect

		-- Unleash Elements => Unleash Flame/Unleash Frost/Unleash Wind
		Spells(73680):Aliases(73683, 73682, 73681):OnSelf()

	------------------------------------------------------------------------------
	elseif class == 'WARLOCK' then
	------------------------------------------------------------------------------

		-- Soul link
		Spells(19028, 25228):OnPet()

		Spells(1120):Aliases('BELOW25'):Glowing() -- Drain Soul
		Spells(17877):Aliases('BELOW20'):Glowing() -- Shadowburn

		-- Display soul shard count on Soulburn
		ShowSpecial("SOUL_SHARDS", 74434) -- Soulburn

		SelfBuffs(
			687,   -- Demon Armor
			7812,  -- Sacrifice (voidwalker buff)
			19028, -- Soul Link
			28176  -- Fel Armor
		)

		SelfTalentProc(29722, 47383, 34936, 54274):WithStack() -- Incinerate => Molten Core, Backlash or Backdraft
		SelfTalentProc( 6353, 63165, 85385) -- Soul Fire => Decimation or Improved Soul Fire
		SelfTalentProc(  686, 17941, 34936) -- Shadow Bolt => Shadow Trance Backlash

		-- Demon Soul and its variants
		Spells(77801):Aliases(79462, 79460, 79459, 79436, 79464)

		-- Show nether ward on shadow ward
		Spells(6229):Aliases(91711):OnSelf()

		Spells(89808):Aliases("DISPELLABLE") -- Singe Magic (Imp)
		Spells(19505):Aliases("DISPELLABLE") -- Devour Magic (Felhunter)

	------------------------------------------------------------------------------
	elseif class == 'MAGE' then
	------------------------------------------------------------------------------

		SelfBuffs(
			 6117, -- Mage Armor
			 7302, -- Frost Armor
			30482, -- Molten Armor
			45438  -- Ice Block
		)

		Spells(30451):Aliases(36032):OnSelf() -- Arcane Blast => Arcane Blast debuff

		Spells(475):Aliases("DISPELLABLE") -- Remove Curse

	------------------------------------------------------------------------------
	elseif class == 'DEATHKNIGHT' then
	------------------------------------------------------------------------------

		-- Contributed by Citlalin

		Aliases(45462, 59879) -- Plague Strike => Blood Plague
		Aliases(45477, 59921) -- Icy Touch => Frost Fever
		Aliases(48721, 81132) -- Blood Boil => Scarlet Fever
		Aliases(47541, 49194) -- Death Coil => Unholy Blight

		Aliases(66188, 77513) -- Death Strike => Blood Shield
		Aliases(49184, 59052) -- Howling Blast => Freezing Fog
		Aliases(49020, 59052) -- Obliterate => Killing Machine

		SelfBuffs(
			48707, -- Anti-Magic Shell
			45529, -- Blood Tap
			49222, -- Bone Shield
			49028, -- Dancing Rune Weapon
			48792, -- Icebound Fortitude
			49039, -- Lichborne
			49206, -- Summon Gargoyle
			55233  -- Vampiric Blood
		)

		GroupBuffs(
			49016 -- Unholy Frenzy
		)

		GroupDebuffs(
			77606, -- Dark Simulacrum
			 9484, -- Chains of Ice
			47476, -- Strangulate
			49203  -- Hungering Cold
		)

		PetBuffs(63560):WithStack() -- Dark Transformation

		Spells(49998):Aliases(77535):OnSelf() -- Blood Shield (thanks to twistdshade)

	------------------------------------------------------------------------------
	elseif class == 'PRIEST' then
	------------------------------------------------------------------------------

		-- Contributed by brotherhobbes
		SelfBuffs(
				588, -- Inner Fire
			73413, -- Inner Will
			15286, -- Vampiric Embrace
			47585  -- Dispersion
		)

		-- Shadow word: Death
		Spells(32379):Aliases('BELOW25'):Glowing()

		-- This will display either the buff or the debuff
		Aliases(17, 6788) -- Power Word: Shield / Weakened Soul

		Spells(527):Aliases("DISPELLABLE") -- Dispel Magic

	------------------------------------------------------------------------------
	elseif class == 'DRUID' then
	------------------------------------------------------------------------------

		-- Display eclipse energy
		ShowSpecial("LUNAR_ENERGY", 5176) -- Wrath
		ShowSpecial("SOLAR_ENERGY", 2912) -- Starfire

		-- Show combo points on Maim, Ferocious Bite, Savage Roar and Rip
		Spells(22568, 22570, 1079):Aliases("COMBO_POINTS"):WithStack()

		-- Show combo points on Savage Roar
		Spells(52610):OnSelf():Aliases("COMBO_POINTS"):WithStack()

		SelfBuffs(
				768, -- Cat Form
				783, -- Travel Form
			 1066, -- Aquatic Form
			 1850, -- Dash
			 5217, -- Tiger's Fury
			 5229, -- Enrage
			 5487, -- Bear Form
			16689, -- Nature's Grasp
			17116, -- Nature's Swiftness
			22812, -- Barkskin
			22842, -- Frenzied Regeneration
			24858, -- Moonkin Form
			33891, -- Tree of Life
			33943, -- Flight Form
			40120, -- Swift Flight Form
			50334, -- Berserk
			52610, -- Savage Roar
			61336, -- Survival Instincts
			80313  -- Pulverize
		)

		Aliases( 8921, 93402) -- Show Sunfire on Moonfire ...
		Aliases(93402,  8921) -- ... and conversely

		Spells(2782, 2908):Aliases("DISPELLABLE") -- Remove Corruption, Soothe

	------------------------------------------------------------------------------
	elseif class == 'PALADIN' then
	------------------------------------------------------------------------------

		-- Hammer of Wrath
		Spells(24275):Aliases('BELOW20'):Glowing()

		SelfBuffs(
				498, -- Divine Protection
				642, -- Divine Shield
			20154, -- Seal of Righteousness
			20164, -- Seal of Justice
			20165, -- Seal of Insight
			25780, -- Righteous Fury
			31801, -- Seal of Truth
			31842, -- Divine Illumination
			31850, -- Ardent Defender
			31884, -- Avenging Wrath
			54428, -- Divine Plea
			85696  -- Zealotry
		)

		ShowSpecial(
			"HOLY_POWER",
			85673, -- Word of Glory
			85256, -- Templar's Verdict
			53600, -- Shield of the Righteous
			85222  -- Light of Dawn
		)

		Spells(84963):OnSelf():Aliases("HOLY_POWER") -- Inquisition

		SelfTalentProc(86150, 86698, 86659, 86669) -- Guardian of Ancient Kings and its 3 variants

		SelfTalentProc(635, 94686) -- Holy Light => Crusader

		GroupBuffs( 7294) -- Retribution Aura
		GroupBuffs(32223) -- Crusader Aura

		Aliases(642, 25771) -- Divine Shield / Forbearance
		Aliases(1022, 25771) -- Hand of Protection / Forbearance

		Aliases(53563, 53651):OnlyMine() -- Beacon of Light => Light's Beacon

		Spells(4987):Aliases("DISPELLABLE") -- Cleanse

	------------------------------------------------------------------------------
	elseif class == 'ROGUE' then
	------------------------------------------------------------------------------

		SelfBuffs(
			 5277, -- Evasion
			31224  -- Cloak of Shadows
		)

		-- Show combo points on Kidney Shot, Rupture, Eviscerate
		Spells(408, 1943, 2098):Aliases("COMBO_POINTS"):WithStack()

		-- Show combo points on Recuperate, Slice and Dice, Envenom
		Spells(73651, 5171, 32645):OnSelf():Aliases("COMBO_POINTS"):WithStack()

		Spells(5938):Aliases("DISPELLABLE") -- Shiv

	end

end
