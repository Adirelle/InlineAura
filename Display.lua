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

local addonName, addon = ...

------------------------------------------------------------------------------
-- Import
------------------------------------------------------------------------------

local L = addon.L
local buttonStateProto = addon.buttonStateProto

------------------------------------------------------------------------------
-- Make often-used globals local
------------------------------------------------------------------------------

--<GLOBALS
local _G = _G
local assert = _G.assert
local ceil = _G.ceil
local CreateFont = _G.CreateFont
local CreateFrame = _G.CreateFrame
local floor = _G.floor
local format = _G.format
local GetTime = _G.GetTime
local IsSpellOverlayed = _G.IsSpellOverlayed
local max = _G.max
local min = _G.min
local next = _G.next
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local strmatch = _G.strmatch
local tinsert = _G.tinsert
local tostring = _G.tostring
local tremove = _G.tremove
local type = _G.type
local UIParent = _G.UIParent
local unpack = _G.unpack
--GLOBALS>

------------------------------------------------------------------------------
-- LibSharedMedia
------------------------------------------------------------------------------
local LSM = LibStub('LibSharedMedia-3.0')

------------------------------------------------------------------------------
-- Local reference to addon settings
------------------------------------------------------------------------------
local profile = addon.db and addon.db.profile
LibStub('AceEvent-3.0').RegisterMessage('InlineAura/Display.lua', 'InlineAura_ProfileChanged', function() profile = addon.db.profile end)

------------------------------------------------------------------------------
-- Home-made bucketed timers
------------------------------------------------------------------------------
-- This is mainly a simplified version of AceTimer-3.0, credits goes to Ace3 authors

local ScheduleTimer, CancelTimer
do
	local assert, type, next, floor, GetTime = assert, type, next, floor, GetTime
	local BUCKETS = 131
	local HZ = 20
	local buckets = {}
	local targets = {}
	for i = 1, BUCKETS do buckets[i] = {} end
	local frame = CreateFrame("Frame")
	frame:Hide()

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
		frame:Show()
	end

	function CancelTimer(target)
		assert(target)
		local bucketNum = targets[target]
		if bucketNum then
			buckets[bucketNum][target] = nil
			targets[target] = nil
			if not next(targets) then
				frame:Hide()
			end
		end
	end

	frame:SetScript('OnUpdate', function()
		local now = GetTime()
		local newIndex = floor(now*HZ)
		for index = lastIndex + 1, newIndex do
			local bucketNum = 1 + (index % BUCKETS)
			local bucket = buckets[bucketNum]
			for target, when in next, bucket do
				if when <= now then
					bucket[target] = nil
					targets[target] = nil
					target:OnUpdate(now)
				end
			end
		end
		lastIndex = newIndex
		if not next(targets) then
			frame:Hide()
		end
	end)
end

------------------------------------------------------------------------------
-- Local values
------------------------------------------------------------------------------

local countFont = CreateFont(addonName.."CountFont")
local fontFile, countdownFontSize = NumberFontNormalLarge:GetFont()

------------------------------------------------------------------------------
-- Dynamic countdown font
------------------------------------------------------------------------------

-- Size and color modifiers
local dynamicModifiers = {
	-- { font scale, r, g, b }
	{ 1.3, 1, 0, 0 }, -- soon
	{ 1.0, 1, 1, 0 }, -- in less than a minute
	{ 0.8, 1, 1, 1 }, -- in more than a minute
}

local function GetCountdownStaticFont()
	return countdownFontSize, unpack(profile.colorCountdown)
end

local function GetCountdownDynamicFont(timeLeft)
	if timeLeft then
		local phase = (timeLeft <= 5 and 1) or (timeLeft <= 60 and 2) or 3
		local scale, r, g, b = unpack(dynamicModifiers[phase])
		return countdownFontSize * scale, r, g, b
	else
		return GetCountdownStaticFont()
	end
end

local GetCountdownFont = GetCountdownStaticFont

------------------------------------------------------------------------------
-- Countdown formatting
------------------------------------------------------------------------------

local function FormatPreciseCountdown(timeLeft)
	if timeLeft >= 3600 then
		return format(L["%dh"], floor(timeLeft/3600)), 1 + floor(timeLeft) % 3600
	elseif timeLeft >= 600 then
		return format(L["%dm"], floor(timeLeft/60)), 1 + floor(timeLeft) % 60
	elseif timeLeft >= 60 then
		return format("%d:%02d", floor(timeLeft/60), floor(timeLeft%60)), timeLeft % 1
	elseif timeLeft >= profile.decimalCountdownThreshold then
		return tostring(floor(timeLeft)), timeLeft % 1
	elseif timeLeft > 0 then
		return format("%.1f", floor(timeLeft*10)/10), 0
	else
		return "0", 0
	end
end

local function FormatImpreciseCountdown(timeLeft)
	if timeLeft >= 3600 then
		return format(L["%dh"], ceil(timeLeft/3600)), ceil(timeLeft) % 3600
	elseif timeLeft >= 60 then
		return format(L["%dm"], ceil(timeLeft/60)), ceil(timeLeft) % 60
	elseif timeLeft > 0 then
		return tostring(floor(timeLeft)), timeLeft % 1
	else
		return "0", 0
	end
end

local FormatCountdown = FormatImpreciseCountdown

------------------------------------------------------------------------------
-- Countdown text widget
------------------------------------------------------------------------------

local textOverlayProto = setmetatable({}, { __index = CreateFrame("Frame") })
local textOverlayMeta = { __index = textOverlayProto }

LibStub('AceEvent-3.0'):Embed(textOverlayProto)
textOverlayProto.Debug = addon.Debug

function textOverlayProto:Initialize()
	local countdownText = self:CreateFontString(nil, "OVERLAY")
	countdownText = self:CreateFontString(nil, "OVERLAY")
	countdownText:SetAllPoints(self)
	self.countdownText = countdownText

	local countText = self:CreateFontString(nil, "OVERLAY")
	countText = self:CreateFontString(nil, "OVERLAY")
	countText:SetFontObject(countFont)
	countText:SetAllPoints(self)
	self.countText = countText

	self:Debug('Initialize')
end

function textOverlayProto:ApplySettings()
	self:Debug('ApplySettings')
	self:UpdateLayout()
	self:UpdateCountdownFont()
end

function textOverlayProto:AttachTo(button)
	local cooldown = _G[button:GetName().."Cooldown"]
	self:Debug('AttachTo', button)
	self:SetParent(button)
	self:SetAllPoints(cooldown)
	self:SetFrameLevel(cooldown:GetFrameLevel() + 5)
	self.countText:Hide()
	self.countdownText:Hide()
	self:Show()
	self:ApplySettings()
end

function textOverlayProto:Detach()
	self:Debug('Detach')
	self:SetExpirationTime(nil)
	self:SetCount(nil)
	self:ClearAllPoints()
	self:Hide()
end

function textOverlayProto:SetExpirationTime(expirationTime)
	if expirationTime == self.expirationTime then return end
	self:Debug("SetExpirationTime", expirationTime)
	self.expirationTime = expirationTime
	if expirationTime then
		expirationTime = floor(expirationTime * 10 + 0.5) / 10.0
		if not self.countdownText:IsShown() then
			self.countdownText:Show()
			self:UpdateLayout()
		end
		self:OnUpdate(GetTime())
	else
		CancelTimer(self)
		if self.countdownText:IsShown() then
			self.countdownText:Hide()
			self:UpdateLayout()
		end
	end
end

function textOverlayProto:OnUpdate(now)
	self:Debug('OnUpdate', now)
	local timeLeft = self.expirationTime - now
	if timeLeft <= 0 then
		return self:SetExpirationTime(nil)
	end
	local text, delay = FormatCountdown(timeLeft)
	if text ~= self.countdownText:GetText() then
		self.timeLeft = timeLeft
		self.countdownText:SetText(text)
		self:UpdateCountdownFont()
	end
	ScheduleTimer(self, min(delay, timeLeft))
end

function textOverlayProto:SetCount(count)
	if count == self.count then return end
	self:Debug("SetCount", count)
	self.count = count
	if count then
		self.countText:SetFormattedText("%d", count)
		if not self.countText:IsShown() then
			self.countText:Show()
			self:UpdateLayout()
		end
	elseif self.countText:IsShown() then
		self.countText:Hide()
		self:UpdateLayout()
	end
end

local function SetTextPosition(fontstring, position)
	if position ~= fontstring.position then
		fontstring.position = position
		fontstring:SetJustifyH(strmatch(position, 'LEFT') or strmatch(position, 'RIGHT') or 'MIDDLE')
		fontstring:SetJustifyV(strmatch(position, 'TOP') or strmatch(position, 'BOTTOM') or 'CENTER')
	end
end

function textOverlayProto:UpdateLayout()
	self:Debug("UpdateLayout", self.expirationTime, self.count)
	if self.expirationTime and self.count then
		SetTextPosition(self.countdownText, profile.twoTextFirstPosition)
		SetTextPosition(self.countText, profile.twoTextSecondPosition)
	elseif self.count then
		SetTextPosition(self.countText, profile.singleTextPosition)
	elseif self.expirationTime then
		SetTextPosition(self.countdownText, profile.singleTextPosition)
	end
end

function textOverlayProto:UpdateCountdownFont()
	local size, r, g, b = GetCountdownFont(self.timeLeft)
	local countdownText = self.countdownText
	countdownText:SetTextColor(r, g, b)
	countdownText:SetFont(fontFile, size, profile.fontFlag)
	local overflowRatio = max(
		countdownText:GetStringWidth() / (self:GetParent():GetWidth()-8),
		countdownText:GetStringHeight() / (self:GetParent():GetHeight()-8)
	)
	if overflowRatio > 1 then
		return countdownText:SetFont(fontFile, max(5, size / overflowRatio), profile.fontFlag)
	end
end

------------------------------------------------------------------------------
-- Countdown and stack feedback
------------------------------------------------------------------------------

do
	local heap = {}
	local active = {}
	local serial = 0

	local function CreateTextOverlay()
		serial = serial + 1
		local overlay = setmetatable(CreateFrame("Frame", addonName.."TextOverlay"..serial, UIParent), textOverlayMeta)
		overlay:Hide()
		overlay:Initialize()
		return overlay
	end

	function buttonStateProto:ShowTextOverlay()
		if not self.textOverlay then
			local overlay = tremove(heap) or CreateTextOverlay()
			overlay:AttachTo(self.button)
			active[overlay] = true
			self.textOverlay = overlay
		end
		return self.textOverlay
	end

	function buttonStateProto:HideTextOverlay()
		local overlay = self.textOverlay
		if overlay then
			overlay:Detach()
			active[overlay] = nil
			tinsert(heap, overlay)
			self.textOverlay = nil
		end
	end

	function addon:UpdateWidgets()
		fontFile = LSM:Fetch(LSM.MediaType.FONT, profile.fontName)
		countdownFontSize = addon.bigCountdown and profile.largeFontSize or profile.smallFontSize
		countFont:SetFont(fontFile, profile.smallFontSize, profile.fontFlag)
		countFont:SetTextColor(unpack(profile.colorStack))
		GetCountdownFont = profile.dynamicCountdownColor and GetCountdownDynamicFont or GetCountdownStaticFont
		FormatCountdown = profile.preciseCountdown and FormatPreciseCountdown or FormatImpreciseCountdown
		for overlay in pairs(active) do
			overlay:ApplySettings()
		end
	end
end

function buttonStateProto:UpdateTextOverlay()
	if self.expirationTime or self.count then
		local overlay = self:ShowTextOverlay()
		overlay:SetExpirationTime(self.expirationTime)
		overlay:SetCount(self.count)
	else
		self:HideTextOverlay()
	end
end

------------------------------------------------------------------------------
-- Vertex color setter
------------------------------------------------------------------------------

local function SetCheckedTextureColor(button, r, g, b, a)
	local texture = button:GetCheckedTexture()
	local oR, oG, oB, oA = texture:GetVertexColor()
	texture:SetVertexColor(r, g, b, a or 1)
	return oR, oG, oB, oA
end

local function GetNormalTexture(button)
	return button:GetNormalTexture()
end

-- ElvUI compatibility
function addon:HasElvUI()
	SetCheckedTextureColor = function(button, r, g, b, a, blendMode)
		local texture = button:GetCheckedTexture()
		local oR, oG, oB, oA = texture:GetTexture()
		local oBlendMode =  texture:GetBlendMode()
		texture:SetTexture(r, g, b, a or 1)
		texture:SetBlendMode(blendMode or "ADD")
		return oR, oG, oB, oA, oBlendMode
	end
end

-- Masque compatibility
function addon:HasMasque(lib)
	GetNormalTexture = function(button) return lib:GetNormal(button) end
	local callback = function() return addon:RequireUpdate(true) end
	lib:Register("Blizzard", callback)
	lib:Register("Dominos", callback)
	lib:Register("Bartender4", callback)
end

------------------------------------------------------------------------------
-- Highlight feedback
------------------------------------------------------------------------------

do
	local serial = 1
	local heap = {}

	local OnHide, AnimOutFinished

	local function CreateOverlayGlow()
		serial = serial + 1
		local overlay = CreateFrame("Frame", addonName.."ButtonOverlay"..serial, UIParent, "ActionBarButtonSpellActivationAlert")
		overlay.animOut:SetScript("OnFinished", AnimOutFinished)
		overlay:SetScript("OnHide", OnHide)
		return overlay
	end

	function AnimOutFinished(animGroup)
		local overlay = animGroup:GetParent()
		overlay:Hide()
		overlay:ClearAllPoints()
		overlay:SetParent(nil)
		overlay.state.overlay = nil
		overlay.state = nil
		tinsert(heap, overlay)
	end

	function OnHide(button)
		if button.animOut:IsPlaying() then
			button.animOut:Stop()
			return AnimOutFinished(button.animOut)
		end
	end

	function buttonStateProto:ShowOverlayGlow()
		local overlay = self.overlay
		if overlay then
			if overlay.animOut:IsPlaying() then
				overlay.animOut:Stop()
				overlay.animIn:Play()
			end
		else
			overlay = tremove(heap) or CreateOverlayGlow()
			local button = self.button
			local width, height = button:GetSize()
			overlay:SetParent(button)
			overlay:ClearAllPoints()
			overlay:SetSize(width * 1.4, height * 1.4)
			overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -width * 0.2, height * 0.2)
			overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", width * 0.2, -height * 0.2)
			overlay:Show()
			overlay.animIn:Play()
			overlay.state, self.overlay = self, overlay
		end
	end

	function buttonStateProto:HideOverlayGlow()
		local overlay = self.overlay
		if overlay then
			if overlay.animIn:IsPlaying() then
				overlay.animIn:Stop()
			end
			if overlay:IsVisible() then
				overlay.animOut:Play()
			else
				AnimOutFinished(overlay.animOut)
			end
		end
	end
end

------------------------------------------------------------------------------
-- Updating
------------------------------------------------------------------------------

function buttonStateProto:IsUsableAtAll()
	local usable, noPower = self:IsUsable()
	return usable or noPower
end

function buttonStateProto:IsOnCooldown()
	local start, duration, enable = self:GetCooldown()
	return enable ~= 0 and start ~= 0 and duration > 1.5
end

function buttonStateProto:CanShowGlow()
	return (profile.glowOutOfCombat or addon.inCombat)
		and (profile.glowUnusable or self:IsUsableAtAll())
		and (profile.glowOnCooldown or not self:IsOnCooldown())
		and not (self.spellId and IsSpellOverlayed(self.spellId))
end

function buttonStateProto:UpdateGlowing()
	if self.highlight == "glowing" and self:CanShowGlow() then
		self:ShowOverlayGlow()
	else
		self:HideOverlayGlow()
	end
end

function buttonStateProto:UpdateUsable()
	if self.highlight == "glowing" then
		if not profile.glowUnusable then
			return self:UpdateGlowing()
		end
	elseif self.highlight == "dim" then
		self.button.icon:SetVertexColor(0.4, 0.4, 0.4)
		GetNormalTexture(self.button):SetVertexColor(1.0, 1.0, 1.0)
	end
end

function buttonStateProto:UpdateState()
	if self.highlight == "border" then
		local color = profile["color"..self.highlightBorder]
		if color then
			self.button:SetChecked(true)
			if not self.previousCheckedColors then
				self.previousCheckedColors = { SetCheckedTextureColor(self.button, unpack(color)) }
			else
				SetCheckedTextureColor(self.button, unpack(color))
			end
			return
		end
	end
	if self.previousCheckedColors then
		SetCheckedTextureColor(self.button, unpack(self.previousCheckedColors))
		self.previousCheckedColors = nil
	end
end
