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

local function SetSpellDefaults(auraType, id, ...)
	local defaults = { 
		auraType = auraType,
	}
	local name = GetSpellInfo(id)
	SPELL_DEFAULTS[name] = defaults
	if select('#', ...) > 0 then
		local aliases = {}
		defaults.aliases = aliases
		for i = 1, select('#', ...) do
			local aliasId = select(i, ...)
			local aliasName = GetSpellInfo(aliasId)
			table.insert(aliases, aliasName)
		end
	end
end

local SELF_BUFF_UNITS = { player = true, pet = false, focus = false, target = false }
local function DeclareSelfBuffs(ids)
	for i, id in ipairs(ids) do
		local name = GetSpellInfo(id)
		local defaults = SPELL_DEFAULTS[name] or {}
		SPELL_DEFAULTS[name] = defaults
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
	SPELL_DEFAULTS[GetSpellInfo(136)] = { auraType = 'buff', unitsToScan = { pet = true, player = false, focus = false, target = false } }

elseif class == 'WARRIOR' then
	SetSpellDefaults('debuff', 47498, 47467) -- Devastate => Sunder Armor
	
elseif class == 'WARLOCK' then
	SetSpellDefaults('debuff', 686, 17794) -- Shadow Bolt => Shadow Mastery
	
elseif class == 'MAGE' then
	-- Proposed by FlareCDE
	SetSpellDefaults('debuff', 42859, 22959) -- Scorch => Improved Scorch
	
elseif class == 'DEATHKNIGHT' then
	-- Proposed by jexxlc
	SetSpellDefaults('debuff', 45462, 55078) -- Plague Strike => Blood Plague
	SetSpellDefaults('debuff', 45477, 55095) -- Icy Touch => Frost Fever
	
elseif class == 'DRUID' then
	SetSpellDefaults('buff',  1126, 21849) -- Mark of the Wild => Gift of the Wild
	SetSpellDefaults('buff', 21849,  1126) -- Gift of the Wild => Mark of the Wild
	-- Proposed by pusikas2
	SetSpellDefaults('debuff', 48564, 48566) -- Mangle - Bear => Mangle - Cat
	SetSpellDefaults('debuff', 48566, 48564) -- Mangle - Cat => Mangle - Bear
	SetSpellDefaults('debuff', 48475, 48476) -- Faerie Fire (Feral) => Faerie Fire
end

