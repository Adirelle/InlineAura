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
if not InlineAura then return end

local addonName, ns = ...

local InlineAura = InlineAura
local SPELL_DEFAULTS = InlineAura.DEFAULT_OPTIONS.profile.spells

local _, class = UnitClass('player')
local version = GetAddOnMetadata(addonName, "Version")
local reported = {}

-- Get the spell name, throwing error if not found
local function GetSpellName(id, level)
	local name
	if InlineAura.keywords[id] then
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

-- Get the spell defaults, creating the table if need be
local function GetSpellDefaults(id, level)
	local name = GetSpellName(id, (level or 0) + 1)
	if not SPELL_DEFAULTS[name] then
		SPELL_DEFAULTS[name] = {}
	end
	return SPELL_DEFAULTS[name]
end

-- Create a list of aliases, ignoring origId when found in ...
local function MakeAliases(origId, ...)
	local aliases = {}
	for i = 1,select('#', ...) do
		local id = select(i, ...)
		if id ~= origId then
			table.insert(aliases, GetSpellName(id, 2))
		end
	end
	if #aliases > 0 then
		return aliases
	end
end

-- Defines spell type and aliases
local function Aliases(auraType, id, ...)
	local defaults = GetSpellDefaults(id, 1)
	defaults.auraType = auraType
	defaults.aliases = MakeAliases(id, ...)
end

-- Defines buffs that only apply to the player
local SELF_BUFF_UNITS = { player = true, pet = false, focus = false, target = false }
local function SelfBuffs(...)
	for i = 1, select('#', ...) do
		local id = select(i, ...)
		local defaults = GetSpellDefaults(id, 1)
		defaults.auraType = 'buff'
		defaults.unitsToScan = SELF_BUFF_UNITS
	end
end

-- Defines auras that appear on the player and modify another spell
local function SelfTalentProc(spellId, talentId)
	local defaults = GetSpellDefaults(spellId, 1)
	local talent = GetSpellName(talentId, 1)
	defaults.auraType = 'buff'
	defaults.unitsToScan = SELF_BUFF_UNITS
	defaults.alternateColor = true
	if defaults.aliases then
		for i, alias in pairs(defaults.aliases) do
			if alias == talent then
				return
			end
		end
		table.insert(defaults.aliases, talent)
	else
		defaults.aliases = { talent }
	end
end

-- Declare a category of group-wide buffs
local function GroupBuffs(...) 
	for i = 1, select('#', ...) do
		local id = select(i, ...)
		local defaults = GetSpellDefaults(id, 1)
		defaults.auraType = 'buff'
		defaults.onlyMine = false
		defaults.aliases = MakeAliases(id, ...)
	end
end

-- Declare a category of group-wide debuffs
local function GroupDebuffs(...)
	for i = 1, select('#', ...) do
		local id = select(i, ...)
		local defaults = GetSpellDefaults(id, 1)
		defaults.auraType = 'debuff'
		defaults.onlyMine = false
		defaults.aliases = MakeAliases(id, ...)
	end
end

-- Declare group (de)buffs that are brought by several classes
local GroupAuras
do
	local t = {}
	function GroupAuras(auraType, ...)
		wipe(t)
		for i = 2, select('#', ...), 2 do
			tinsert(t, (select(i, ...)))
		end
		for i = 1, select('#', ...), 2 do
			local spellClass, spellId = select(i, ...)
			if spellClass == class then
				local defaults = GetSpellDefaults(spellId, 1)
				defaults.auraType = auraType
				defaults.onlyMine = false
				defaults.aliases = MakeAliases(spellId, unpack(t))
			end
		end
	end
end

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
- Reduced Physical Damage Done (10%)
]]

--- Buffs ---

-- Increased Stats (5%)
GroupAuras("buff", 
	"PALADIN", 20217, -- Blessing of Kings
	"DRUID",    1126, -- Mark of the Wild
	"HUNTER",  90363  -- Embrace of the Shale Spider (exotic pet ability)
)

-- Increased Attack Power (10%)
GroupAuras("buff",
	"PALADIN",     19740, -- Blessing of Might
	"DEATHKNIGHT", 53138, -- Abomination's Might (passive)
	"HUNTER",      19506, -- Trueshot Aura (passive)
	"SHAMAN",      30808  -- Unleashed Rage (passive)
)

-- Increased Spell Power (6%)
GroupAuras("buff",
	"MAGE",   1459, -- Arcane Brillance
	"SHAMAN", 8227  -- Flametongue Totem
)

-- Increased Physical Haste (10%)
GroupAuras("buff",
	"DEATHKNIGHT", 55610, -- Improved Icy Talons (passive)
	"HUNTER",      53290, -- Hunting Party (passive)
	"SHAMAN",       8512  -- Windfury Totem
)

-- Increased Spell Haste (5%)
GroupAuras("buff",
	"SHAMAN",  3738, -- Wrath of Air Totem
	"PRIEST", 15473, -- Shadowform (passive)
	"DRUID",  24907  -- Moonkin Aura (passive)
)

-- Burst Haste (30%)
GroupAuras("buff",
	"SHAMAN", (UnitFactionGroup("player") == "Horde" and 2825 or 32182), -- Bloodlust/Heroism
	"MAGE",   80353, -- Time Warp
	"HUNTER", 90355  -- Ancient Hysteria (exotic pet ability)
)

-- Agility & Strength bonuses
GroupAuras("buff", 
	"WARRIOR",      6673, -- Battle Shout
	"SHAMAN",       8075, -- Strength of Earth Totem
	"DEATHKNIGHT", 57330, -- Horn of Winter
	"HUNTER",      93435  -- Roar of Courage (pet ability)
)

-- Stamina Bonus
GroupAuras("buff",
	"PRIEST",  21562, -- Power Word: Fortitude
	"WARRIOR",   469, -- Commanding Shout
	"WARLOCK",  6307, -- Blood Pact (imp ability)
	"HUNTER",  90364  -- Qiraji Fortitude (exotic pet ability)
)

-- Armor Bonus
GroupAuras("buff", 
	"PALADIN",  465, -- Devotion Aura
	"SHAMAN",  8071  -- Stoneskin Totem
)

-- Mana Bonus
GroupAuras("buff",
	"MAGE",     1459, -- Arcane Brillance
	"WARLOCK", 54424  -- Fel Intelligence (felhunter ability)
)

-- Pushback Resistance
GroupAuras("buff",
	"PALADIN", 19746, -- Concentration Aura
	"SHAMAN",  87718  -- Totem of Tranquil Mind
)

--- Debuffs ---

-- Spell Damage Taken (8%)
GroupAuras("debuff",
	"WARLOCK",      1490, -- Curse of the Elements
	"WARLOCK",     85479, -- Jinx
	"ROGUE",       58410, -- Master Poisoner (passive)
	"DEATHKNIGHT", 51160, -- Ebon Plaguebringer (passive)
	"DRUID",       48506, -- Earth and Moon (passive)
	"HUNTER",      34889, -- Fire Breath (pet ability)
	"HUNTER",      24844  -- Lightning Breath (pet ability)
)

-- Bleed Damage Taken (30%)
GroupAuras("debuff",
	"DRUID",   33878, -- Mangle (bear)
	"DRUID",   33876, -- Mangle (cat)
	"ROGUE",   16511, -- Hemorrhage
	"WARRIOR", 29836, -- Blood Frenzy (passive)
	"HUNTER",  50271, -- Tendon Ripe (pet ability)
	"HUNTER",  35290, -- Gore (pet ability)
	"HUNTER",  57386  -- Stampede (pet ability)
)

-- Reduced Casting Speed (30%)
GroupAuras("debuff", 
	"WARLOCK",      1714, -- Curse of Tongues
	"ROGUE",        5761, -- Mind-Numbing Poison
	"MAGE",        31589, -- Slow
	"DEATHKNIGHT", 73975, -- Necrotic Strike
	"HUNTER",      50274, -- Spore Cloud (pet ability)
	"HUNTER",      58604  -- Lava Breath (pet ability)
)

-- Reduced Armor (12%)
GroupAuras("debuff",
	"WARRIOR",  7386, -- Sunder Armor
	"WARRIOR", 20243, -- Devastate
	"ROGUE",    8647, -- Expose Armor
	"DRUID",     770, -- Faerie Fire
	"DRUID",   16857, -- Faerie Fire (feral)
	"HUNTER",  35387, -- Corrosive Spit (pet ability)
	"HUNTER",  50498  -- Tear Armor (pet ability)
)

-- Reduced Healing (25%)
GroupAuras("debuff",
	"WARRIOR", 12294, -- Mortal Strike
	"WARRIOR", 46910, -- Furious Attacks
	"PRIEST",  15313, -- Improved Mind Blast
	"ROGUE",   13219, -- Wound Poison
	"HUNTER",  82654, -- Widow Venom
	"WARLOCK", 30213, -- Legion Strike (felguard ability)
	"HUNTER",  54680  -- Monstrous Bite (exotic pet ability)
)

------------------------------------------------------------------------------
if class == 'HUNTER' then
------------------------------------------------------------------------------

	Aliases('debuff',  1499,  3355) -- Freezing Trap => Freezing Trap Effect
	Aliases('debuff', 13795, 13797) -- Immolation Trap => Immolation Trap Effect
	Aliases('debuff', 13813, 13812) -- Explosive Trap => Explosive Trap Effect
	
	Aliases('buff', 19434, 82925) -- Aimed Shot => Ready, Set, Aim...	

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
		53224, -- Improved Steady Shot
		82692  -- Focus Fire
	)
	
	GroupBuffs(20043) -- Aspect of the Wild
	GroupBuffs(13159) -- Aspect of the Pack
	
	GroupDebuffs(1130, 53243) -- Hunter's Mark, Marked For Death

	-- Pet only spells
	local PET_UNITS = { pet = true, player = false, focus = false, target = false }

	-- Mend Pet
	local MendPet = GetSpellDefaults(136)
	MendPet.auraType = 'buff'
	MendPet.unitsToScan = PET_UNITS
	
	-- Bestial Wrath
	local BestialWrath = GetSpellDefaults(19574)
	BestialWrath.auraType = 'buff'
	BestialWrath.unitsToScan = PET_UNITS

------------------------------------------------------------------------------
elseif class == 'WARRIOR' then
------------------------------------------------------------------------------

	GroupDebuffs(1160) -- Demoralizing Shout

	SelfBuffs(
			871, -- Shield Wall
		 1719, -- Recklessness
		 2565, -- Shield Block
		12292, -- Death Wish
		12975, -- Last Stand
		18499, -- Berserker Rage
		20230, -- Retaliation
		23920, -- Spell Reflection
		46924, -- Bladestorm
		55694  -- Enraged Regeneration
	)

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

	GroupDebuffs(51514) -- Hex
	GroupDebuffs(76780) -- Bind Elemental
	
------------------------------------------------------------------------------
elseif class == 'WARLOCK' then
------------------------------------------------------------------------------

	-- Display soul shard count on Soulburn
	Aliases("buff", 74434, 'SOUL_SHARDS')

	SelfTalentProc(29722, 47383) -- Incinerate => Molten Core
	SelfTalentProc(6353, 63165) -- Soul Fire => Decimation

	GroupDebuffs(710) -- Banish
	GroupDebuffs(5782) -- Fear

------------------------------------------------------------------------------
elseif class == 'MAGE' then
------------------------------------------------------------------------------

	-- Polymorphs
	GroupDebuffs(118, 28272, 28271, 61025, 61305)

------------------------------------------------------------------------------
elseif class == 'DEATHKNIGHT' then
------------------------------------------------------------------------------

	-- Contributed by jexxlc
	Aliases('debuff', 45462, 55078) -- Plague Strike => Blood Plague
	Aliases('debuff', 45477, 55095) -- Icy Touch => Frost Fever

------------------------------------------------------------------------------
elseif class == 'PRIEST' then
------------------------------------------------------------------------------

	-- Contributed by brotherhobbes
	SelfBuffs(
		  588, -- Inner Fire
		15286, -- Vampiric Embrace
		47585  -- Dispersion
	)
	
	GroupBuffs(27683) -- Shadow Protection

	GroupDebuffs(9484) -- Shackle Undead

------------------------------------------------------------------------------
elseif class == 'DRUID' then
------------------------------------------------------------------------------

	-- Display eclipse energy
	Aliases("buff", 5176, "LUNAR_ENERGY") -- Wrath
	Aliases("buff", 2912, "SOLAR_ENERGY") -- Starfire

	SelfBuffs(
		  768, -- Cat Form
		  783, -- Travel Form
		 1066, -- Aquatic Form
		 1850, -- Dash
		 5217, -- Tiger's Fury
		 5225, -- Track Humanoids
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
		61336  -- Survival Instincts
	)
	
	GroupDebuffs(  339) -- Entangling Roots
	GroupDebuffs(33786) -- Cyclone

------------------------------------------------------------------------------
elseif class == 'PALADIN' then
------------------------------------------------------------------------------

	SelfBuffs(
		  498, -- Divine Protection
		  642, -- Divine Shield
		20164, -- Seal of Justice
		20165, -- Seal of Light
		25780, -- Righteous Fury
		31842, -- Divine Illumination
		31884, -- Avenging Wrath
		53651  -- Beacon of Light buff name on player is Light's Beacon		
	)
	
	-- Spells that use Holy Power
	Aliases("buff", 85673, "HOLY_POWER") -- Word of Glory
	Aliases("buff", 85256, "HOLY_POWER") -- Templar's Verdict
	Aliases("buff", 53385, "HOLY_POWER") -- Divine Storm
	Aliases("buff", 53600, "HOLY_POWER") -- Shield of the Righteous
	Aliases("buff", 84963, "HOLY_POWER") -- Inquisition

	GroupBuffs( 7294) -- Retribution Aura	
	GroupBuffs(19891) -- Resistance Aura
	GroupBuffs(32223) -- Crusader Aura
	
	GroupDebuffs(20066) -- Repentance
	GroupDebuffs(10326) -- Turn Evil

end

