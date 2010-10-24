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

local AddAura = InlineAura.AddAura
local RemoveAura = InlineAura.RemoveAura

------------------------------------------------------------------------------
-- Basic: buffs and debuffs
------------------------------------------------------------------------------

local UnitAura = UnitAura

local function ScanAuras(unit, filter)
	local i = 1
	repeat
		local name, _, _, count, _, duration, expirationTime, isMine, _, _, spellId = UnitAura(unit, i, filter)
		if name then
			AddAura(unit, name, count, duration, expirationTime, isMine, filter, spellId)
			i = i + 1
		end
	until not name
end
InlineAura:RegisterAuraScanner("*", function(unit)
	ScanAuras(unit, "HELPFUL")
	ScanAuras(unit, "HARMFUL")
end)

------------------------------------------------------------------------------
-- Basic: tracking
------------------------------------------------------------------------------

local GetNumTrackingTypes, GetTrackingInfo = GetNumTrackingTypes, GetTrackingInfo

local function UpdateTracking()
	for i = 1, GetNumTrackingTypes() do
		local name, _, active, category = GetTrackingInfo(i)
		if category == 'spell' then
			if active then
				AddAura("player", name, nil, nil, nil, true, "HELPFUL")
			else
				RemoveAura("player", name)
			end
		end
	end
end

InlineAura:RegisterAuraScanner("player", UpdateTracking)
InlineAura.MINIMAP_UPDATE_TRACKING = UpdateTracking
InlineAura:RegisterEvent('MINIMAP_UPDATE_TRACKING')

------------------------------------------------------------------------------
-- Shaman: totems
------------------------------------------------------------------------------

if playerClass == "SHAMAN" then

	local GetTotemInfo = GetTotemInfo

	local function UpdateTotems()
		for i = 1, MAX_TOTEMS do
			local haveTotem, name, startTime, duration = GetTotemInfo(i)
			if haveTotem and name and name ~= "" then
				name = name:gsub("%s[IVX]-$", "") -- Whoever proposed to use roman numerals in enchant names should be shot
				AddAura("player", name, 0, duration, startTime+duration, true, "HELPFUL")
			else
				RemoveAura("player", name)
			end
		end
	end

	InlineAura:RegisterAuraScanner("player", UpdateTotems)
	InlineAura.PLAYER_TOTEM_UPDATE = UpdateTotems
	InlineAura:RegisterEvent('PLAYER_TOTEM_UPDATE')

end

------------------------------------------------------------------------------
-- Warlock: soul shards and Paladin: holy power
------------------------------------------------------------------------------

if playerClass == "WARLOCK" or playerClass == "PALADIN" then

	local UnitPower = UnitPower

	local POWER_TYPE, POWER_NAME
	if playerClass == "WARLOCK" then
		POWER_TYPE, POWER_NAME = SPELL_POWER_SOUL_SHARDS, "SOUL_SHARDS" -- L["SOUL_SHARDS"]
	else
		POWER_TYPE, POWER_NAME = SPELL_POWER_HOLY_POWER, "HOLY_POWER"-- L["HOLY_POWER"]
	end

	local function UpdatePower()
		local power = UnitPower("player", POWER_TYPE)
		if power and power > 0 then
			AddAura("player", POWER_NAME, power, nil, nil, true, "HELPFUL")
		else
			RemoveAura("player", POWER_NAME)
		end
	end

	local function UNIT_POWER(self, event, unit, type)
		if unit == "player" and type == POWER_NAME then
			return UpdatePower()
		end
	end
	
	InlineAura:RegisterAuraScanner("player", UpdatePower)
	InlineAura:RegisterSpecial(POWER_NAME, "UNIT_POWER", UNIT_POWER)
end

------------------------------------------------------------------------------
-- Rogue and druid: combo points
------------------------------------------------------------------------------

if playerClass == "ROGUE" or playerClass == "DRUID" then

	local GetComboPoints = GetComboPoints

	local function UpdateComboPoints()
		local points = GetComboPoints("player")
		if points and points > 0 then
			AddAura("player", "COMBO_POINTS", points, nil, nil, true, "HELPFUL")
		else
			RemoveAura("player", "COMBO_POINTS")
		end
	end

	InlineAura:RegisterAuraScanner("player", UpdateComboPoints)
	InlineAura:RegisterSpecial("COMBO_POINTS", "PLAYER_COMBO_POINTS", UpdateComboPoints) -- L["COMBO_POINTS"]
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

	function UpdateEclipse()
		if isMoonkin and direction and power and power ~= 0 then
			if direction == "moon" then
				AddAura("player", "LUNAR_ENERGY", -power, nil, nil, true, "HELPFUL")
				RemoveAura("player", "LUNAR_ENERGY")
			else
				RemoveAura("player", "SOLAR_ENERGY")
				AddAura("player", "SOLAR_ENERGY", power, nil, nil, true, "HELPFUL")
			end
		else
			RemoveAura("player", "LUNAR_ENERGY")
			RemoveAura("player", "SOLAR_ENERGY")
		end
	end

	function InlineAura:UNIT_POWER(event, unit, type)
		if unit == "player" and type == "ECLIPSE" then
			local newPower = math.ceil(100 * UnitPower("player", SPELL_POWER_ECLIPSE) / UnitPowerMax("player", SPELL_POWER_ECLIPSE))
			if newPower ~= power then
				power = newPower
				if event == "UNIT_POWER" then
					return UpdateEclipse()
				end
			end
		end
	end

	function InlineAura:ECLIPSE_DIRECTION_CHANGE(event)
		local newDirection = GetEclipseDirection()
		if newDirection ~= direction then
			direction = newDirection
			if event == "ECLIPSE_DIRECTION_CHANGE" then
				return UpdateEclipse()
			end
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
			return UpdateEclipse()
		end
	end
	
	InlineAura:RegisterSpecial("LUNAR_ENERGY", "PLAYER_TALENT_UPDATE")
	InlineAura:RegisterSpecial("SOLAR_ENERGY", "PLAYER_TALENT_UPDATE")
	InlineAura:RegisterAuraScanner("player", UpdateEclipse)

end

