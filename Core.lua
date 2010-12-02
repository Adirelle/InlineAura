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

InlineAura = LibStub('AceAddon-3.0'):NewAddon('InlineAura', 'AceEvent-3.0')
local InlineAura = InlineAura

------------------------------------------------------------------------------
-- Retrieve the localization table
------------------------------------------------------------------------------

local L = ns.L
InlineAura.L = L

------------------------------------------------------------------------------
-- Locals
------------------------------------------------------------------------------

local db

local auraChanged = {}
local unitGUIDs = {}
local needUpdate = false
local configUpdated = false

local buttons = {}
local newButtons = {}
local activeButtons = {}
InlineAura.buttons = buttons
ns.buttons = buttons

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

local ActionButton_UpdateOverlayGlow = ActionButton_UpdateOverlayGlow -- Hook protection

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
InlineAura.dprint = dprint

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
				disabled = false,
				auraType = 'regular',
				highlight = 'border',
				default = false,
			},
		},
		enabledUnits = {
			player = true,
			pet = true,
			target = true,
			focus = true,
			mouseover = false,
		}
	},
}
InlineAura.DEFAULT_OPTIONS = DEFAULT_OPTIONS

-- Events only needed if the unit is enabled
local UNIT_EVENTS = {
	focus = 'PLAYER_FOCUS_CHANGED',
	mouseover = 'UPDATE_MOUSEOVER_UNIT',
}

------------------------------------------------------------------------------
-- Some Unit helpers
------------------------------------------------------------------------------

local MY_UNITS = { player = true, pet = true, vehicle = true }

-- These two functions return nil when unit does not exist
local UnitIsBuffable = function(unit) return MY_UNITS[unit] or UnitCanAssist('player', unit) end
local UnitIsDebuffable = function(unit) return UnitCanAttack('player', unit) end

------------------------------------------------------------------------------
-- Safecall
------------------------------------------------------------------------------

local safecall
do
	local pcall, geterrorhandler, _ERRORMESSAGE = pcall, geterrorhandler, _ERRORMESSAGE
	local reported = {}

	local function safecall_inner(ok, ...)
		if not ok then
			local msg = ...
			local handler = geterrorhandler()
			if handler == _ERRORMESSAGE then
				if not reported[msg] then
					reported[msg] = true
					print('|cffff0000InlineAura error report:|r', msg)
				end
			else
				handler(msg)
			end
		else
			return ...
		end
	end

	function safecall(...)
		return safecall_inner(pcall(...))
	end
	ns.safecall = safecall
end

------------------------------------------------------------------------------
-- State plugins
------------------------------------------------------------------------------

local stateModules = {}
local stateKeywords = {}
local stateSpellHooks = {}
local statePrototype = { Debug = function() end }
--@debug@
if AdiDebug then
	AdiDebug:Embed(statePrototype, "InlineAura")
else
--@end-debug@
	function statePrototype.Debug() end
--@debug@
end
--@end-debug@

InlineAura.stateModules = stateModules
InlineAura.stateKeywords = stateKeywords
InlineAura.stateSpellHooks = stateSpellHooks
InlineAura.statePrototype = statePrototype

function statePrototype:OnDisable()
	for keyword, module in pairs(stateKeywords) do
		if module == self then
			stateKeywords[keyword] = nil
		end
	end
	for spell, module in pairs(stateSpellHooks) do
		if module == self then
			stateSpellHooks[spell] = nil
		end
	end
end

function statePrototype:RegisterKeywords(...)
	for i = 1, select('#', ...) do
		local keyword = select(i, ...)
		stateKeywords[keyword] = self
	end
end

function statePrototype:RegisterSpellHooks(...)
	for i = 1, select('#', ...) do
		local spell = select(i, ...)
		stateSpellHooks[spell] = self
	end
end

function statePrototype:CanTestUnit(unit, aura, spell)
	return true
end

function statePrototype:Test(aura, unit, onlyMyBuffs, onlyMyDebuffs, spell)
	-- Return something meaningful there
end

-- Registry methods

function InlineAura:NewStateModule(name, ...)
	assert(not stateModules[name], format("State module %q already defined", name))
	local special = self:NewModule(name, statePrototype, 'AceEvent-3.0', ...)
	stateModules[name] = special
	return special
end

------------------------------------------------------------------------------
-- Aura lookup
------------------------------------------------------------------------------

local function GetBorderHighlight(isDebuff, isMine)
	return strjoin('', 'border', isDebuff and "Debuff" or "Buff", isMine and "Mine" or "Others")
end

local function CheckAura(aura, unit, helpfulFilter, harmfulFilter)
	local isDebuff = false
	local name, _, _, count, _, duration, expirationTime, caster = UnitAura(unit, aura, nil, harmfulFilter)
	if name then
		isDebuff = true
	else
		name, _, _, count, _, duration, expirationTime, caster = UnitAura(unit, aura, nil, helpfulFilter)
	end
	if name then
		return true, count ~= 0 and count or nil, true, duration ~= 0 and expirationTime or nil, true, GetBorderHighlight(isDebuff, MY_UNITS[caster])
	end
end

local overlayedSpells = {}

local function AuraLookup(unit, onlyMyBuffs, onlyMyDebuffs, ...)
	local helpfulFilter = onlyMyBuffs and "HELPFUL PLAYER" or "HELPFUL"
	local harmfulFilter = onlyMyDebuffs and "HARMFUL PLAYER" or "HARMFUL"
	local hasCount, count, hasCountdown, expirationTime, hasHighlight, highlight
	local hasNewCount, newCount, hasNewCountdown, newExpiratiomTime, hasNewHighlight, newHighlight
	local spell = ...
	if overlayedSpells[spell] then
		hasHighlight, highlight = true, "glowing"
	end
	for i = 1, select('#', ...) do
		local aura = select(i, ...)
		local stateModule = stateKeywords[aura] or stateSpellHooks[aura]
		if stateModule and stateModule:CanTestUnit(unit, aura, spell) then
			hasNewCount, newCount, hasNewCountdown, newExpiratiomTime, hasNewHighlight, newHighlight = stateModule:Test(aura, unit, onlyMyBuffs, onlyMyDebuffs, spell)
		else
			hasNewCount, newCount, hasNewCountdown, newExpiratiomTime, hasNewHighlight, newHighlight = CheckAura(aura, unit, helpfulFilter, harmfulFilter)
		end
		if hasNewCount then
			hasCount, count = true, newCount
		end
		if hasNewCountdown and (not hasCountdown or not newExpiratiomTime or (expirationTime and newExpiratiomTime > expirationTime)) then
			hasCountdown, expirationTime = true, newExpiratiomTime
		end
		if hasNewHighlight then
			hasHighlight, highlight = true, newHighlight
		end
	end
	return hasCount and count or nil, hasCountdown and expirationTime or nil, hasHighlight and highlight or nil
end

local EMPTY_TABLE = {}
local function GetAuraToDisplay(spell, target, specific)
	local aliases
	local hideStack = db.profile.hideStack
	local hideCountdown = db.profile.hideCountdown
	local onlyMyBuffs = db.profile.onlyMyBuffs
	local onlyMyDebuffs = db.profile.onlyMyDebuffs

	-- No pet aura when no real pet is available
	if target == "pet" and (not UnitExists("pet") or UnitIsUnit("pet", "vehicle")) then
		return
	end

	-- Specific spell overrides global settings
	if specific then
		aliases = specific.aliases
		if specific.hideStack ~= nil then
			hideStack = specific.hideStack
		end
		if specific.hideCountdown ~= nil then
			hideCountdown = specific.hideCountdown
		end
		if specific.auraType == "special" then
			onlyMyBuffs, onlyMyDebuffs, hideStack, hideCountdown = true, true, false, false
		elseif specific.onlyMine ~= nil then
			onlyMyBuffs, onlyMyDebuffs = specific.onlyMine, specific.onlyMine
		end
	end

	-- Look for the aura or its aliases
	local count, expirationTime, highlight = AuraLookup(target, onlyMyBuffs, onlyMyDebuffs, spell, unpack(aliases or  EMPTY_TABLE))

	if specific then
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
			-- Select the state that actually match the result from AuraLookup
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
		dprint('GetAuraToDisplay', specific.highlight, specific.invertHighlight, '|', prevHighlight, '=>', highlight)
	end

	return (not hideStack) and count ~= 0 and count or nil, (not hideCountdown) and expirationTime or nil, highlight
end

------------------------------------------------------------------------------
-- Aura updating
------------------------------------------------------------------------------

local function FilterEmpty(v) if v and strtrim(tostring(v)) ~= "" and v ~= 0 then return v end end

local function FindMacroOptions(...)
	for i = 1, select('#', ...) do
		local line = select(i, ...)
		local prefix, suffix = strsplit(" ", strtrim(line), 2)
		if suffix and (prefix == '#show' or prefix == '#showtooltip' or strsub(prefix, 1, 1) ~= "#") then
			return suffix
		end
	end
end

local function GuessMacroTarget(index)
	local body = assert(GetMacroBody(index), format("Can't find macro body for %q", index))
	local options = FindMacroOptions(strsplit("\n", body))
	if options then
		local action, target = SecureCmdOptionParse(options)
		return FilterEmpty(action) and FilterEmpty(target)
	end
end

local function GuessSpellTarget(helpful)
	if IsModifiedClick("SELFCAST") then
		return "player"
	elseif IsModifiedClick("FOCUSCAST") then
		return "focus"
	elseif helpful and not UnitIsBuffable("target") and (InlineAura.db.profile.emulateAutoSelfCast or GetCVarBool("autoSelfCast")) then
		return "player"
	else
		return "target"
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
		item, spell = GetItemInfo(param), GetItemSpell(param)
	elseif action == "spell" then
		spell = GetSpellInfo(param)
	end
	if not spell then
		return -- Nothing to handle
	end

	local auraType = item and "self" or "regular"

	-- Check spell hooks
	local spellHook = stateSpellHooks[item or spell]
	if spellHook then
		local overrideAuraType = spellHook.OverrideAuraType
		if type(overrideAuraType) == "string" then
			auraType = overrideAuraType
		elseif type(overrideAuraType) == "function" then
			auraType = overrideAuraType(spellHook, item or spell) or auraType
		end
	end

	-- Check for specific settings
	local specific = rawget(db.profile.spells, item or spell)
	if type(specific) == "table" then
		if specific.disabled then
			return -- Don't want to handle
		end
		if specific.auraType then
			auraType = specific.auraType
		end
	else
		specific = nil
	end

	-- Solve special aura types ASAP
	if auraType == "self" or auraType == "special" then
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

	local spell, target, specific
	if state.action == "macro" then
		local macroAction, macroParam = GetMacroAction(state.param)
		spell, target, specific = AnalyzeAction(macroAction, macroParam)
		if state.spell ~= spell or state.targetHint ~= target or state.specific ~= specific then
			state.spell, state.targetHint, state.specific = spell, target, specific
			force = true
		end
		if target == "friend" or target == "foe" then
			target = GuessMacroTarget(state.param) or target
		end
		--@debug@
		if force then
			self:Debug('UpdateButtonAura: macro:', state.param, '=>', macroAction, macroParam, '=>', spell, target, specific)
		end
		--@end-debug@
	else
		spell, target, specific = state.spell, state.targetHint, state.specific
	end

	-- Find actual units for these
	if target == "friend" or target == "foe" then
		target = FilterEmpty(SecureButton_GetModifiedUnit(self)) or GuessSpellTarget(target == "friend")
		--@debug@
		if force then
			self:Debug('UpdateButtonAura: smart target:', target)
		end
		--@end-debug@
	end

	-- Get the GUID
	local guid = target and UnitGUID(target)

	if force or guid ~= state.guid or auraChanged[guid or state.guid or false] then
		--@debug@
		self:Debug("UpdateButtonAura: updating because", (force and "forced") or (guid ~= state.guid and "guid changed") or "aura changed", "|", spell, target, specific, guid)
		--@end-debug@
		state.guid = guid

		local count, expirationTime, highlight

		if spell and target then
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
			ns.ShowCountdownAndStack(self, expirationTime, count)
		end
	end
end

------------------------------------------------------------------------------
-- Action handling
------------------------------------------------------------------------------

local function UpdateAction_Hook(self)
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
		if action == "item" and param and not GetItemSpell(GetItemInfo(param) or param) then
			action, param = nil, nil
		end
	end
	if action ~= state.action or param ~= state.param then
		state.action, state.param = action, param
		activeButtons[self] = (action and param) or nil
		local forceUpdate
		if action ~= "macro" then
			local spell, targetHint, specific = AnalyzeAction(action, param)
			if state.spell ~= spell or state.targetHint ~= targetHint or state.specific ~= specific then
				state.spell, state.targetHint, state.specific = spell, targetHint, specific
				forceUpdate = true
			end
			--@debug@
			self:Debug("UpdateAction_Hook: action changed =>", action, param, "static:", spell, targetHint, specific, forceUpdate and "| forcing update")
			--@end-debug@
		else
			forceUpdate = true
			--@debug@
			self:Debug("UpdateAction_Hook: action changed =>", action, param)
			--@end-debug@
		end
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
	buttons[self] = { button = self }
	--@debug@
	if AdiDebug then
		AdiDebug:Embed(self, 'InlineAura')
	else
	--@end-debug@
		self.Debug = self.Debug or NOOP
	--@debug@
	end
	--@end-debug@
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
			InlineAura:RegisterEvent(event)
		else
			InlineAura:UnregisterEvent(event)
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
	ns.UpdateWidgets()
end

local mouseoverUnit
local function UpdateMouseover(elapsed)
	-- Track mouseover changes, since most events aren't fired for mouseover
	if unitGUIDs['mouseover'] ~= UnitGUID('mouseover') then
		InlineAura:UPDATE_MOUSEOVER_UNIT("OnUpdate-changed")
	elseif not mouseoverUnit then
		InlineAura.mouseoverTimer = InlineAura.mouseoverTimer + elapsed
		if InlineAura.mouseoverTimer > 0.5 then
			InlineAura:UPDATE_MOUSEOVER_UNIT("OnUpdate-timer")
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
	for button in pairs(activeButtons) do
		UpdateButtonAura(button, needUpdate or configUpdated)
	end
end

function InlineAura:OnUpdate(elapsed)
	-- Configuration has been updated
	if configUpdated then
		safecall(UpdateConfig)
	end

	-- Watch for mouseover aura if we can't get UNIT_AURA events
	if unitGUIDs['mouseover'] then
		safecall(UpdateMouseover, elapsed)
	end

	-- Handle new buttons
	if next(newButtons) then
		safecall(InitializeNewButtons)
		wipe(newButtons)
	end

	-- Update buttons
	if next(auraChanged) or needUpdate or configUpdated then
		safecall(UpdateButtons)
		needUpdate, configUpdated = false, false
		wipe(auraChanged)
	end

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

function InlineAura:AuraChanged(unit)
	local oldGUID = unitGUIDs[unit]
	local realUnit = ApplyVehicleModifier(unit)
	local guid = realUnit and db.profile.enabledUnits[unit] and UnitGUID(realUnit)
	if oldGUID and not guid then
		auraChanged[oldGUID] = true
	end
	if guid then
		auraChanged[guid] = true
	end
	unitGUIDs[unit] = guid
	if guid and UnitIsUnit(unit, 'mouseover') then
		--@debug@
		dprint('AuraChanged:', unit, 'is mouseover')
		--@end-debug@
		self.mouseoverTimer = 0
	end
end

function InlineAura:UNIT_ENTERED_VEHICLE(event, unit)
	if unit == 'player' then
		return self:AuraChanged("player")
	end
end

function InlineAura:UNIT_AURA(event, unit)
	return self:AuraChanged(unit)
end

function InlineAura:UNIT_PET(event, unit)
	if unit == 'player' then
		return self:AuraChanged("pet")
	end
end

function InlineAura:PLAYER_ENTERING_WORLD(event)
	for unit, enabled in pairs(db.profile.enabledUnits) do
		if enabled then
			self:AuraChanged(unit)
		end
	end
end

function InlineAura:PLAYER_FOCUS_CHANGED(event)
	return self:AuraChanged("focus")
end

function InlineAura:PLAYER_TARGET_CHANGED(event)
	return self:AuraChanged("target")
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
end

function InlineAura:UPDATE_MOUSEOVER_UNIT(event)
	--@debug@
	dprint('UPDATE_MOUSEOVER_UNIT', event)
	--@end-debug@
	mouseoverUnit = GetUnitForMouseover()
	return self:AuraChanged("mouseover")
end

function InlineAura:MODIFIER_STATE_CHANGED(event)
	return self:RequireUpdate()
end

function InlineAura:CVAR_UPDATE(event, name)
	if name == 'AUTO_SELF_CAST_TEXT' then
		--@debug@
		dprint('CVAR_UPDATE', event)
		--@end-debug@
		return self:RequireUpdate(true)
	end
end

function InlineAura:UPDATE_BINDINGS(event, name)
	return self:RequireUpdate(true)
end

function InlineAura:UPDATE_MACROS(event, name)
	return self:RequireUpdate(true)
end

function InlineAura:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(event, id)
	local name = GetSpellInfo(id)
	if name and not overlayedSpells[name] then
		overlayedSpells[name] = true
		return self:AuraChanged("player")
	end
end

function InlineAura:SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(event, id)
	local name = GetSpellInfo(id)
	if name and overlayedSpells[name] then
		overlayedSpells[name] = nil
		return self:AuraChanged("player")
	end
end

local updateFrame
function InlineAura:OnEnable()

	-- Retrieve default spell configuration, if loaded
	if InlineAura_LoadDefaults then
		safecall(InlineAura_LoadDefaults, self)
		InlineAura_LoadDefaults = nil
	end

	if not self.db then
		-- Saved variables setup
		db = LibStub('AceDB-3.0'):New("InlineAuraDB", DEFAULT_OPTIONS)
		db.RegisterCallback(self, 'OnProfileChanged', 'RequireUpdate')
		db.RegisterCallback(self, 'OnProfileCopied', 'RequireUpdate')
		db.RegisterCallback(self, 'OnProfileReset', 'RequireUpdate')
		self.db = db
		ns.db = db

		LibStub('LibDualSpec-1.0'):EnhanceDatabase(db, "Inline Aura")

		-- Update the database from previous versions
		for name, spell in pairs(db.profile.spells) do
			if type(spell) == "table" and not spell.default then
				local units = spell.unitsToScan
				if type(units) ~= "table" then units = nil end
				local auraType = spell.auraType
				if auraType == "buff" then
					if units and units.pet then
						auraType = "pet"
					elseif units and units.player and not units.target and not units.focus then
						auraType = "self"
					else
						auraType = "regular"
					end
				elseif auraType == "debuff" or auraType == "enemy" or auraType == "friend" then
					auraType = "regular"
				end
				if spell.alternateColor then
					spell.highlight = "glowing"
					spell.alternateColor = nil
				end
				spell.auraType = auraType
				spell.unitsToScan = nil
			end
		end
	end

	-- Setup
	self.bigCountdown = true

	-- Setup basic event listening up
	self:RegisterEvent('UNIT_AURA')
	self:RegisterEvent('UNIT_PET')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('UNIT_ENTERED_VEHICLE')
	self:RegisterEvent('UNIT_EXITED_VEHICLE', 'UNIT_ENTERED_VEHICLE')
	self:RegisterEvent('MODIFIER_STATE_CHANGED')
	self:RegisterEvent('CVAR_UPDATE')
	self:RegisterEvent('UPDATE_BINDINGS')
	self:RegisterEvent('UPDATE_MACROS')

	self:RegisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_SHOW')
	self:RegisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_HIDE')

	-- standard buttons
	self:RegisterButtons("ActionButton", 12)
	self:RegisterButtons("BonusActionButton", 12)
	self:RegisterButtons("MultiBarRightButton", 12)
	self:RegisterButtons("MultiBarLeftButton", 12)
	self:RegisterButtons("MultiBarBottomRightButton", 12)
	self:RegisterButtons("MultiBarBottomLeftButton", 12)

	local ActionButton_HideOverlayGlow_Hook = ns.ActionButton_HideOverlayGlow_Hook
	local UpdateButtonState_Hook = ns.UpdateButtonState_Hook
	local UpdateButtonUsable_Hook = ns.UpdateButtonUsable_Hook

	-- Hooks
	hooksecurefunc('ActionButton_OnLoad', ActionButton_OnLoad_Hook)
	hooksecurefunc('ActionButton_UpdateState', function(...) return safecall(UpdateButtonState_Hook, ...) end)
	hooksecurefunc('ActionButton_UpdateUsable', function(...) return safecall(UpdateButtonUsable_Hook, ...) end)
	hooksecurefunc('ActionButton_Update', function(...) return safecall(ActionButton_Update_Hook, ...) end)
	hooksecurefunc('ActionButton_HideOverlayGlow', function(...) return safecall(ActionButton_HideOverlayGlow_Hook, ...) end)

	-- ButtonFacade support
	ns.EnableLibButtonFacadeSupport()

	-- Miscellanous addon support
	if Dominos then
		self:RegisterButtons("DominosActionButton", 120)
		hooksecurefunc(Dominos.ActionButton, "Skin", ActionButton_OnLoad_Hook)
		ns.RegisterLBFCallback("Dominos")
	end
	if OmniCC or CooldownCount then
		InlineAura.bigCountdown = false
	end
	local LAB, LAB_version = LibStub("LibActionButton-1.0", true)
	if LAB then
		if LAB_version >= 11 then -- Callbacks and GetAllButtons() are supported since minor 11
			--@debug@
			dprint("Found LibActionButton-1.0 version", LAB_version)
			--@end-debug@
			LAB.RegisterCallback(self, "OnButtonCreated", function(_, button) return InitializeButton(button) end)
			LAB.RegisterCallback(self, "OnButtonUpdate", function(_, button) return UpdateAction_Hook(button) end)
			LAB.RegisterCallback(self, "OnButtonUsable", function(_, button) return UpdateButtonUsable_Hook(button) end)
			LAB.RegisterCallback(self, "OnButtonState", function(_, button) return UpdateButtonState_Hook(button) end)
			for button in pairs(LAB:GetAllButtons()) do
				newButtons[button] = true
			end
		else
			local _, loader = issecurevariable(LAB, "CreateButton")
			print("|cffff0000InlineAura: the version of LibActionButton-1.0 embedded in", (loader or "???"), "is not supported. Please consider updating it.|r")
		end
	end
	if Bartender4 then
		self:RegisterButtons("BT4Button", 120) -- should not be necessary
		ns.RegisterLBFCallback("Bartender4")
	end

	-- Refresh everything
	self:RequireUpdate(true)

	-- Our bucket thingy
	self.mouseoverTimer = 1
	updateFrame = CreateFrame("Frame")
	updateFrame:SetScript('OnUpdate', function(_, elapsed) return self:OnUpdate(elapsed) end)

	-- Scan unit in case of delayed loading
	self:PLAYER_ENTERING_WORLD()
end

------------------------------------------------------------------------------
-- Configuration GUI loader
------------------------------------------------------------------------------

local function LoadConfigGUI()
	safecall(LoadAddOn, 'InlineAura_Config')
end

-- Chat command line
SLASH_INLINEAURA1 = "/inlineaura"
function SlashCmdList.INLINEAURA()
	LoadConfigGUI()
	InterfaceOptionsFrame_OpenToCategory(L['Inline Aura'])
end

-- InterfaceOptionsFrame spy
CreateFrame("Frame", nil, InterfaceOptionsFrameAddOns):SetScript('OnShow', LoadConfigGUI)


