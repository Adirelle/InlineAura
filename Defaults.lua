--[[
Copyright (C) 2009-2010 Adirelle

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

function InlineAura_LoadDefaults(self)
	-- No identation there to avoid messing up with source control

	local SPELL_DEFAULTS = self.DEFAULT_OPTIONS.profile.spells

	local _, class = UnitClass('player')
	local version = "@file-hash@/@project-version@"
	--@debug@
	version = "developer"
	--@end-debug@
	local reported = {}
	local SPECIALS = self.SPECIALS

	-- Get the spell name, throwing error if not found
	local function GetSpellName(id, level)
		local name
		if SPECIALS[id] then
			return id
		end
		local rawId = tonumber(string.match(id, "^#(%d+)$"))
		if rawId then
			if GetSpellInfo(rawId) then
				name = '#'..rawId
			end
		else
			name = GetSpellInfo(id)
		end
		if not name then
			if not reported[id] then
				local source = debugstack((level or 0)+2, 1,0):match(":(%d+)")
				geterrorhandler()(format("Wrong spell id. Please report this error with the following information: id=%s, class=%s, version=%s, line=%s", tostringall(id, class, version, source)))
				reported[id] = true
			end
			return "Unknown spell #"..tostring(id)
		else
			return name
		end
	end

	local Spells, SpellsByClass
	do
		local proto = {}
		local obj = setmetatable({ids = {}, spells = {}}, {__index=proto})

		local function GetSpell(id, level)
			local name = GetSpellName(id, (level or 0) + 2)
			if not SPELL_DEFAULTS[name] then
				SPELL_DEFAULTS[name] = {
					id = id,
					hideStack = true,
				}
			end
			return SPELL_DEFAULTS[name], name
		end

		function Spells(...)
			wipe(obj.spells)
			wipe(obj.ids)
			for i = 1, select('#', ...) do
				local id = select(i, ...)
				obj.spells[id] = GetSpell(id)
				tinsert(obj.ids, id)
			end
			return obj
		end

		function SpellsByClass(...)
			wipe(obj.spells)
			wipe(obj.ids)
			for i = 1, select('#', ...), 2 do
				local spellClass, id = select(i, ...)
				if spellClass == class and not IsPassiveSpell(id) then
					obj.spells[id] = GetSpell(id)
				end
				tinsert(obj.ids, id)
			end
			return obj
		end

		function proto:ForEach(func, ...)
			for id, spell in pairs(self.spells) do
				func(spell, ...)
			end
			return self
		end

		function proto:AreMutualAliases()
			return self:Aliases(unpack(self.ids))
		end

		local singleMethods

		singleMethods = {
			-- Stack display
			WithStack = function(spell) spell.hideStack = false end,
			NoStack = function(spell) spell.hideStack = true end,
			-- Countdown display
			WithCountdown = function(spell) spell.hideCountdown = false end,
			NoCountdown = function(spell) spell.hideCountdown = true end,
			-- Mine/others display
			OnlyMine = function(spell) spell.onlyMine = true end,
			ShowOthers = function(spell) spell.onlyMine = false end,
			-- Aura type
			IsRegular = function(spell) spell.auraType = "regular" end,
			OnSelf = function(spell) spell.auraType = "self" end,
			OnPet = function(spell) spell.auraType = "pet" end,
			ShowSpecial = function(spell, keyword)
				spell.auraType = "special"
				singleMethods.Aliases(spell, keyword)
			end,
			-- Highlight
			Glowing = function(spell) spell.highlight = "glowing" end,
			ColoredBorder = function(spell) spell.highlight = "border" end,
			NoHighlight = function(spell) spell.highlight = "none" end,
		}

		-- Aliases
		function singleMethods.Aliases(spell, ...)
			for i = 1, select('#', ...) do
				local id = select(i, ...)
				if id ~= spell.id then
					local name = GetSpellName(id, 1)
					if not spell.aliases then
						spell.aliases = {}
					end
					if not spell.aliases[name] then
						tinsert(spell.aliases, name)
						spell.aliases[name] = true
					end
				end
			end
		end

		for name, func in pairs(singleMethods) do
			local func = func
			proto[name] = function(self, ...) return self:ForEach(func, ...) end
		end
	end

	-- Defines spell type and aliases
	local function Aliases(mainId, ...) return Spells(mainId):Aliases(...) end

	-- Defines buffs that only apply to the player
	local function SelfBuffs(...) return Spells(...):OnSelf():OnlyMine() end

	-- Define pet buffs
	local function PetBuffs(...) return Spells(...):OnPet() end

	-- Add special display
	local function ShowSpecial(special, ...) return Spells(...):WithStack():Glowing():ShowSpecial(special) end

	-- Defines auras that appear on the player and modify another spell
	local function SelfTalentProc(spellId, ...) return Spells(spellId):Aliases(...):OnSelf():OnlyMine():Glowing() end

	-- Declare a category of group-wide buffs
	local function GroupBuffs(...) return Spells(...):AreMutualAliases():OnSelf():ShowOthers() end

	-- Declare a category of group-wide debuffs
	local function GroupDebuffs(...) return Spells(...):AreMutualAliases():ShowOthers() end

	-- Declare (de)buffs that are brought by several classes
	local function SharedAuras(...) return SpellsByClass(...):AreMutualAliases():ShowOthers()	end

	------------------------------------------------------------------------------
	-- Group (de)buffs
	------------------------------------------------------------------------------
	--[[
	Do not list the (de)buffs that are all auras, procs, passive or come with the normal combat rotation.

	Fully passive (de)buffs:
	- Increased Damage (3%)
	- Increased Critical Chance (5%)
	- Increased Spell Power (10%)
	- Physical Damage Taken (4%)
	- Spell Crit Taken (5%)
	- Reduced Attack Speed (20%)
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
		"MAGE",   80353, -- Time Warp
		"HUNTER", 90355  -- Ancient Hysteria (exotic pet ability)
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
		"WARLOCK",     85479, -- Jinx
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
		"DRUID",   91565, -- Faerie Fire
		"HUNTER",  35387, -- Corrosive Spit (pet ability)
		"HUNTER",  50498  -- Tear Armor (pet ability)
	)

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

	-- Trying a big crowd control category (using Phanx's list)
	SharedAuras(
		"WARLOCK",   710, -- Banish
		"SHAMAN",  76780, -- Bind Elemental
		"DRUID",   33786, -- Cyclone
		"DRUID",     339, -- Entangling Roots
		"WARLOCK",  5782, -- Fear
		"HUNTER",   3355, -- Freezing Trap
		"SHAMAN",  51514, -- Hex
		"DRUID",    2637 ,-- Hibernate
		"MAGE",      118 ,-- Polymorph
		"MAGE",    61305 ,-- Polymorph (Black Cat)
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

	------------------------------------------------------------------------------
	-- Profession tracking
	------------------------------------------------------------------------------

	SelfBuffs(
		2383, -- Find Herbs
		2580  -- Find Minerals
	)

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

		PetBuffs(
				136, -- Mend Pet
			19574  -- Bestial Wrath
		)

	------------------------------------------------------------------------------
	elseif class == 'WARRIOR' then
	------------------------------------------------------------------------------

		SelfBuffs(
				871, -- Shield Wall
			 1719, -- Recklessness
			 2565, -- Shield Block
			12292, -- Death Wish
			12975, -- Last Stand
			18499, -- Berserker Rage
			20230, -- Retaliation
			23881, -- Bloodthirst
			23920, -- Spell Reflection
			34428, -- Victory Rush
			46924, -- Bladestorm
			55694  -- Enraged Regeneration
		)

		-- Contributed by Moozhe
		SelfTalentProc(5308, 90806):WithStack()  -- Execute => Executioner stacks
		SelfTalentProc(   78, 50685) -- Heroic Strike => Incite
		SelfTalentProc( 1464, 46916) -- Slam => Bloodsurge
		SelfTalentProc( 7384, 60503) -- Overpower => Taste For Blood
		SelfTalentProc(34428, 32216) -- Victory Rush => Victorious

		-- Cleave & Whirlwind => Meat Cleaver
		Spells(845, 1680):Aliases(85738):OnSelf():WithStack():Glowing()

		Spells(85288):Aliases(12292, 18499, 12880):OnSelf() -- Raging Blow => Death Wish, Berserker Rage, Enrage

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
			55198 -- Tidal Force
		)

	------------------------------------------------------------------------------
	elseif class == 'WARLOCK' then
	------------------------------------------------------------------------------

		-- Soul link
		Aliases(19028, 25228)

		-- Display soul shard count on Soulburn
		ShowSpecial("SOUL_SHARDS", 74434) -- Soulburn

		SelfBuffs(
			687,   -- Demon Armor
			6229,  -- Shadow Ward
			7812,  -- Sacrifice (voidwalker buff)
			19028, -- Soul Link
			28176  -- Fel Armor
		)

		-- Incinerate => Molten Core, Backlash or Backdraft
		SelfTalentProc(29722, 47383, 34936, 54274):WithStack()
		SelfTalentProc( 6353, 63165, 85385) -- Soul Fire => Decimation or Improved Soul Fire
		SelfTalentProc(  686, 17941, 34936) -- Shadow Bolt => Shadow Trance Backlash

	------------------------------------------------------------------------------
	elseif class == 'MAGE' then
	------------------------------------------------------------------------------

		SelfBuffs(
			 6117, -- Mage Armor
			 7302, -- Frost Armor
			30482, -- Molten Armor
			45438  -- Ice Block
		)

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

	------------------------------------------------------------------------------
	elseif class == 'PRIEST' then
	------------------------------------------------------------------------------

		-- Contributed by brotherhobbes
		SelfBuffs(
				588, -- Inner Fire
			15286, -- Vampiric Embrace
			47585  -- Dispersion
		)

		-- This will display either the buff or the debuff
		Aliases(17, 6788) -- Power Word: Shield / Weakened Soul

	------------------------------------------------------------------------------
	elseif class == 'DRUID' then
	------------------------------------------------------------------------------

		-- Faerie Fire debuff and spell ids are different
		Aliases(  770, 91565)
		Aliases(16857, 91565)

		-- Display eclipse energy
		ShowSpecial("LUNAR_ENERGY", 5176) -- Wrath
		ShowSpecial("SOLAR_ENERGY", 2912) -- Starfire

		-- Kitty combo points
		ShowSpecial("COMBO_POINTS",
			22570, -- Maim
			22568  -- Ferocious Bite
		)

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

	------------------------------------------------------------------------------
	elseif class == 'PALADIN' then
	------------------------------------------------------------------------------

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
			84963  -- Inquisition
		)

		GroupBuffs( 7294) -- Retribution Aura
		GroupBuffs(32223) -- Crusader Aura

		Aliases(642, 25771) -- Divine Shield / Forbearance
		Aliases(1022, 25771) -- Hand of Protection / Forbearance

		Aliases(53563, 53651):OnlyMine() -- Beacon of Light => Light's Beacon

	------------------------------------------------------------------------------
	elseif class == 'ROGUE' then
	------------------------------------------------------------------------------

		SelfBuffs(
			 5171, -- Slice and Dice
			 5277, -- Evasion
			31224, -- Cloak of Shadows
			32645, -- Envenom
			73651  -- Recuperate
		)

		-- Combo points
		ShowSpecial("COMBO_POINTS",
				408, -- Kidney Shot
			 2098  -- Eviscerate
		)

	end

	-- Cleanup
	for name, spell in pairs(SPELL_DEFAULTS) do
		spell.id = nil
		spell.default = true
		if spell.aliases and #(spell.aliases) > 0 then
			spell.aliases = { unpack(spell.aliases) }
		else
			spell.aliases = nil
		end
	end

end
