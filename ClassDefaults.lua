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

local function GetSpellName(id)
	local name = GetSpellInfo(id)
	if not name then
		error("Invalid spell id "..tostring(id), 4)
	end
	return name
end

local function GetSpellDefaults(id)
	local name = GetSpellName(id)
	if not SPELL_DEFAULTS[name] then
		SPELL_DEFAULTS[name] = {}
	end
	return SPELL_DEFAULTS[name]
end

local function SetSpellDefaults(auraType, id, ...)
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

local SELF_BUFF_UNITS = { player = true, pet = false, focus = false, target = false }

local function DeclareSelfBuffs(ids)
	for i, id in ipairs(ids) do
		local defaults = GetSpellDefaults(id)
		defaults.auraType = 'buff'
		defaults.unitsToScan = SELF_BUFF_UNITS
	end
end

local _, class = UnitClass('player')

if class == 'HUNTER' then

	SetSpellDefaults('debuff', 60192, 60210,  3355) -- Freezing Arrow => Freezing Arrow Effect and Freezing Trap Effect
	SetSpellDefaults('debuff',  1499,  3355, 60210) -- Freezing Trap => Freezing Trap Effect and Freezing Arrow Effect
	SetSpellDefaults('debuff', 13795, 13797) -- Immolation Trap => Immolation Trap Effect
	SetSpellDefaults('debuff', 13813, 13812) -- Explosive Trap => Explosive Trap Effect
	
	DeclareSelfBuffs({
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
	SetSpellDefaults('debuff', 47498, 47467) -- Devastate => Sunder Armor
	
	DeclareSelfBuffs({
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
		-- These are not really buffs but we aliases them to talent buffs
		 1464, -- Slam
		 5308, -- Execute
		 7384, -- Overpower
		23922, -- Shield Slam
	})

	-- Alias spells to talents that modify them
	SetSpellDefaults('buff',  1464, 46916) -- lights up Slam when Bloodsurge talent procs
	SetSpellDefaults('buff', 23922, 46951) -- lights up Shield Slam when Sword and Board talent procs
	SetSpellDefaults('buff',  7384, 60503) -- lights up Overpower when Taste for Blood talent procs
	SetSpellDefaults('buff',  5308, 52437) -- lights up Execute when Sudden Death talent procs
	
elseif class == 'WARLOCK' then
	SetSpellDefaults('debuff', 686, 17794) -- Shadow Bolt => Shadow Mastery
	
elseif class == 'MAGE' then

	-- Contributed by FlareCDE
	SetSpellDefaults('debuff', 42859, 22959) -- Scorch => Improved Scorch
	
elseif class == 'DEATHKNIGHT' then

	-- Contributed by jexxlc
	SetSpellDefaults('debuff', 45462, 55078) -- Plague Strike => Blood Plague
	SetSpellDefaults('debuff', 45477, 55095) -- Icy Touch => Frost Fever
	
elseif class == 'PRIEST' then

	-- Contributed by brotherhobbes
	DeclareSelfBuffs({
		  588, -- Inner Fire
		15473, -- Shadowform
		47585, -- Dispersion
	})

	SetSpellDefaults('buff',  1243, 21562) -- Power Word: Fortitude => Prayer of Fortitude
	SetSpellDefaults('buff', 21562,  1243) -- Prayer of Fortitude => Power Word: Fortitude

	SetSpellDefaults('buff',   976, 27683) -- Shadow Protection => Prayer of Shadow Protection
	SetSpellDefaults('buff', 27683,   976) -- Prayer of Shadow Protection => Shadow Protection

	SetSpellDefaults('buff', 14752, 27681) -- Divine Spirit => Prayer of Spirit
	SetSpellDefaults('buff', 27681, 14752) -- Prayer of Spirit => Divine Spirit

elseif class == 'DRUID' then

	DeclareSelfBuffs({
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

	SetSpellDefaults('buff',  1126, 21849) -- Mark of the Wild => Gift of the Wild
	SetSpellDefaults('buff', 21849,  1126) -- Gift of the Wild => Mark of the Wild
	
	-- Contributed by pusikas2
	SetSpellDefaults('debuff', 48564, 48566) -- Mangle - Bear => Mangle - Cat
	SetSpellDefaults('debuff', 48566, 48564) -- Mangle - Cat => Mangle - Bear
	SetSpellDefaults('debuff', 48475, 48476) -- Faerie Fire (Feral) => Faerie Fire
	SetSpellDefaults('debuff', 48476, 48475) -- Faerie Fire => Faerie Fire (Feral)
end

