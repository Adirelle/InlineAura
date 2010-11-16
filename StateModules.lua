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

if not InlineAura then return end

local _, playerClass = UnitClass("player")

------------------------------------------------------------------------------
-- Warlocks' Soul Shards and Paladins' Holy Power
------------------------------------------------------------------------------

if playerClass == "WARLOCK" or playerClass == "PALADIN" then
	local POWER_TYPE, SPELL_POWER
	if playerClass == "WARLOCK"  then
		POWER_TYPE, MAX_POWER = "SOUL_SHARDS", 10
	else
		POWER_TYPE, MAX_POWER = "HOLY_POWER", MAX_HOLY_POWER
	end
	local SPELL_POWER = _G["SPELL_POWER_"..POWER_TYPE]
	local UnitPower = UnitPower

	local powerState = InlineAura:NewStateModule(POWER_TYPE)

	function powerState:OnEnable()
		self:RegisterKeywords(POWER_TYPE)
		self:RegisterEvent("UNIT_POWER")
	end

	function powerState:AcceptUnit(unit)
		return unit == "player"
	end

	function powerState:Test(aura)
		local power = UnitPower("player", SPELL_POWER)
		return aura, power, nil, false, true, power == MAX_POWER
	end

	function powerState:UNIT_POWER(event, unit, type)
		if unit == "player" and type == POWER_TYPE then
			InlineAura:AuraChanged("player")
		end
	end

end

------------------------------------------------------------------------------
-- Rogue and druid: combo points
------------------------------------------------------------------------------

if playerClass == "ROGUE" or playerClass == "DRUID" then
	local GetComboPoints = GetComboPoints
	local MAX_COMBO_POINTS = MAX_COMBO_POINTS

	local comboPoints = InlineAura:NewStateModule("ComboPoints")

	function comboPoints:OnEnable()
		self:RegisterKeywords("COMBO_POINTS")
		self:RegisterEvent('PLAYER_COMBO_POINTS')
	end

	function comboPoints:AcceptUnit(unit)
		return unit == "player"
	end

	function comboPoints:Test(aura, unit)
		local points = GetComboPoints("player")
		return aura, points, nil, false, true, points == MAX_COMBO_POINTS
	end

	function comboPoints:PLAYER_COMBO_POINTS()
		InlineAura:AuraChanged("player")
	end
end

------------------------------------------------------------------------------
-- Druid: eclipse energy (moonkins)
------------------------------------------------------------------------------

if playerClass == "DRUID" then

	local SPELL_POWER_ECLIPSE = SPELL_POWER_ECLIPSE
	local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
	local GetEclipseDirection = GetEclipseDirection
	local GetPrimaryTalentTree = GetPrimaryTalentTree

	local isMoonkin, direction, power

	local eclipseState = InlineAura:NewStateModule("Eclipse")

	function eclipseState:OnEnable()
		self:RegisterKeywords("LUNAR_ENERGY", "SOLAR_ENERGY")
		self:RegisterEvent('PLAYER_TALENT_UPDATE')
		self:PLAYER_TALENT_UPDATE("OnEnable")
	end

	function eclipseState:PLAYER_TALENT_UPDATE(event)
		local newIsMoonkin = (GetPrimaryTalentTree() == 1)
		if isMoonkin ~= newIsMoonkin then
			isMoonkin = newIsMoonkin
			if isMoonkin then
				self:RegisterEvent('UNIT_POWER')
				self:RegisterEvent('ECLIPSE_DIRECTION_CHANGE')
				self:ECLIPSE_DIRECTION_CHANGE(event)
				self:UNIT_POWER(event, "player", "ECLIPSE")
			else
				self:UnregisterEvent('UNIT_POWER')
				self:UnregisterEvent('ECLIPSE_DIRECTION_CHANGE')
			end
			InlineAura:AuraChanged("player")
		end
	end

	function eclipseState:UNIT_POWER(event, unit, type)
		if unit == "player" and type == "ECLIPSE" then
			local newPower = math.ceil(100 * UnitPower("player", SPELL_POWER_ECLIPSE) / UnitPowerMax("player", SPELL_POWER_ECLIPSE))
			if newPower ~= power then
				power = newPower
				InlineAura:AuraChanged("player")
			end
		end
	end

	function eclipseState:ECLIPSE_DIRECTION_CHANGE(event)
		local newDirection = GetEclipseDirection()
		if newDirection ~= direction then
			direction = newDirection
			InlineAura:AuraChanged("player")
		end
	end

	function eclipseState:Test(aura)
		if aura == "LUNAR_ENERGY" then
			return aura, isMoonkin and direction == "moon" and -power, nil, false, true
		elseif aura == "SOLAR_ENERGY" then
			return aura, isMoonkin and direction == "sun" and power, nil, false, true
		end
	end

end

------------------------------------------------------------------------------
-- Shaman totems
------------------------------------------------------------------------------

if playerClass == "SHAMAN" then

	local totemState = InlineAura:NewStateModule("Totems")
	totemState.OverrideAuraType = "self"

	local TOTEMS = {
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
		16190, -- Mana Tide Totem
	}

	local function GetSpellNames(id, ...)
		if id then
			return GetSpellInfo(id), GetSpellNames(...)
		end
	end

	function totemState:OnEnable()
		self:RegisterKeywords("TOTEM")
		self:RegisterSpellHooks(GetSpellNames(unpack(TOTEMS)))
		self:RegisterEvent('PLAYER_TOTEM_UPDATE')
	end

	function totemState:PLAYER_TOTEM_UPDATE()
		InlineAura:AuraChanged("player")
	end

	function totemState:CanTestUnit(unit)
		return unit == "player"
	end

	function totemState:Test(spell)
		spell = strlower(spell)
		for index = 1, 4 do
			local haveTotem, name, startTime, duration = GetTotemInfo(index)
			if haveTotem and name and strlower(name) == spell then
				return name, nil, startTime and duration and (startTime + duration) or nil, false, true, true
			end
		end
	end

end
