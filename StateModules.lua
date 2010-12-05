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

local _, addon = ...
local _, playerClass = UnitClass("player")

local UnitIsBuffable = addon.UnitIsBuffable
local UnitIsDebuffable = addon.UnitIsDebuffable
local GetBorderHighlight = addon.GetBorderHighlight

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

	local powerState = addon:NewStateModule(POWER_TYPE)
	powerState.keywords = { POWER_TYPE }

	function powerState:PostEnable()
		self:RegisterEvent("UNIT_POWER")
	end

	function powerState:Test(aura)
		local power = UnitPower("player", SPELL_POWER)
		return true, power, false, nil, power == MAX_POWER, "glowing"
	end

	function powerState:UNIT_POWER(event, unit, type)
		if unit == "player" and type == POWER_TYPE then
			addon:AuraChanged("player")
		end
	end

end

------------------------------------------------------------------------------
-- Rogue and druid: combo points
------------------------------------------------------------------------------

if playerClass == "ROGUE" or playerClass == "DRUID" then
	local GetComboPoints = GetComboPoints
	local MAX_COMBO_POINTS = MAX_COMBO_POINTS

	local comboPoints = addon:NewStateModule("ComboPoints")
	comboPoints.keywords = { "COMBO_POINTS" }
	comboPoints.auraType = "regular"
	comboPoints.specialTarget = "target"

	function comboPoints:PostEnable()
		self:RegisterEvent('UNIT_COMBO_POINTS')
	end

	function comboPoints:Test(_, unit)
		local points = GetComboPoints("player", "target")
		return true, points, false, nil, points == MAX_COMBO_POINTS, "glowing"
	end

	function comboPoints:UNIT_COMBO_POINTS(_, unit)
		if unit == "player" or unit == "vehicle" then
			return addon:AuraChanged("target")
		end
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

	local eclipseState = addon:NewStateModule("Eclipse")
	eclipseState.keywords = { "LUNAR_ENERGY", "SOLAR_ENERGY" }

	function eclipseState:PostEnable()
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
			addon:AuraChanged("player")
		end
	end

	function eclipseState:UNIT_POWER(event, unit, type)
		if unit == "player" and type == "ECLIPSE" then
			local newPower = math.ceil(100 * UnitPower("player", SPELL_POWER_ECLIPSE) / UnitPowerMax("player", SPELL_POWER_ECLIPSE))
			if newPower ~= power then
				power = newPower
				addon:AuraChanged("player")
			end
		end
	end

	function eclipseState:ECLIPSE_DIRECTION_CHANGE(event)
		local newDirection = GetEclipseDirection()
		if newDirection ~= direction then
			direction = newDirection
			addon:AuraChanged("player")
		end
	end

	function eclipseState:Test(aura)
		if power then
			if aura == "LUNAR_ENERGY" then
				return isMoonkin and direction ~= "sun", -power
			elseif aura == "SOLAR_ENERGY" then
				return isMoonkin and direction ~= "moon", power
			end
		end
	end

end

------------------------------------------------------------------------------
-- Shaman totems
------------------------------------------------------------------------------

if playerClass == "SHAMAN" then

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
	
	local totemState = addon:NewStateModule("Totems")
	totemState.keywords = { "TOTEM" }
	totemState.spellHooks = { GetSpellNames(unpack(TOTEMS)) }

	function totemState:PostEnable()
		self:RegisterEvent('PLAYER_TOTEM_UPDATE')
	end

	function totemState:PLAYER_TOTEM_UPDATE()
		addon:AuraChanged("player")
	end

	function totemState:Test(spell)
		spell = strlower(spell)
		for index = 1, 4 do
			local haveTotem, name, startTime, duration = GetTotemInfo(index)
			if haveTotem and name and strlower(name) == spell then
				return false, nil, startTime and duration, startTime + duration, true, "BuffMine"
			end
		end
	end

end

------------------------------------------------------------------------------
-- Health threshold
------------------------------------------------------------------------------

local healthThresholds
if playerClass == "WARRIOR" or playerClass == "HUNTER" then
	healthThresholds = { 20 }
elseif playerClass == "PALADIN" then
	healthThresholds = { 20, 35 }
elseif playerClass == "WARLOCK" then
	healthThresholds = { 20, 25 }
elseif playerClass == "PRIEST" then
	healthThresholds = { 25 }
elseif playerClass == "ROGUE" then
	healthThresholds = { 35 }
elseif playerClass == "DRUID" then
	healthThresholds = { 25, 80 }
end

if healthThresholds then

	local keywords = {}
	for i, threshold in ipairs(healthThresholds) do
		tinsert(keywords, "BELOW"..threshold)
		tinsert(keywords, "ABOVE"..threshold)
	end

	local healthState = addon:NewStateModule("Health")
	healthState.auraType = "regular"
	healthState.states = {}
	healthState.keywords = keywords

	function healthState:OnEnable()
		self:RegisterEvent('UNIT_HEALTH')
		self:RegisterEvent('UNIT_HEALTH_MAX', 'UNIT_HEALTH')
		wipe(self.states)
	end

	function healthState:GetState(unit)
		if unit and UnitExists(unit) and not UnitIsDeadOrGhost(unit) and addon.db.profile.enabledUnits[unit] then
			local current, max = UnitHealth(unit), UnitHealthMax(unit)
			if max > 0 then
				local pct = 100 * current / max
				for i, threshold in ipairs(healthThresholds) do
					if pct <= threshold then
						healthState:Debug('GetState(', unit, '):', pct)
						return threshold
					end
				end
				healthState:Debug('GetState(', unit, '):', 100)
				return 100
			end
		end
		healthState:Debug('GetState(', unit, '):', nil)
	end

	function healthState:UNIT_HEALTH(event, unit)
		local newState = self:GetState(unit)
		if newState ~= self.states[unit] then
			self.states[unit] = newState
			addon:AuraChanged(unit)
		end
	end

	function healthState:CanTestUnit(unit, _, spell)
		if IsHelpfulSpell(spell) then
			return UnitIsBuffable(unit)
		else
			return UnitIsDebuffable(unit)
		end
	end

	function healthState:Test(condition, unit, onlyMyBuffs, onlyMyDebuffs, spell)
		if not IsUsableSpell(spell) or (GetSpellCooldown(spell) or 0) ~= 0 then return end
		local below = tonumber(strmatch(condition, '^BELOW(%d+)$'))
		local above = tonumber(strmatch(condition, '^ABOVE(%d+)$'))
		local state = self:GetState(unit)
		if state then
			self:Debug('Test(', condition, unit, '): below:', below, below and state <= below, "above:", above, above and state >= above)
			return false, nil, false, nil, (below and state <= below) or (above and state >= above), "glowing"
		end
	end

end

------------------------------------------------------------------------------
-- Dispell
------------------------------------------------------------------------------

local dispellState = addon:NewStateModule("Dispell")
dispellState.auraType = "regular"
dispellState.keywords = {"DISPELLABLE"}

function dispellState:Test(_, unit)
	local selectFilter, magicOnly
	if UnitIsDebuffable(unit) then
		selectFilter, magicOnly = "HELPFUL", true
	elseif UnitIsBuffable(unit) then
		selectFilter, magicOnly = "HARMFUL|RAID", nil
	else
		return
	end
	local i = 1
	local maxExpirationTime
	repeat
		local name, _, _, _, debuffType, duration, expirationTime = UnitAura(unit, i, selectFilter)
		if name and expirationTime and (not magicOnly or debuffType == "Magic") then
			if not maxExpirationTime or expirationTime > maxExpirationTime then
				maxExpirationTime = expirationTime
			end
		end
		i = i + 1
	until not name
	if maxExpirationTime then
		return false, nil, true, maxExpirationTime, true, GetBorderHighlight(magicOnly, false)
	end
end

