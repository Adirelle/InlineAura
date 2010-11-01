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
-- Warlock: soul shards
------------------------------------------------------------------------------

if playerClass == "WARLOCK" then
	local UnitPower = UnitPower
	local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS
	InlineAura:RegisterSpecial(
		"SOUL_SHARDS", function() return UnitPower("player", SPELL_POWER_SOUL_SHARDS) end,
		"UNIT_POWER", function(self, event, unit, type)
			if unit == "player" and type == "SOUL_SHARDS" then
				InlineAura:AuraChanged("player")
			end
		end
	)
end

------------------------------------------------------------------------------
-- Warlock: holy power
------------------------------------------------------------------------------

if playerClass == "PALADIN" then
	local UnitPower = UnitPower
	local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER
	local MAX_HOLY_POWER = MAX_HOLY_POWER
	InlineAura:RegisterSpecial(
		"HOLY_POWER", function()
			local power = UnitPower("player", SPELL_POWER_HOLY_POWER)
			return power, power == MAX_HOLY_POWER
		end,
		"UNIT_POWER", function(self, event, unit, type)
			if unit == "player" and type == "HOLY_POWER" then
				return InlineAura:AuraChanged("player")
			end
		end
	)

end


------------------------------------------------------------------------------
-- Rogue and druid: combo points
------------------------------------------------------------------------------

if playerClass == "ROGUE" or playerClass == "DRUID" then
	local GetComboPoints = GetComboPoints
	local MAX_COMBO_POINTS = MAX_COMBO_POINTS
	InlineAura:RegisterSpecial(
		"COMBO_POINTS", function()
			local points = GetComboPoints("player")
			return points, points == MAX_COMBO_POINTS
		end,
		"PLAYER_COMBO_POINTS", function()
			return InlineAura:AuraChanged("player")
		end
	)
end

------------------------------------------------------------------------------
-- Druid: eclipse energy (moonkins)
------------------------------------------------------------------------------

-- Moonkin eclipse points
if playerClass == "DRUID" then

	local SPELL_POWER_ECLIPSE = SPELL_POWER_ECLIPSE
	local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
	local GetEclipseDirection = GetEclipseDirection
	local GetPrimaryTalentTree = GetPrimaryTalentTree

	local isMoonkin, direction, power

	function InlineAura:UNIT_POWER(event, unit, type)
		if unit == "player" and type == "ECLIPSE" then
			local newPower = math.ceil(100 * UnitPower("player", SPELL_POWER_ECLIPSE) / UnitPowerMax("player", SPELL_POWER_ECLIPSE))
			if newPower ~= power then
				power = newPower
				InlineAura:AuraChanged("player")
			end
		end
	end

	function InlineAura:ECLIPSE_DIRECTION_CHANGE(event)
		local newDirection = GetEclipseDirection()
		if newDirection ~= direction then
			direction = newDirection
			InlineAura:AuraChanged("player")
		end
	end

	function InlineAura:PLAYER_TALENT_UPDATE(event)
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

	InlineAura:RegisterSpecial("LUNAR_ENERGY", function() return isMoonkin and direction == "moon" and -power end, "PLAYER_TALENT_UPDATE")
	InlineAura:RegisterSpecial("SOLAR_ENERGY", function() return isMoonkin and direction == "sun" and power end, "PLAYER_TALENT_UPDATE")
end

