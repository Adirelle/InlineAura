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

-----------------------------------------------------------------------------
-- Configuration panel
-----------------------------------------------------------------------------

local InlineAura = InlineAura
local L = InlineAura.L

-- This is used to prevent AceDB to load the default values for a spell
-- when it has been explictly removed by the user. I'd rather use "false",
-- but it seems AceDB has some issue with it.
local REMOVED = '**REMOVED**'

-----------------------------------------------------------------------------
-- Default option handler
-----------------------------------------------------------------------------

local handler = {}

function handler:Set(info, ...)
	if info.type == 'color' then
		local color = InlineAura.db.profile[info.arg]
		color[1], color[2], color[3], color[4] = ...
	else
		InlineAura.db.profile[info.arg] = ...
	end
	InlineAura:RequireUpdate(true)
end

function handler:Get(info)
	if info.type == 'color' then
		return unpack(InlineAura.db.profile[info.arg])
	else
		return InlineAura.db.profile[info.arg]
	end
end

-----------------------------------------------------------------------------
-- Main options
-----------------------------------------------------------------------------

local options = {
	type = 'group',
	handler = handler,
	set = 'Set',
	get = 'Get',
	args = {
		onlyMyBuffs = {
			name = L['Only my buffs'],
			desc = L['Check to ignore buffs cast by other characters.'],
			type = 'toggle',
			arg = 'onlyMyBuffs',
			order = 10,
		},
		onlyMyDebuffs = {
			name = L['Only my debuffs'],
			desc = L['Check to ignore debuffs cast by other characters.'],
			type = 'toggle',
			arg = 'onlyMyDebuffs',
			order = 20,
		},
		hideCountdown = {
			name = L['No countdown'],
			desc = L['Check to hide the aura countdown.'],
			type = 'toggle',
			arg = 'hideCountdown',
			order = 30,
		},
		hideStack = {
			name = L['No application count'],
			desc = L['Check to hide the aura application count (charges or stacks).'],
			type = 'toggle',
			arg = 'hideStack',
			order = 40,
		},
		preciseCountdown = {
			name = L['Precise countdown'],
			desc = L['Check to have a more accurate countdown display for short-lived auras.'],
			type = 'toggle',
			arg = 'preciseCountdown',
			disabled = function(info) return InlineAura.db.profile.hideCountdown end,
			order = 45,
		},
		colors = {
			name = L['Border colors'],
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
					disabled = function() return InlineAura.db.profile.onlyMyBuffs end,
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
					disabled = function() return InlineAura.db.profile.onlyMyDebuffs end,
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
				fontName = {
					name = L['Font name'],
					desc = L['Select the font to be used to display both countdown and application count.'],
					type = 'select',
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					arg = 'fontName',
					order = 10,
				},
				smallFontSize = {
					name = L['Size of small text'],
					desc = L['The small font is used to display aura application count and also countdown when OmniCC is loaded.'],
					type = 'range',
					min = 5,
					max = 30,
					step = 1,
					arg = 'smallFontSize',
					order = 20,
				},
				largeFontSize = {
					name = L['Size of large text'],
					desc = L['The large font is used to display aura countdowns unless OmniCC is loaded.'],
					type = 'range',
					min = 5,
					max = 30,
					step = 1,
					arg = 'largeFontSize',
					order = 30,
				},
				colorCountdown = {
					name = L['Countdown text color'],
					type = 'color',
					arg = 'colorCountdown',
					hasAlpha = true,
					order = 40,
				},
				colorStack = {
					name = L['Application text color'],
					type = 'color',
					arg = 'colorStack',
					hasAlpha = true,
					order = 50,
				},
			},
		},
	},
}

-----------------------------------------------------------------------------
-- Spell specific options
-----------------------------------------------------------------------------

---- Main panel options

local spellPanelHandler = {}
local spellSpecificHandler = {}

local spellToAdd

local spellOptions = {
	name = L['Spell specific settings'],
	type = 'group',
	handler = spellPanelHandler,
	args = {
		addInput = {
			name = L['New spell name'],
			type = 'input',
			get = function(info) return spellToAdd end,
			set = function(info, value) spellToAdd = value end,
			validate = function(info, value) 
				if value and GetSpellInfo(value) and GetSpellInfo(GetSpellInfo(value)) then
					return true
				else
					return L["Unknown spell: %s"]:format(tostring(value))
				end
			end,
			order = 10,
		},
		addButton = {
			name = L['Add spell'],
			type = 'execute',
			order = 20,
			func = function(info) 
				info.handler:AddSpell(spellToAdd)
				spellToAdd = nil
			end,
			disabled = function() return not spellToAdd end,
		},
		editList = {
			name = L['Spell to edit'],
			type = 'select',
			get = function(info) return spellSpecificHandler:GetSelectedSpell() end,
			set = function(info, value) spellSpecificHandler:SelectSpell(value) end,
			disabled = 'HasNoSpell',
			values = 'GetSpellList',
			order = 30,
		},
		removeButton = {
			name = L['Remove spell'],
			type = 'execute',
			func = function(info) 
				info.handler:RemoveSpell(spellSpecificHandler:GetSelectedSpell())
			end,
			disabled = function() return spellSpecificHandler:IsNoSpellSelected() end,
			confirm = true,
			confirmText = L['Do you really want to remove these aura specific settings ?'],
			order = 40,
		},		
		settings = {
			name = function(info) return spellSpecificHandler:GetSelectedSpellName() end,
			type = 'group',
			hidden = 'IsNoSpellSelected', 	
			handler = spellSpecificHandler,
			get = 'Get',
			set = 'Set',
			inline = true,
			order = 50,
			args = {
				disable = {
					name = L['Disable'],
					type = 'toggle',
					arg = 'disabled',
					order = 10,
				},
				auraType = {
					name = L['Aura type'],
					type = 'select',
					arg = 'auraType',
					disabled = 'IsSpellDisabled',
					values = {
						buff = L['Buff'],
						debuff = L['Debuff'],
					},
					order = 20,
				},
				onlyMine = {
					name = L['Only show mine'],
					type = 'toggle',
					arg = 'onlyMine',
					tristate = true,
					disabled = 'IsSpellDisabled',
					order = 30,
				},
				aliases = {
					name = L['Aura to lookup'],
					usage = L['One name per line'],
					type = 'input',
					arg = 'aliases',
					disabled = 'IsSpellDisabled',
					multiline = true,
					get = 'GetAliases',
					set = 'SetAliases',
					order = 40,
				},
			},
		},
	},
} 

do
	local spellList = {}
	function spellPanelHandler:GetSpellList()
		wipe(spellList)
		for name, data in pairs(InlineAura.db.profile.spells) do
			if type(data) == 'table' then
				spellList[name] = name
			end
		end
		return spellList
	end
end

function spellPanelHandler:HasNoSpell()
	return not next(self:GetSpellList())
end

function spellPanelHandler:AddSpell(name)
	InlineAura.db.profile.spells[name] = {}
	spellSpecificHandler:SelectSpell(name)
	InlineAura:RequireUpdate(true)
end

function spellPanelHandler:RemoveSpell(name)
	if InlineAura.DEFAULT_OPTIONS.profile.spells[name] then
		InlineAura.db.profile.spells[name] = REMOVED
	else
		InlineAura.db.profile.spells[name] = nil
	end
	InlineAura:RequireUpdate(true)
	spellSpecificHandler:ListUpdated()
end

---- Specific aura options

function spellSpecificHandler:ListUpdated()
	if self.name and type(InlineAura.db.profile.spells[self.name]) == 'table' then
		return self:SelectSpell(self.name)
	end
	for name, data in pairs(InlineAura.db.profile.spells) do
		if type(data) == 'table' then
			return self:SelectSpell(name)
		end
	end
	self:SelectSpell(nil)
end

function spellSpecificHandler:GetSelectedSpell()
	return self.name
end

function spellSpecificHandler:GetSelectedSpellName()
	return self.name or ""
end

function spellSpecificHandler:SelectSpell(name)
	local db = name and InlineAura.db.profile.spells[name]
	if type(db) == 'table' then
		self.name, self.db = name, db
	else 
		self.name, self.db = nil, nil
	end
end

function spellSpecificHandler:IsNoSpellSelected()
	return not self.name
end

function spellSpecificHandler:IsSpellDisabled()
	return not self.db or self.db.disabled
end

function spellSpecificHandler:Set(info, ...)
	if info.type == 'color' then
		local color = self.db[info.arg]
		color[1], color[2], color[3], color[4] = ...
	else
		self.db[info.arg] = ...
	end
	InlineAura:RequireUpdate(true)
end

function spellSpecificHandler:Get(info)
	if info.type == 'color' then
		return unpack(self.db[info.arg])
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
		self.db.aliases = aliases
	end
	for name in tostring(value):gmatch("[^\n]+") do
		table.insert(aliases, name)
	end
	InlineAura:RequireUpdate(true)
end

-----------------------------------------------------------------------------
-- Setup method
-----------------------------------------------------------------------------

function InlineAura:SetupConfig()
	local AceConfig = LibStub("AceConfig-3.0")
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")

	-- Register main options
	AceConfig:RegisterOptionsTable('InlineAura-main', options)

	-- Register spell specific options
	AceConfig:RegisterOptionsTable('InlineAura-spells', spellOptions)

	-- Register profile options
	AceConfig:RegisterOptionsTable('InlineAura-profiles', LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)	)

	-- Create Blizzard AddOn option frames
	local mainTitle = L['Inline Aura']
	local mainPanel = AceConfigDialog:AddToBlizOptions('InlineAura-main', mainTitle)
	AceConfigDialog:AddToBlizOptions('InlineAura-spells', spellOptions.name, mainTitle)
	AceConfigDialog:AddToBlizOptions('InlineAura-profiles', L['Profiles'], mainTitle)

	-- Chat command line
	SLASH_INLINEAURA1 = "/inlineaura"
	function SlashCmdList.INLINEAURA()
		InterfaceOptionsFrame_OpenToCategory(mainPanel)
	end
	
	-- Update selected spell on database change
	InlineAura.db.RegisterCallback(spellSpecificHandler, 'OnProfileChanged', 'ListUpdated')
	InlineAura.db.RegisterCallback(spellSpecificHandler, 'OnProfileCopied', 'ListUpdated')
	InlineAura.db.RegisterCallback(spellSpecificHandler, 'OnProfileReset', 'ListUpdated')	
	spellSpecificHandler:ListUpdated()
end


