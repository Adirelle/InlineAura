--[[
Inline Aura - displays aura information inside action buttons
Copyright (C) 2009-2012 Adirelle (adirelle@gmail.com)

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

Contributors :
  - crymson,
  - Moozhe,
  - brotherhobbes,
  - Citlalin,
  - Phanx),
  - Thrael,
  - FreakPsych,
  - nulian,
  - Kleinerelf.
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
		"PALADIN",   20217, -- Blessing of Kings
		"DRUID",      1126, -- Mark of the Wild
		"MONK",     115921, -- Legacy of the Emporer
		"HUNTER",    90363  -- Embrace of the Shale Spider (shale spider)
	):OnSelf()

	-- Increased Attack Power (10%)
	SharedAuras(
		"DEATHKNIGHT", 57330, -- Horn of Winter
		"HUNTER",      19506, -- Trueshot Aura (passive)
		"WARRIOR",      6673  -- Battle Shout
	):OnSelf()

	-- Increased Spell Power (10%)
	SharedAuras(
		"MAGE",      1459, -- Arcane Brillance
		"SHAMAN",   77747, -- Burning Wrath (passive)
		"WARLOCK", 109773, -- Dark Intent
		"HUNTER",  126309  -- Still Water (waterstrider)
	):OnSelf()

	-- Increased Physical Haste (10%)
	SharedAuras(
		"DEATHKNIGHT",  55610, -- Improved Icy Talons
		"ROGUE",       113742, -- Swiftblade's Cunning (passive)
		"SHAMAN",       30809, -- Unleashed Rage
		"HUNTER",      128432, -- Cackling Hown (hyena)
		"HUNTER",      128433  -- Serpent's Swiftness (serpent)
	):OnSelf()

	-- Increased Spell Haste (5%)
	SharedAuras(
		"SHAMAN", 51470, -- Elemental Oath (passive)
		"PRIEST", 15473  -- Shadowform (passive)
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

	-- Mastery Bonus
	SharedAuras(
		"PALADIN",  19740, -- Blessing of Might
		"SHAMAN",  116956, -- Grace of Air (passive)
		"HUNTER",   93435  -- Roar of Courage (pet ability)
	):OnSelf()

	-- Stamina Bonus
	SharedAuras(
		"PRIEST",   21562, -- Power Word: Fortitude
		"WARRIOR",    469, -- Commanding Shout
		"HUNTER",   90364  -- Qiraji Fortitude (exotic pet ability)
	):OnSelf()

	--- Debuffs ---

	-- Spell Damage Taken (5%)
	SharedAuras(
		"WARLOCK",      1490, -- Curse of the Elements
		"WARLOCK",    116202, -- Aura of the Elements
		"ROGUE",       58410, -- Master Poisoner (passive)
		"HUNTER",      34889, -- Fire Breath (pet ability)
		"HUNTER",      24844  -- Lightning Breath (pet ability)
	)

	-- Increasing Casting Time (50%)
	SharedAuras(
		"WARLOCK",     109466, -- Curse of Enfeeblement
		"WARLOCK",     116198, -- Aura of Enfeeblement
		"ROGUE",         5761, -- Mind-Numbing Poison
		"DEATHKNIGHT",  73975, -- Necrotic Strike
		"HUNTER",       90314, -- Tailspin (pet ability)
		"HUNTER",      126402, -- Trample (pet ability)
		"HUNTER",       50274, -- Spore Cloud (pet ability)
		"HUNTER",       58604  -- Lava Breath (pet ability)
	)

	-- Reduced Armor (12%)
	SharedAuras(
		"*",       113746, -- Weakened Armor (main effect)
		"WARRIOR",   7386, -- Sunder Armor
		"WARRIOR", 100130, -- Wild Strike
		"WARRIOR",  20243, -- Devastate
		"ROGUE",     8647, -- Expose Armor
		"DRUID",      770, -- Faerie Fire
		"DRUID",   102355, -- Faerie Swarm
		"HUNTER",   50285, -- Dust Cloud (pet ability)
		"HUNTER",   50498  -- Tear Armor (pet ability)
	):WithStack()

	-- Reduced Healing (25%)
	SharedAuras(
		"*",       115804, -- Mortal Wounds (main effect)
		"WARRIOR",  12294, -- Mortal Strike
		"WARRIOR", 100130, -- Wild Strike
		"ROGUE",     8679, -- Wound Poison
		"HUNTER",   82654, -- Widow Venom
		"WARLOCK",  30213, -- Legion Strike
		"MONK",    107428, -- Rising Sun Kick
		"HUNTER",   54680  -- Monstrous Bite (exotic pet ability)
	)

	-- Physical Damage Done (10%)
	SharedAuras(
	   "*",            115798, -- Weakened Blows (main effect)
		"DRUID",       106830, -- Thrash (Cat)
		"DRUID",        77758, -- Thrash (Bear)
		"HUNTER",       50256, -- Demoralizing Roar (pet ability)
		"HUNTER",       24423, -- Demoralizing Screech (pet ability)
		"MONK",        121253, -- Keg Smash
		"WARRIOR",       6343, -- Thunder Clap
		"DEATHKNIGHT",  81132, -- Scarlet Fever
		"SHAMAN",        8042, -- Earth Shock
		"PALADIN",      53595  -- Hammer of the Righteous
	)

	-- Physical Damage Taken (4%)
	SharedAuras(
		 "*",            81326, -- Physical Vulnerability
		"DEATH KNIGHT",  81328, -- Brittle Bones
		"DEATH KNIGHT",  51160, -- Ebon Plaguebringer
		"PALADIN",      111529, -- Judgments of the Bold
		--"WARRIOR",       86346, -- Colossus Smash
		"HUNTER",        35290, -- Gore (pet ability)
		"HUNTER",        50518, -- Ravage (pet ability)
		"HUNTER",        57386, -- Stampede (exotic pet ability)
		"HUNTER",        55749  -- Acid Spit (exotic pet ability)
	)

	-- Pulls CC and tactical debuffs from DRData-1.0
	do
		local DRData = LibStub('DRData-1.0')

		-- Rename some categories
		local catMap = {
			charge        = "stun",
			ctrlstun      = "stun",
			rndstun       = "stun",
			ctrlroot      = "root",
			entrapment    = "root",
			disarm        = "disarm",
			disorient     = "disorient",
			dragons       = "disorient",
			scatters      = "disorient";
			silence       = "silence",
			taunt         = "taunt",
			banish        = "banish",
			cyclone       = "banish",
			iceward       = "IGNORE",
			mc            = "IGNORE",
			bindelemental = "IGNORE",
		}

		-- Group by category
		local byCat = {}
		for id, cat in pairs(DRData:GetSpells()) do
			cat = catMap[cat] or "generic"
			if cat ~= "IGNORE" then
				if byCat[cat] then
					tinsert(byCat[cat], id)
				else
					byCat[cat] = { id }
				end
			end
		end

		-- Build the spell aliases
		for cat, ids in pairs(byCat) do
			GroupDebuffs(unpack(ids))
		end
	end

	-- Snares and anti-snares
	-- Note that some of these are talent procs or passive effects.
	-- This is intended as they will show up on active spells anyway.
	SharedAuras(
		"*",            1604, -- Dazed,
		"DEATHKNIGHT", 45524, -- Chains of Ice
		"DRUID",       50259, -- Dazed (feral charge effect)
		"DRUID",       58180, -- Infected Wounds
		"DRUID",       61391, -- Typhoon
		"MAGE",        31589, -- Slow
		"MAGE",        44614, -- Frostfire Bolt
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
		"MONK",       116095, -- Disable (1 stack)
		"PALADIN",      1044, -- Hand of Freedom
		"ROGUE",        3409, -- Crippling Poison
		"ROGUE",       26679, -- Deadly Throw
		"SHAMAN",       3600, -- Earthbind
		"SHAMAN",       8034, -- Frostbrand Attack
		"SHAMAN",       8056, -- Frost Shock
		"SHAMAN",       8178, -- Grounding Totem Effect
		"WARLOCK",     18223, -- Curse of Exhaustion
		"WARIROR",      1715, -- Piercing Howl
		"WARRIOR",     12323  -- Hamstring
	)

	-- Interrupts
	SpellsByClass(
		"DEATHKNIGHT", 47476, -- Strangulate
		"DEATHKNIGHT", 47528, -- Mind Freeze
		"DEATHKNIGHT", 91802, -- Shambling Rush (Ghoul)
		"DRUID",       78675, -- Solar Beam
		"DRUID",       80964, -- Skull Bash (bear)
		"DRUID",       80965, -- Skull Bash (cat)
		"HUNTER",      26090, -- Pummel (Gorilla)
		"HUNTER",      34490, -- Silencing Shot
		"HUNTER",      50318, -- Serenity Dust (Moth)
		"HUNTER",      50479, -- Nether Shock (Nether Ray)
		"MAGE",         2139, -- Counterspell
		"MONK",       116705, -- Spear Hand Strike
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
	if IsClass('HUNTER') then
	------------------------------------------------------------------------------

		Aliases( 1499,  3355) -- Freezing Trap => Freezing Trap Effect
		Aliases(13795, 13797) -- Immolation Trap => Immolation Trap Effect
		Aliases(13813, 13812) -- Explosive Trap => Explosive Trap Effect

		-- Aimed Shot => Ready, Set, Aim...
		SelfTalentProc(19434, 82925):WithStack():NoHighlight()

		-- Steady Shot => Steady Focus
		SelfTalentProc(56641, 53224):NoStack():ColoredBorder()

		-- Kill Shot & Murder of Crows
		Spells(53351):Aliases('BELOW20'):Glowing()
		Spells(131894):Aliases('BELOW20'):Glowing()

		SelfBuffs(
			  5118, -- Aspect of the Cheetah
			 13165, -- Aspect of the Hawk
			109260, -- Aspect of the Iron Hawk
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

		GroupDebuffs(1130) -- Hunter's Mark

		Spells(19801):Aliases("DISPELLABLE") -- Tranquilizing Shot => foes' magic buffs

		PetBuffs(
			  136, -- Mend Pet
			19574  -- Bestial Wrath
		)
	end

	------------------------------------------------------------------------------
	if IsClass('WARRIOR') then
	------------------------------------------------------------------------------

		SelfBuffs(
			  871, -- Shield Wall
			 2565, -- Shield Block
			12292, -- Death Wish
			12328, -- Sweeping Strikes
			12975, -- Last Stand
			18499, -- Berserker Rage
			23920, -- Spell Reflection
			46924, -- Bladestorm
			55694  -- Enraged Regeneration
		)

		-- Execute
		Spells(5308):Aliases('BELOW20'):Glowing()

		SelfTalentProc( 20243, 122013):Glowing() -- Devestate => Incite
		SelfTalentProc(100130,  46916):Glowing() -- Wild Strike => Bloodsurge
		SelfTalentProc(  7384,  60503):Glowing() -- Overpower => Taste For Blood
		SelfTalentProc( 34428,  32216):Glowing() -- Victory Rush => Victorious

		-- Self Buffs with Stacks: Recklessness, Retaliation
		Spells(1719):OnSelf()
		-- Cleave & Whirlwind & Raging Blow => Meat Cleaver
		Spells(845, 1680, 96103):Aliases(12950):OnSelf():WithStack()

		-- Raging Blow => Raging Blow!
		Spells(85288):Aliases(131116):OnSelf()

		-- Shattering Throw => Divine Shield, Hand of Protection
		Spells(64382):Aliases(642, 1022):Glowing()

		-- Shattering Throw => Divine Shield, Hand of Protection
		Spells(64382):Aliases(642, 1022):Glowing()

		-- Bloodthirst
		Spells(23881):OnSelf():NoCountdown()

		-- Colossus Smash
		Spells(86346):OnlyMine()
	end

	------------------------------------------------------------------------------
	if IsClass('SHAMAN') then
	------------------------------------------------------------------------------

		SelfBuffs(
			  324, -- Lightning Shield
			 2645, -- Ghost Wolf
			16188, -- Nature's Swiftness
			30823, -- Shamanistic Rage
			52127 -- Water Shield
		)

		Spells(370, 51886):Aliases("DISPELLABLE") -- Purge and Cleanse Spirit

		-- Totems
		Spells(
			  3599, -- Searing Totem
			  2484, -- Earthgrab Totem
			  5394, -- Healing Stream Totem
			  8190, -- Magma Totem
			  8177, -- Grounding Totem
			  8143, -- Tremor Totem
			  2062, -- Earth Elemental Totem
			  2894, -- Fire Elemental Totem
			 16190, -- Mana Tide Totem
			 98008, -- Spirit Link Totem
			108269, -- Capacitor Totem
			108270, -- Stone Bulwark Totem
			108273, -- Windwalk Totem
			108280, -- Healing Tide Totem
			120668  -- Stormlash Totem
		):Aliases("TOTEM"):OnSelf()

		-- Some totems grants a (de)buff with a different name
		Spells(16190):Aliases(16191) -- Mana Tide Totem => Mana Tide
		Spells(8177):Aliases(8178) -- Grounding Totem => Grounding Totem Effect

		-- Unleash Elements => Unleash Flame/Unleash Frost/Unleash Wind
		Spells(73680):Aliases(73683, 73682, 73681):OnSelf()
	end

	------------------------------------------------------------------------------
	if IsClass('WARLOCK') then
	------------------------------------------------------------------------------

		-- Soul link
		Spells(108415):OnPet()

		Spells(1120):Aliases('BELOW20'):Glowing() -- Drain Soul
		Spells(17877):Aliases('BELOW20'):Glowing() -- Shadowburn

		Spells(105174):Aliases(47960) -- Hand of Gul'dan => Shadowflame

		-- Display soul shard count on Soulburn
		ShowSpecial("SOUL_SHARDS", 74434):NoHighlight() -- Soulburn

		SelfBuffs(
			  7812, -- Sacrifice (voidwalker buff)
			108415  -- Soul Link
		)

		SelfTalentProc(29722, 122351, 117896):WithStack() -- Incinerate => Molten Core, Backdraft
		SelfTalentProc( 6353, 108869) -- Soul Fire => Decimation
		SelfTalentProc(  686, 108563) -- Shadow Bolt => Backlash

		SelfBuffs(
			113860, -- Misery
			113861, -- Knowledge
			113858  -- Instability
		)

		-- Show nether ward on shadow ward
		Spells(6229):Aliases(91711):OnSelf()

		-- Show Immolation Aura on Self
		Spells(104025):OnSelf()

		Spells(89808):Aliases("DISPELLABLE") -- Singe Magic (Imp)
		Spells(19505):Aliases("DISPELLABLE") -- Devour Magic (Felhunter)
	end

	------------------------------------------------------------------------------
	if IsClass('MAGE') then
	------------------------------------------------------------------------------

		SelfBuffs(
			 6117, -- Mage Armor
			 7302, -- Frost Armor
			30482, -- Molten Armor
			45438  -- Ice Block
		)

		Spells(30451):Aliases(36032):OnSelf() -- Arcane Blast => Arcane Blast debuff

		Spells(475):Aliases("DISPELLABLE") -- Remove Curse
	end

	------------------------------------------------------------------------------
	if IsClass('MONK') then
	------------------------------------------------------------------------------

		-- Tiger Palm => Tiger Power
		Spells(100787):Aliases(125359):OnSelf()

		-- Blackout Kick => Serpent's Zeal (mistweavers), Shuffle (brewmasters)
		Spells(100784):Aliases(115307, 127722):OnSelf()

		-- Guard => Power Guard
		Spells(115295):Aliases(118636):OnSelf()

		-- Detox
		Spells(115450):Aliases("DISPELLABLE")

	end

	------------------------------------------------------------------------------
	if IsClass('DEATHKNIGHT') then
	------------------------------------------------------------------------------

		Aliases(45462, 59879) -- Plague Strike => Blood Plague
		Aliases(45477, 59921) -- Icy Touch => Frost Fever
		Aliases(48721, 81132) -- Blood Boil => Scarlet Fever

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
			47476 -- Strangulate
		)

		PetBuffs(63560):WithStack() -- Dark Transformation

		Spells(49998):Aliases(77535):OnSelf() -- Blood Shield (thanks to twistdshade)

		-- Soul Reaper
		Spells(114866):Aliases('BELOW35'):Glowing()
	end

	------------------------------------------------------------------------------
	if IsClass('PRIEST') then
	------------------------------------------------------------------------------

		SelfBuffs(
				588, -- Inner Fire
			73413, -- Inner Will
			15286, -- Vampiric Embrace
			47585  -- Dispersion
		)

		-- Shadow word: Death
		Spells(32379):Aliases('BELOW20'):Glowing()

		-- This will display either the buff or the debuff
		Aliases(17, 6788) -- Power Word: Shield / Weakened Soul

		Spells(527):Aliases("DISPELLABLE") -- Dispel Magic
	end

	------------------------------------------------------------------------------
	if IsClass('DRUID') then
	------------------------------------------------------------------------------

		-- Display eclipse energy
		ShowSpecial("LUNAR_ENERGY", 5176) -- Wrath
		ShowSpecial("SOLAR_ENERGY", 2912) -- Starfire

		-- Show combo points on Maim, Ferocious Bite, Savage Roar and Rip
		Spells(22568, 22570, 1079):Aliases("COMBO_POINTS"):WithStack()

		-- Only show aliases (e.g. weakened armor debuff) on Faerie Fire/
		Spells(770, 102355):OnlyAliases()

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
			22812, -- Barkskin
			22842, -- Frenzied Regeneration
			24858, -- Moonkin Form
			33891, -- Tree of Life
			33943, -- Flight Form
			40120, -- Swift Flight Form
			50334, -- Berserk
			52610, -- Savage Roar
			61336  -- Survival Instincts
		)

		-- Incarnation and its spec variantes
		Aliases(106731, 102560, 102543, 102558, 33891):OnSelf():OnlyMine()

		Spells(2782, 2908):Aliases("DISPELLABLE") -- Remove Corruption, Soothe
	end

	------------------------------------------------------------------------------
	if IsClass('PALADIN') then
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
			 71166, -- Divine Favor
			 31850, -- Ardent Defender
			 31884, -- Avenging Wrath
			 54428, -- Divine Plea
			105809  -- Holy Avenger
		)

		ShowSpecial(
			"HOLY_POWER",
			85256, -- Templar's Verdict
			114163,-- Eternal Flame
			85673, -- Word of Glory
			85222  -- Light of Dawn
		)

		Spells(84963):OnSelf():Aliases("HOLY_POWER") -- Inquisition

		SelfTalentProc(86698, 86659, 86669) -- Guardian of Ancient Kings and its 3 variants

		SelfTalentProc(19750, 94686) -- Flash of Light => Supplication

		Aliases(642, 25771) -- Divine Shield / Forbearance
		Aliases(1022, 25771) -- Hand of Protection / Forbearance

		Aliases(53563, 53651):OnlyMine() -- Beacon of Light => Light's Beacon
		Aliases(114163, 114163):OnlyMine() -- Eternal Flame
		Aliases(53600, 132403):OnSelf() -- Shield of the Righteous

		Spells(4987):Aliases("DISPELLABLE") -- Cleanse
	end

	------------------------------------------------------------------------------
	if IsClass('ROGUE') then
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
