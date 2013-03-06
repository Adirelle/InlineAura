--[[
Inline Aura - displays aura information inside action buttons
Copyright (C) 2009-2012 Adirelle (adirelle@gmail.com)

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

local UnitIsBuffable = addon.UnitIsBuffable
local UnitIsDebuffable = addon.UnitIsDebuffable
local GetBorderHighlight = addon.GetBorderHighlight

------------------------------------------------------------------------------
-- Make often-used globals local
------------------------------------------------------------------------------

--<GLOBALS
local _G = _G
local ceil = _G.ceil
local GetComboPoints = _G.GetComboPoints
local GetEclipseDirection = _G.GetEclipseDirection
local GetSpecialization = _G.GetSpecialization
local GetSpellInfo = _G.GetSpellInfo
local GetTotemInfo = _G.GetTotemInfo
local ipairs = _G.ipairs
local IsHelpfulSpell = _G.IsHelpfulSpell
local MAX_COMBO_POINTS = _G.MAX_COMBO_POINTS
local MAX_HOLY_POWER = _G.MAX_HOLY_POWER
local setmetatable = _G.setmetatable
local SPELL_POWER_ECLIPSE = _G.SPELL_POWER_ECLIPSE
local SPELL_POWER_SOUL_SHARDS = _G.SPELL_POWER_SOUL_SHARDS
local SPELL_POWER_HOLY_POWER = _G.SPELL_POWER_HOLY_POWER
local strlower = _G.strlower
local tinsert = _G.tinsert
local UnitAura = _G.UnitAura
local UnitCastingInfo = _G.UnitCastingInfo
local UnitChannelInfo = _G.UnitChannelInfo
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType
local wipe = _G.wipe
--GLOBALS>

local IsClass = addon.IsClass

local interestingUnits = setmetatable({
	player = true,
	pet = true,
	target = true
}, { __index = function(t, unit)
	if unit == "focus" or unit == "mouseover" then
		return addon.db.profile.enabledUnits[unit]
	end
	t[unit] = false
end })

------------------------------------------------------------------------------
-- Warlocks' Soul Shards
------------------------------------------------------------------------------

if IsClass("WARLOCK") then
	local soulShardState = addon:NewStateModule("SOUL_SHARDS")
	soulShardState.keywords = { "SOUL_SHARDS" }
	soulShardState.features = {
		stacks = true,
		highlight = true,
		highlightThreshold = true,
		highlightMaxThreshold = 3
	}
	soulShardState.defaults = { highlightThreshold = 1 }

	function soulShardState:PostEnable()
		self:RegisterEvent("UNIT_POWER")
	end

	function soulShardState:Test(aura)
		local pref = self.db.profile
		local power = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
		return pref.stacks, power, false, nil, pref.highlight and power >= pref.highlightThreshold, true
	end

	function soulShardState:UNIT_POWER(event, unit, type)
		if unit == "player" and type == "SOUL_SHARDS" then
			addon:AuraChanged("player")
		end
	end

end

------------------------------------------------------------------------------
-- Paladins' Holy Power
------------------------------------------------------------------------------

if IsClass("PALADIN") then
	local holyPowerStat = addon:NewStateModule("HOLY_POWER")
	holyPowerStat.keywords = { "HOLY_POWER" }
	holyPowerStat.features = {
		stacks = true,
		highlight = true,
		highlightThreshold = true,
		highlightMaxThreshold = MAX_HOLY_POWER
	}
	holyPowerStat.defaults = {
		highlightThreshold = MAX_HOLY_POWER
	}

	function holyPowerStat:PostEnable()
		self:RegisterEvent("UNIT_POWER")
		self.auraName = GetSpellInfo(86172) -- Divine Purpose
	end

	function holyPowerStat:Test(aura)
		local pref = self.db.profile
		local power = UnitPower("player", SPELL_POWER_HOLY_POWER)
		local highlight = pref.highlight and (power >= pref.highlightThreshold or UnitAura("player", self.auraName))
		return pref.stacks, power, false, nil, highlight, true
	end

	function holyPowerStat:UNIT_POWER(event, unit, type)
		if unit == "player" and type == "HOLY_POWER" then
			addon:AuraChanged("player")
		end
	end

end

------------------------------------------------------------------------------
-- Rogue and druid: combo points
------------------------------------------------------------------------------

if IsClass("ROGUE") or IsClass("DRUID") then
	local comboPoints = addon:NewStateModule("COMBO_POINTS")
	comboPoints.keywords = { "COMBO_POINTS" }
	comboPoints.auraType = "regular"
	comboPoints.specialTarget = "target"
	comboPoints.features = { stacks = true, highlight = true, highlightThreshold = true, highlightMaxThreshold = MAX_COMBO_POINTS }
	comboPoints.defaults = { highlightThreshold = MAX_COMBO_POINTS }

	function comboPoints:PostEnable()
		self:RegisterEvent('UNIT_COMBO_POINTS')
	end

	function comboPoints:Test(_, unit)
		local pref = self.db.profile
		local points = GetComboPoints("player", "target")
		return pref.stacks, points, false, nil, pref.highlight and points >= pref.highlightThreshold, true
	end

	function comboPoints:UNIT_COMBO_POINTS(_, unit)
		if unit == "player" or unit == "vehicle" then
			addon:AuraChanged("player")
			return addon:AuraChanged("target")
		end
	end

end

------------------------------------------------------------------------------
-- Druid: eclipse energy (moonkins)
------------------------------------------------------------------------------

if IsClass("DRUID") then
	local isMoonkin, direction, power

	local eclipseState = addon:NewStateModule("Eclipse energy") -- L['Eclipse energy']
	eclipseState.keywords = { "LUNAR_ENERGY", "SOLAR_ENERGY" }

	function eclipseState:PostEnable()
		self:RegisterEvent('PLAYER_TALENT_UPDATE')
		self:PLAYER_TALENT_UPDATE("OnEnable")
	end

	function eclipseState:PLAYER_TALENT_UPDATE(event)
		local spec = GetSpecialization()
		local newIsMoonkin = spec and (GetSpecializationInfo(spec) == 102) -- see SpellBookFrame.lua
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
			local newPower = ceil(100 * UnitPower("player", SPELL_POWER_ECLIPSE) / UnitPowerMax("player", SPELL_POWER_ECLIPSE))
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

if IsClass("SHAMAN") then

	local totemState = addon:NewStateModule("Totem timers") -- L['Totem timers']
	totemState.keywords = { "TOTEM" }
	totemState.features = { countdown = true, highlight = true }

	function totemState:PostEnable()
		self:RegisterEvent('PLAYER_TOTEM_UPDATE')
		self:PLAYER_TOTEM_UPDATE()
	end

	function totemState:PLAYER_TOTEM_UPDATE()
		addon:AuraChanged("player")
	end

	function totemState:Test(aura, unit, onlyMyBuffs, onlyMyDebuffs, spell)
		spell = strlower(spell)
		for index = 1, 4 do
			local haveTotem, name, startTime, duration = GetTotemInfo(index)
			if haveTotem and name and strlower(name) == spell then
				local pref = self.db.profile
				return false, nil, pref.countdown and startTime and duration, startTime + duration, pref.highlight, "BuffMine"
			end
		end
	end

end

------------------------------------------------------------------------------
-- Health threshold
------------------------------------------------------------------------------

local healthThresholds = {}
if IsClass("PRIEST") or IsClass("WARLOCK") or IsClass("WARRIOR") or IsClass("HUNTER") or IsClass("PALADIN") then
	tinsert(healthThresholds, 20)
end
if IsClass("PALADIN") or IsClass("ROGUE") or IsClass("DEATHKNIGHT") then
	tinsert(healthThresholds, 35)
end
if IsClass("DEATHKNIGHT") then
	tinsert(healthThresholds, 45) -- T15 4p bonus
end
if IsClass("DRUID") then
	tinsert(healthThresholds, 80)
end
if IsClass("MONK") then
	tinsert(healthThresholds, 10) -- PvP Touch of Death
end

if #healthThresholds > 0 then

	local keywords = {}
	local tests = {}
	for i, threshold in ipairs(healthThresholds) do
		tinsert(keywords, "BELOW"..threshold)
		tinsert(keywords, "ABOVE"..threshold)
		local threshold = threshold
		tests["BELOW"..threshold] = function(value) return value <= threshold end
		tests["ABOVE"..threshold] = function(value) return value > threshold end
	end

	local healthState = addon:NewStateModule("Health threshold") --L['Health threshold']
	healthState.auraType = "regular"
	healthState.states = {}
	healthState.keywords = keywords

	function healthState:PostEnable()
		self:RegisterEvent('UNIT_HEALTH_FREQUENT', 'UNIT_HEALTH')
		self:RegisterEvent('UNIT_HEALTH_MAX', 'UNIT_HEALTH')
		wipe(self.states)
	end

	function healthState:GetState(unit)
		if unit and interestingUnits[unit] and UnitExists(unit) and not UnitIsDeadOrGhost(unit) then
			local current, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
			if current <= 0 or maxHealth == 0 then
				return 0
			elseif current >= maxHealth then
				return 100
			else
				local pct = 100 * current / maxHealth
				for i, threshold in ipairs(healthThresholds) do
					if pct <= threshold then
						return threshold
					end
				end
				return 100
			end
		end
	end

	function healthState:UNIT_HEALTH(event, unit)
		local newState = self:GetState(unit)
		if newState ~= self.states[unit] then
			--@debug@
			self:Debug(event, unit, ':', self.states[unit], '=>', newState)
			--@end-debug@
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
		local test = tests[condition]
		if test then
			local state = self:GetState(unit)
			if state then
				--@debug@
				self:Debug('Test(', condition, unit, '):', test(state))
				--@end-debug@
				return false, nil, false, nil, test(state), true
			end
		end
	end

end

------------------------------------------------------------------------------
-- Dispell
------------------------------------------------------------------------------

local LibDispellable = LibStub('LibDispellable-1.0')

local dispellState = addon:NewStateModule("Dispel") -- L['Dispel']
dispellState.auraType = "regular"
dispellState.keywords = {"DISPELLABLE"}
dispellState.features = { countdown = true, highlight = true }

function dispellState:Test(_, unit, _, _, spell)
	local offensive = UnitIsDebuffable(unit)
	local maxExpirationTime
	for i, spellID, name, _, _, _, _, _, expirationTime in LibDispellable:IterateDispellableAuras(unit, offensive) do
		if GetSpellInfo(spellID) == spell and expirationTime and (not maxExpirationTime or expirationTime > maxExpirationTime) then
			maxExpirationTime = expirationTime
		end
	end
	if maxExpirationTime then
		local pref = self.db.profile
		return false, nil, pref.countdown, maxExpirationTime, pref.highlight, GetBorderHighlight(offensive, false)
	end
end

------------------------------------------------------------------------------
-- Interrupt
------------------------------------------------------------------------------

local interruptState = addon:NewStateModule("Interrupt") -- L['Interrupt']
interruptState.specialTarget = "foe"
interruptState.keywords = { "INTERRUPTIBLE" }
interruptState.features = { countdown = true, highlight = true }

function interruptState:PostEnable()
	self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', "SpellCastChanged")
	self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', "SpellCastChanged")
	self:RegisterEvent('UNIT_SPELLCAST_START', "SpellCastChanged")
	self:RegisterEvent('UNIT_SPELLCAST_STOP', "SpellCastChanged")
	self:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', "SpellCastChanged")
	self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE', "SpellCastChanged")
end

function interruptState:SpellCastChanged(event, unit)
	if interestingUnits[unit] and self:CanTestUnit(unit) then
		self:Debug('SpellCastChanged', event, unit)
		return addon:AuraChanged(unit)
	end
end

function interruptState:Test(_, unit, _, _, spell)
	local name, _, _, _, _, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
	if not name then
		name, _, _, _, _, endTime, _, notInterruptible = UnitChannelInfo(unit)
	end
	self:Debug('Casting/channelling', name, endTime, notInterruptible)
	if name and endTime and not notInterruptible then
		local pref = self.db.profile
		return false, nil, pref.countdown, endTime/1000, pref.highlight, true
	end
end

------------------------------------------------------------------------------
-- Power state
------------------------------------------------------------------------------

local powerThresholds = {}
if IsClass("MAGE") then
	tinsert(powerThresholds, 40)
end
if IsClass("WARRIOR") or IsClass("HUNTER") then
	tinsert(powerThresholds, 60)
end
if IsClass("DRUID") then
	tinsert(powerThresholds, 80)
end

if #powerThresholds > 0 then

	local keywords = {}
	local tests = {}
	for i, threshold in ipairs(powerThresholds) do
		tinsert(keywords, "PWBELOW"..threshold)
		tinsert(keywords, "PWABOVE"..threshold)
		local threshold = threshold
		tests["PWBELOW"..threshold] = function(value) return value <= threshold end
		tests["PWABOVE"..threshold] = function(value) return value > threshold end
	end

	local powerState = addon:NewStateModule("Power threshold") --L['Power threshold']
	powerState.auraType = "self"
	powerState.keywords = keywords
	powerState.features = {  highlight = true }

	function powerState:PostEnable()
		self:RegisterEvent('UNIT_POWER')
		self:RegisterEvent('UNIT_POWER_MAX', 'UNIT_POWER')
		self:RegisterEvent('UNIT_DISPLAYPOWER')
		self:UNIT_DISPLAYPOWER('PostEnable', 'player')
	end

	function powerState:GetState()
		local current, maxpower = UnitPower("player", self.powerIndex), UnitPowerMax("player", self.powerIndex)
		if current <= 0 or maxpower == 0 then
			return 0
		elseif current >= maxpower then
			return 100
		else
			local pct = 100 * current / maxpower
			for i, threshold in ipairs(powerThresholds) do
				if pct <= threshold then
					return threshold
				end
			end
			return 100
		end
	end

	function powerState:UNIT_DISPLAYPOWER(event, unit)
		if unit == "player" then
			self.powerIndex, self.powerType = UnitPowerType("player")
			return self:UNIT_POWER(event, "player", self.powerType)
		end
	end

	function powerState:UNIT_POWER(event, unit, powerType)
		if unit == "player" and powerType == self.powerType then
			local newState = self:GetState()
			if newState ~= self.state then
				--@debug@
				self:Debug(event, ':', self.state, '=>', newState)
				--@end-debug@
				self.state = newState
				addon:AuraChanged("player")
			end
		end
	end

	function powerState:CanTestUnit(unit)
		return unit == "player"
	end

	function powerState:Test(condition, unit, onlyMyBuffs, onlyMyDebuffs, spell)
		local test = tests[condition]
		return false, nil, false, nil, test and test(self.state), "border"
	end

end
