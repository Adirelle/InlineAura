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

local addonName, ns = ...

------------------------------------------------------------------------------
-- Our main frame
------------------------------------------------------------------------------

local InlineAura = CreateFrame('Frame', 'InlineAura')

------------------------------------------------------------------------------
-- Retrieve the localization table
------------------------------------------------------------------------------

local L = ns.L
InlineAura.L = L

------------------------------------------------------------------------------
-- Locals
------------------------------------------------------------------------------

local db

local unitAuras = {
	player = {},
	target = {},
	pet = {},
	focus = {}
}
local enabledUnits = {
	player = true,
	target = true,
}
local timerFrames = {}
local needUpdate = false
local configUpdated = false
local inVehicle = false

local buttons = {}
local newbuttons = {}
InlineAura.buttons = buttons

------------------------------------------------------------------------------
-- Libraries and helpers
------------------------------------------------------------------------------

local LSM = LibStub('LibSharedMedia-3.0')

local function dprint() end
--@debug@
if tekDebug then
	local frame = tekDebug:GetFrame(addonName)
	dprint = function(...)
		return frame:AddMessage(string.join(", ", tostringall(...)):gsub("([:=]), ", "%1"))
	end
end
--@end-debug@
InlineAura.dprint = dprint

------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------
local FONTMEDIA = LSM.MediaType.FONT

local FONT_NAME = LSM:GetDefault(FONTMEDIA)
local FONT_FLAGS = "OUTLINE"
local FONT_SIZE_SMALL = 13
local FONT_SIZE_LARGE = 20

local DEFAULT_OPTIONS = {
	profile = {
		onlyMyBuffs = true,
		onlyMyDebuffs = true,
		hideCountdown = false,
		hideStack = false,
		showStackAtTop = false,
		preciseCountdown = false,
		decimalCountdownThreshold = 10,
		singleTextPosition = 'BOTTOM',
		twoTextFirstPosition = 'BOTTOMLEFT',
		twoTextSecondPosition = 'BOTTOMRIGHT',
		fontName = FONT_NAME,
		smallFontSize     = FONT_SIZE_SMALL,
		largeFontSize     = FONT_SIZE_LARGE,
		colorBuffMine     = { 0.0, 1.0, 0.0, 1.0 },
		colorBuffOthers   = { 0.0, 1.0, 1.0, 1.0 },
		colorDebuffMine   = { 1.0, 0.0, 0.0, 1.0 },
		colorDebuffOthers = { 1.0, 1.0, 0.0, 1.0 },
		colorCountdown    = { 1.0, 1.0, 1.0, 1.0 },
		colorStack        = { 1.0, 1.0, 0.0, 1.0 },
		spells = {
			['**'] = {
				disabled = false,
				auraType = 'friend',
			},
		},
	},
}
InlineAura.DEFAULT_OPTIONS = DEFAULT_OPTIONS

-- Events only needed if the unit is enabled
local UNIT_EVENTS = {
	pet = 'UNIT_PET',
	focus = 'PLAYER_FOCUS_CHANGED',
}

-- Units to scan (and in which order) depending on the aura type
local UNITS_TO_SCAN_BY_TYPE = {
	enemy = { 'focus', 'target' },
	friend = { 'focus', 'target', 'player' },
	self = { 'player' },
	special = { 'player' },
	pet = { 'pet' },
}

-- All units we work with
local ALL_UNITS = { 'focus', 'target', 'pet', 'player' } 

------------------------------------------------------------------------------
-- Table recycling stub
------------------------------------------------------------------------------

local new, del
do
	local heap = setmetatable({}, {__mode='k'})
	function new()
		local t = next(heap)
		if t then
			heap[t] = nil
		else
			t = {}
		end
		return t
	end
	function del(t)
		if type(t) == "table" then
			wipe(t)
			heap[t] = true
		end
	end
end
InlineAura.new, InlineAura.del = new, del

------------------------------------------------------------------------------
-- Some Unit helpers
------------------------------------------------------------------------------

local UnitCanAssist, UnitCanAttack, UnitIsUnit = UnitCanAssist, UnitCanAttack, UnitIsUnit

local MY_UNITS = { player = true, pet = true, vehicle = true }

-- These two functions return nil when unit does not exist
local UnitIsBuffable = function(unit) return MY_UNITS[unit] or UnitCanAssist('player', unit) end
local UnitIsDebuffable = function(unit) return UnitCanAttack('player', unit) end

local origUnitAura = _G.UnitAura
local UnitAura = function(...)
	local name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellId = origUnitAura(...)
	return name, rank, icon, count, debuffType, duration, expirationTime, MY_UNITS[caster or "none"], isStealable, shouldConsolidate, spellId
end

-- This is meant to be hooked by conditional parts
function InlineAura:SetupHook() end

------------------------------------------------------------------------------
-- Aura monitoring core
------------------------------------------------------------------------------

local function WipeAuras(auras)
	if next(auras) then
		for name,aura in pairs(auras) do
			del(aura)
		end
		wipe(auras)
		needUpdate = true
	end
end

local auraScanners = {}
InlineAura.auraScanners = auraScanners

local UpdateUnitAuras
do
	local serial = 0
	local callbacks = setmetatable({}, {__mode='k'})
	function UpdateUnitAuras(unit, event)
		local auras
		if inVehicle and (unit == 'player' or unit == 'vehicle') then
			unit = 'vehicle'
			auras = unitAuras.player
		else
			auras = unitAuras[unit]
		end
		serial = (serial + 1) % 1000000

		-- Avoid recreating callback on every call
		local now = GetTime()
		local callback = callbacks[auras]
		if not callback then
			callback = function(name, count, duration, expirationTime, isMine, filter, spellId)
				if not count or count == 0 then
					count = nil
				end
				duration, expirationTime, isMine = tonumber(duration) or 0, tonumber(expirationTime) or 0, not not isMine
				if expirationTime > 0 and expirationTime < now then return end
				local data = auras[name]
				if not data then
					data = new()
					auras[name] = data
					needUpdate = true
					--@debug@
					dprint('New aura', unit, name)
					--@end-debug@
				elseif data.serial == serial and data.isMine and not isMine then
					-- Do not overwrite player's auras by others' auras when they have already seen during this scan
					data = nil
				elseif expirationTime ~= data.expirationTime or count ~= data.count or isMine ~= data.isMine then
					needUpdate = true
					--@debug@
					dprint('Updating aura', unit, name)
					--@end-debug@
				end
				if data then
					data.serial = serial
					data.count = count
					data.duration = duration
					data.expirationTime = expirationTime
					data.isMine = isMine
					data.type = (filter == "HARMFUL") and "Debuff" or "Buff"
					if spellId then
						auras['#'..spellId] = data
					end
				end
			end
			callbacks[auras] = callback
		end

		-- Give every scanner a try
		for index, scan in ipairs(auraScanners) do
			local ok, msg = pcall(scan, callback, unit)
			if not ok then
				geterrorhandler()(msg)
			end
		end

		-- Remove auras that have faded out
		for name, data in pairs(auras) do
			if not data.serial or data.serial ~= serial then
				auras[name] = del(auras[name])
				needUpdate = true
				--@debug@
				dprint('Removing aura', unit, name)
				--@end-debug@
			end
		end
	end
	InlineAura.UpdateUnitAuras = UpdateUnitAuras
end

------------------------------------------------------------------------------
-- Aura scanners
------------------------------------------------------------------------------

-- This scanner scans all auras
do
	local function ScanAuras(callback, unit, filter)
		local i = 1
		repeat
			local name, _, _, count, _, duration, expirationTime, isMine, _, _, spellId = UnitAura(unit, i, filter)
			if name then
				callback(name, count, duration, expirationTime, isMine, filter, spellId)
				i = i + 1
			end
		until not name
	end

	tinsert(auraScanners, function(callback, unit)
		ScanAuras(callback, unit, "HELPFUL")
		ScanAuras(callback, unit, "HARMFUL")
	end)
end

-- This scanner handles tracking as player self buff
tinsert(auraScanners, function(callback, unit)
	if unit ~= 'player' then return end
	for i = 1, GetNumTrackingTypes() do
		local name, _, active, category = GetTrackingInfo(i)
		if active and category == 'spell' then
			callback(name, 0, nil, nil, true, "HELPFUL")
		end
	end
end)
function InlineAura:MINIMAP_UPDATE_TRACKING(event)
	UpdateUnitAuras("player", event)
end
InlineAura:RegisterEvent('MINIMAP_UPDATE_TRACKING')

local keywords = {}
InlineAura.keywords = keywords
local KEYWORD_EVENTS = {}

local _, playerClass = UnitClass("player")

-- Shaman totem support
if playerClass == "SHAMAN" then
	--@debug@
	dprint("watching totems")
	--@end-debug@
	local GetTotemInfo = GetTotemInfo

	tinsert(auraScanners, function(callback, unit)
		if unit ~= 'player' then return end
		for i = 1, MAX_TOTEMS do
			local haveTotem, name, startTime, duration = GetTotemInfo(i)
			if haveTotem and name and name ~= "" then
				name = name:gsub("%s[IVX]-$", "") -- Whoever proposed to use roman numerals in enchant names should be shot
				callback(name, 0, duration, startTime+duration, true, "HELPFUL")
			end
		end
	end)

	function InlineAura:PLAYER_TOTEM_UPDATE(event)
		UpdateUnitAuras("player", event)
	end
	InlineAura:RegisterEvent('PLAYER_TOTEM_UPDATE')

-- Warlock Soul Shards and Paladin Holy Power
elseif playerClass == "WARLOCK" or playerClass == "PALADIN" then
	local UnitPower = UnitPower
	
	local POWER_TYPE, POWER_NAME
	if playerClass == "WARLOCK" then
		POWER_TYPE, POWER_NAME = SPELL_POWER_SOUL_SHARDS, "SOUL_SHARDS" -- L["SOUL_SHARDS"]
	else
		POWER_TYPE, POWER_NAME = SPELL_POWER_HOLY_POWER, "HOLY_POWER"
	end
	keywords[POWER_NAME] = true
	KEYWORD_EVENTS[POWER_NAME] = "UNIT_POWER"
	--@debug@
	dprint("watching", POWER_NAME)
	--@end-debug@
	
	tinsert(auraScanners, function(callback, unit)
		if unit ~= 'player' then return end
		-- name, count, duration, expirationTime, isMine, spellId
		callback(POWER_NAME, UnitPower("player", POWER_TYPE) or 0, nil, nil, true, "HELPFUL")
	end)

	function InlineAura:UNIT_POWER(event, unit, type)
		if unit == "player" and type == POWER_NAME then
			return UpdateUnitAuras("player", event)
		end
	end
end
	
-- Rogue and Kitty combo points
if playerClass == "ROGUE" or playerClass == "DRUID" then
	--@debug@
	dprint("watching combo points")
	--@end-debug@
	local GetComboPoints = GetComboPoints
	keywords.COMBO_POINTS = true -- L["COMBO_POINTS"]
	KEYWORD_EVENTS.COMBO_POINTS = "PLAYER_COMBO_POINTS"	
	
	tinsert(auraScanners, function(callback, unit)
		if unit ~= 'player' then return end
		-- name, count, duration, expirationTime, isMine, spellId
		callback("COMBO_POINTS", GetComboPoints("player"), nil, nil, true, "HELPFUL")
	end)
		
	function InlineAura:PLAYER_COMBO_POINTS(event, unit)
		return UpdateUnitAuras("player", event)
	end	
end

-- Moonkin eclipse points
if playerClass == "DRUID" then
	--@debug@
	dprint("watching eclipse energy")
	--@end-debug@
	local SPELL_POWER_ECLIPSE = SPELL_POWER_ECLIPSE
	local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
	local GetEclipseDirection = GetEclipseDirection
	local GetPrimaryTalentTree = GetPrimaryTalentTree
	
	local isMoonkin, direction, power
	keywords.LUNAR_ENERGY = true
	keywords.SOLAR_ENERGY = true
	KEYWORD_EVENTS.LUNAR_ENERGY = "PLAYER_TALENT_UPDATE"
	KEYWORD_EVENTS.SOLAR_ENERGY = "PLAYER_TALENT_UPDATE"
	
	tinsert(auraScanners, function(callback, unit)
		if unit ~= 'player' or not isMoonkin or not direction or not power then return end		
		if direction == "moon" then
			callback("LUNAR_ENERGY", -power, nil, nil, true, "HELPFUL")
		else
			callback("SOLAR_ENERGY", power, nil, nil, true, "HELPFUL")
		end
	end)
	function InlineAura:UNIT_POWER(event, unit, type)
		if unit == "player" and type == "ECLIPSE" then
			local newPower = math.ceil(100 * UnitPower("player", SPELL_POWER_ECLIPSE) / UnitPowerMax("player", SPELL_POWER_ECLIPSE))
			if newPower ~= power then
				power = newPower
				if event == "UNIT_POWER" then
					return UpdateUnitAuras("player", event)	
				end
			end
		end
	end
	function InlineAura:ECLIPSE_DIRECTION_CHANGE(event)
		local newDirection = GetEclipseDirection()
		if newDirection ~= direction then
			direction = newDirection
			if event == "ECLIPSE_DIRECTION_CHANGE" then
				return UpdateUnitAuras("player", event)			
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
			return UpdateUnitAuras("player", event)	
		end
	end
end

------------------------------------------------------------------------------
-- Countdown formatting
------------------------------------------------------------------------------

local floor, ceil = math.floor, math.ceil

local function GetPreciseCountdownText(timeLeft, threshold)
	if timeLeft >= 3600 then
		return L["%dh"]:format(floor(timeLeft/3600)), 1 + floor(timeLeft) % 3600
	elseif timeLeft >= 600 then
		return L["%dm"]:format(floor(timeLeft/60)), 1 + floor(timeLeft) % 60
	elseif timeLeft >= 60 then
		return ("%d:%02d"):format(floor(timeLeft/60), floor(timeLeft%60)), timeLeft % 1
	elseif timeLeft >= threshold then
		return tostring(floor(timeLeft)), timeLeft % 1
	elseif timeLeft >= 0 then
		return ("%.1f"):format(floor(timeLeft*10)/10), 0
	else
		return "0"
	end
end

local function GetImpreciseCountdownText(timeLeft)
	if timeLeft >= 3600 then
		return L["%dh"]:format(ceil(timeLeft/3600)), ceil(timeLeft) % 3600
	elseif timeLeft >= 60 then
		return L["%dm"]:format(ceil(timeLeft/60)), ceil(timeLeft) % 60
	elseif timeLeft > 0 then
		return tostring(floor(timeLeft)), timeLeft % 1
	else
		return "0"
	end
end

local function GetCountdownText(timeLeft, precise, threshold)
	return (precise and GetPreciseCountdownText or GetImpreciseCountdownText)(timeLeft, threshold)
end

------------------------------------------------------------------------------
-- Home-made bucketed timers
------------------------------------------------------------------------------
-- This is mainly a simplified version of AceTimer-3.0, credits goes to Ace3 authors

local ScheduleTimer, CancelTimer, FireTimers, TimerCallback
do
	local BUCKETS = 131
	local HZ = 20
	local buckets = {}
	local targets = {}
	for i = 1, BUCKETS do buckets[i] = {} end

	local lastIndex = floor(GetTime()*HZ)

	function ScheduleTimer(target, delay)
		assert(target and type(delay) == "number" and delay >= 0)
		if targets[target] then
			buckets[targets[target]][target] = nil
		end
		local when = GetTime() + delay
		local index = floor(when*HZ) + 1
		local bucketNum = 1 + (index % BUCKETS)
		buckets[bucketNum][target] = when
		targets[target] = bucketNum
	end

	function CancelTimer(target)
		assert(target)
		local bucketNum = targets[target]
		if bucketNum then
			buckets[bucketNum][target] = nil
			targets[target] = nil
		end
	end

	function ProcessTimers()
		local now = GetTime()
		local newIndex = floor(now*HZ)
		for index = lastIndex + 1, newIndex do
			local bucketNum = 1 + (index % BUCKETS)
			local bucket = buckets[bucketNum]
			for target, when in pairs(bucket) do
				if when <= now then
					bucket[target] = nil
					targets[target] = nil
					TimerCallback(target)
				end
			end
		end
		lastIndex = newIndex
	end
end

------------------------------------------------------------------------------
-- Timer frame handling
------------------------------------------------------------------------------

local TimerFrame_OnUpdate, TimerFrame_Skin, TimerFrame_Display, TimerFrame_UpdateCountdown

local function SetTextPosition(text, position)
	text:SetJustifyH(position:match('LEFT') or position:match('RIGHT') or 'MIDDLE')
	text:SetJustifyV(position:match('TOP') or position:match('BOTTOM') or 'CENTER')
end

function TimerFrame_UpdateTextLayout(self)
	local stackText, countdownText = self.stackText, self.countdownText
	if countdownText:IsShown() and stackText:IsShown() then
		SetTextPosition(countdownText, InlineAura.db.profile.twoTextFirstPosition)
		SetTextPosition(stackText, InlineAura.db.profile.twoTextSecondPosition)
	elseif countdownText:IsShown() then
		SetTextPosition(countdownText, InlineAura.db.profile.singleTextPosition)
	elseif stackText:IsShown() then
		SetTextPosition(stackText, InlineAura.db.profile.singleTextPosition)
	end
end

function TimerFrame_Skin(self)
	local font = LSM:Fetch(FONTMEDIA, db.profile.fontName)

	local countdownText = self.countdownText
	countdownText.fontName = font
	countdownText.baseFontSize = db.profile[InlineAura.bigCountdown and "largeFontSize" or "smallFontSize"]
	countdownText:SetFont(font, countdownText.baseFontSize, FONT_FLAGS)
	countdownText:SetTextColor(unpack(db.profile.colorCountdown))

	local stackText = self.stackText
	stackText:SetFont(font, db.profile.smallFontSize, FONT_FLAGS)
	stackText:SetTextColor(unpack(db.profile.colorStack))

	TimerFrame_UpdateTextLayout(self)
end

function TimerFrame_OnUpdate(self)
	TimerFrame_UpdateCountdown(self, GetTime())
end

-- Compat
TimerFrame_CancelTimer = CancelTimer
TimerCallback = TimerFrame_OnUpdate

function TimerFrame_UpdateCountdown(self, now)
	local timeLeft = self.expirationTime - now
	local displayTime, delay = GetCountdownText(timeLeft, db.profile.preciseCountdown, db.profile.decimalCountdownThreshold)
	self.countdownText:SetText(displayTime)
	if delay then
		ScheduleTimer(self, math.min(delay, timeLeft))
	end
end

function TimerFrame_Display(self, expirationTime, count, now, hideCountdown)
	local stackText, countdownText = self.stackText, self.countdownText

	if count then
		stackText:SetText(count)
		stackText:Show()
	else
		stackText:Hide()
	end

	if not hideCountdown and expirationTime then
		self.expirationTime = expirationTime
		TimerFrame_UpdateCountdown(self, now)
		countdownText:Show()
		countdownText:SetFont(countdownText.fontName, countdownText.baseFontSize, FONT_FLAGS)
		local sizeRatio = countdownText:GetStringWidth() / (self:GetWidth()-4)
		if sizeRatio > 1 then
			countdownText:SetFont(countdownText.fontName, countdownText.baseFontSize / sizeRatio, FONT_FLAGS)
		end
	else
		TimerFrame_CancelTimer(self)
		countdownText:Hide()
	end
	
	if stackText:IsShown() or countdownText:IsShown() then
		self:Show()
		TimerFrame_UpdateTextLayout(self)
	else
		self:Hide()
	end
end

local function CreateTimerFrame(button)
	local timer = CreateFrame("Frame", nil, button)
	local cooldown = _G[button:GetName()..'Cooldown']
	timer:SetFrameLevel(cooldown:GetFrameLevel() + 5)
	timer:SetAllPoints(cooldown)
	timer:SetToplevel(true)
	timer:Hide()
	timer:SetScript('OnHide', TimerFrame_CancelTimer)
	timerFrames[button] = timer

	local countdownText = timer:CreateFontString(nil, "OVERLAY")
	countdownText:SetAllPoints(timer)
	countdownText:Show()
	timer.countdownText = countdownText

	local stackText = timer:CreateFontString(nil, "OVERLAY")
	stackText:SetAllPoints(timer)
	timer.stackText = stackText

	TimerFrame_Skin(timer)

	return timer
end

------------------------------------------------------------------------------
-- Aura lookup
------------------------------------------------------------------------------

local function GetTristateValue(value, default)
	if value ~= nil then
		return value
	else
		return default
	end
end

local function CheckAura(auras, name, onlyMyBuffs, onlyMyDebuffs)
	local aura = auras[name]
	if aura and (aura.isMine or not ((aura.type == "Buff" and onlyMyBuffs) or (aura.type == "Debuff" and onlyMyDebuffs))) then
		return aura
	end
end

local function LookupAura(auras, spell, aliases, onlyMine, ...)
	local onlyMyBuffs = GetTristateValue(onlyMine, InlineAura.db.profile.onlyMyBuffs)
	local onlyMyDebuffs = GetTristateValue(onlyMine, InlineAura.db.profile.onlyMyDebuffs)
	local aura = CheckAura(auras, spell, onlyMyBuffs, onlyMyDebuffs)
	if not aura and aliases then
		for i, alias in ipairs(aliases) do
			aura = CheckAura(auras, alias, onlyMyBuffs, onlyMyDebuffs)
			if aura then
				break
			end
		end
	end
	if aura then
		return aura, aura.type, ...
	end
end

local function GetAuraToDisplay(spell)
	local specific = rawget(db.profile.spells, spell) -- Bypass AceDB auto-creation
	if type(specific) == 'table' then
		if specific.disabled then
			return
		end
		local auraType = specific.auraType
		local hideStack = GetTristateValue(specific.hideStack, db.profile.hideStack)
		local hideCountdown = GetTristateValue(specific.hideCountdown, db.profile.hideCountdown)
		if auraType == "self" then -- Self auras
			return LookupAura(unitAuras.player, spell, specific.aliases, true, hideStack, hideCountdown, specific.alternateColor)
		elseif auraType == "special" then -- Special display
			return LookupAura(unitAuras.player, spell, specific.aliases, true, false, false, false)		
		elseif auraType == "pet" then -- Pet auras
			if UnitExists("pet") then
				return LookupAura(unitAuras.pet, spell, specific.aliases, specific.onlyMine, hideStack, hideCountdown, specific.alternateColor)
			end
		else -- Friend or enemy
			local buffTest = (auraType == "enemy") and UnitIsDebuffable or UnitIsBuffable
			for i, unit in ipairs(UNITS_TO_SCAN_BY_TYPE[auraType]) do
				if enabledUnits[unit] and buffTest(unit) then
					return LookupAura(unitAuras[unit], spell, specific.aliases, specific.onlyMine, hideStack, hideCountdown, specific.alternateColor)
				end
			end
		end
	else
		if UnitIsBuffable('target') then
			return LookupAura(unitAuras.target, spell, nil, 'Buff', db.profile.onlyMyBuffs, db.profile.hideStack, db.profile.hideCountdown)
		elseif UnitIsDebuffable('target') then
			local aura, auraType = LookupAura(unitAuras.target, spell, nil, 'Debuff', db.profile.onlyMyDebuffs, db.profile.hideStack, db.profile.hideCountdown)
			if aura then
				return aura, auraType, db.profile.hideStack
			end
		end
		return LookupAura(unitAuras.player, spell, nil, 'Buff', db.profile.onlyMyBuffs, db.profile.hideStack, db.profile.hideCountdown)
	end
end

------------------------------------------------------------------------------
-- Visual feedback
------------------------------------------------------------------------------

local function UpdateTimer(self, aura, hideStack, hideCountdown)
	if aura and aura.serial and not (hideCountdown and hideStack) then
		local now = GetTime()
		local expirationTime = aura.expirationTime
		if expirationTime and expirationTime <= now then
			expirationTime = nil
		end
		local count = not hideStack and aura.count
		if count and count == 0 then
			count = nil
		end
		if expirationTime or count then
			local frame = timerFrames[self] or CreateTimerFrame(self)
			return TimerFrame_Display(frame, expirationTime, count, now, hideCountdown)
		end
	end
	if timerFrames[self] then
		timerFrames[self]:Hide()
	end
end

local function SetVertexColor(texture, r, g, b, a)
	texture:SetVertexColor(r, g, b, a)
end

local IsSpellOverlayed = IsSpellOverlayed
local ActionButton_ShowOverlayGlow = ActionButton_ShowOverlayGlow
local ActionButton_HideOverlayGlow = ActionButton_HideOverlayGlow

local function GetSpellId(type, data)
	if type == 'action' then
		type, data = GetActionInfo(data)
	end
	if type == 'spell' then
		return data
	elseif type == 'macro' then
		return GetMacroSpell(data)
	elseif type == 'item' then
		return GetItemSpell(data)
	end
end

local function SafeUpdateOverlayGlow(self)
	local spellId = GetSpellId(self:__IA_GetAction())
	if tonumber(spellId) and IsSpellOverlayed(spellId) then
		ActionButton_ShowOverlayGlow(self)
		return true
	else
		ActionButton_HideOverlayGlow(self)
	end
end

local function UpdateHighlight(self, aura, color, alternate)
	local texture = self:GetCheckedTexture()
	if aura and aura.expirationTime and aura.expirationTime > GetTime() then
		if alternate then
			ActionButton_ShowOverlayGlow(self)
		elseif not SafeUpdateOverlayGlow(self) then
			SetVertexColor(texture, unpack(color))
			self:__IA_SetChecked(true)
		end
	else
		SafeUpdateOverlayGlow(self)
		texture:SetVertexColor(1, 1, 1)
		local type, data = self:__IA_GetAction()
		if type == "action" and data then
			self:__IA_SetChecked(IsCurrentAction(data) or IsAutoRepeatAction(data))
		end
	end
end

------------------------------------------------------------------------------
-- LibButtonFacade compatibility
------------------------------------------------------------------------------

local function LBF_SetVertexColor(texture, r, g, b, a)
	local R, G, B, A = texture:GetVertexColor()
	texture:SetVertexColor(r*R, g*G, b*B, a*(A or 1))
end

local function LBF_Callback()
	configUpdated = true
end

------------------------------------------------------------------------------
-- Our core
------------------------------------------------------------------------------

local spellNames = setmetatable({}, {__index = function(t, id)
	local numId = tonumber(id)
	if numId then
		local name = GetSpellInfo(numId)
		if name then
			t[id] = name
			return name
		end
	end
	return id
end})

local function UpdateButton(self)
	if not self:IsVisible() or not buttons[self] then return end
	local spell = spellNames[GetSpellId(self:__IA_GetAction())]
	local aura, auraType, color, hideStack, hideCountdown, alternateColor
	if spell then
		aura, auraType, hideStack, hideCountdown, alternateColor = GetAuraToDisplay(spell)		
		if aura and not alternateColor then
			color = db.profile['color'..auraType..(aura.isMine and 'Mine' or 'Others')]
		end
	end
	UpdateHighlight(self, aura, color, alternateColor)
	UpdateTimer(self, aura, hideStack, hideCountdown)
end

local function Blizzard_GetAction(self)
	return 'action', ActionButton_GetPagedID(self)
end

local function InitializeButton(self)
	if buttons[self] then return end
	buttons[self] = true
	self.__IA_SetChecked = self.SetChecked
	if self.__LAB_Version then
		--@debug@
		dprint("Initializing LAB button", self:GetName(), "v", self.__LAB_Version)
		--@end-debug@
		self.__IA_GetAction = self.GetAction
		hooksecurefunc(self, 'SetChecked', UpdateButton)
	else
		self.__IA_GetAction = Blizzard_GetAction
	end
end

------------------------------------------------------------------------------
-- Button hooks
------------------------------------------------------------------------------

local function ActionButton_OnLoad_Hook(self)
	if not buttons[self] and not newbuttons[self] then
		newbuttons[self] = true
		needUpdate = true
	end
end

local function ActionButton_Update_Hook(self)
	if not buttons[self] then
		newbuttons[self] = true
		needUpdate = true
		return
	else
		return UpdateButton(self)
	end
end

------------------------------------------------------------------------------
-- Button updates
------------------------------------------------------------------------------

local UpdateUnitListeners
do
	local function IsEnabledUnit(unit)
		for name, spell in pairs(db.profile.spells) do
			if type(spell) == "table" and not spell.disabled then
				for i, spellUnit in pairs(UNITS_TO_SCAN_BY_TYPE[spell.auraType]) do
					if spellUnit == unit then
						return true
					end
				end
			end
		end
	end
	function UpdateUnitListeners()
		for i, unit in pairs(ALL_UNITS) do
			local event = UNIT_EVENTS[unit]
			local found = IsEnabledUnit(unit)
			enabledUnits[unit] = found
			if found then
				if event then
					InlineAura:RegisterEvent(event)
				end				
			else
				if event then
					InlineAura:UnregisterEvent(event)
				end				
				WipeAuras(unitAuras[unit])
			end
		end
	end
end

local UpdateKeywordListeners
do
	local t ={}
	function UpdateKeywordListeners()
		wipe(t)
		for keyword, event in pairs(KEYWORD_EVENTS) do
			t[event] = false
		end
		for name, spell in pairs(db.profile.spells) do
			if not spell.disabled and spell.aliases then
				for i, alias in pairs(spell.aliases) do
					local event = KEYWORD_EVENTS[alias]
					if event then
						--@debug@
						dprint("Have to listen for", event, "for keyword", alias, "for spell", name)
						--@end-debug@
						t[event] = true
					end
				end
			end
		end
		for event, enabled in pairs(t) do
			if enabled then
				if not InlineAura:IsEventRegistered(event) then
					--@debug@
					dprint("Starting listening for", event)
					--@end-debug@
					InlineAura:RegisterEvent(event)
					InlineAura[event](InlineAura, "UpdateKeywordListeners")
				end
			elseif InlineAura:IsEventRegistered(event) then
				--@debug@
				dprint("Stopping listening for", event)
				--@end-debug@
				InlineAura:UnregisterEvent(event)
				InlineAura[event](InlineAura, "UpdateKeywordListeners")
			end
		end
	end
end

local enabledEvents = {}
function InlineAura:OnUpdate()
	if configUpdated then
		-- Update event listening based on units
		UpdateUnitListeners()
		-- Update event listening based on keywords
		UpdateKeywordListeners()
		-- Update all auras
		for unit in pairs(enabledUnits) do
			UpdateUnitAuras(unit)
		end
		-- Update timer skins
		for button, timerFrame in pairs(timerFrames) do
			TimerFrame_Skin(timerFrame)
		end
	end
	if needUpdate or configUpdated then
		if next(newbuttons) then
			-- Handle new buttons
			for button in pairs(newbuttons) do
				InitializeButton(button)
			end
			wipe(newbuttons)
		end
		-- Update buttons
		for button in pairs(buttons) do
			UpdateButton(button)
		end
		needUpdate, configUpdated = false, false
	end
	ProcessTimers()
end

function InlineAura:RequireUpdate(config)
	configUpdated = config
	needUpdate = true
end

function InlineAura:RegisterButtons(prefix, count)
	for id = 1, count do
		local button = _G[prefix .. id]
		if button and not buttons[button] and not newbuttons[button] then
			newbuttons[button] = true
			needUpdate = true
		end
	end
end

------------------------------------------------------------------------------
-- Event handling
------------------------------------------------------------------------------

function InlineAura:UNIT_ENTERED_VEHICLE(event, unit)
	if unit == 'player' then
		inVehicle = (event == 'UNIT_ENTERED_VEHICLE')
		UpdateUnitAuras('player', event)
	end
end

InlineAura.UNIT_EXITED_VEHICLE = InlineAura.UNIT_ENTERED_VEHICLE

function InlineAura:UNIT_AURA(event, unit)
	if enabledUnits[unit] or (unit == 'vehicle' and inVehicle) then
		UpdateUnitAuras(unit, event)
	end
end

function InlineAura:UNIT_PET(event, unit)
	if unit == 'player' then
		UpdateUnitAuras('pet', event)
		needUpdate = true
	end
end

function InlineAura:PLAYER_ENTERING_WORLD(event)
	inVehicle = not not UnitControllingVehicle('player')
	for unit in pairs(enabledUnits) do
		UpdateUnitAuras(unit, event)
	end
end

function InlineAura:PLAYER_FOCUS_CHANGED(event)
	UpdateUnitAuras('focus', event)
	needUpdate = true
end

function InlineAura:PLAYER_TARGET_CHANGED(event)
	UpdateUnitAuras('target', event)
	needUpdate = true
end

function InlineAura:VARIABLES_LOADED()
	self.VARIABLES_LOADED = nil
	self:UnregisterEvent('VARIABLES_LOADED')
		
	-- ButtonFacade support
	local LBF = LibStub('LibButtonFacade', true)
	local LBF_RegisterCallback = function() end
	if LBF then
		SetVertexColor = LBF_SetVertexColor
		LBF:RegisterSkinCallback("Blizzard", LBF_Callback)
	end
	-- Miscellanous addon support
	if Dominos then
		self:RegisterButtons("DominosActionButton", 72)
		hooksecurefunc(Dominos.ActionButton, "Skin", ActionButton_OnLoad_Hook)
		if LBF then
			LBF:RegisterSkinCallback("Dominos", LBF_Callback)
		end
	end
	if Bartender4 then
		self:RegisterButtons("BT4Button", 120)
		if LBF then
			LBF:RegisterSkinCallback("Bartender4", LBF_Callback)
		end
	end
	if OmniCC or CooldownCount then
		InlineAura.bigCountdown = false
	end
	local LAB, LAB_version = LibStub("LibActionButton-1.0", true)
	if LAB then
		--@debug@
		dprint("Found LibActionButton-1.0 version", LAB_version)
		--@end-debug@
		hooksecurefunc(LAB, "CreateButton", function(_, id, name, header, config)
			local button = name and _G[name]
			if button then
				ActionButton_OnLoad_Hook(button)
			end
		end)
	end
	
	-- Do nothing, unless it's been hooked
	self:SetupHook()

	-- Refresh everything
	self:RequireUpdate(true)

	-- Our bucket thingy
	self:SetScript('OnUpdate', self.OnUpdate)

	-- Scan unit in case of delayed loading
	if IsLoggedIn() then
		self:PLAYER_ENTERING_WORLD()
	end
end

function InlineAura:ADDON_LOADED(event, name)
	if name ~= addonName then return end
	self:UnregisterEvent('ADDON_LOADED')
	self.ADDON_LOADED = nil

	-- Retrieve default spell values
	self:LoadDefaults()

	-- Saved variables setup
	db = LibStub('AceDB-3.0'):New("InlineAuraDB", DEFAULT_OPTIONS)
	db.RegisterCallback(self, 'OnProfileChanged', 'RequireUpdate')
	db.RegisterCallback(self, 'OnProfileCopied', 'RequireUpdate')
	db.RegisterCallback(self, 'OnProfileReset', 'RequireUpdate')
	self.db = db

	LibStub('LibDualSpec-1.0'):EnhanceDatabase(db, "Inline Aura")
	
	-- Update the database from previous versions
	for name, spell in pairs(db.profile.spells) do
		if type(spell) == "table" then
			local units = spell.unitsToScan
			if type(units) ~= "table" then units = nil end
			local auraType = spell.auraType
			if auraType == "buff" then
				if units and units.pet then
					auraType = "pet"
				elseif units and not units.target and not units.focus then
					auraType = "self"
				else
					auraType = "friend"
				end
			elseif auraType == "debuff" then
				auraType = "enemy"
			end
			if spell.auraType ~= auraType then
				spell.auraType = auraType
				spell.unitsToScan = nil
			end
		end
	end

	-- Setup
	self.bigCountdown = true

	-- Setup basic event listening up
	self:RegisterEvent('UNIT_AURA')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('UNIT_ENTERED_VEHICLE')
	self:RegisterEvent('UNIT_EXITED_VEHICLE')

	if IsLoggedIn() then
		self:VARIABLES_LOADED()
	else
		self:RegisterEvent('VARIABLES_LOADED')
	end

	-- standard buttons
	self:RegisterButtons("ActionButton", 12)
	self:RegisterButtons("BonusActionButton", 12)
	self:RegisterButtons("MultiBarRightButton", 12)
	self:RegisterButtons("MultiBarLeftButton", 12)
	self:RegisterButtons("MultiBarBottomRightButton", 12)
	self:RegisterButtons("MultiBarBottomLeftButton", 12)

	-- Hooks
	hooksecurefunc('ActionButton_OnLoad', ActionButton_OnLoad_Hook)
	hooksecurefunc('ActionButton_UpdateState', UpdateButton)
	hooksecurefunc('ActionButton_Update', ActionButton_Update_Hook)
	hooksecurefunc('ActionButton_ShowOverlayGlow', UpdateButton)
	hooksecurefunc('ActionButton_HideOverlayGlow', UpdateButton)
end

-- Event handler
InlineAura:SetScript('OnEvent', function(self, event, ...)
	if type(self[event]) == 'function' then
		local success, msg = pcall(self[event], self, event, ...)
		if not success then
			geterrorhandler()(msg)
		end
	--@debug@
	else
		dprint('InlineAura: registered event has no handler: '..event)
	--@end-debug@
	end
end)

-- Initialize on ADDON_LOADED
InlineAura:RegisterEvent('ADDON_LOADED')

------------------------------------------------------------------------------
-- Configuration GUI loader
------------------------------------------------------------------------------

local function LoadConfigGUI()
	LoadAddOn('InlineAura_Config')
end

-- Chat command line
SLASH_INLINEAURA1 = "/inlineaura"
function SlashCmdList.INLINEAURA()
	LoadConfigGUI()
	InterfaceOptionsFrame_OpenToCategory(L['Inline Aura'])
end

-- InterfaceOptionsFrame spy
CreateFrame("Frame", nil, InterfaceOptionsFrameAddOns):SetScript('OnShow', LoadConfigGUI)
