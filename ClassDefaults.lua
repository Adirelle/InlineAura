--[[
Copyright (C) 2009 Adirelle

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

local SPELL_DEFAULTS = InlineAura.DEFAULT_OPTIONS.profile.spells

-- Get the spell name, throwing error if not found
local function GetSpellName(id)
	local name = GetSpellInfo(id)
	if not name then
		error("Invalid spell id "..tostring(id), 4)
	end
	return name
end

-- Get the spell defaults, creating the table if need be
local function GetSpellDefaults(id)
	local name = GetSpellName(id)
	if not SPELL_DEFAULTS[name] then
		SPELL_DEFAULTS[name] = {}
	end
	return SPELL_DEFAULTS[name]
end

-- Defines spell type and aliases
local function Aliases(auraType, id, ...)
	local defaults = GetSpellDefaults(id)
	defaults.auraType = auraType
	if select('#', ...) > 0 then
		local aliases = {}
		for i = 1, select('#', ...) do
			table.insert(aliases, GetSpellName(select(i, ...)))
		end
		defaults.aliases = aliases
	end
end

-- Defines buffs that only apply to the player
local SELF_BUFF_UNITS = { player = true, pet = false, focus = false, target = false }
local function SelfBuffs(ids)
	for i, id in ipairs(ids) do
		local defaults = GetSpellDefaults(id)
		defaults.auraType = 'buff'
		defaults.unitsToScan = SELF_BUFF_UNITS
	end
end

-- Defines auras that appear on the player and modify another spell
local function SelfTalentProc(spellId, talentId)
	local defaults = GetSpellDefaults(spellId)
	local talent = GetSpellName(talentId)
	defaults.auraType = 'buff'
	defaults.unitsToScan = SELF_BUFF_UNITS
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

local _, class = UnitClass('player')

if class == 'HUNTER' then

	Aliases('debuff', 60192, 60210,  3355) -- Freezing Arrow => Freezing Arrow Effect and Freezing Trap Effect
	Aliases('debuff',  1499,  3355, 60210) -- Freezing Trap => Freezing Trap Effect and Freezing Arrow Effect
	Aliases('debuff', 13795, 13797) -- Immolation Trap => Immolation Trap Effect
	Aliases('debuff', 13813, 13812) -- Explosive Trap => Explosive Trap Effect

	SelfBuffs({
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
	})

	-- Mend Pet applies only on the pet
	local MendPet = GetSpellDefaults(136)
	MendPet.auraType = 'buff'
	MendPet.unitsToScan = { pet = true, player = false, focus = false, target = false }

elseif class == 'WARRIOR' then

	-- Contributed by brotherhobbes
	Aliases('debuff', 47498, 47467) -- Devastate => Sunder Armor

	SelfBuffs({
			871, -- Shield Wall
		 1719, -- Recklessness
		 2565, -- Shield Block
		12292, -- Death Wish
		12975, -- Last Stand
		18499, -- Berserker Rage
		20230, -- Retaliation
		23920, -- Spell Reflection
		46924, -- Bladestorm
		55694, -- Enraged Regeneration
	})

	SelfTalentProc( 1464, 46916) -- Slam => Bloodsurge
	SelfTalentProc(23922, 46951) -- Shield Slam => Sword and Board
	SelfTalentProc( 7384, 60503) -- Overpower => Taste for Blood
	SelfTalentProc( 5308, 52437) -- Execute => Sudden Death

elseif class == 'WARLOCK' then
	Aliases('debuff', 686, 17794) -- Shadow Bolt => Shadow Mastery

elseif class == 'MAGE' then

	-- Intellect buffs
	Aliases('buff',  1459, 23028, 61024, 61316) -- Arcane Intellect = 3 others
	Aliases('buff', 23028,  1459, 61024, 61316) -- Arcane Brilliance = 3 others
	Aliases('buff', 61024,  1459, 23028, 61316) -- Dalaran Intellect = 3 others
	Aliases('buff', 61316,  1459, 23028, 61024) -- Dalaran Brilliance = 3 others

	-- Contributed by FlareCDE
	Aliases('debuff', 42859, 22959) -- Scorch => Improved Scorch

	-- Contributed by sun
	SelfTalentProc(11366, 44445) -- Pyroblast => Hot Streak
	SelfTalentProc( 5143,	44404) -- Arcane Missiles => Missile Barrage
	SelfTalentProc(  133, 57761) -- Fireball => Brain Freeze (buff named "Fireball!")

elseif class == 'DEATHKNIGHT' then

	-- Contributed by jexxlc
	Aliases('debuff', 45462, 55078) -- Plague Strike => Blood Plague
	Aliases('debuff', 45477, 55095) -- Icy Touch => Frost Fever

elseif class == 'PRIEST' then

	-- Contributed by brotherhobbes
	SelfBuffs({
		  588, -- Inner Fire
		15473, -- Shadowform
		47585, -- Dispersion
	})

	Aliases('buff',  1243, 21562) -- Power Word: Fortitude => Prayer of Fortitude
	Aliases('buff', 21562,  1243) -- Prayer of Fortitude => Power Word: Fortitude

	Aliases('buff',   976, 27683) -- Shadow Protection => Prayer of Shadow Protection
	Aliases('buff', 27683,   976) -- Prayer of Shadow Protection => Shadow Protection

	Aliases('buff', 14752, 27681) -- Divine Spirit => Prayer of Spirit
	Aliases('buff', 27681, 14752) -- Prayer of Spirit => Divine Spirit

elseif class == 'DRUID' then

	SelfBuffs({
		  768, -- Cat Form
		  783, -- Travel Form
		 1066, -- Aquatic Form
		 5487, -- Bear Form
		 9634, -- Dire Bear Form
		24858, -- Moonkin Form
		33891, -- Tree of Life
		33943, -- Flight Form
		40120, -- Swift Flight Form
	})

	Aliases('buff',  1126, 21849) -- Mark of the Wild => Gift of the Wild
	Aliases('buff', 21849,  1126) -- Gift of the Wild => Mark of the Wild

	-- Contributed by pusikas2
	Aliases('debuff', 48564, 48566) -- Mangle - Bear => Mangle - Cat
	Aliases('debuff', 48566, 48564) -- Mangle - Cat => Mangle - Bear
	Aliases('debuff', 48475, 48476) -- Faerie Fire (Feral) => Faerie Fire
	Aliases('debuff', 48476, 48475) -- Faerie Fire => Faerie Fire (Feral)

elseif class == 'PALADIN' then

	local _, race = UnitRace('player')

	SelfBuffs({
		25780, -- Righteous Fury
		31884, -- Avenging Wrath
		20164, -- Seal of Justice
		20165, -- Seal of Light
		21084, -- Seal of Righteousness
		20166, -- Seal of Wisdom
	})

	if race == 'BloodElf' then
		SelfBuffs({
			31892, -- Seal of Blood
			53736, -- Seal of Corruption
		})
	else
		SelfBuffs({
			53720, -- Seal of the Martyr
			31801, -- Seal of Vengeance
		})
	end

	-- Holy Light is modified both by Infusion of Light and Light's Grace but
	-- they have different effects so we only show one.
	SelfTalentProc(  635, 31834) -- Holy Light => Light's Grace
	SelfTalentProc(19750, 53672) -- Flash of Light => Infusion of Light

	-- Blessings
	Aliases('buff', 19740, 25782) -- Blessing of Might => Greater Blessing of Might
	Aliases('buff', 25782, 19740) -- Greater Blessing of Might => Blessing of Might

	Aliases('buff', 19742, 25894) -- Blessing of Wisdom => Greater Blessing of Wisdom
	Aliases('buff', 25894, 19742) -- Greater Blessing of Wisdom => Blessing of Wisdom

	Aliases('buff', 20911, 25899) -- Blessing of Sanctuary => Greater Blessing of Sanctuary
	Aliases('buff', 25899, 20911) -- Greater Blessing of Sanctuary => Blessing of Sanctuary

	Aliases('buff', 20217, 25898) -- Blessing of Kings => Greater Blessing of Kings
	Aliases('buff', 25899, 20217) -- Greater Blessing of Kings => Blessing of Kings

end

