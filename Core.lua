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
	focus = {},
	mouseover = {},
}
local unitGUIDs = {}
local auraChanged = {}
local enabledUnits = {
	player = true,
	target = true,
}
local timerFrames = {}
local needUpdate = false
local configUpdated = false
local inVehicle = false

local buttons = {}
local newButtons = {}
local activeButtons = {}
InlineAura.buttons = buttons

------------------------------------------------------------------------------
-- Libraries and helpers
------------------------------------------------------------------------------

local LSM = LibStub('LibSharedMedia-3.0')

local function dprint() end
--@debug@
if tekDebug then
	local frame = tekDebug:GetFrame(addonName)
	local type, tostring, format = type, tostring, format
	local function mytostringall(a, ...)
		local str
		if type(a) == "table" and type(a.GetName) == "function" then
			str = format("|cffff8844[%s]|r", tostring(a:GetName()))
		else
			str = tostring(a)
		end
		if select('#', ...) > 0 then
			return str, mytostringall(...)
		else
			return str
		end
	end
	dprint = function(...)
		return frame:AddMessage(strjoin(" ", mytostringall(...)))
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
		customOrder = false,
		friendOrdering = "target,player",
		enemyOrdering = "target",
	},
}
InlineAura.DEFAULT_OPTIONS = DEFAULT_OPTIONS

-- Events only needed if the unit is enabled
local UNIT_EVENTS = {
	pet = 'UNIT_PET',
	focus = 'PLAYER_FOCUS_CHANGED',
	mouseover = 'UPDATE_MOUSEOVER_UNIT',
}

-- Units to scan (and in which order) depending on the aura type
local UNITS_TO_SCAN_BY_TYPE = {
	enemy = { 'mouseover', 'focus', 'target' },
	friend = { 'mouseover', 'focus', 'target', 'player' },
	self = { 'player' },
	special = { 'player' },
	pet = { 'pet' },
}

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

local function WipeAuras(unit)
	local auras = unitAuras[unit]
	if next(auras) then
		for name,aura in pairs(auras) do
			if name ~= "__GUID" then
				auras[name] = del(aura)
			end
		end
		unitGUIDs[unit] = nil
		auraChanged[unit] = true
		--@debug@
		dprint("Wiped", unit, "auras")
		--@end-debug@
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
		
		local guid = UnitGUID(unit)
		if unitGUIDs[unit] ~= guid then
			WipeAuras(unit)
		end

		if UnitExists(unit) then
			unitGUIDs[unit] = guid
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
						auraChanged[unit] = true
						--@debug@
						dprint('New aura', unit, name)
						--@end-debug@
					elseif data.serial == serial and data.isMine and not isMine then
						-- Do not overwrite player's auras by others' auras when they have already seen during this scan
						data = nil
					elseif expirationTime ~= data.expirationTime or count ~= data.count or isMine ~= data.isMine then
						auraChanged[unit] = true
						--@debug@
						dprint('Updating aura', unit, name)
						--@end-debug@
					end
					if data then
						data.name = name
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
					auraChanged[unit] = true
					--@debug@
					dprint('Removing aura', unit, name)
					--@end-debug@
				end
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
-- LibButtonFacade compatibility
------------------------------------------------------------------------------

local function SetVertexColor(texture, r, g, b, a)
	texture:SetVertexColor(r, g, b, a)
end

local function LBF_SetVertexColor(texture, r, g, b, a)
	local R, G, B, A = texture:GetVertexColor()
	texture:SetVertexColor(r*R, g*G, b*B, a*(A or 1))
end

local function LBF_Callback()
	configUpdated = true
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
		return aura, ...
	end
end

local function GetAuraToDisplay(spell, target)
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
			--[[
		else -- Friend or enemy
			local buffTest = (auraType == "enemy") and UnitIsDebuffable or UnitIsBuffable
			for i, unit in ipairs(UNITS_TO_SCAN_BY_TYPE[auraType]) do
				if enabledUnits[unit] and buffTest(unit) then
					return LookupAura(unitAuras[unit], spell, specific.aliases, specific.onlyMine, hideStack, hideCountdown, specific.alternateColor)
				end
			end
			--]]
		elseif target then -- Friend or enemy
			--@debug@
			--dprint("GetAuraToDisplay, specific", "spell=", spell, "type=", auraType, "target=", target)
			--@end-debug@
			if (auraType == "enemy" and UnitIsDebuffable(target)) or (auraType == "friend" and UnitIsBuffable(target)) then
				return LookupAura(unitAuras[target], spell, specific.aliases, specific.onlyMine, hideStack, hideCountdown, specific.alternateColor)
			end
		end
	elseif target then
		--@debug@
		--dprint("GetAuraToDisplay, generic", "spell=", spell, "target=", target)
		--@end-debug@
		local buffTest, onlyMine
		if IsHarmfulSpell(spell) then
			buffTest, onlyMine = UnitIsDebuffable, db.profile.onlyMyDebuffs
		else
			buffTest, onlyMine = UnitIsBuffable, db.profile.onlyMyBuffs
		end
		if buffTest(target) then
			return LookupAura(unitAuras[target], spell, nil, onlyMine, db.profile.hideStack, db.profile.hideCountdown)
		end
		--[[
		local auraType, buffTest, onlyMine
		if IsHarmfulSpell(spell) then
			auraType, buffTest, onlyMine = "enemy", UnitIsDebuffable, db.profile.onlyMyDebuffs
		else
			auraType, buffTest, onlyMine = "friend", UnitIsBuffable, db.profile.onlyMyBuffs
		end
		local hideStack, hideCountdown = db.profile.hideStack, db.profile.hideCountdown
		for i, unit in ipairs(UNITS_TO_SCAN_BY_TYPE[auraType]) do
			if enabledUnits[unit] and buffTest(unit) then
				return LookupAura(unitAuras[unit], spell, nil, onlyMine, hideStack, hideCountdown)
			end
		end
		--]]

	end
end

------------------------------------------------------------------------------
-- Spell name memo
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

------------------------------------------------------------------------------
-- Visual feedback hooks
------------------------------------------------------------------------------

local function UpdateTimer(self)
	local aura = self.__IA_aura, self.__IA_hideStack, self.__IA_hideCountdown
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

local ActionButton_ShowOverlayGlow = ActionButton_ShowOverlayGlow

local function ActionButton_HideOverlayGlow_Hook(self)
	if buttons[self] and self.__IA_glow then
		--@debug@
		dprint(self, "Enforcing glow")
		--@end-debug@
		return ActionButton_ShowOverlayGlow(self)
	end
end

local function UpdateButtonState_Hook(self)
	if not buttons[self] then return end
	local aura = not self.__IA_glow and self.__IA_aura
	local texture = self:GetCheckedTexture()
	if aura and aura.expirationTime and aura.expirationTime > GetTime() then
		--@debug@
		dprint(self, "Showing border", aura.name)	
		--@end-debug@
		local color = db.profile['color'..aura.type..(aura.isMine and 'Mine' or 'Others')]
		self:__IA_SetChecked(true)
		SetVertexColor(texture, unpack(color))
	else
		texture:SetVertexColor(1, 1, 1)
	end
	return UpdateTimer(self)
end

------------------------------------------------------------------------------
-- Aura updating
------------------------------------------------------------------------------

local function FindMacroOptions(...)
	for i = 1, select('#', ...) do
		local line = select(i, ...)
		local prefix, suffix = strsplit(" ", line:trim(), 2)
		if suffix and (prefix == '#show' or prefix == '#showtooltip' or prefix:sub(1,1) ~= "#") then
			return suffix
		end
	end
end

local function GuessMacroTarget(index)
	local options = FindMacroOptions(strsplit("\n", GetMacroBody(index)))
	if options then
		local action, target = SecureCmdOptionParse(options)
		if action and action ~= "" and target and target ~= "" then
			return target
		end
	end
end

local function GuessSpellTarget(spell)
	if IsModifiedClick("SELFCAST") then
		return "player"
	elseif IsModifiedClick("FOCUSCAST") then
		return "focus"
	elseif IsHelpfulSpell(spell) and not UnitIsBuffable("target") and GetCVarBool("autoSelfCast") then
		return "player"
	else
		return "target"
	end
end

local function UpdateButtonAura(self, force)
	if not buttons[self] then return end
	local action, param = self.__IA_action, self.__IA_param
	local spell, target = param, SecureButton_GetModifiedUnit(self)
	if target == "" then target = nil end
	if spell then
		if action == "macro" then
			spell = GetMacroSpell(param)
			if not target then
				target = GuessMacroTarget(param) or GuessSpellTarget(spell)
			end
		elseif not target then
			target = GuessSpellTarget(spell)
		end
	end
	local guid = target and UnitGUID(target)
	if force or spell ~= self.__IA_spell or guid ~= self.__IA_guid or (target and auraChanged[target]) then
		--@debug@
		dprint(self, "spell=", spell, "target=", target, "guid=", guid, "auraChanged=", target and auraChanged[target])
		--@end-debug@
		self.__IA_spell, self.__IA_guid = spell, guid
		local aura, hideStack, hideCountdown, glow
		if spell then
			aura, hideStack, hideCountdown, glow = GetAuraToDisplay(spell, target)
		end
		if self.__IA_aura ~= aura or self.__IA_hideStack ~= hideStack or self.__IA_hideCountdown ~= hideCountdown or self.__IA_glow ~= glow then
			--@debug@
			dprint(self, "need update =>", aura and aura.name)
			--@end-debug@
			self.__IA_aura, self.__IA_hideStack, self.__IA_hideCountdown, self.__IA_glow = aura, hideStack, hideCountdown, glow
			self:__IA_UpdateState()
			ActionButton_UpdateOverlayGlow(self)
		end
	end
end

------------------------------------------------------------------------------
-- Action handling
------------------------------------------------------------------------------

local function ParseAction(self)
	local action, param = self:__IA_GetAction()
	if action == 'action' then
		local _, spellId
		action, param, _, spellId = GetActionInfo(param)
		if action == 'equipmentset' then
			return
		elseif action == 'companion' then
			action, param = 'spell', spellId
		end
	end
	if action == 'item' then
		return "spell", GetItemSpell(param)
	elseif action == 'spell' then
		return action, spellNames[param]
	elseif action == "macro" then
		return action, param
	end
end

local function UpdateAction_Hook(self)
	if not buttons[self] then return end
	local action, param
	if self:IsVisible() then
		action, param = ParseAction(self)
	end
	if action ~= self.__IA_action or param ~= self.__IA_param then
		--@debug@
		dprint(self, "action changed =>", action, param)
		--@end-debug@
		self.__IA_action, self.__IA_param = action, param
		activeButtons[self] = (action and param) or nil
		return UpdateButtonAura(self)
	end
end

------------------------------------------------------------------------------
-- Button initializing
------------------------------------------------------------------------------

local function Blizzard_GetAction(self)
	return 'action', self.action
end

local function InitializeButton(self)
	if buttons[self] then return end
	buttons[self] = true
	self.__IA_SetChecked = self.SetChecked
	if self.__LAB_Version then
		self.__IA_GetAction = self.GetAction
		self.__IA_UpdateState = self.Update
		hooksecurefunc(self, 'SetChecked', UpdateButtonState_Hook)
		hooksecurefunc(self, 'UpdateAction', UpdateAction_Hook)		
	else
		self.__IA_GetAction = Blizzard_GetAction
		self.__IA_UpdateState = ActionButton_UpdateState
	end
	UpdateAction_Hook(self)
end

------------------------------------------------------------------------------
-- Blizzard button hooks
------------------------------------------------------------------------------

local function ActionButton_OnLoad_Hook(self)
	if not buttons[self] and not newButtons[self] then
		newButtons[self] = true
		return true
	end
end

local function ActionButton_Update_Hook(self)
	return ActionButton_OnLoad_Hook(self) or UpdateAction_Hook(self)
end

------------------------------------------------------------------------------
-- Event listener stuff
------------------------------------------------------------------------------

local UpdateUnitListeners
do
	local function IsEnabledUnit(unit)
		return true
		--[[
		for name, spell in pairs(db.profile.spells) do
			if type(spell) == "table" and not spell.disabled then
				for i, spellUnit in pairs(UNITS_TO_SCAN_BY_TYPE[spell.auraType]) do
					if spellUnit == unit then
						return true
					end
				end
			end
		end
		--]]
	end
	local function FillTableWith(t, ...)
		wipe(t)
		for i = 1, select('#', ...) do
			t[i] = select(i, ...)
		end
		return t
	end
	local ALL_UNITS = { target = true, focus = true, mouseover = true, player = true, pet = true }
	function UpdateUnitListeners()
--[[
		-- Rebuild friend and enemy unit list
		FillTableWith(UNITS_TO_SCAN_BY_TYPE.friend, strsplit(",", db.profile.friendOrdering:lower()))
		FillTableWith(UNITS_TO_SCAN_BY_TYPE.enemy, strsplit(",", db.profile.enemyOrdering:lower()))
		--@debug@
		dprint("friend:", db.profile.friendOrdering, "enemy:", db.profile.enemyOrdering)
		--@end-debug@
		-- Rebuild the complete unit list
		wipe(ALL_UNITS)
		for auraTypes, units in pairs(UNITS_TO_SCAN_BY_TYPE) do
			for i, unit in ipairs(units) do
				ALL_UNITS[unit] = true
			end
		end
--]]
		-- Now check for actually enabled units
		for unit in pairs(ALL_UNITS) do
			local event = UNIT_EVENTS[unit]
			local found = IsEnabledUnit(unit)
			enabledUnits[unit] = found
			--@debug@
			dprint("Unit", unit, found and "enabled" or "disabled")
			--@end-debug@
			if found then
				if event then
					--@debug@
					dprint("Starting listening for", event, "for unit", unit)
					--@end-debug@
					InlineAura:RegisterEvent(event)
				end
			else
				if event then
					--@debug@
					dprint("Stopping listening for", event, "for unit", unit)
					--@end-debug@
					InlineAura:UnregisterEvent(event)
				end
				WipeAuras(unit)
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

------------------------------------------------------------------------------
-- Button updates
------------------------------------------------------------------------------

local enabledEvents = {}
function InlineAura:OnUpdate(elapsed)
	-- Configuration has been updated
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
	
	-- Emulate missing mouseover events
	if unitGUIDs.mouseover then
		if UnitGUID("mouseover") ~= unitGUIDs.mouseover or not self.mouseoverTimer or self.mouseoverTimer < elapsed then
			self:UPDATE_MOUSEOVER_UNIT("OnUpdate")
			self.mouseoverTimer = 1
		else
			self.mouseoverTimer = self.mouseoverTimer - elapsed
		end
	end
	
	-- Handle new buttons
	if next(newButtons) then
		for button in pairs(newButtons) do
			InitializeButton(button)
		end
		wipe(newButtons)
	end
	
	-- Update buttons
	if next(auraChanged) or needUpdate or configUpdated then
		for button in pairs(activeButtons) do
			UpdateButtonAura(button, configUpdated)
		end
		needUpdate, configUpdated = false, false
		wipe(auraChanged)
	end
	
	-- Update timers
	ProcessTimers()
end

function InlineAura:RequireUpdate(config)
	configUpdated = config
	needUpdate = true
end

function InlineAura:RegisterButtons(prefix, count)
	for id = 1, count do
		local button = _G[prefix .. id]
		if button and not buttons[button] and not newButtons[button] then
			newButtons[button] = true
		end
	end
end

------------------------------------------------------------------------------
-- Event handling
------------------------------------------------------------------------------

function InlineAura:UNIT_ENTERED_VEHICLE(event, unit)
	if unit == 'player' then
		inVehicle = (event == 'UNIT_ENTERED_VEHICLE')
		return UpdateUnitAuras('player', event)
	end
end

InlineAura.UNIT_EXITED_VEHICLE = InlineAura.UNIT_ENTERED_VEHICLE

function InlineAura:UNIT_AURA(event, unit)
	if enabledUnits[unit] or (unit == 'vehicle' and inVehicle) then
		return UpdateUnitAuras(unit, event)
	end
end

function InlineAura:UNIT_PET(event, unit)
	if unit == 'player' then
		return UpdateUnitAuras('pet', event)
	end
end

function InlineAura:PLAYER_ENTERING_WORLD(event)
	inVehicle = not not UnitControllingVehicle('player')
	for unit in pairs(enabledUnits) do
		UpdateUnitAuras(unit, event)
	end
end

function InlineAura:PLAYER_FOCUS_CHANGED(event)
	return UpdateUnitAuras('focus', event)
end

function InlineAura:PLAYER_TARGET_CHANGED(event)
	return UpdateUnitAuras('target', event)
end

function InlineAura:MODIFIER_STATE_CHANGED(event)
	needUpdate = true
end

function InlineAura:UPDATE_MOUSEOVER_UNIT(event)
	UpdateUnitAuras('mouseover', event)
	self.mouseoverTimer = 1
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
	self:RegisterEvent('MODIFIER_STATE_CHANGED')

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
	hooksecurefunc('ActionButton_UpdateState', UpdateButtonState_Hook)
	hooksecurefunc('ActionButton_Update', ActionButton_Update_Hook)
	hooksecurefunc('ActionButton_HideOverlayGlow', ActionButton_HideOverlayGlow_Hook)
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
