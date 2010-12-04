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

-----------------------------------------------------------------------------
-- Configuration panel
-----------------------------------------------------------------------------

local addon = LibStub('AceAddon-3.0'):GetAddon('InlineAura')
if not addon then return end

local L = addon.L
local SPELL_DEFAULTS = addon.DEFAULT_OPTIONS.profile.spells

-----------------------------------------------------------------------------
-- Default option handler
-----------------------------------------------------------------------------

local handler = {}

function handler:GetDatabase(info)
	local db = addon.db.profile
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
			disabled = function(info) return addon.db.profile.hideCountdown end,
			order = 45,
		},
		decimalCountdownThreshold = {
			name = L['Decimal countdown threshold'],
			desc = L['This is the threshold under which tenths of second are displayed.'],
			type = 'range',
			min = 1,
			max = 10,
			step = 0.5,
			disabled = function(info) return addon.db.profile.hideCountdown or not addon.db.profile.preciseCountdown end,
			order = 46,
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
						[""] = L['None'],
						OUTLINE = L['Outline'],
						THICKOUTLINE = L['Thick outline'],
					},
				},
				dynamicCountdownColor = {
					name = L['Dynamic countdown'],
					desc = L['Make the countdown color, and size if possible, depends on remaining time.'],
					type = 'toggle',
					order = 35,
					disabled = function() return addon.db.profile.hideCountdown end,
				},
				colorCountdown = {
					name = L['Countdown text color'],
					type = 'color',
					hasAlpha = true,
					order = 40,
					disabled = function() return addon.db.profile.hideCountdown or addon.db.profile.dynamicCountdownColor end,
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
					values = function(info) return info.handler:ListTextPositions(info, addon.db.profile.twoTextSecondPosition) end,
					disabled = function(info) return addon.db.profile.hideCountdown or addon.db.profile.hideStack end,
					order = 20,
				},
				twoTextSecond = {
					name = L['Application count position'],
					desc = L['Select where to place the application count text when both values are shown.'],
					type = 'select',
					arg = 'twoTextSecondPosition',
					values = function(info) return info.handler:ListTextPositions(info, addon.db.profile.twoTextFirstPosition) end,
					disabled = function(info) return addon.db.profile.hideCountdown or addon.db.profile.hideStack end,
					order = 30,
				},
				oneText = {
					name = L['Single value position'],
					desc = L['Select where to place a single value.'],
					type = 'select',
					arg = 'singleTextPosition',
					values = "ListTextPositions",
					disabled = function(info) return addon.db.profile.hideCountdown and addon.db.profile.hideStack end,
					order = 40,
				},
			},
		},
	},
}

-----------------------------------------------------------------------------
-- Class specific options
-----------------------------------------------------------------------------

local _, playerClass = UnitClass("player")
local isPetClass = (playerClass == "WARLOCK" or playerclass == "MAGE" or playerClass == "DEATHKNIGHT" or playerClass == "HUNTER")

local GetSpecialList
do
	local t = {}
	function GetSpecialList()
		wipe(t)
		for keyword, module in pairs(addon.stateKeywords) do
			t[keyword] = L[keyword]
		end
		return t
	end
end

-----------------------------------------------------------------------------
-- Spell specific options
-----------------------------------------------------------------------------

local ValidateName, spellPanel

local function BuildSelectDesc(text, ...)
	for i = 1, select('#', ...), 2 do
		text = format("%s\n\n|cff44ff44%s|r: %s", text, select(i, ...))
	end
	return text
end

local statusColors = { ignore = "ff7744", preset = "00ffff", user = "44ff44", global = "cccccc" }

local GetSpellList
do
	local spellList = {}

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
				label = format("%s |T%s:20:20:0:0:64:64:4:60:4:60|t", label, icon)
			end
			local settings = rawget(addon.db.profile.spells, key)
			local status = settings and settings.status or "global"
			spellList[key] = format("|cff%s%s|r", statusColors[status], label)
		end
	end

	function GetSpellList()
		wipe(spellList)
		-- Scan action buttons for spells and items
		for button, state in pairs(addon.buttons) do
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
		-- Add spell from spellbooks
		local index = 1
		repeat
			local name = GetSpellInfo(index, "spell")
			if name and not spellList[name] and not IsPassiveSpell(name) then
				AddEntry("spell", name)
			end
			index = index + 1
		until not name
		-- Merge current settings
		for key in pairs(addon.db.profile.spells) do
			if not spellList[key] then
				if GetSpellInfo(key) then
					AddEntry("spell", key)
				elseif GetItemInfo(key) then
					AddEntry("item", key)
				else
					--@debug@
					addon.dprint("Can't find out if it is an item or a spell, deleting:", key)
					--@end-debug@
					addon.db.profile.spells[key] = nil
				end
			end
		end
		return spellList
	end
end

---- Spell panel options

local spellSpecificHandler = {}

local spellOptions = {
	name = L['Spell specific settings'],
	type = 'group',
	handler = spellSpecificHandler,
	get = 'Get',
	set = 'Set',
	disabled = 'IsReadOnly',
	hidden = 'IsNotViewable',
	args = {
		spell = {
			name = L['Spell'],
			desc = L['Select the spell to edit or to remove its specific settings. Spells with specific defaults are written in |cff77ffffcyan|r. Removed spells with specific defaults are written in |cff777777gray|r.'],
			type = 'select',
			width = 'double',
			get = function(info) return spellSpecificHandler:GetSelectedSpell() end,
			set = function(info, value) spellSpecificHandler:SelectSpell(value) end,
			values = GetSpellList,
			disabled = false,
			hidden = false,
			order = 10,
		},
		status = {
			name = L['Type'],
			type = "select",
			arg = 'status',
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
				L["Pet"], L["watch pet (de)buffs in any case."],
				L["Special"], L["display special values that are not (de)buffs."]
			),
			type = 'select',
			arg = 'auraType',
			values = {
				regular = L['Regular'],
				self = L['Self'],
				pet = isPetClass and L['Pet'] or nil,
				special = L['Special'] or nil,
			},
			order = 60,
		},
		specialAlias = {
			name = L['Value to display'],
			desc = L['Select which special value should be displayed.'],
			type = 'select',
			arg = 'aliases',
			get = function(info) return info.handler.db.aliases and info.handler.db.aliases[1] end,
			set = function(info, value)
				if not info.handler.db.aliases then
					info.handler.db.aliases = { value }
				else
					info.handler.db.aliases[1] = value
				end
				addon:RequireUpdate(true)
			end,
			values = GetSpecialList,
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
			arg = 'aliases',
			multiline = true,
			get = 'GetAliases',
			set = 'SetAliases',
			validate = 'ValidateAliases',
			hidden = function(info) return info.handler:IsNotViewable() or info.handler:IsSpecial() end,
			order = 70,
		},
		onlyMine = {
			name = L['Only show mine'],
			desc = L["Only display the (de)buff if it has been applied by yourself, your pet or your vehicle."].."\n"..L['The grey mark means "use global settings" while an empty box and the yellow mark enforce specific settings.'],
			type = 'toggle',
			arg = 'onlyMine',
			tristate = true,
			hidden = function(info) return info.handler:IsNotViewable() or info.handler:IsSpecial() end,
			order = 65,
		},
		hideCountdown = {
			name = L['No countdown'],
			desc = L['Hide the countdown text for this spell.'].."\n"..L['The grey mark means "use global settings" while an empty box and the yellow mark enforce specific settings.'],
			type = 'toggle',
			arg = 'hideCountdown',
			tristate = true,
			hidden = function(info) return info.handler:IsNotViewable() or info.handler:IsSpecial() end,
			order = 90,
		},
		hideStack = {
			name = L['No application count'],
			desc = L['Hide the application count text for this spell.'].."\n"..L['The grey mark means "use global settings" while an empty box and the yellow mark enforce specific settings.'],
			type = 'toggle',
			arg = 'hideStack',
			tristate = true,
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
				L['None'], L['Do not highlight the button.'],
				L['Dim'], L['Dim the button when the (de)buff is NOT found (reversed logic).'],
				L['Colored border'], L['Display a colored border. Its color depends on the kind and owner of the (de)buff.'],
				L['Glowing animation'], L['Display the Blizzard shiny, animated border.']
			),
			type = 'select',
			arg = 'highlight',
			values = {
				none = L['None'],
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
			arg = 'invertHighlight',
			disabled = function(info) return info.handler:IsReadOnly() or info.handler.db.highlight == "none" end,
			order = 130,
		},
	},
}

---- Specific aura options

function spellSpecificHandler:ListUpdated()
	self:SelectSpell(nil)
end

function spellSpecificHandler:GetSelectedSpell()
	return self.name
end

function spellSpecificHandler:GetSelectedSpellName()
	return self.name or "???"
end

function spellSpecificHandler:GetStatus()
	return self.status
end

function spellSpecificHandler:SetStatus(_, status)
	addon.db.profile.spells[self.name].status = status
	addon:RequireUpdate(true)
	self:SelectSpell(self.name)
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

function spellSpecificHandler:Reset()
	if self:IsReadOnly() then return end
	local settings = addon.db.profile.spells[self.name]
	wipe(settings)
	copy(SPELL_DEFAULTS[self.name] or SPELL_DEFAULTS['**'], settings)
	settings.status = "user"
	addon:RequireUpdate(true)
end

do
	local values = {
		global = format('|cff%s%s|r', statusColors.global, L['None (global settings)']),
		preset = format('|cff%s%s|r', statusColors.preset, L['Preset']),
		user = format('|cff%s%s|r', statusColors.user, L['User-defined']),
		ignore = format('|cff%s%s|r', statusColors.ignore, L['Ignored']),
	}
	local tmp = copy(values, {})
	function spellSpecificHandler:GetStatusList()
		tmp.preset = SPELL_DEFAULTS[self.name] and values.preset or nil
		return tmp
	end
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

function spellSpecificHandler:IsNotViewable()
	return not self.name or (self.status ~= "preset" and self.status ~= "user")
end

function spellSpecificHandler:IsReadOnly()
	return self.status ~= "user"
end

function spellSpecificHandler:IsSpecial()
	return self.db and self.db.auraType == "special"
end

function spellSpecificHandler:Set(info, ...)
	if self:IsReadOnly() then return end
	if info.type == 'color' then
		local color = self.db[info.arg]
		color[1], color[2], color[3], color[4] = ...
	elseif info.type == 'multiselect' then
		local key, value = ...
		value = value and true or false
		if type(self.db[info.arg]) ~= 'table' then
			self.db[info.arg] = { key = value }
		else
			self.db[info.arg][key] = value
		end
	else
		self.db[info.arg] = ...
	end
	addon:RequireUpdate(true)
end

function spellSpecificHandler:Get(info, key)
	if info.type == 'color' then
		return unpack(self.db[info.arg])
	elseif info.type == 'multiselect' then
		return type(self.db[info.arg]) == "table" and self.db[info.arg][key]
	else
		return self.db[info.arg]
	end
end

function spellSpecificHandler:GetAliases(info)
	local aliases = self.db.aliases
	return type(aliases) == 'table' and table.concat(aliases, "\n") or nil
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
			table.insert(aliases, name)
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

function spellSpecificHandler:ValidateAliases(info, value)
	for name in tostring(value):gmatch("[^\n]+") do
		name = name:trim()
		if name ~= "" and not ValidateName(name) then
			return L["Unknown spell: %s"]:format(name)
		end
	end
	return true
end

-----------------------------------------------------------------------------
-- Spell name validation
-----------------------------------------------------------------------------

do
	local GetSpellInfo, GetItemInfo = GetSpellInfo, GetItemInfo, strlower, rawget
	local keywords = addon.stateKeywords
	local id = 0
	local function doValidateName(value)
		if keywords[value] then
			return value, 'keyword'
		end
		local spellId = tonumber(strmatch('spell:(%d+)', value))
		if spellId then
			return GetSpellInfo(spellId), 'spell'
		end
		local itemId = tonumber(strmatch('item:(%d+)', value))
		if itemId then
			return GetItemInfo(itemId), 'item'
		end
		local itemName = GetItemInfo(value)
		if itemName then
			return itemName, 'item'
		end
		local knownSpell = GetSpellInfo(value)
		if knownSpell then
			return knownSpell, 'spell'
		end
		value = strlower(value)
		while id < 100000 do -- Arbitrary high spell id
			local name = GetSpellInfo(id)
			id = id + 1
			if name and strlower(name) == value then
				return name, 'spell'
			end
		end
	end

	local validNames = setmetatable({}, {
		__mode = 'kv',
		__index = function(self, key)
			local name, type = doValidateName(key)
			local result = name and strjoin('|', name, type) or false
			self[key] = result
			return result
		end
	})

	function ValidateName(name)
		if type(name) == "string" then
			local info = validNames[name]
			if info then
				return strsplit('|', info)
			end
		end
	end
end

-----------------------------------------------------------------------------
-- Setup
-----------------------------------------------------------------------------

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Register main options
AceConfig:RegisterOptionsTable('InlineAura-main', options)

-- Register spell specific options
AceConfig:RegisterOptionsTable('InlineAura-spells', spellOptions)

-- Register profile options
local dbOptions = LibStub('AceDBOptions-3.0'):GetOptionsTable(addon.db)
LibStub('LibDualSpec-1.0'):EnhanceOptions(dbOptions, addon.db)
AceConfig:RegisterOptionsTable('InlineAura-profiles', dbOptions)

-- Create Blizzard AddOn option frames
local mainTitle = L['Inline Aura']
local mainPanel = AceConfigDialog:AddToBlizOptions('InlineAura-main', mainTitle)
spellPanel = AceConfigDialog:AddToBlizOptions('InlineAura-spells', L['Spell specific settings'], mainTitle)
AceConfigDialog:AddToBlizOptions('InlineAura-profiles', L['Profiles'], mainTitle)

-- Update selected spell on database change
addon.db.RegisterCallback(spellSpecificHandler, 'OnProfileChanged', 'ListUpdated')
addon.db.RegisterCallback(spellSpecificHandler, 'OnProfileCopied', 'ListUpdated')
addon.db.RegisterCallback(spellSpecificHandler, 'OnProfileReset', 'ListUpdated')
spellSpecificHandler:ListUpdated()
