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

local addonName, addon = ...

------------------------------------------------------------------------------
-- Our main frame
------------------------------------------------------------------------------

LibStub('AceAddon-3.0'):NewAddon(addon, 'InlineAura', 'AceEvent-3.0')

------------------------------------------------------------------------------
-- Retrieve the localization table
------------------------------------------------------------------------------

local L = addon.L

------------------------------------------------------------------------------
-- Locals
------------------------------------------------------------------------------

local db

local auraChanged = {}
local tokenChanged = {}

local tokenGUIDs = {}
local tokenUnits = {}

local needUpdate = false
local configUpdated = false

local buttons = {}
local newButtons = {}
local activeButtons = {}
addon.buttons = buttons

------------------------------------------------------------------------------
-- Make often-used globals local
------------------------------------------------------------------------------

local UnitCanAssist, UnitCanAttack = UnitCanAssist, UnitCanAttack
local UnitGUID, UnitIsUnit, UnitAura = UnitGUID, UnitIsUnit, UnitAura
local IsHarmfulSpell, IsHelpfulSpell = IsHarmfulSpell, IsHelpfulSpell
local unpack, type, pairs, rawget, next = unpack, type, pairs, rawget, next
local strsplit, strtrim, strsub, select = strsplit, strtrim, strsub, select
local format, ceil, floor, tostring, gsub = format, ceil, floor, tostring, gsub
local GetTotemInfo, GetActionInfo, GetItemInfo = GetTotemInfo, GetActionInfo, GetItemInfo
local GetNumTrackingTypes, GetTrackingInfo = GetNumTrackingTypes, GetTrackingInfo
local SecureCmdOptionParse, GetMacroBody = SecureCmdOptionParse, GetMacroBody
local GetCVarBool, SecureButton_GetModifiedUnit = GetCVarBool, SecureButton_GetModifiedUnit
local GetMacroSpell, GetMacroItem, IsHelpfulItem = GetMacroSpell, GetMacroItem, IsHelpfulItem

------------------------------------------------------------------------------
-- Libraries and helpers
------------------------------------------------------------------------------

local LSM = LibStub('LibSharedMedia-3.0')

local function dprint() end
--@debug@
if AdiDebug then
	dprint = AdiDebug:GetSink('InlineAura')
end
--@end-debug@
addon.dprint = dprint

------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------

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
		fontName      = LSM:GetDefault(LSM.MediaType.FONT),
		smallFontSize = 13,
		largeFontSize = 20,
		fontFlag      = "OUTLINE",
		colorBuffMine     = { 0.0, 1.0, 0.0, 1.0 },
		colorBuffOthers   = { 0.0, 1.0, 1.0, 1.0 },
		colorDebuffMine   = { 1.0, 0.0, 0.0, 1.0 },
		colorDebuffOthers = { 1.0, 1.0, 0.0, 1.0 },
		colorCountdown    = { 1.0, 1.0, 1.0, 1.0 },
		colorStack        = { 1.0, 1.0, 0.0, 1.0 },
		spells = {
			['**'] = {
				auraType = 'regular',
				highlight = 'border',
			},
		},
		spellStatuses = {
			['*'] = 'global'
		},
		enabledUnits = {
			focus = true,
			mouseover = false,
		},
		configSpellSources = {
			['*'] = false,
			preset = true,
			actionbars = true,
		},
	},
}

local PRESETS = {}
addon.PRESETS = PRESETS

-- Events only needed if the unit is enabled
local UNIT_EVENTS = {
	focus = 'PLAYER_FOCUS_CHANGED',
	mouseover = 'UPDATE_MOUSEOVER_UNIT',
}

------------------------------------------------------------------------------
-- Some Unit helpers
------------------------------------------------------------------------------

local MY_UNITS = { player = true, pet = true, vehicle = true }

function addon.UnitIsBuffable(unit)
	return MY_UNITS[unit] or UnitCanAssist('player', unit)
end

function addon.UnitIsDebuffable(unit)
	return UnitCanAttack('player', unit)
end

function addon.GetBorderHighlight(isDebuff, isMine)
	return strjoin('', 'border', isDebuff and "Debuff" or "Buff", isMine and "Mine" or "Others")
end

local UnitIsBuffable = addon.UnitIsBuffable
local UnitIsDebuffable = addon.UnitIsDebuffable
local GetBorderHighlight = addon.GetBorderHighlight

------------------------------------------------------------------------------
-- State plugins
------------------------------------------------------------------------------

local stateModules = {}
local stateKeywords = {}

local statePrototype = {}
statePrototype.auraType = "special"
statePrototype.specialTarget = "player"
statePrototype.keywords = {}

if AdiDebug then
	AdiDebug:Embed(statePrototype, "InlineAura")
else
	function statePrototype.Debug() end
end

addon.allKeywords = {}

function statePrototype:OnInitialize()
	for i, keyword in pairs(self.keywords) do
		addon.allKeywords[keyword] = self
	end
	local features, defaults = self.features, self.defaults
	self.db = addon.db:RegisterNamespace(self.moduleName, { profile = {
		enabled = true,
		countdown = features and features.countdown and true or nil,
		stacks = features and features.stacks and true or nil,
		highlight = features and features.highlight and true or nil,
		highlightThreshold = features and features.highlightThreshold and (defaults and defaults.highlightThreshold or features.highlightMaxThreshold or 1) or nil,
	}})
	self:SetEnabledState(self.db.profile.enabled)
	if self.PostInitialize then
		self:PostInitialize()
	end
end

function statePrototype:OnEnable()
	for i, keyword in pairs(self.keywords) do
		stateKeywords[keyword] = self
	end
	if self.PostEnable then
		self:PostEnable()
	end
end

function statePrototype:OnDisable()
	for i, keyword in pairs(self.keywords) do
		stateKeywords[keyword] = nil
	end
end

function statePrototype:CanTestUnit(unit, aura, spell)
	if self.auraType == "special" then
		if self.specialTarget == "foe" then
			return UnitIsDebuffable(unit)
		elseif self.specialTarget == "friend" then
			return UnitIsBuffable(unit)
		else
			return unit == self.specialTarget
		end
	elseif self.auraType == "self" then
		return unit == "player"
	elseif self.auraType == "pet" then
		return unit == "pet"
	else
		return true
	end
end

function statePrototype:Test(aura, unit, onlyMyBuffs, onlyMyDebuffs, spell)
	-- Return something meaningful there
end

-- Registry methods

function addon:NewStateModule(name, ...)
	assert(not stateModules[name], format("State module %q already defined", name))
	local special = self:NewModule(name, statePrototype, 'AceEvent-3.0', ...)
	stateModules[name] = special
	dprint("New state module:", name)
	return special
end

function addon:IterateStateModules()
	return next, stateModules
end

------------------------------------------------------------------------------
-- Aura lookup
------------------------------------------------------------------------------

local function FirstNotNull(a, b) if a ~= nil then return a else return b end end

local function CheckAura(aura, unit, onlyMyBuffs, onlyMyDebuffs)
	local isDebuff = false
	local name, _, _, count, _, duration, expirationTime, caster = UnitDebuff(unit, aura, nil, onlyMyDebuffs and "PLAYER" or nil)
	if name then
		isDebuff = true
	else
		name, _, _, count, _, duration, expirationTime, caster = UnitBuff(unit, aura, nil, onlyMyBuffs and "PLAYER" or nil)
	end
	if name then
		if duration == 0 then duration = nil end
		if count == 0 then count = nil end
		return count, count, duration and expirationTime, expirationTime, true, GetBorderHighlight(isDebuff, MY_UNITS[caster]), isDebuff and 10 or 20
	end
end

local function AuraLookup(unit, onlyMyBuffs, onlyMyDebuffs, ...)
	local hasCount, count, hasCountdown, expirationTime, hasHighlight, highlight
	local hasNewCount, newCount, hasNewCountdown, newExpiratiomTime, hasNewHighlight, newHighlight, newPriority
	local priority = 0
	local spell = ...
	for i = 1, select('#', ...) do
		local aura = select(i, ...)
		local module = stateKeywords[aura]
		if module and module:CanTestUnit(unit, aura, spell) then
			hasNewCount, newCount, hasNewCountdown, newExpiratiomTime, hasNewHighlight, newHighlight, newPriority = module:Test(aura, unit, onlyMyBuffs, onlyMyDebuffs, spell)
			if not newPriority then newPriority = 30 end
			dprint("AuraLookup", aura, module, "=>", hasNewCount, newCount, hasNewCountdown, newExpiratiomTime, hasNewHighlight, newHighlight)
		else
			hasNewCount, newCount, hasNewCountdown, newExpiratiomTime, hasNewHighlight, newHighlight, newPriority = CheckAura(aura, unit, onlyMyBuffs, onlyMyDebuffs)
			if not newPriority then newPriority = 0 end
		end
		if newPriority > priority then
			-- If priority goes up, replace old values with the new ones
			if hasNewCount then
				hasCount, count, priority = true, newCount, newPriority
			end
			if hasNewCountdown then
				hasCountdown, expirationTime, priority = true, newExpiratiomTime, newPriority
			end
			if hasNewHighlight then
				hasHighlight, highlight, priority = true, newHighlight, newPriority
			end
		elseif newPriority == priority then
			-- With same priorities, smartly combine values
			if hasNewCount and hasNewCountdown and hasCount and hasCountdown then
				if newCount > count then
					count, expirationTime = newCount, newExpiratiomTime
				elseif newCount == count and newExpiratiomTime > expirationTime then
					expirationTime = newExpiratiomTime
				end
			else
				if strmatch(aura, "ENERGY") then
					dprint("AuraLookup(count)", aura, "current=", hasCount, count, "new=", hasNewCount, newCount)
				end
				if hasNewCount and newCount > (hasCount and count or 0) then
					hasCount, count = true, newCount
				end
				if hasNewCountdown and newExpiratiomTime > (hasCountdown and expirationTime or 0) then
					hasCountdown, expirationTime = true, newExpiratiomTime
				end
			end
			if hasNewHighlight then
				hasHighlight, highlight = true, newHighlight
			end
		end
	end
	return hasCount, count, hasCountdown, expirationTime, hasHighlight, highlight
end

local function GetAuraToDisplay(spell, target, specific)

	local hasCount, count, hasCountdown, expirationTime, hasHighlight, highlight
	local hideStack, hideCountdown

	if not specific then
		-- No specific settings: pretty straightforward
		hideStack, hideCountdown = db.profile.hideStack, db.profile.hideCountdown
		hasCount, count, hasCountdown, expirationTime, hasHighlight, highlight = CheckAura(spell, target, db.profile.onlyMyBuffs, db.profile.onlyMyDebuffs)

	else

		if specific.auraType == "special" then
			-- Special: use only the matching module

			local module = stateKeywords[specific.special]
			if module and module:CanTestUnit(target, specific.special, spell) then
				hasCount, count, hasCountdown, expirationTime, hasHighlight, highlight = module:Test(specific.special, target, true, true, spell)
				if hasHighlight and highlight then
					highlight = specific.highlight or "glowing"
				end
			end

		else
			-- Has specific settings but not special

			-- Get boolean settings
			hideStack = FirstNotNull(specific.hideStack, db.profile.hideStack)
			hideCountdown = FirstNotNull(specific.hideCountdown, db.profile.hideCountdown)
			local onlyMyBuffs = FirstNotNull(specific.onlyMine, db.profile.onlyMyBuffs)
			local onlyMyDebuffs = FirstNotNull(specific.onlyMine, db.profile.onlyMyDebuffs)

			if specific.aliases then
				-- Has aliases: we need to test them all and combine the results
				hasCount, count, hasCountdown, expirationTime, hasHighlight, highlight = AuraLookup(target, onlyMyBuffs, onlyMyDebuffs, spell, unpack(specific.aliases))
			else
				-- No alias: simple test
				hasCount, count, hasCountdown, expirationTime, hasHighlight, highlight = CheckAura(spell, target, onlyMyBuffs, onlyMyDebuffs)
			end

			if hasHighlight and highlight == true then
				highlight = "glowing"
			end
		end

		if not hasHighlight then
			highlight = nil
		end

		local prevHighlight = highlight
		if specific.highlight == "none" then
			highlight = nil
		else
			local show, hide = specific.highlight, nil
			if highlight == "glowing" then
				-- Glowing has precedence
				show = highlight
			elseif show == "border" and highlight and strmatch(highlight, '^border') then
				-- Reuse provided border color
				show = highlight
			elseif show == "dim" then
				-- These one has inverted logic
				show, hide = hide, show
			end
			if specific.invertHighlight then
				-- Invert if the user asked for it
				show, hide = hide, show
			end
			-- Select the state that actually matches the result from AuraLookup
			if highlight then
				highlight = show
			else
				highlight = hide
			end
			if highlight == "border" then
				-- Still "border", a specific color must be chosen
				highlight = GetBorderHighlight(UnitIsDebuffable(target), true)
			end
		end
	end

	return (hasCount and not hideStack and count ~= 0) and count or nil, (hasCountdown and not hideCountdown) and expirationTime or nil, highlight
end

------------------------------------------------------------------------------
-- Aura updating
------------------------------------------------------------------------------

function addon:GetSpellSettings(id)
	local status = db.profile.spellStatuses[id]
	if status == "preset" then
		return PRESETS[id], status
	elseif status == "user" then
		return db.profile.spells[id], status
	else
		return nil, status
	end
end

local function FilterEmpty(v) if v and strtrim(tostring(v)) ~= "" and v ~= 0 then return v end end

local optionPrefixes = {
	['#showtooltip'] = true,
	['#show'] = true,
}
for _, cmd in pairs({"CAST", "CASTRANDOM", "CASTSEQUENCE", "USE", "USERANDOM"}) do
	for i = 1, 16 do
		local alias = _G["SLASH_"..cmd..i]
		if alias then
			optionPrefixes[alias] = true
		else
			break
		end
	end
end

local function FindMacroOptions(...)
	for i = 1, select('#', ...) do
		local line = select(i, ...)
		local prefix, suffix = strsplit(" ", strtrim(line), 2)
		if prefix and suffix and optionPrefixes[strtrim(strlower(prefix))] then
			return suffix
		end
	end
end

local macroOptionsMemo = setmetatable({}, {__index = function(self, index)
	local body = assert(GetMacroBody(index), format("Can't find macro body for %q", index))
	local options = FindMacroOptions(strsplit("\n", body))
	self[index] = options or false
	return options
end})

local function GuessMacroTarget(index)
	local options = macroOptionsMemo[index]
	if options then
		local action, target = SecureCmdOptionParse(options)
		return FilterEmpty(action) and FilterEmpty(target)
	end
end

local function ApplyVehicleModifier(unit)
	if UnitHasVehicleUI("player") then
		if unit == "player" then
			return "vehicle"
		elseif unit == "pet" then
			return
		end
	elseif unit == "vehicle" then
		return
	end
	return unit
end

local function AnalyzeAction(action, param)
	if not action or not param then return end
	local item, spell
	if action == "item" then
		item = GetItemInfo(param)
		spell = GetItemSpell(item) or item
	elseif action == "spell" then
		spell = GetSpellInfo(param)
	end
	if not spell then
		return -- Nothing to handle
	end

	local auraType = item and "self" or "regular"
	local id = item or spell

	-- Check for specific settings
	local specific, status = addon:GetSpellSettings(id)
	if status == "ignore" then
		return -- Don't want to handle
	end
	if specific then
		auraType = specific.auraType
	end

	-- Check modules, either through "special" aura type or spell hooks
	local module
	if auraType == "special" then
		module = specific.special and stateKeywords[specific.special]
		if not module then
			--@debug@
			dprint("Unknown module for", specific.special)
			--@end-debug@
			return
		end
	end
	if module then
		auraType = module.auraType
	end

	--@debug@
	if specific and specific.auraType == "special" then
		dprint(id, "special", specific.special, module, '=>', auraType, module.specialTarget)
	end
	--@end-debug@

	-- Solve special aura types ASAP
	if auraType == "special" then
		if module.specialTarget ~= "regular" then
			return spell, module.specialTarget, specific
		end
	elseif auraType == "self" then
		return spell, "player", specific
	elseif auraType == "pet" then
		return spell, "pet", specific
	end

	-- Educated guess
	local helpful
	if item then
		helpful = IsHelpfulItem(item)
	else
		helpful = IsHelpfulSpell(spell)
	end
	return spell, helpful and "friend" or "foe", specific
end

local function GetMacroAction(index)
	local macroSpell = GetMacroSpell(index)
	if macroSpell then
		return "spell", macroSpell
	end
	local macroItem = GetMacroItem(index)
	if macroItem then
		return "item", macroItem
	end
end

local function UpdateButtonAura(self, force)
	local state = buttons[self]
	if not state then return end

	local spell, targetHint, specific = state.spell, state.targetHint, state.specific
	local target
	if targetHint == "friend" or targetHint == "foe" then
		if state.action == "macro" then
			target = GuessMacroTarget(state.param)
		else
			target = FilterEmpty(SecureButton_GetModifiedUnit(self))
		end
	end
	if not target then
		target = tokenUnits[targetHint]
	end

	-- Get the GUID
	local guid = target and UnitGUID(target)

	if force or guid ~= state.guid or auraChanged[guid or state.guid or false] then
		--@debug@
		self:Debug("UpdateButtonAura: updating because", (force and "forced") or (guid ~= state.guid and "guid changed") or "aura changed", "|", spell, target, specific, guid)
		--@end-debug@
		state.guid = guid

		local count, expirationTime, highlight
		if spell and target and (targetHint ~= "foe" or UnitIsDebuffable(target)) and (targetHint ~= "friend" or UnitIsBuffable(target)) and UnitExists(target) and UnitIsVisible(target) and UnitIsConnected(target) and not UnitIsDeadOrGhost(target) then
			count, expirationTime, highlight = GetAuraToDisplay(spell, target, specific)
			--@debug@
			self:Debug("GetAuraToDisplay", spell, target, specific, "=>", "count=", count, "expirationTime=", expirationTime, "highlight=", highlight)
			--@end-debug@
		end

		if state.highlight ~= highlight or force then
			--@debug@
			self:Debug("GetAuraToDisplay: updating highlight")
			--@end-debug@
			state.highlight = highlight
			self:__IA_Update()
		end

		if state.count ~= count or state.expirationTime ~= expirationTime or force then
			--@debug@
			self:Debug("GetAuraToDisplay: updating countdown and/or stack", expirationTime, count)
			--@end-debug@
			state.count, state.expirationTime = count, expirationTime
			addon.ShowCountdownAndStack(self, expirationTime, count)
		end
	end
end

------------------------------------------------------------------------------
-- Action handling
------------------------------------------------------------------------------

local function UpdateAction_Hook(self, forceUpdate)
	local state = buttons[self]
	if not state then return end
	local action, param
	if self:IsVisible() then
		action, param = self:__IA_GetAction()
		if action == 'action' then
			local actionAction, actionParam, _, spellId = GetActionInfo(param)
			if actionAction == 'companion' then
				action, param = 'spell', spellId
			elseif actionAction == "spell" or actionAction == "item" or actionAction == "macro" then
				action, param = actionAction, actionParam
			else
				action, param = nil, nil
			end
		end
		state.spellId = (action == "spell") and tonumber(param)
	end
	if forceUpdate or action == "macro" or action ~= state.action or param ~= state.param then
		state.action, state.param = action, param, action
		local spell, targetHint, specific, active
		if action and param then
			if action == "macro" then
				local macroAction, macroParam = GetMacroAction(param)
				if macroAction and macroParam then
					spell, targetHint, specific = AnalyzeAction(macroAction, macroParam)
					active = "*"
				end
			else
				spell, targetHint, specific = AnalyzeAction(action, param)
				active = targetHint
			end
		end
		activeButtons[self] = active
		if state.spell ~= spell or state.targetHint ~= targetHint or state.specific ~= specific then
			state.spell, state.targetHint, state.specific = spell, targetHint, specific
			forceUpdate = true
		end
		--@debug@
		self:Debug("UpdateAction_Hook: action changed =>", action, param, "static:", spell, targetHint, specific, forceUpdate and "| forcing update")
		--@end-debug@
		return UpdateButtonAura(self, forceUpdate)
	end
end

------------------------------------------------------------------------------
-- Button initializing
------------------------------------------------------------------------------

local function Blizzard_GetAction(self)
	return 'action', self.action
end

local function Blizzard_Update(self)
	ActionButton_UpdateOverlayGlow(self)
	ActionButton_UpdateState(self)
	ActionButton_UpdateUsable(self)
end

local function LAB_GetAction(self)
	return self:GetAction()
end

local function LAB_Update(self)
	ActionButton_UpdateOverlayGlow(self)
	return self:UpdateAction(true)
end

local function NOOP() end
local function InitializeButton(self)
	if buttons[self] then return end
	local state = { button = self }
	buttons[self] = state
	if AdiDebug then
		AdiDebug:Embed(self, 'InlineAura')
	elseif not self.Debug then
		self.Debug = NOOP
	end
	if AdiProfiler then
		AdiProfiler:RegisterFrame(self, "ia:ActionButton")
	end
	if self.__LAB_Version then
		self.__IA_GetAction = LAB_GetAction
		self.__IA_Update = LAB_Update
		self:HookScript('OnShow', UpdateAction_Hook)
	else
		self.__IA_GetAction = Blizzard_GetAction
		self.__IA_Update = Blizzard_Update
	end
	return UpdateAction_Hook(self)
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

local function UpdateUnitListeners()
	for unit, event in pairs(UNIT_EVENTS) do
		if db.profile.enabledUnits[unit] then
			addon:RegisterEvent(event)
		else
			addon:UnregisterEvent(event)
		end
	end
end

------------------------------------------------------------------------------
-- Bucketed updates
------------------------------------------------------------------------------

local function UpdateConfig()
	-- Update event listening based on units
	UpdateUnitListeners()

	-- Update timer skins
	addon:UpdateWidgets()
end

local function UpdateMouseover(elapsed)
	-- Track mouseover changes, since most events aren't fired for mouseover
	if tokenGUIDs['mouseover'] ~= UnitGUID('mouseover') then
		addon:UPDATE_MOUSEOVER_UNIT("OnUpdate-changed")
	elseif tokenUnits['mouseover'] == 'mouseover' then
		addon.mouseoverTimer = addon.mouseoverTimer + elapsed
		if addon.mouseoverTimer > 0.5 then
			addon:AuraChanged('mouseover')
		end
	end
end

local function InitializeNewButtons()
	-- Initializing any pending buttons
	for button in pairs(newButtons) do
		InitializeButton(button)
	end
end

local function UpdateButtons()
	-- Update all buttons
	if configUpdated then
		for button in pairs(buttons) do
			UpdateAction_Hook(button, true)
		end
	elseif needUpdate then
		for button in pairs(activeButtons) do
			UpdateButtonAura(button, needUpdate)
		end
	else
		for button, hint in pairs(activeButtons) do
			if hint == "*" or tokenChanged[hint] or auraChanged[tokenGUIDs[hint]] then
				UpdateButtonAura(button, needUpdate)
			end
		end
	end
end

function addon:OnUpdate(elapsed)
	-- Configuration has been updated
	if configUpdated then
		UpdateConfig()
	end

	-- Watch for mouseover aura if we can't get UNIT_AURA events
	if tokenGUIDs['mouseover'] then
		UpdateMouseover(elapsed)
	end

	-- Handle new buttons
	if next(newButtons) then
		InitializeNewButtons()
		wipe(newButtons)
	end

	-- Update buttons
	if needUpdate or configUpdated or next(auraChanged) or next(tokenChanged) then
		UpdateButtons()
		needUpdate, configUpdated = false, false
		wipe(auraChanged)
		wipe(tokenChanged)
	end

end

function addon:RequireUpdate(config)
	configUpdated = config
	needUpdate = true
end

function addon:RegisterButtons(prefix, count)
	for id = 1, count do
		local button = _G[prefix .. id]
		if button and not buttons[button] and not newButtons[button] then
			newButtons[button] = true
		end
	end
end

------------------------------------------------------------------------------
-- Tokens and GUIDs handling
------------------------------------------------------------------------------

function addon:UpdateToken(token, unitHint)
	local guid, unit
	if unitHint ~= "none" then
		unit = ApplyVehicleModifier(unitHint or token)
		guid = unit and UnitGUID(unit)
	end
	tokenUnits[token] = unit
	local oldGUID = tokenGUIDs[token]
	if guid ~= oldGUID then
		--@debug@
		dprint(token, "changed:", oldGUID, "=>", guid)
		--@end-debug@
		tokenGUIDs[token] = guid
		tokenChanged[token] = true
	end
end

local function GetUnitForMouseover()
	if UnitIsUnit("mouseover", "vehicle") then
		return "vehicle"
	elseif UnitIsUnit("mouseover", "player") then
		return "player"
	elseif UnitIsUnit("mouseover", "pet") then
		return "pet"
	elseif GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			if UnitIsUnit("mouseover", "raid"..i) then
				return "raid"..i
			elseif UnitIsUnit("mouseover", "raidpet"..i) then
				return "raidpet"..i
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers() do
			if UnitIsUnit("mouseover", "party"..i) then
				return "party"..i
			elseif UnitIsUnit("mouseover", "partypet"..i) then
				return "partypet"..i
			end
		end
	elseif UnitIsUnit("mouseover", "target") then
		return "target"
	elseif UnitIsUnit("mouseover", "focus") then
		return "focus"
	end
	return "mouseover"
end

function addon:UpdateTokens(which)
	if which == "all" then
		self:UpdateToken("player")
	end
	if which == "all" or which == "pet" then
		self:UpdateToken("pet")
	end
	if which == "all" or which == "focus" then
		self:UpdateToken("focus", db.profile.enabledUnits.focus and "focus" or "none")
	end
	if which == "all" or which == "target" or which == "focus" then
		local target = "target"
		if IsModifiedClick("SELFCAST") then
			target = "player"
		elseif IsModifiedClick("FOCUSCAST") then
			target = "focus"
		end
		self:UpdateToken("target", target)
		self:UpdateToken("friend", (UnitIsBuffable(target) and target) or ((addon.db.profile.emulateAutoSelfCast or GetCVarBool("autoSelfCast")) and "player") or "none")
		self:UpdateToken("foe", UnitIsDebuffable(target) and target or "none")
	end
	self:UpdateToken("mouseover", db.profile.enabledUnits.mouseover and GetUnitForMouseover() or "none")
end

function addon:AuraChanged(unit)
	local guid = tokenGUIDs[unit] or UnitGUID(unit)
	if guid then
		--@debug@
		if not auraChanged[guid] then
			dprint(unit, "aura changed", guid)
		end
		--@end-debug@
		auraChanged[guid] = true
		if UnitIsUnit(unit, "mouseover") then
			self.mouseoverTimer = 0
		end
	end
end

------------------------------------------------------------------------------
-- Event handling
------------------------------------------------------------------------------

function addon:UNIT_AURA(event, unit)
	self:AuraChanged(unit)
end

function addon:UNIT_PET(event, unit)
	if unit == "player" then
		self:UpdateTokens("pet")
	end
end
addon.UNIT_ENTERED_VEHICLE = addon.UNIT_PET

function addon:PLAYER_ENTERING_WORLD(event)
	self:UpdateTokens("all")
end

function addon:PLAYER_FOCUS_CHANGED(event)
	self:UpdateTokens("focus")
end

function addon:PLAYER_TARGET_CHANGED(event)
	self:UpdateTokens("target")
end
addon.MODIFIER_STATE_CHANGED = addon.PLAYER_TARGET_CHANGED

function addon:UPDATE_MOUSEOVER_UNIT(event)
	self:UpdateTokens("mouseover")
end

function addon:UNIT_FACTION(event, unit)
	self:UpdateTokens(unit)
end

function addon:CVAR_UPDATE(event, name)
	if name == 'AUTO_SELF_CAST_TEXT' then
		return self:RequireUpdate(true)
	end
end

function addon:UPDATE_BINDINGS(event)
	return self:RequireUpdate(true)
end

function addon:UPDATE_MACROS(event)
	wipe(macroOptionsMemo)
	return self:RequireUpdate(true)
end

local overlayedSpells = {}
addon.overlayedSpells = overlayedSpells

function addon:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(event, id)
	local name = GetSpellInfo(id)
	local enable = (event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW") or nil
	if overlayedSpells[name] ~= enable then
		addon.dprint("Spell glowing", name, '=>', enable)
		overlayedSpells[name] = enable
		for button in pairs(activeButtons) do
			local state = buttons[button]
			if state.action == "macro" and state.spell == name then
				ActionButton_UpdateOverlayGlow(button)
			end
		end
	end
end
------------------------------------------------------------------------------
-- Addon and library support
------------------------------------------------------------------------------

local addonSupport = {
	Dominos = function(self)
		self:RegisterButtons("DominosActionButton", 120)
		hooksecurefunc(Dominos.ActionButton, "Skin", ActionButton_OnLoad_Hook)
	end,
	OmniCC = function(self)
		self.bigCountdown = false
	end,
	Bartender4 = function(self)
		self:RegisterButtons("BT4Button", 120) -- should not be necessary
	end,
	tullaRange = function(self)
		hooksecurefunc(tullaRange, "SetButtonColor", self.UpdateButtonUsable_Hook)
	end,
}
addonSupport.CooldownCount = addonSupport.OmniCC
addonSupport.tullaCC = addonSupport.OmniCC

local librarySupport = {
	["LibButtonFacade"] = function(self, lib, minor)
		self:HasLibButtonFacade(lib)
		local callback = function()	return self:RequireUpdate(true)	end
		lib:RegisterSkinCallback("Blizzard", callback)
		lib:RegisterSkinCallback("Dominos", callback)
		lib:RegisterSkinCallback("Bartender4", callback)
	end,
	["LibActionButton-1.0"] = function(self, lib, minor)
		if minor >= 11 then -- Callbacks and GetAllButtons() are supported since minor 11
			local UpdateButtonState_Hook = addon.UpdateButtonState_Hook
			local UpdateButtonUsable_Hook = addon.UpdateButtonUsable_Hook
			lib.RegisterCallback(self, "OnButtonCreated", function(_, button) return InitializeButton(button) end)
			lib.RegisterCallback(self, "OnButtonUpdate", function(_, button) return UpdateAction_Hook(button) end)
			lib.RegisterCallback(self, "OnButtonUsable", function(_, button) return UpdateButtonUsable_Hook(button) end)
			lib.RegisterCallback(self, "OnButtonState", function(_, button) return UpdateButtonState_Hook(button) end)
			for button in pairs(lib:GetAllButtons()) do
				newButtons[button] = true
			end
		else
			local _, loader = issecurevariable(lib, "CreateButton")
			print("|cffff0000addon: the version of LibActionButton-1.0 embedded in", (loader or "???"), "is not supported. Please consider updating it.|r")
		end
	end
}

function addon:CheckAddonSupport()
	for major, handler in pairs(librarySupport) do
		local lib, minor = LibStub(major, true)
		if lib then
			librarySupport[major] = nil
			handler(self, lib, minor)
		end
	end
	for name, handler in pairs(addonSupport) do
		if IsAddOnLoaded(name) then
			addonSupport[name] = nil
			handler(self)
		else
			local _, _, _, enabled, loadable, reason = GetAddOnInfo(name)
			if not enabled or not loadable then
				addonSupport[name] = nil
			end
		end
	end
	if not next(addonSupport) and not next(librarySupport) then
		self.CheckAddonSupport, addonSupport, librarySupport = nil, nil, nil
		self:UnregisterEvent('ADDON_LOADED')
		return true
	end
end

------------------------------------------------------------------------------
-- Initialization
------------------------------------------------------------------------------

function addon:LoadSpellDefaults(event)
	--@debug@
	dprint('Loaded default settings on', event)
	--@end-debug@

	-- Remove current defaults
	if self.db then
		self.db:RegisterDefaults(nil)
	end

	-- Insert spell defaults
	InlineAura_LoadDefaults(self, PRESETS, DEFAULT_OPTIONS.profile.spellStatuses)

	-- Register updated defaults
	if self.db then
		self.db:RegisterDefaults(DEFAULT_OPTIONS)
	end

	-- Clean up
	self:UnregisterEvent('SPELLS_CHANGED')
	addon_LoadDefaults = nil

	-- We have them
	self.defaultsLoaded = true

	-- Now that we have defaults, upgrade the profile
	self:UpgradeProfile()
end

local SV_VERSION = 2

-- Mark new profiles with the database version
function addon:NewProfile()
	db.profile.version = SV_VERSION
	self:RequireUpdate(true)
end

-- Upgrade the database from previous versions
function addon:UpgradeProfile()
	if not self.defaultsLoaded then return end

	-- Upgrade only if needed
	local version = db.profile.version or 0
	if version < SV_VERSION then

		-- 0 => 1
		if version < 1 then
			for name, spell in pairs(db.profile.spells) do
				if type(spell) == "table" then
					if spell.disabled then
						spell.status = "ignore"
						spell.disabled = nil
					else
						local units = spell.unitsToScan
						spell.unitsToScan = nil
						if type(units) == "table" then
							local auraType = spell.auraType
							if auraType == "buff" then
								if units.pet then
									spell.auraType = "pet"
								elseif units.player and not units.target and not units.focus then
									spell.auraType = "self"
								else
									spell.auraType = "regular"
								end
							elseif auraType == "debuff" or auraType == "enemy" or auraType == "friend" then
								spell.auraType = "regular"
							end
						elseif not units then
							if spell.auraType == "special" and not spell.special and spell.aliases then
								spell.special = spell.aliases[1]
								spell.aliases = nil
							end
						end
						if spell.alternateColor then
							spell.highlight = "glowing"
							spell.alternateColor = nil
						end
					end
				else
					db.profile.spells[name] = nil
					db.profile.spellStatuses[name] = "global"
				end
			end
		end

		-- 1 => 2
		if version < 2 then
			for name, spell in pairs(db.profile.spells) do
				local status = rawget(spell, 'status')
				if status then
					db.profile.spellStatuses[name] = status
					spell.status = nil
				end
			end
		end

		-- Do not forget to "tag" the upgraded profile
		db.profile.version = SV_VERSION
	end

	-- Clean unused settings
	for name in pairs(db.profile.spells) do
		if db.profile.spellStatuses[name] ~= "user" then
			db.profile.spells[name] = nil
		end
	end

	-- And update all
	self:RequireUpdate(true)
end

function addon:OnInitialize()
	-- Saved variables setup
	db = LibStub('AceDB-3.0'):New("InlineAuraDB", DEFAULT_OPTIONS)
	db.RegisterCallback(self, 'OnNewProfile', 'NewProfile')
	db.RegisterCallback(self, 'OnProfileReset', 'NewProfile')
	db.RegisterCallback(self, 'OnProfileChanged', 'UpgradeProfile')
	db.RegisterCallback(self, 'OnProfileCopied', 'UpgradeProfile')
	self.db = db

	LibStub('LibDualSpec-1.0'):EnhanceDatabase(db, "Inline Aura")

	self.bigCountdown = true
	self.firstEnable = true
	self.mouseoverTimer = 1
end

local updateFrame
function addon:OnEnable()

	if self.firstEnable then
		--@alpha@
		if geterrorhandler() == _ERRORMESSAGE then
			print("|cffff0000InlineAura: you are testing an alpha version of Inline Aura without a proper error handler. Please install one like BugGrabber or Swatter prior to reporting any issue.|r")
		end
		--@end-alpha@
	
		self.firstEnable = nil

		-- Retrieve default spell configuration
		if InlineAura_LoadDefaults then
			if IsLoggedIn() then
				-- Already logged in, spell data should be available
				self:LoadSpellDefaults('OnEnable')
			else
				-- Wait for the first SPELLS_CHANGED to ensure spell data are available
				self:RegisterEvent('SPELLS_CHANGED', "LoadSpellDefaults")
			end
		else
			self.defaultsLoaded = true
			self:UpgradeProfile()
		end

		-- Secure hooks
		hooksecurefunc('ActionButton_OnLoad', ActionButton_OnLoad_Hook)
		hooksecurefunc('ActionButton_UpdateState', self.UpdateButtonState_Hook)
		hooksecurefunc('ActionButton_UpdateUsable', self.UpdateButtonUsable_Hook)
		hooksecurefunc('ActionButton_UpdateCooldown', self.UpdateButtonCooldown_Hook)
		hooksecurefunc('ActionButton_Update', ActionButton_Update_Hook)
		hooksecurefunc("ActionButton_HideOverlayGlow", self.ActionButton_HideOverlayGlow_Hook)

		-- Our bucket thingy
		local delay = 0
		updateFrame = CreateFrame("Frame")
		updateFrame:SetScript('OnUpdate', function(_, elapsed)
			delay = delay + elapsed
			if delay >= 0.09 then
				self:OnUpdate(delay)
				delay = 0
			end
		end)

		-- standard buttons
		self:RegisterButtons("ActionButton", 12)
		self:RegisterButtons("BonusActionButton", 12)
		self:RegisterButtons("MultiBarRightButton", 12)
		self:RegisterButtons("MultiBarLeftButton", 12)
		self:RegisterButtons("MultiBarBottomRightButton", 12)
		self:RegisterButtons("MultiBarBottomLeftButton", 12)
	end

	-- Check for addon and library support
	if self.CheckAddonSupport and not self:CheckAddonSupport() then
		self:RegisterEvent('ADDON_LOADED', "CheckAddonSupport")
	end

	-- Set basic event listening up
	self:RegisterEvent('UNIT_AURA')
	self:RegisterEvent('UNIT_PET')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('UNIT_ENTERED_VEHICLE')
	self:RegisterEvent('UNIT_EXITED_VEHICLE', 'UNIT_ENTERED_VEHICLE')
	self:RegisterEvent('UNIT_FACTION')
	self:RegisterEvent('UNIT_TARGETABLE_CHANGED', 'UNIT_FACTION')
	self:RegisterEvent('MODIFIER_STATE_CHANGED')
	self:RegisterEvent('CVAR_UPDATE')
	self:RegisterEvent('UPDATE_BINDINGS')
	self:RegisterEvent('UPDATE_MACROS')
	self:RegisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_SHOW')
	self:RegisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_HIDE', 'SPELL_ACTIVATION_OVERLAY_GLOW_SHOW')

	-- Refresh everything
	self:RequireUpdate(true)

	-- Scan unit in case of delayed loading
	self:PLAYER_ENTERING_WORLD()
end

------------------------------------------------------------------------------
-- Configuration GUI loader
------------------------------------------------------------------------------

local function LoadConfigGUI()
	LoadAddOn('InlineAura_Config')
end

-- Chat command line
SLASH_addon1 = "/InlineAura"
function SlashCmdList.addon()
	LoadConfigGUI()
	InterfaceOptionsFrame_OpenToCategory(L['Inline Aura'])
end

-- InterfaceOptionsFrame spy
CreateFrame("Frame", nil, InterfaceOptionsFrameAddOns):SetScript('OnShow', LoadConfigGUI)

------------------------------------------------------------------------------
-- Profiling stuff
------------------------------------------------------------------------------

if AdiProfiler then
	-- "Interesting functions"
	AdiProfiler:RegisterFunction(CheckAura, "ia:CheckAura")
	AdiProfiler:RegisterFunction(AuraLookup, "ia:AuraLookup")
	AdiProfiler:RegisterFunction(UpdateButtons, "ia:UpdateButtons")
	AdiProfiler:RegisterFunction(UpdateButtonAura, "ia:UpdateButtonAura")
	AdiProfiler:RegisterFunction(GetMacroAction, "ia:GetMacroAction")
	AdiProfiler:RegisterFunction(AnalyzeAction, "ia:AnalyzeAction")
	AdiProfiler:RegisterFunction(GuessMacroTarget, "ia:GuessMacroTarget")
	AdiProfiler:RegisterFunction(FilterEmpty, "ia:FilterEmpty")
	AdiProfiler:RegisterFunction(SecureButton_GetModifiedUnit, "ia:SecureButton_GetModifiedUnit")
	AdiProfiler:RegisterFunction(UnitIsDebuffable, "ia:UnitIsDebuffable")
	AdiProfiler:RegisterFunction(UnitIsBuffable, "ia:UnitIsBuffable")
	AdiProfiler:RegisterFunction(GetAuraToDisplay, "ia:GetAuraToDisplay")
	AdiProfiler:RegisterFunction(addon.UpdateTokens, "ia:UpdateTokens")
	AdiProfiler:RegisterFunction(addon.UpdateToken, "ia:UpdateToken")

	-- Hooks
	AdiProfiler:RegisterFunction(UpdateAction_Hook, "ia:UpdateAction_Hook")
end
