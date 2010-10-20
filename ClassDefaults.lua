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
	if InlineAura.keywords[name] then
		return name
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
			geterrorhandler()(format("Wrong spell id. Please report this error with the following information: id=%d, class=%s, version=%s, line=%s", id, class, version, source or "?"))
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

------------------------------------------------------------------------------
if class == 'HUNTER' then
------------------------------------------------------------------------------

	Aliases('debuff', 60192, 60210,  3355) -- Freezing Arrow => Freezing Arrow Effect and Freezing Trap Effect
	Aliases('debuff',  1499,  3355, 60210) -- Freezing Trap => Freezing Trap Effect and Freezing Arrow Effect
	Aliases('debuff', 13795, 13797) -- Immolation Trap => Immolation Trap Effect
	Aliases('debuff', 13813, 13812) -- Explosive Trap => Explosive Trap Effect
	
	Aliases('buff', 19434, 82925) -- Aimed Shot => Ready, Set, Aim...	

	SelfBuffs(
		13161, -- Aspect of the Beast
		 5118, -- Aspect of the Cheetah
		61846, -- Aspect of the Dragonhawk
		13165, -- Aspect of the Hawk
		13163, -- Aspect of the Monkey
		34074, -- Aspect of the Viper
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
	
	GroupDebuffs(1130) -- Hunter's Mark

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

	GroupBuffs( 469) -- Commanding Shout
	GroupBuffs(6673) -- Battle Shout

	GroupDebuffs(1160) -- Demoralizing Shout

	-- Contributed by brotherhobbes
	Aliases('debuff', 47498, 47467) -- Devastate => Sunder Armor

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

	SelfTalentProc( 1464, 46916) -- Slam => Bloodsurge
	SelfTalentProc(23922, 46951) -- Shield Slam => Sword and Board
	SelfTalentProc( 7384, 60503) -- Overpower => Taste for Blood
	SelfTalentProc( 5308, 52437) -- Execute => Sudden Death

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

	SelfTalentProc( 331, 53390) -- Healing Wave => Tidal Waves
	SelfTalentProc(8004, 53390) -- Lesser Healing Wave => Tidal Waves
	
	GroupDebuffs(51514) -- Hex
	
------------------------------------------------------------------------------
elseif class == 'WARLOCK' then
------------------------------------------------------------------------------

	SelfTalentProc(  686, 17941) -- Shadow Bolt => Shadow Trance
	SelfTalentProc(  686, 34936) -- Shadow Bolt => Backlash
	
	SelfTalentProc(29722, 34936) -- Incinerate => Backlash
	SelfTalentProc(29722, 47383) -- Incinerate => Molten Core
	SelfTalentProc(29722, 54274) -- Incinerate => Backdraft

	SelfTalentProc(6353, 63165) -- Soul Fire => Decimation

	-- Glyph of Life Tap
	SelfTalentProc( 1454, 63321) -- Life Tap => Life Tap
	SelfTalentProc(18220, 63321) -- Dark Pact => Life Tap
	
	GroupDebuffs(1490) -- Curse of the Elements
	GroupDebuffs(710) -- Banish

------------------------------------------------------------------------------
elseif class == 'MAGE' then
------------------------------------------------------------------------------

	-- Intellect buffs 
	GroupBuffs(1459, 23028, 61024, 61316) -- Arcane Intellect, Arcane Brilliance, Dalaran Intellect, Dalaran Brilliance
	
	-- Polymorphs
	GroupDebuffs(118, 28272, 28271, 61025, 61305)
	
	-- Firestarter proc
	SelfTalentProc(11113, 54741) -- Blast Wave => Firestarter
	SelfTalentProc(31661, 54741) -- Dragon's Breath => Firestarter

	-- Contributed by FlareCDE
	Aliases('debuff', 42859, 22959) -- Scorch => Improved Scorch
	
	-- Improved Scorch is actually a target talent proc
	GetSpellDefaults(42859).alternateColor = true

	-- Contributed by sun
	SelfTalentProc(11366, 44445) -- Pyroblast => Hot Streak
	SelfTalentProc( 5143,	44404) -- Arcane Missiles => Missile Barrage
	SelfTalentProc(  133, 57761) -- Fireball => Brain Freeze (buff named "Fireball!")

------------------------------------------------------------------------------
elseif class == 'DEATHKNIGHT' then
------------------------------------------------------------------------------
	
	GroupBuffs(57330) -- Horn of Winter
	
	-- Contributed by jexxlc
	Aliases('debuff', 45462, 55078) -- Plague Strike => Blood Plague
	Aliases('debuff', 45477, 55095) -- Icy Touch => Frost Fever

	-- Reported by shine2009
	SelfTalentProc(49895, 49194) -- Death Coil => Unholy Blight
	SelfTalentProc(45902, 66803) -- Blood Strike => Desolation

------------------------------------------------------------------------------
elseif class == 'PRIEST' then
------------------------------------------------------------------------------

	-- Contributed by brotherhobbes
	SelfBuffs(
		  588, -- Inner Fire
		15286,  -- Vampiric Embrace
		15473, -- Shadowform
		47585 -- Dispersion
	)
	
	GroupBuffs( 1243, 21562) -- Power Word: Fortitude, Prayer of Fortitude
	GroupBuffs(  976, 27683) -- Shadow Protection, Prayer of Shadow Protection
	GroupBuffs(14752, 27681) -- Divine Spirit, Prayer of Spirit
	
	GroupDebuffs(9484) -- Shackle Undead
	
	SelfTalentProc( 585, 33151) -- Smite => Surge of Light
	SelfTalentProc(2061, 33151) -- Flash Heal => Surge of Light
	SelfTalentProc( 596, 63731) -- Prayer of Healing => Serendipity
  SelfTalentProc(2060, 63731) -- Greater Heal => Serendipity
	
------------------------------------------------------------------------------
elseif class == 'DRUID' then
------------------------------------------------------------------------------

	GroupBuffs(1126) -- Mark of the Wild

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
	
	-- Eclipse
	SelfTalentProc(5176, '#48517') -- Wrath damage increase 
	SelfTalentProc(2912, '#48518') -- Starfire crit increase

	GroupDebuffs(33917) -- Mangle

	-- Contributed by pusikas2
	GroupDebuffs(  770, 16857) -- Faerie Fire, Faerie Fire (Feral)

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

	SelfTalentProc(635, 54149) -- Holy Light => Infusion of Light
	
	-- Blessings
	GroupBuffs(19740) -- Blessing of Might
	GroupBuffs(20217) -- Blessing of Kings

	GroupDebuffs(20066) -- Repentance
	GroupDebuffs(10326) -- Turn Evil

end

