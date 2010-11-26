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
-- Import
------------------------------------------------------------------------------

local L = ns.L
local dprint = ns.dprint
local safecall = ns.safecall
local buttons = ns.buttons

------------------------------------------------------------------------------
-- LibSharedMedia
------------------------------------------------------------------------------
local LSM = LibStub('LibSharedMedia-3.0')
local FONTMEDIA = LSM.MediaType.FONT
local FONT_FLAGS = "OUTLINE"

------------------------------------------------------------------------------
-- Countdown formatting
------------------------------------------------------------------------------

local function GetPreciseCountdownText(timeLeft, threshold)
	if timeLeft >= 3600 then
		return format(L["%dh"], floor(timeLeft/3600)), 1 + floor(timeLeft) % 3600
	elseif timeLeft >= 600 then
		return format(L["%dm"], floor(timeLeft/60)), 1 + floor(timeLeft) % 60
	elseif timeLeft >= 60 then
		return format("%d:%02d", floor(timeLeft/60), floor(timeLeft%60)), timeLeft % 1
	elseif timeLeft >= threshold then
		return tostring(floor(timeLeft)), timeLeft % 1
	elseif timeLeft >= 0 then
		return format("%.1f", floor(timeLeft*10)/10), 0
	else
		return "0"
	end
end

local function GetImpreciseCountdownText(timeLeft)
	if timeLeft >= 3600 then
		return format(L["%dh"], ceil(timeLeft/3600)), ceil(timeLeft) % 3600
	elseif timeLeft >= 60 then
		return format(L["%dm"], ceil(timeLeft/60)), ceil(timeLeft) % 60
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

local ScheduleTimer, CancelTimer
do
	local assert, type, next, floor, GetTime = assert, type, next, floor, GetTime
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
			for target, when in next, bucket do
				if when <= now then
					bucket[target] = nil
					targets[target] = nil
					safecall(target.OnUpdate, target)
				end
			end
		end
		lastIndex = newIndex
	end
end

------------------------------------------------------------------------------
-- Timer frame handling
------------------------------------------------------------------------------

local timerProto = setmetatable({}, {__index = CreateFrame("Frame")})
local timerMeta = { __index = timerProto }

local function SetTextPosition(text, position)
	text:SetJustifyH(position:match('LEFT') or position:match('RIGHT') or 'MIDDLE')
	text:SetJustifyV(position:match('TOP') or position:match('BOTTOM') or 'CENTER')
end

function timerProto:UpdateTextLayout()
	local stackText, countdownText = self.stackText, self.countdownText
	if countdownText:IsShown() and stackText:IsShown() then
		SetTextPosition(countdownText, ns.db.profile.twoTextFirstPosition)
		SetTextPosition(stackText, ns.db.profile.twoTextSecondPosition)
	elseif countdownText:IsShown() then
		SetTextPosition(countdownText, ns.db.profile.singleTextPosition)
	elseif stackText:IsShown() then
		SetTextPosition(stackText, ns.db.profile.singleTextPosition)
	end
end

function timerProto:Skin()
	local font = LSM:Fetch(FONTMEDIA, ns.db.profile.fontName)

	local countdownText = self.countdownText
	countdownText.fontName = font
	countdownText.baseFontSize = ns.db.profile[InlineAura.bigCountdown and "largeFontSize" or "smallFontSize"]
	countdownText:SetFont(font, countdownText.baseFontSize, FONT_FLAGS)
	countdownText:SetTextColor(unpack(ns.db.profile.colorCountdown))

	local stackText = self.stackText
	stackText:SetFont(font, ns.db.profile.smallFontSize, FONT_FLAGS)
	stackText:SetTextColor(unpack(ns.db.profile.colorStack))

	self:UpdateTextLayout()
end

function timerProto:OnUpdate()
	self:UpdateCountdown(GetTime())
end

local dynamicModifiers = {
	-- { font scale, r, g, b }
	{ 1.3, 1, 0, 0 }, -- soon
	{ 1.0, 1, 1, 0 }, -- in less than a minute
	{ 0.8, 1, 1, 1 }, -- in more than a minute
}

function timerProto:UpdateCountdown(now)
	local timeLeft = self.expirationTime - now
	local displayTime, delay = GetCountdownText(timeLeft, ns.db.profile.preciseCountdown, ns.db.profile.decimalCountdownThreshold)
	local countdownText = self.countdownText
	countdownText:SetText(displayTime)
	if ns.db.profile.dynamicCountdownColor then
		local phase = (timeLeft <= 5 and 1) or (timeLeft <= 60 and 2) or 3
		if phase ~= self.dynamicPhase then
			self.dynamicPhase = phase
			local scale, r, g, b = unpack(dynamicModifiers[phase])
			if InlineAura.bigCountdown then
				countdownText:SetFont(countdownText.fontName, countdownText.actualFontSize * scale, FONT_FLAGS)
			end
			countdownText:SetTextColor(r, g, b)
		end
	end
	if delay then
		ScheduleTimer(self, math.min(delay, timeLeft))
	end
end

function timerProto:Display(expirationTime, count, now)
	local stackText, countdownText = self.stackText, self.countdownText

	if count then
		stackText:SetText(count)
		stackText:Show()
	else
		stackText:Hide()
	end

	if expirationTime then
		self.expirationTime = expirationTime
		countdownText:Show()
		countdownText:SetFont(countdownText.fontName, countdownText.baseFontSize, FONT_FLAGS)
		local sizeRatio = countdownText:GetStringWidth() / (self:GetWidth()-4)
		if sizeRatio > 1 then
			countdownText.actualFontSize = countdownText.baseFontSize / sizeRatio
			countdownText:SetFont(countdownText.fontName, countdownText.actualFontSize, FONT_FLAGS)
		else
			countdownText.actualFontSize = countdownText.baseFontSize
		end
		self.dynamicPhase = nil
		self:UpdateCountdown(now)
	else
		CancelTimer(self)
		countdownText:Hide()
	end

	if stackText:IsShown() or countdownText:IsShown() then
		self:Show()
		self:UpdateTextLayout(self)
	else
		self:Hide()
	end
end

local function CreateTimerFrame(button)
	local timer = setmetatable(CreateFrame("Frame", nil, button), timerMeta)
	local cooldown = _G[button:GetName()..'Cooldown']
	timer:SetFrameLevel(cooldown:GetFrameLevel() + 5)
	timer:SetAllPoints(cooldown)
	timer:SetToplevel(true)
	timer:Hide()
	timer:SetScript('OnHide', CancelTimer)

	local countdownText = timer:CreateFontString(nil, "OVERLAY")
	countdownText:SetAllPoints(timer)
	countdownText:Show()
	timer.countdownText = countdownText

	local stackText = timer:CreateFontString(nil, "OVERLAY")
	stackText:SetAllPoints(timer)
	timer.stackText = stackText

	timer:Skin()

	return timer
end

------------------------------------------------------------------------------
-- Visual feedback hooks
------------------------------------------------------------------------------

local timerFrames = {}

function ns.UpdateTimer(self)
	local state = buttons[self]
	if not state then return end
	if state.name and (state.expirationTime or state.count) then
		local now = GetTime()
		local expirationTime = state.expirationTime
		if expirationTime and expirationTime <= now then
			expirationTime = nil
		end
		local count = state.count
		if count == 0 then
			count = nil
		end
		if expirationTime or count then
			local frame = timerFrames[self]
			if not frame then
				frame = CreateTimerFrame(self)
				timerFrames[self] = frame
			end
			return frame:Display(expirationTime, count, now)
		end
	end
	if timerFrames[self] then
		timerFrames[self]:Hide()
	end
end

function ns.ReskinTimers()
	for button, frame in pairs(timerFrames) do
		frame:Skin()
	end
end

function ns.ActionButton_HideOverlayGlow_Hook(self)
	local state = buttons[self]
	if not state then return end
	if state.highlight == "glowing" then
		--@debug@
		self:Debug("Enforcing glowing for", state.name)
		--@end-debug@
		return ActionButton_ShowOverlayGlow(self)
	end
end

local function SetVertexColor(texture, r, g, b, a)
	texture:SetVertexColor(r, g, b, a)
end

function ns.UpdateButtonState_Hook(self)
	local state = buttons[self]
	if not state then return end
	local texture = self:GetCheckedTexture()
	if state.highlight == "border" then
		--@debug@
		self:Debug("Showing border for", state.name)
		--@end-debug@
		local color = ns.db.profile['color'..(state.isDebuff and "Debuff" or "Buff")..(state.isMine and 'Mine' or 'Others')]
		self:SetChecked(true)
		SetVertexColor(texture, unpack(color))
	else
		texture:SetVertexColor(1, 1, 1)
	end
end

------------------------------------------------------------------------------
-- LibButtonFacade compatibility
------------------------------------------------------------------------------

local LBF

local function LBF_SetVertexColor(texture, r, g, b, a)
	local R, G, B, A = texture:GetVertexColor()
	texture:SetVertexColor(r*R, g*G, b*B, a*(A or 1))
end

local function LBF_Callback()
	InlineAura:RequireUpdate(true)
end

function ns.EnableLibButtonFacadeSupport()
	local LBF = LibStub('LibButtonFacade', true)
	if not LBF then return end
	SetVertexColor = LBF_SetVertexColor
	ns.RegisterLBFCallback("Blizzard")
end

function ns.RegisterLBFCallback(skin)
	if LBF then
		LBF:RegisterSkinCallback(skin, LBF_Callback)
	end
end

