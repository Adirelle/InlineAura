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
-- Our main frame
------------------------------------------------------------------------------

InlineAura = CreateFrame('Frame')
local InlineAura = InlineAura

------------------------------------------------------------------------------
-- Retrieve the localization table
------------------------------------------------------------------------------

-- Use a loose table until the string list get stable
local InlineAura_L = _G.InlineAura_L
InlineAura.L = setmetatable(InlineAura_L, {__index = function(self, key)
	self[key] = key
	--@debug@
	print("Missing locale:", key)
	--@end-debug@
	return key
end})

_G.InlineAura_L = nil -- cleanup the global namespace

------------------------------------------------------------------------------
-- Locals
------------------------------------------------------------------------------

local db

local L = InlineAura.L

local playerAuras = {}
local targetAuras = {}
local timerFrames = {}

------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------

local UPDATE_PERIOD = 0.25

local LSM = LibStub('LibSharedMedia-3.0')
local FONTMEDIA = LSM.MediaType.FONT

local FONT_NAME = LSM:GetDefault(FONTMEDIA)
local FONT_FLAGS = "OUTLINE"
local FONT_SIZE_SMALL = 13
local FONT_SIZE_LARGE = 20

local DEFAULT_OPTIONS = {
	profile = {
		onlyMyBuffs = false,
		onlyMyDebuffs = false,
		hideCountdown = false,
		hideStack = false,
		preciseCountdown = false,
		fontName = FONT_NAME,
		smallFontSize = FONT_SIZE_SMALL,
		largeFontSize = FONT_SIZE_LARGE,
		colorBuffMine = { 0.0, 1.0, 0.0, 1.0 },
		colorBuffOthers = { 0.0, 1.0, 1.0, 1.0 },
		colorDebuffMine = { 1.0, 0.0, 0.0, 1.0 },
		colorDebuffOthers = { 1.0, 1.0, 0.0, 1.0 },
		colorCountdown = { 1.0, 1.0, 1.0, 1.0 },
		colorStack = { 1.0, 1.0, 1.0, 1.0 },
		spells = {
			['**'] = {
				disabled = false,
				auraType = 'buff',
			},
		},
	},
}
InlineAura.DEFAULT_OPTIONS = DEFAULT_OPTIONS

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
-- Aura monitoring
------------------------------------------------------------------------------

local function WipeAuras(auras)
	if next(auras) then
		for name,aura in pairs(auras) do
			del(aura)
		end
		wipe(auras)
		InlineAura.needUpdate = true
	end
end

local UnitAura = _G.UnitAura

do -- 3.1 compatibility
	local _, buildNumber = GetBuildInfo()
	if tonumber(buildNumber) >= 9658 then
		local origUnitAura, UnitIsUnit = _G.UnitAura, _G.UnitIsUnit
		UnitAura = function(...)
			local name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = origUnitAura(...)
			local isMine = name and caster and (UnitIsUnit(caster, 'player') or UnitIsUnit(caster, 'pet'))
			return name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable
		end
	end
end

local serial = 0

local function UpdateUnitAuras(auras, unit, filter)
	serial = (serial + 1) % 10000

	-- First, get all auras, included those applied by other players (if configured so)
	for i = 1,255 do
		local name, _, _, count, _, duration, expirationTime, isMine = UnitAura(unit, i, filter)
		if not name then
			break
		elseif not isMine then
			local data = auras[name]
			if not data then
				data = new()
				auras[name] = data
				InlineAura.needUpdate = true
			elseif expirationTime ~= data.expirationTime or count ~= data.count or data.isMine then
				InlineAura.needUpdate = true
			end
			data.serial = serial
			data.count = count
			data.duration = duration
			data.expirationTime = expirationTime
			data.isMine = false
		end
	end
	-- Then get the aura applied only by the player
	local filter_mine = filter .. '|PLAYER'
	for i = 1,255 do
		local name, _, _, count, _, duration, expirationTime = UnitAura(unit, i, filter_mine)
		if not name then
			break
		end
		local data = auras[name]
		if not data then
			data = new()
			auras[name] = data
			InlineAura.needUpdate = true
		elseif expirationTime ~= data.expirationTime or count ~= data.count or not data.isMine then
			InlineAura.needUpdate = true			
		end
		data.serial = serial
		data.count = count
		data.duration = duration
		data.expirationTime = expirationTime
		data.isMine = true
	end
	-- Handle tracking as self buff
	if unit == 'player' then
		for i = 1, GetNumTrackingTypes() do
			local name, _, active, category = GetTrackingInfo(i)
			if active and category == 'spell' then
				local data = auras[name]
				if not data then
					data = new()
					auras[name] = data
					InlineAura.needUpdate = true
				end
				data.serial = serial
				data.count = 0
				data.isMine = true
			end
		end
	end
	-- Remove auras that have faded out
	for name, data in pairs(auras) do
		if data.serial ~= serial then
			auras[name] = del(auras[name])
			InlineAura.needUpdate = true
		end
	end
end

local function UpdatePlayerBuffs()
	UpdateUnitAuras(playerAuras, 'player', 'HELPFUL')
end

local function UpdateTargetAuras()
	if UnitExists('target') then
		if UnitIsFriend('player', 'target') then
			UpdateUnitAuras(targetAuras, 'target', 'HELPFUL')
		else
			UpdateUnitAuras(targetAuras, 'target', 'HARMFUL')
		end
	else
		WipeAuras(targetAuras)
	end
end

------------------------------------------------------------------------------
-- Countdown formatting
------------------------------------------------------------------------------

local floor = math.floor
local ceil = math.ceil

local function GetPreciseCountdownText(timeLeft)
	if timeLeft >= 3600 then
		return L["%dh"]:format(floor(timeLeft/3600)), timeLeft % 3600
	elseif timeLeft >= 600 then
		return L["%dm"]:format(floor(timeLeft/60)), timeLeft % 60
	elseif timeLeft >= 60 then
		return ("%d:%02d"):format(floor(timeLeft/60), floor(timeLeft%60)), timeLeft % 1
	elseif timeLeft >= 10 then
		return tostring(floor(timeLeft)), timeLeft % 1
	elseif timeLeft >= 0.1 then
		return ("%.1f"):format(floor(timeLeft*10)/10), timeLeft % 0.1
	end
end

local function GetImpreciseCountdownText(timeLeft)
	if timeLeft >= 3600 then
		return L["%dh"]:format(ceil(timeLeft/3600)), timeLeft % 3600
	elseif timeLeft >= 60 then
		return L["%dm"]:format(ceil(timeLeft/60)), timeLeft % 60
	else
		return ceil(timeLeft), timeLeft % 1
	end
end

local function GetCountdownText(timeLeft, precise)
	return (precise and GetPreciseCountdownText or GetImpreciseCountdownText)(timeLeft)
end

------------------------------------------------------------------------------
-- Timer frame handling
------------------------------------------------------------------------------

local TimerFrame_OnUpdate

local function TimerFrame_Skin(self)
	local font = LSM:Fetch(FONTMEDIA, db.profile.fontName)

	local countdownText = self.countdownText
	countdownText.fontName = font
	countdownText.baseFontSize = db.profile[InlineAura.bigCountdown and "largeFontSize" or "smallFontSize"]
	countdownText:SetFont(font, countdownText.baseFontSize, FONT_FLAGS)
	countdownText:SetTextColor(unpack(db.profile.colorCountdown))

	local stackText = self.stackText
	stackText:SetFont(font, db.profile.smallFontSize, FONT_FLAGS)
	stackText:SetTextColor(unpack(db.profile.colorStack))
end

local function CreateTimerFrame(button)
	local timer = CreateFrame("Frame", nil, button)
	local cooldown = _G[button:GetName()..'Cooldown']
	timer:SetFrameLevel(cooldown:GetFrameLevel() + 5)
	timer:SetAllPoints(cooldown)
	timer:SetToplevel(true)
	timer.delay = 0
	timer:SetScript('OnUpdate', TimerFrame_OnUpdate)

	timerFrames[button] = timer

	local countdownText = timer:CreateFontString(nil, "OVERLAY")
	countdownText:SetAllPoints(timer)
	countdownText:SetJustifyV(InlineAura.bigCountdown and 'MIDDLE' or 'BOTTOM')
	timer.countdownText = countdownText

	local stackText = timer:CreateFontString(nil, "OVERLAY")
	stackText:SetAllPoints(timer)
	stackText:SetJustifyH("RIGHT")
	stackText:SetJustifyV("BOTTOM")
	timer.stackText = stackText

	TimerFrame_Skin(timer)

	return timer
end

local function TimerFrame_Update(self)
	local data = self.data
	if not data or not data.expirationTime or data.expirationTime <= GetTime() or (db.profile.hideCountdown and db.profile.hideStack) then
		self.data = nil
		self:Hide()
		return
	end

	local countdownJustfiyH = 'CENTER'
	local stackText = self.stackText
	if not db.profile.hideStack and data.count and data.count > 0 then
		stackText:SetText(data.count)
		if not InlineAura.bigCountdown then
			countdownJustfiyH = 'LEFT'
		end
		stackText:Show()
	else
		stackText:Hide()
	end

	local countdownText = self.countdownText
	local timeLeft = data.expirationTime - GetTime()
	local displayTime
	displayTime, self.delay = GetCountdownText(timeLeft, db.profile.preciseCountdown)
	if db.profile.hideCountdown or not displayTime then
		countdownText:Hide()
		self.delay = timeLeft
	else
		countdownText:SetFont(countdownText.fontName, countdownText.baseFontSize, FONT_FLAGS)
		countdownText:SetJustifyH(countdownJustfiyH)
		countdownText:SetText(displayTime)
		countdownText:Show()

		local sizeRatio = countdownText:GetStringWidth() / (self:GetWidth()-4)
		if sizeRatio > 1 then
			countdownText:SetFont(countdownText.fontName, countdownText.baseFontSize / sizeRatio, FONT_FLAGS)
		end
	end

end

function TimerFrame_OnUpdate(self, elapsed)
	self.delay = self.delay - elapsed
	if self.delay <= 0 then
		TimerFrame_Update(self)
	end
end

------------------------------------------------------------------------------
-- Aura lookup
------------------------------------------------------------------------------

local function CheckAura(auras, name, onlyMine)
	local aura = auras[name]
	if aura and (aura.isMine or not onlyMine) then
		return aura
	end
end

local function LookupAura(auras, spell, aliases, auraType, onlyMine)
	local aura = CheckAura(auras, spell, onlyMine)
	if not aura and aliases then
		for i, alias in ipairs(aliases) do
			aura = CheckAura(auras, alias, onlyMine)
			if aura then
				break
			end
		end
	end
	if aura then
		return aura, auraType
	end
end

local function GetTristateValue(value, default)
	if value ~= nil then
		return value
	else
		return default
	end
end

local function GetAuraToDisplay(spell)
	local specific = rawget(db.profile.spells, spell) -- Bypass AceDB auto-creation
	local onlyMine, aliases
	if type(specific) == 'table' then
		if specific.disabled then
			return
		end
		if specific.auraType == 'debuff' then
			if UnitExists('target') and not UnitIsFriend('player', 'target') then
				return LookupAura(targetAuras, spell, specific.aliases, 'Debuff', GetTristateValue(specific.onlyMine, db.profile.onlyMyDebuffs))
			end
		else
			if UnitExists('target') and UnitIsFriend('player', 'target') then
				return LookupAura(targetAuras, spell, specific.aliases, 'Buff', GetTristateValue(specific.onlyMine, db.profile.onlyMyBuffs))
			else
				return LookupAura(playerAuras, spell, specific.aliases, 'Buff', GetTristateValue(specific.onlyMine, db.profile.onlyMyBuffs))
			end
		end
	else
		if UnitExists('target') then
			if UnitIsFriend('player', 'target') then
				return LookupAura(targetAuras, spell, nil, 'Buff', db.profile.onlyMyBuffs)
			else
				local aura, auraType = LookupAura(targetAuras, spell, nil, 'Debuff', db.profile.onlyMyDebuffs)
				if aura then
					return aura, auraType
				end
			end
		end
		return LookupAura(playerAuras, spell, nil, 'Buff', db.profile.onlyMyBuffs)
	end
end

------------------------------------------------------------------------------
-- Visual feedback
------------------------------------------------------------------------------

local function UpdateTimer(self, aura)
	if aura and aura.serial then
		local timer = timerFrames[self] or CreateTimerFrame(self)
		timer.data = aura
		timer:Show()
		TimerFrame_Update(timer)
	elseif timerFrames[self] then
		timerFrames[self].data = nil
		timerFrames[self]:Hide()
	end
end

local function UpdateHighlight(self, aura, color)
	local texture = self:GetCheckedTexture()
	if aura then
		texture:SetVertexColor(unpack(color))
		self:SetChecked(true)
	else
		texture:SetVertexColor(1, 1, 1)
	end
end

------------------------------------------------------------------------------
-- LibButtonFacade compatibility
------------------------------------------------------------------------------

local function LBF_UpdateHighlight(self, aura, color)
	local texture = self:GetCheckedTexture()
	if aura then
		local r, g, b, a = unpack(color)
    local R, G, B, A = texture:GetVertexColor()
		texture:SetVertexColor(r*R, g*G, b*B, a*(A or 1))
		self:SetChecked(true)
	else
		texture:SetVertexColor(1, 1, 1)
	end
end

local function LBF_Callback()
	InlineAura:RequireUpdate(true)
end

------------------------------------------------------------------------------
-- Button hooks
------------------------------------------------------------------------------

local function ActionButton_OnLoad_Hook(self)
	InlineAura.buttons[self] = true
end

local function ActionButton_UpdateState_Hook(self)
	InlineAura.buttons[self] = true
	local spell = self.actionName
	if spell and self.actionType == 'macro' then
		spell = GetMacroSpell(spell)
	end
	local aura, color
	if spell then
		local auraType
		aura, auraType = GetAuraToDisplay(spell)
		if aura then
			color = db.profile['color'..auraType..(aura.isMine and 'Mine' or 'Others')]
		end
	end
	UpdateHighlight(self, aura, color)
	UpdateTimer(self, aura)
end

local function ActionButton_Update_Hook(self)
	self.actionName, self.actionType = nil, nil
	if self.action then
		local type, arg1, arg2 = GetActionInfo(ActionButton_GetPagedID(self))

		self.actionType = type
		if type == 'spell' then
			if arg1 and arg2 and arg1 > 0 then
				self.actionName = GetSpellName(arg1, arg2)
			end
		elseif type == 'item' then
			self.actionName = GetItemSpell(arg1)
		else
			self.actionName = arg1
		end
	end
	ActionButton_UpdateState_Hook(self)
end

------------------------------------------------------------------------------
-- Button update
------------------------------------------------------------------------------

InlineAura.buttons = {}

InlineAura:SetScript('OnUpdate', function(self, elapsed)
	if self.needUpdate then
		if self.configUpdated then
			for button, timerFrame in pairs(timerFrames) do
				TimerFrame_Skin(timerFrame)
			end
			self.configUpdated = false
		end
		for button in pairs(self.buttons) do
			if button:IsVisible() and HasAction(button.action) then
				ActionButton_UpdateState(button)
			end
		end
		self.needUpdate = false
	end
end)

function InlineAura:RequireUpdate(configUpdated)
	self.configUpdated = configUpdated
	if configUpdated then
		UpdatePlayerBuffs()
		UpdateTargetAuras()
	end
	self.needUpdate = true
end

function InlineAura:RegisterButtons(prefix, count)
	for id = 1, count do
		local button = _G[prefix .. id]
		if button then
			self.buttons[button] = true
		end
	end
end

------------------------------------------------------------------------------
-- Event handling
------------------------------------------------------------------------------

InlineAura:SetScript('OnEvent', function(self, event, name)
	if name ~= 'InlineAura' then
		return
	end
	self:UnregisterEvent('ADDON_LOADED')

	-- Saved variables setup
	db = LibStub('AceDB-3.0'):New("InlineAuraDB", DEFAULT_OPTIONS)
	db.RegisterCallback(self, 'OnProfileChanged', 'RequireUpdate')
	db.RegisterCallback(self, 'OnProfileCopied', 'RequireUpdate')
	db.RegisterCallback(self, 'OnProfileReset', 'RequireUpdate')
	self.db = db

	-- New event handler
	self:SetScript('OnEvent', function(self, event, arg1, ...)
		if event == 'UNIT_AURA' then
			if arg1 == 'player' then
				UpdatePlayerBuffs()
			elseif arg1 == 'target' then
				UpdateTargetAuras()
			end
		elseif event == 'PLAYER_ENTERING_WORLD' then
			UpdatePlayerBuffs()
			UpdateTargetAuras()
		elseif event == 'PLAYER_TARGET_CHANGED' then
			UpdateTargetAuras()
			self.needUpdate = true
		elseif event == 'VARIABLES_LOADED' then
			-- ButtonFacade support
			local LBF = LibStub('LibButtonFacade', true)
			local LBF_RegisterCallback = function() end
			if LBF then
				UpdateHighlight = LBF_UpdateHighlight
				LBF:RegisterSkinCallback("Blizzard", LBF_Callback)
			end
			-- Miscellanous addon support
			if Dominos then 
				self:RegisterButtons("DominosActionButton", 48)
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
			self:RequireUpdate()
		end
	end)

	-- Setup
	self.bigCountdown = true

	-- Set event listening up
	self:RegisterEvent('UNIT_AURA')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('VARIABLES_LOADED')

	-- standard buttons
	self:RegisterButtons("ActionButton", 12)
	self:RegisterButtons("BonusActionButton", 12)
	self:RegisterButtons("MultiBarRightButton", 12)
	self:RegisterButtons("MultiBarLeftButton", 12)
	self:RegisterButtons("MultiBarBottomRightButton", 12)
	self:RegisterButtons("MultiBarBottomLeftButton", 12)

	-- Hooks
	hooksecurefunc('ActionButton_OnLoad', ActionButton_OnLoad_Hook)
	hooksecurefunc('ActionButton_UpdateState', ActionButton_UpdateState_Hook)
	hooksecurefunc('ActionButton_Update', ActionButton_Update_Hook)

	self:SetupConfig()
end)

-- Initialize on ADDON_LOADED
InlineAura:RegisterEvent('ADDON_LOADED')

