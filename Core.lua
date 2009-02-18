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

local bigCountdown = true

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
		for name,data in pairs(auras) do
			del(data)
		end
		wipe(auras)
		InlineAura.needUpdate = true
	end
end

local newAuras = {}
local function UpdateUnitAuras(auras, unit, filter)
	wipe(newAuras)
	-- First, get all auras, included those applied by other players (if configured so)
	for i = 1,255 do
		local name, _, _, count, _, duration, expirationTime, isMine = UnitAura(unit, i, filter)
		if not name then
			break
		else
			local data, isNew = newAuras[name], false
			if not data then
				data, isNew = new(), true
				newAuras[name] = data
			end
			if isNew or (expirationTime or 0) > (data.expirationTime or 0) or (count or 0) > (data.count or 0) then
				data.count = count
				data.duration = duration
				data.expirationTime = expirationTime
				data.isMine = isMine and true or false
			end
		end
	end
	-- Then get the aura applied only by the player
	local filter_mine = filter .. '|PLAYER'
	for i = 1,255 do
		local name, _, _, count, _, duration, expirationTime = UnitAura(unit, i, filter_mine)
		if not name then
			break
		end
		local data = newAuras[name]
		if not data then
			data = new()
			newAuras[name] = data
		end
		data.count = count
		data.duration = duration
		data.expirationTime = expirationTime
		data.isMine = true
	end
	-- Remove auras that have faded out
	for name, data in pairs(auras) do
		if not newAuras[name] then
			auras[name] = del(auras[name])
			InlineAura.needUpdate = true
		end
	end
	-- Add new auras and update existing ones
	for name, data in pairs(newAuras) do
		local old = auras[name]
		if old then
			if old.isMine ~= data.isMine or old.count ~= data.count or old.duration ~= data.duration or old.expirationTime ~= data.expirationTime then
				InlineAura.needUpdate = true
			end
			del(old)
		else
			InlineAura.needUpdate = true
		end
		auras[name] = data
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
	countdownText.baseFontSize = db.profile[bigCountdown and "largeFontSize" or "smallFontSize"]
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
	countdownText:SetJustifyV(bigCountdown and 'MIDDLE' or 'BOTTOM')
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
		if not bigCountdown then
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
-- Button hooks
------------------------------------------------------------------------------

local function ActionButton_UpdateTimer(self, data)
	if not data or not data.duration or data.duration == 0 or GetTime() > data.expirationTime then
		if timerFrames[self] then
			timerFrames[self].data = nil
			timerFrames[self]:Hide()
		end
		return
	end
	local timer = timerFrames[self] or CreateTimerFrame(self)
	timer.data = data
	timer:Show()
	TimerFrame_Update(timer)
end

local function ActionButton_UpdateBorder(self, spell)
	if spell then
		local aura, auraType = GetAuraToDisplay(spell)
		if aura then
			local color = db.profile['color'..auraType..(aura.isMine and 'Mine' or 'Others')]
			self:GetCheckedTexture():SetVertexColor(unpack(color))
			ActionButton_UpdateTimer(self, aura)
			return true
		end
	end

	ActionButton_UpdateTimer(self, nil)
	self:GetCheckedTexture():SetVertexColor(1, 1, 1)
end

local function ActionButton_IsSpellInUse(self)
	local actionName = self.actionName
	if actionName then
		if self.actionType == 'macro' then
			return ActionButton_UpdateBorder(self, GetMacroSpell(actionName))
		else
			return ActionButton_UpdateBorder(self, actionName)
		end
	end
end

local function ActionButton_UpdateSpell(self)
	if self.action then
		local type, arg1, arg2 = GetActionInfo(ActionButton_GetPagedID(self))

		self.actionType = type
		if type == 'spell' then
			if arg1 and arg2 and arg1 > 0 then
				self.actionName = GetSpellName(arg1, arg2)
			else
				self.actionName = nil
			end
		elseif type == 'item' then
			self.actionName = GetItemSpell(arg1)
		else
			self.actionName = arg1
		end

		ActionButton_UpdateState(self)
	end
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
		elseif event == 'VARIABLES_LOADED' then
			-- Miscellanous addon support
			if Dominos then self:RegisterButtons("DominosActionButton", 48) end
			if Bartender4 then self:RegisterButtons("BT4Button", 120) end
			if OmniCC then bigCountdown = false end
			self:RequireUpdate()
		end
	end)

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
	hooksecurefunc('ActionButton_UpdateState', function(self)
		InlineAura.buttons[self] = true
		self:SetChecked(ActionButton_IsSpellInUse(self) or self:GetChecked())
	end)

	hooksecurefunc('ActionButton_Update', function(self)
		ActionButton_UpdateSpell(self)
	end)

	hooksecurefunc('ActionButton_OnLoad', function(self)
		InlineAura.buttons[self] = true
	end)

	self:SetupConfig()
end)

-- Initialize on ADDON_LOADED
InlineAura:RegisterEvent('ADDON_LOADED')

