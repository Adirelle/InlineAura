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

-----------------------------------------------------------------------------
-- Configuration panel
-----------------------------------------------------------------------------

local addon = LibStub('AceAddon-3.0'):GetAddon('InlineAura')
if not addon then return end

local L = addon.L
local PRESETS = addon.PRESETS

------------------------------------------------------------------------------
-- Make often-used globals local
------------------------------------------------------------------------------

--<GLOBALS
local _G = _G
local ACTIONBAR_LABEL = _G.ACTIONBAR_LABEL
local BOOKTYPE_PET = _G.BOOKTYPE_PET
local BOOKTYPE_SPELL = _G.BOOKTYPE_SPELL
local COMBATLOG_FILTER_STRING_MY_PET = _G.COMBATLOG_FILTER_STRING_MY_PET
local CreateFrame = _G.CreateFrame
local format = _G.format
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetItemInfo = _G.GetItemInfo
local GetItemSpell = _G.GetItemSpell
local GetMacroItem = _G.GetMacroItem
local GetMacroSpell = _G.GetMacroSpell
local GetNumSpellTabs = _G.GetNumSpellTabs
local GetSpellInfo = _G.GetSpellInfo
local GetSpellTabInfo = _G.GetSpellTabInfo
local gsub = _G.gsub
local huge = _G.math.huge
local IsPassiveSpell = _G.IsPassiveSpell
local next = _G.next
local NO = _G.NO
local NONE = _G.NONE
local pairs = _G.pairs
local PET = _G.PET
local rawget = _G.rawget
local select = _G.select
local SPELLBOOK = _G.SPELLBOOK
local strjoin = _G.strjoin
local strlower = _G.strlower
local strmatch = _G.strmatch
local strsplit = _G.strsplit
local strtrim = _G.strtrim
local tconcat = _G.table.concat
local tinsert = _G.tinsert
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local unpack = _G.unpack
local wipe = _G.wipe
local YES = _G.YES
--GLOBALS>

------------------------------------------------------------------------------
-- Local reference to addon settings
------------------------------------------------------------------------------
local profile = addon.db and addon.db.profile
LibStub('AceEvent-3.0').RegisterMessage('InlineAura/Config.lua', 'InlineAura_ProfileChanged',function() profile = addon.db.profile end)

-----------------------------------------------------------------------------
-- Default option handler
-----------------------------------------------------------------------------

local handler = {}

function handler:GetDatabase(info)
	local db = profile
	local key = info.arg or info[#info]
	if type(key) == "table" then
		for i = 1, #key-1 do
			db = db[key[i]]
		end
		key = key[#key]
	end
	return db, key
end

function handler:Set(info, ...)
	local db, key = self:GetDatabase(info)
	if info.type == 'color' then
		local color = db[key]
		color[1], color[2], color[3], color[4] = ...
	elseif info.type == 'multiselect' then
		local subKey, value = ...
		db[key][subKey] = value
	else
		db[key] = ...
	end
	addon:RequireUpdate(true)
end

function handler:Get(info, subKey)
	local db, key = self:GetDatabase(info)
	if info.type == 'color' then
		return unpack(db[key])
	elseif info.type == 'multiselect' then
		return db[key][subKey]
	else
		return db[key]
	end
end

local positions = {
	TOPLEFT = L['Top left'],
	TOP = L['Top'],
	TOPRIGHT = L['Top right'],
	LEFT = L['Left'],
	CENTER = L['Center'],
	RIGHT = L['Right'],
	BOTTOMLEFT = L['Bottom left'],
	BOTTOM = L['Bottom'],
	BOTTOMRIGHT = L['Bottom right'],
}
local tmp = {}
function handler:ListTextPositions(info, exclude)
	local exclude2 = addon.bigCountdown or 'CENTER'
	wipe(tmp)
	for pos, label in pairs(positions) do
		if pos ~= exclude and pos ~= exclude2 then
			tmp[pos] = label
		end
	end
	return tmp
end

-----------------------------------------------------------------------------
-- Main options
-----------------------------------------------------------------------------

local options = {
	name = format("%s %s", L['Inline Aura'], GetAddOnMetadata("InlineAura", "Version")),
	type = 'group',
	handler = handler,
	set = 'Set',
	get = 'Get',
	args = {
		onlyMyBuffs = {
			name = L['Only my buffs'],
			desc = L['Ignore buffs cast by other characters.'],
			type = 'toggle',
			order = 10,
		},
		onlyMyDebuffs = {
			name = L['Only my debuffs'],
			desc = L['Ignore debuffs cast by other characters.'],
			type = 'toggle',
			order = 20,
		},
		hideCountdown = {
			name = L['No countdown'],
			desc = L['Do not display the remaining time countdown in the action buttons.'],
			type = 'toggle',
			order = 30,
		},
		hideStack = {
			name = L['No application count'],
			desc = L['Do not display (de)buff application count in the action buttons.'],
			type = 'toggle',
			order = 40,
		},
		preciseCountdown = {
			name = L['Precise countdown'],
			desc = L['Use a more accurate rounding, down to tenths of second, instead of the default Blizzard rounding.'],
			type = 'toggle',
			disabled = function(info) return profile.hideCountdown end,
			order = 45,
		},
		decimalCountdownThreshold = {
			name = L['Decimal countdown threshold'],
			desc = L['This is the threshold under which tenths of second are displayed.'],
			type = 'range',
			min = 1,
			max = 10,
			step = 0.5,
			disabled = function(info) return profile.hideCountdown or not profile.preciseCountdown end,
			order = 46,
		},
		glowingAnimation = {
			name = L["Glowing highlight"],
			desc = L["Allow you to disable glowing highlight in certain situations."],
			type = 'group',
			inline = true,
			order = 47,
			args ={
				glowUnusable = {
					name = L["Unusable"],
					desc = L["Uncheck this to disable highlight for unusable actions."],
					type = 'toggle',
				},
				glowOnCooldown = {
					name = L["On cooldown"],
					desc = L["Uncheck this to disable highlight for actions in cooldown."],
					type = 'toggle',
				},
				glowOutOfCombat = {
					name = L["Out of combat"],
					desc = L["Uncheck this to disable highlight out of combat."],
					type = 'toggle',
				},
			}
		},
		targeting = {
			name = L['Targeting settings'],
			desc = L['Options related to the units to watch and the way to select them depending on the spells.'],
			type = 'group',
			inline = true,
			order = 49,
			args = {
				focus = {
					name = L['Watch focus'],
					desc = L['Watch (de)buff changes on your focus. Required only to properly update macros that uses @focus targeting.'],
					type = 'toggle',
					order = 10,
					arg = {'enabledUnits', 'focus'},
				},
				mouseover = {
					name = L['Watch unit under mouse cursor'],
					desc = L['Watch (de)buff changes on the unit under the mouse cursor. Required only to properly update macros that uses @mouseover targeting.'],
					type = 'toggle',
					order = 20,
					arg = {'enabledUnits', 'mouseover'},
				},
				emulateAutoSelfCast = {
					name = L['Emulate auto self cast'],
					desc = L['Behave as if the interface option "Auto self cast" was enabled, e.g. test helpful spells on yourself when you are not targeting a friendly unit.\nNote: this enables the old Inline Aura behavior with friendly spells.'],
					type = 'toggle',
					order = 30,
				},
			},
		},
		colors = {
			name = L['Border highlight colors'],
			desc = L['Select the colors used to highlight the action button. There are selected based on aura type and caster.'],
			type = 'group',
			inline = true,
			order = 50,
			args = {
				buffMine = {
					name = L['My buffs'],
					desc = L['Select the color to use for the buffs you cast.'],
					type = 'color',
					arg = 'colorBuffMine',
					order = 10,
				},
				buffOthers = {
					name = L["Others' buffs"],
					desc = L['Select the color to use for the buffs cast by other characters.'],
					type = 'color',
					arg = 'colorBuffOthers',
					order = 20,
				},
				debuffMine = {
					name = L["My debuffs"],
					desc = L['Select the color to use for the debuffs you cast.'],
					type = 'color',
					arg = 'colorDebuffMine',
					order = 30,
				},
				debuffOthers = {
					name = L["Others' debuffs"],
					desc = L['Select the color to use for the debuffs cast by other characters.'],
					type = 'color',
					arg = 'colorDebuffOthers',
					order = 40,
				},
			},
		},
		text = {
			name = L['Text appearance'],
			type = 'group',
			inline = true,
			order = 60,
			args = {
				smallCountdownExplanation = {
					name = L['Either OmniCC or CooldownCount is loaded so aura countdowns are displayed using small font only.'],
					type = 'description',
					hidden = function() return addon.bigCountdown end,
					order = 5,
				},
				fontName = {
					name = L['Font name'],
					desc = L['Select the font to be used to display both countdown and application count.'],
					type = 'select',
					dialogControl = 'LSM30_Font',
					-- GLOBALS: AceGUIWidgetLSMlists
					values = AceGUIWidgetLSMlists.font,
					order = 10,
				},
				smallFontSize = {
					name = function() return addon.bigCountdown and L['Size of small text'] or L['Font size'] end,
					desc = function()
						return addon.bigCountdown and L['The small font is used to display application count.']
							or L['Adjust the font size of countdown and application count texts.']
					end,
					type = 'range',
					min = 5,
					max = 30,
					step = 1,
					order = 20,
				},
				largeFontSize = {
					name = L['Size of large text'],
					desc = L['The large font is used to display countdowns.'],
					type = 'range',
					min = 5,
					max = 30,
					step = 1,
					hidden = function() return not addon.bigCountdown end,
					order = 30,
				},
				fontFlag = {
					name = L['Font effect'],
					desc = L['Select an effect to enhance the readability of the texts.'],
					type = 'select',
					order = 33,
					values = {
						[""] = NONE,
						OUTLINE = L['Outline'],
						THICKOUTLINE = L['Thick outline'],
					},
				},
				dynamicCountdownColor = {
					name = L['Dynamic countdown'],
					desc = L['Make the countdown color, and size if possible, depends on remaining time.'],
					type = 'toggle',
					order = 35,
					disabled = function() return profile.hideCountdown end,
				},
				colorCountdown = {
					name = L['Countdown text color'],
					type = 'color',
					hasAlpha = true,
					order = 40,
					disabled = function() return profile.hideCountdown or profile.dynamicCountdownColor end,
				},
				colorStack = {
					name = L['Application text color'],
					type = 'color',
					hasAlpha = true,
					order = 50,
				},
			},
		},
		layout = {
			name = L['Text Position'],
			type = 'group',
			inline = true,
			order = 70,
			args = {
				_desc = {
					type = 'description',
					name = L['Select where to display countdown and application count in the button. When only one value is displayed, the "single value position" is used instead of the regular one.'],
					order = 10,
				},
				twoTextFirst = {
					name = L['Countdown position'],
					desc = L['Select where to place the countdown text when both values are shown.'],
					type = 'select',
					arg = 'twoTextFirstPosition',
					values = function(info) return info.handler:ListTextPositions(info, profile.twoTextSecondPosition) end,
					disabled = function(info) return profile.hideCountdown or profile.hideStack end,
					order = 20,
				},
				twoTextSecond = {
					name = L['Application count position'],
					desc = L['Select where to place the application count text when both values are shown.'],
					type = 'select',
					arg = 'twoTextSecondPosition',
					values = function(info) return info.handler:ListTextPositions(info, profile.twoTextFirstPosition) end,
					disabled = function(info) return profile.hideCountdown or profile.hideStack end,
					order = 30,
				},
				oneText = {
					name = L['Single value position'],
					desc = L['Select where to place a single value.'],
					type = 'select',
					arg = 'singleTextPosition',
					values = "ListTextPositions",
					disabled = function(info) return profile.hideCountdown and profile.hideStack end,
					order = 40,
				},
			},
		},
	},
}

-----------------------------------------------------------------------------
-- Spell specific options
-----------------------------------------------------------------------------

-- Upvalues

local spellPanel
local spellSpecificHandler = {}

local _, playerClass = UnitClass("player")
local isPetClass = (playerClass == "WARLOCK" or playerClass == "MAGE" or playerClass == "DEATHKNIGHT" or playerClass == "HUNTER")

-- Constants

local SPELLBOOK_FORMAT = SPELLBOOK..': %s'

local STATUS_COLORS = { ignore = "ff7744", preset = "00ffff", user = "44ff44", global = "cccccc" }
local STATUS_LABELS = {
	global = format('|cff%s%s|r', STATUS_COLORS.global, NONE),
	preset = format('|cff%s%s|r', STATUS_COLORS.preset, L['Preset']),
	user = format('|cff%s%s|r', STATUS_COLORS.user, L['User-defined']),
	ignore = format('|cff%s%s|r', STATUS_COLORS.ignore, L['Ignored']),
}

-- List of keywords

local keywordList = {}
function spellSpecificHandler:GetKeywordList()
	wipe(keywordList)
	for keyword, module in pairs(addon.allKeywords) do
		local text = L[keyword]
		if not module:IsEnabled() then
			text = "|cff777777"..text.."|r"
		end
		keywordList[keyword] = text
	end
	return keywordList
end

-- List of spells

local spellList = {}

local function HasSpellPreset(name)
	return name and not not PRESETS[name]
end

local function IsSpellInList(name)
	return name and not not spellList[name]
end

local function AddEntry(action, param)
	local key, icon, label, _
	if action == 'item' then
		label, _, _, _, _, _, _, _, _, icon = GetItemInfo(param)
		key = label and GetItemSpell(label)
		if not key then return end
		label = format("%s (%s)", key, label)
	elseif action == 'spell' then
		label, _, icon = GetSpellInfo(param)
		key = label
	end
	if key and label then
		if icon then
			label = format("|T%s:20:20:0:0:64:64:4:60:4:60|t %s", icon, label)
		end
		local _, status = addon:GetSpellSettings(key)
		spellList[key] = format("|cff%s%s|r", STATUS_COLORS[status], label)
	end
end

local function MergeSpellbook(spellbook, minIndex, maxIndex)
	for index = minIndex, maxIndex do
		local name = GetSpellInfo(index, spellbook)
		if not name then
			break
		elseif not spellList[name] and not IsPassiveSpell(name) then
			AddEntry("spell", name)
		end
	end
end

local function AddSpellOrItem(key)
	if not spellList[key] then
		if GetSpellInfo(key) then
			AddEntry("spell", key)
		elseif GetItemInfo(key) then
			AddEntry("item", key)
		end
	end
end

function spellSpecificHandler:GetSpellList()
	wipe(spellList)
	local pref = profile.configSpellSources
	if pref.actionbars then
		-- Scan action buttons for spells and items
		for button, state in pairs(addon.buttonRegistry) do
			local action, param = state.action, state.param
			if action == "macro" then
				local macro = param
				param = GetMacroSpell(macro)
				if param and param ~= "" then
					action = "spell"
				else
					param = GetMacroItem(macro)
					if param and param ~= "" then
						action = "item"
					else
						action = nil
					end
				end
			end
			if action and param then
				AddEntry(action, param)
			end
		end
	end
	for i = 1, GetNumSpellTabs() do
		if pref['spellbook'..i] then
			local _, _, offset, numSlots = GetSpellTabInfo(i)
			MergeSpellbook(BOOKTYPE_SPELL, 1 + offset, offset + numSlots)
		end
	end
	if pref.spellbook_pet then
		MergeSpellbook(BOOKTYPE_PET, 1, huge)
	end
	if pref.modified then
		for key, status in pairs(profile.spellStatuses) do
			if status ~= (PRESETS[key] and "preset" or "global") then
				AddSpellOrItem(key)
			end
		end
	end
	if pref.preset then
		for key in pairs(PRESETS) do
			AddSpellOrItem(key)
		end
	end
	spellSpecificHandler:ListUpdated()
	return spellList
end

-- The list of source of spells

local spellListList = {}
function spellSpecificHandler:GetSpellListList()
	wipe(spellListList)
	spellListList.actionbars = ACTIONBAR_LABEL
	spellListList.modified = L['Modified settings']
	spellListList.preset = L['Presets']
	spellListList.spellbook_pet = UnitExists("pet") and format(SPELLBOOK_FORMAT, COMBATLOG_FILTER_STRING_MY_PET) or nil
	for i = 1, GetNumSpellTabs() do
		local name, _, _, numSlots = GetSpellTabInfo(i)
		if numSlots > 0 then
			spellListList["spellbook"..i] = format(SPELLBOOK_FORMAT, name)
		end
	end
	return spellListList
end

-- Helpers

local function BuildSelectDesc(text, ...)
	for i = 1, select('#', ...), 2 do
		text = format("%s\n\n|cff44ff44%s|r: %s", text, select(i, ...))
	end
	return text
end

local function copy(src, dst)
	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = copy(v, {})
		else
			dst[k] = v
		end
	end
	return dst
end

-- Current spell selection handling

function spellSpecificHandler:ListUpdated()
	if not spellList[self.name] then
		self:SelectSpell(nil)
	end
end

function spellSpecificHandler:GetSelectedSpell()
	return self.name
end

function spellSpecificHandler:GetSelectedSpellName()
	return self.name or "???"
end

function spellSpecificHandler:SelectSpell(name)
	if name then
		self.name, self.db, self.status = name, addon:GetSpellSettings(name)
	else
		self.name, self.db, self.status = nil, nil, nil
	end
end

function spellSpecificHandler:IsNoSpellSelected()
	return not self.name
end

-- Current spell status handling

function spellSpecificHandler:GetStatus()
	return self.status
end

function spellSpecificHandler:SetStatus(_, status)
	if status == "user" and PRESETS[self.name] and not rawget(profile.spells, self.name) then
		copy(PRESETS[self.name], profile.spells[self.name])
	end
	profile.spellStatuses[self.name] = status
	addon:RequireUpdate(true)
	self:SelectSpell(self.name)
end

function spellSpecificHandler:Reset()
	if self:IsReadOnly() then return end
	wipe(self.db)
	if PRESETS[self.name] then
		copy(PRESETS[self.name], self.db)
	else
		self.db.auraType = "regular"
		self.db.highlight = "border"
	end
	addon:RequireUpdate(true)
end

local statusList = copy(STATUS_LABELS, {})
function spellSpecificHandler:GetStatusList()
	statusList.preset = HasSpellPreset(self.name) and STATUS_LABELS.preset or nil
	return statusList
end

function spellSpecificHandler:IsNotViewable()
	return not self.name or (self.status ~= "preset" and self.status ~= "user")
end

function spellSpecificHandler:IsReadOnly()
	return self.status ~= "user"
end

function spellSpecificHandler:IsSpecial()
	return self.db and self.db.auraType == "special"
end

-- Generic attribute handling

function spellSpecificHandler:GetDatabase(info)
	local db, key = self.db, info.arg or info[#info]
	if type(key) == "table" then
		for i = 1, #key-1 do
			db = db[key[i]]
		end
		key = key[#key]
	end
	return db, key
end

function spellSpecificHandler:Set(info, ...)
	if self:IsReadOnly() then return end
	local db, key = self:GetDatabase(info)
	if info.type == 'color' then
		local color = db[key]
		color[1], color[2], color[3], color[4] = ...
	elseif info.type == 'multiselect' then
		local subKey, value = ...
		value = value and true or false
		if type(db[key]) ~= 'table' then
			db[key] = { [subKey] = value }
		else
			db[key][subKey] = value
		end
	else
		db[key] = ...
	end
	addon:RequireUpdate(true)
end

function spellSpecificHandler:Get(info, subKey)
	local db, key = self:GetDatabase(info)
	if info.type == 'color' then
		return unpack(db[key])
	elseif info.type == 'multiselect' then
		return type(db[key]) == "table" and db[key][subKey]
	else
		return db[key]
	end
end

function spellSpecificHandler:GetTristate(info)
	return tostring(self:Get(info))
end

function spellSpecificHandler:SetTristate(info, value)
	if value == "nil" then
		self:Set(info, nil)
	else
		self:Set(info, value == "true")
	end
end

local tristateValues = { ["true"] = YES, ["false"] = NO, ["nil"] = L['Use global setting'] }

-- Aura type handling

local auraTypeList = {
	regular = L['Regular'],
	self = L['Self'],
}
function spellSpecificHandler:GetAuraTypeList(_, value)
	auraTypeList.pet = isPetClass and PET or nil
	auraTypeList.special = next(addon.allKeywords) and L['Special'] or nil
	return auraTypeList
end

-- Aliases handling

function spellSpecificHandler:GetAliases(info)
	local aliases = self.db.aliases
	return type(aliases) == 'table' and tconcat(aliases, "\n") or nil
end

-- Spell name validation

local ValidateName
do
	local cache = {}

	-- Convert to lowercase, trim leading and trailing spaces, and convert Unicode non-breaking space to simple space
	local function normalize(name)
		return gsub(strtrim(strlower(name)), "\194\160", " ")
	end

	local MAX_ID = 4 * select(4, GetBuildInfo()) -- Arbitrary high spell id based on current version
	local id = 0
	local function LookupName(value, normalizedValue)
		if addon.allKeywords[value] then
			return value, 'keyword'
		end
		local spellId = tonumber(strmatch('spell:(%d+)', value))
		if spellId then
			return GetSpellInfo(spellId), 'spell'
		end
		local knownSpell = GetSpellInfo(value)
		if knownSpell then
			return knownSpell, 'spell'
		end
		while id < MAX_ID do
			id = id + 1
			local name = GetSpellInfo(id)
			if name then
				local normalizedName = normalize(name)
				if normalizedName == normalizedValue then
					return name, 'spell'
				else
					cache[normalizedName] = name..'|spell'
				end
			end
		end
	end

	local function ResolveName(name, normalizedName)
		local realName, nameType = LookupName(name, normalizedName)
		if realName and nameType then
			cache[normalizedName] = strjoin('|', realName, nameType)
		end
		return realName, nameType
	end

	function ValidateName(name)
		if type(name) == "string" then
			local normalizedName = normalize(name)
			local info = cache[normalizedName]
			if info then
				return strsplit('|', info)
			else
				return ResolveName(name, normalizedName)
			end
		end
	end
end

local dialog
local function ShowErrorMessage(message)
	if not dialog then
		dialog = CreateFrame("Frame", nil, spellPanel, "DialogBoxFrame")
		dialog:SetFrameStrata("FULLSCREEN_DIALOG")
		dialog:SetSize(384, 128)
		dialog.text = dialog:CreateFontString(nil, "ARTWORK", "GameFontRedLarge")
		dialog.text:SetWidth(360)
		dialog.text:SetPoint("TOP", 0, -16)
		spellPanel:HookScript('OnHide', function() dialog:Hide() end)
	end
	dialog.text:SetText(message)
	dialog:Show()
end

function spellSpecificHandler:SetAliases(info, value)
	local aliases = self.db.aliases
	if aliases then
		wipe(aliases)
	else
		aliases = {}
	end
	for name in tostring(value):gmatch("[^\n]+") do
		name = name:trim()
		if name ~= "" then
			local name = ValidateName(name)
			tinsert(aliases, name)
		end
	end
	if #aliases > 0 then
		self.db.aliases = aliases
	else
		self.db.aliases = nil
	end
	self.db.default = nil
	addon:RequireUpdate(true)
end

local invalids = {}
function spellSpecificHandler:ValidateAliases(info, value)
	wipe(invalids)
	for name in tostring(value):gmatch("[^\n]+") do
		name = name:trim()
		if name ~= "" and not ValidateName(name) then
			tinsert(invalids, name)
		end
	end
	if #invalids > 0 then
		ShowErrorMessage(format(L["Invalid spell names:\n%s."], tconcat(invalids, "\n")))
		return false
	else
		return true
	end
end

-- The spell options themselves

local spellOptions = {
	name = L['Spells'],
	type = 'group',
	handler = spellSpecificHandler,
	get = 'Get',
	set = 'Set',
	disabled = 'IsReadOnly',
	hidden = 'IsNotViewable',
	args = {
		spell = {
			name = L['Current spell'],
			desc = L['Select the spell to edit. The color of the name is based on the setting type for the spell (see Type option below).'],
			type = 'select',
			get = function(info) return spellSpecificHandler:GetSelectedSpell() end,
			set = function(info, value) spellSpecificHandler:SelectSpell(value) end,
			values = 'GetSpellList',
			disabled = false,
			hidden = false,
			order = 10,
		},
		configSpellSources = {
			name = L['Lists spells from ...'],
			desc = BuildSelectDesc(
				L['Sources of spells to show in the "Current spell" dropdown. Use this to reduce that list of spells.'],
				ACTIONBAR_LABEL, L['spells and items visible on the action bars.'],
				L['Modified settings'], L['all settings that differ from default ones.'],
				L['Presets'], L['all the predefined settings, be them in use or not.'],
				SPELLBOOK, L['spells from matching spellbooks.']
			),
			type = 'multiselect',
			control = 'Dropdown',
			get = function(info, key) return profile.configSpellSources[key] end,
			set = function(info, key, value) profile.configSpellSources[key] = value end,
			values = 'GetSpellListList',
			disabled = false,
			hidden = false,
			order = 15,
		},
		status = {
			name = L['Type of settings'],
			desc = BuildSelectDesc(
				L["The kind of settings to use for the spell."],
				STATUS_LABELS.global, L['no specific settings for this spell ; use global ones.'],
				STATUS_LABELS.preset, L['use the predefined settings shipped with Inline Aura.'],
				STATUS_LABELS.user, L['use your own settings.'],
				STATUS_LABELS.ignore, L['totally ignore the spell ; do not show any countdown or highlight.']
			),
			type = "select",
			values = 'GetStatusList',
			get = 'GetStatus',
			set = 'SetStatus',
			disabled = false,
			hidden = 'IsNoSpellSelected',
			order = 20,
		},
		reset = {
			name = L['Reset'],
			type = "execute",
			func = "Reset",
			hidden = function(info) return info.handler:IsNotViewable() or info.handler:IsReadOnly() end,
			order = 30,
		},
		_lookupHeader = {
			name = L['Lookup'],
			type = 'header',
			order = 50,
		},
		auraType = {
			name = L['(De)buff type'],
			desc = BuildSelectDesc(
				L["Select the type of (de)buff of this spell. This is used to select the unit to watch for this spell."],
				L["Regular"], L["watch hostile units for harmful spells and friendly units for helpful spells."],
				L["Self"], L["watch your (de)buffs in any case."],
				PET, L["watch pet (de)buffs in any case."],
				L["Special"], L["display special values that are not (de)buffs."]
			),
			type = 'select',
			values = 'GetAuraTypeList',
			order = 60,
		},
		special = {
			name = L['Value to display'],
			desc = L['Select which special value should be displayed.'],
			type = 'select',
			values = 'GetKeywordList',
			disabled = 'IsReadOnly',
			hidden = function(info) return info.handler:IsNotViewable() or not info.handler:IsSpecial() end,
			order = 70,
		},
		aliases = {
			name = L['Additional (de)buffs'],
			desc = L['Enter additional names to test. This allows to detect alternative or equivalent (de)buffs. Some spells also apply (de)buffs that do not have the same name.\nNote: both buffs and debuffs are tested whether the base spell is harmlful or helpful.'],
			usage = L['Enter one name per line. They are spell-checked ; errors will prevents you to validate.'],
			type = 'input',
			width = 'full',
			multiline = true,
			get = 'GetAliases',
			set = 'SetAliases',
			validate = 'ValidateAliases',
			hidden = function(info) return info.handler:IsNotViewable() or info.handler:IsSpecial() end,
			order = 70,
		},
		onlyMine = {
			name = L['Only show mine'],
			desc = L["Only display the (de)buff if it has been applied by yourself, your pet or your vehicle."],
			type = 'select',
			get = 'GetTristate',
			set = 'SetTristate',
			values = tristateValues,
			hidden = function(info) return info.handler:IsNotViewable() or info.handler:IsSpecial() end,
			order = 65,
		},
		onlyAliases = {
			name = L['Show only aliases'],
			desc = L[''],
			type = 'toggle',
			disabled = 'IsReadOnly',
			order = 75,
		},
		hideCountdown = {
			name = L['No countdown'],
			desc = L['Hide the countdown text for this spell.'],
			type = 'select',
			get = 'GetTristate',
			set = 'SetTristate',
			values = tristateValues,
			hidden = function(info) return info.handler:IsNotViewable() or info.handler:IsSpecial() end,
			order = 90,
		},
		hideStack = {
			name = L['No application count'],
			desc = L['Hide the application count text for this spell.'],
			type = 'select',
			get = 'GetTristate',
			set = 'SetTristate',
			values = tristateValues,
			hidden = function(info) return info.handler:IsNotViewable() or info.handler:IsSpecial() end,
			order = 100,
		},
		_highlightHeader = {
			name = L['Highlight'],
			type = 'header',
			order = 110,
		},
		highlight = {
			name = L['Effect'],
			desc = BuildSelectDesc(
				L['Inline Aura can highlight the action button when the (de)buff is found.'],
				NONE, L['Do not highlight the button.'],
				L['Dim'], L['Dim the button when the (de)buff is NOT found (reversed logic).'],
				L['Colored border'], L['Display a colored border. Its color depends on the kind and owner of the (de)buff.'],
				L['Glowing animation'], L['Display the Blizzard shiny, animated border.']
			),
			type = 'select',
			values = {
				none = NONE,
				dim = L['Dim'],
				border = L['Colored border'],
				glowing = L['Glowing animation'],
			},
			order = 120,
		},
		invertHighlight = {
			name = L['Invert'],
			desc = L["Invert the highlight condition, highlightning when the (de)buff is not found."],
			type = 'toggle',
			disabled = function(info) return info.handler:IsReadOnly() or info.handler.db.highlight == "none" end,
			order = 130,
		},
	},
}

-----------------------------------------------------------------------------
-- Module options
-----------------------------------------------------------------------------

local moduleHandler = {}
local moduleOptions = {
	name = L['Modules'],
	type = 'group',
	handler = moduleHandler,
	get = 'Get',
	set = 'Set',
	args = {
		current = {
			name = L['Current module'],
			type = 'select',
			order = 10,
			values = 'GetModuleList',
			get = 'GetCurrent',
			set = 'SetCurrent',
		},
		options = {
			name = L['Module settings'],
			type = 'group',
			inline = true,
			hidden = 'HasNoCurrent',
			order = 20,
			args = {
				enabled = {
					name = L['Enabled'],
					desc = L['Should the module be used ?'],
					type = 'toggle',
					order = 10,
					get = 'IsEnabled',
					set = 'SetEnabled',
				},
				countdown = {
					name = L['Show countdown'],
					desc = L['Should the countdown provided by this module be displayed ?'],
					type = 'toggle',
					order = 20,
					disabled = 'IsDisabled',
					hidden = 'HasNotFeature',
				},
				stacks = {
					name = L['Show stack count'],
					desc = L['Should the stack count provided by this module be displayed ?'],
					type = 'toggle',
					order = 30,
					disabled = 'IsDisabled',
					hidden = 'HasNotFeature',
				},
				highlight = {
					name = L['Highlight'],
					desc = L['Should this module highlight the button ?'],
					type = 'toggle',
					order = 40,
					disabled = 'IsDisabled',
					hidden = 'HasNotFeature',
				},
				highlightThreshold = {
					name = L['Highlight threshold'],
					desc = L['This module only cause highlighting if the stack count is equal or above this threshold.'],
					type = 'range',
					min = 1,
					step = 1,
					order = 40,
					disabled = 'IsHighlightThresholdDisabled',
				},
				_keywords = {
					name = function(info) return info.handler:GetKeywordList() end,
					type = 'description',
					order = -1,
				},
			},
		},
	},
}

do
	local t = {}
	function moduleHandler:GetModuleList()
		wipe(t)
		for name, module in addon:IterateStateModules() do
			if module.db.profile.enabled then
				t[name] =  L[name]
			else
				t[name] = format("|cff777777%s|r", L[name])
			end
		end
		return t
	end
end

function moduleHandler:GetCurrent() return self.name end
function moduleHandler:HasNoCurrent() return not self.name end

function moduleHandler:SetCurrent(_, name)
	self.name = name
	local module = addon:GetModule(name)
	self.current = module
	local threshold = moduleOptions.args.options.args.highlightThreshold
	if module.features and module.features.highlight and module.features.highlightThreshold then
		threshold.max = module.features.highlightMaxThreshold or 100
		threshold.hidden = false
	else
		threshold.hidden = true
	end
end

function moduleHandler:GetKeywordList()
	return self.current and format(L["This module provides the following keyword(s) for use as an alias: %s."], tconcat(self.current.keywords, ", ")) or ""
end

function moduleHandler:IsEnabled() return self.current and self.current.db.profile.enabled end
function moduleHandler:IsDisabled() return not self:IsEnabled() end

function moduleHandler:SetEnabled(_, value)
	if not self.current then return end
	self.current.db.profile.enabled = value
	if value then
		self.current:Enable()
	else
		self.current:Disable()
	end
	addon:RequireUpdate(true)
end

function moduleHandler:IsHighlightThresholdDisabled()
	return self:IsDisabled() or (self.current and not self.current.db.profile.highlight)
end

function moduleHandler:HasNotFeature(info) return not (self.current and self.current.features and self.current.features[info[#info]]) end
function moduleHandler:Get(info) return self.current and self.current.db.profile[info[#info]] end

function moduleHandler:Set(info, value)
	if not self.current then return end
	self.current.db.profile[info[#info]] = value
	addon:RequireUpdate(true)
end


-----------------------------------------------------------------------------
-- Setup
-----------------------------------------------------------------------------

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

-- Register main options
AceConfig:RegisterOptionsTable('InlineAura-main', options)

-- Register spell specific options
AceConfig:RegisterOptionsTable('InlineAura-spells', spellOptions)

-- Register module options
AceConfig:RegisterOptionsTable('InlineAura-modules', moduleOptions)

-- Register profile options
local dbOptions = LibStub('AceDBOptions-3.0'):GetOptionsTable(addon.db)
LibStub('LibDualSpec-1.0'):EnhanceOptions(dbOptions, addon.db)
AceConfig:RegisterOptionsTable('InlineAura-profiles', dbOptions)

-- Create Blizzard AddOn option frames
local mainTitle = L['Inline Aura']
local mainPanel = AceConfigDialog:AddToBlizOptions('InlineAura-main', mainTitle)
spellPanel = AceConfigDialog:AddToBlizOptions('InlineAura-spells', L['Spells'], mainTitle)
AceConfigDialog:AddToBlizOptions('InlineAura-modules', L['Modules'], mainTitle)
AceConfigDialog:AddToBlizOptions('InlineAura-profiles', L['Profiles'], mainTitle)

-- Update selected spell on database change
addon.db.RegisterCallback(spellSpecificHandler, 'OnProfileChanged', 'ListUpdated')
addon.db.RegisterCallback(spellSpecificHandler, 'OnProfileCopied', 'ListUpdated')
addon.db.RegisterCallback(spellSpecificHandler, 'OnProfileReset', 'ListUpdated')
spellSpecificHandler:ListUpdated()

-- Manage to update the spell list on certain events
spellPanel:SetScript('OnEvent', function(self)
	if self:IsVisible() then
		AceConfigRegistry:NotifyChange("InlineAura-spells")
		spellSpecificHandler:ListUpdated()
	end
end)
spellPanel:RegisterEvent('SPELLS_CHANGED')
spellPanel:RegisterEvent('UPDATE_MACROS')
spellPanel:RegisterEvent('ACTIONBAR_HIDEGRID')

