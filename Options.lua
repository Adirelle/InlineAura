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

function InlineAura:SetupConfig()
	local AceConfig = LibStub("AceConfig-3.0")
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")

	-- Register main options
	AceConfig:RegisterOptionsTable('InlineAura-main', options)

	-- Register profile options
	AceConfig:RegisterOptionsTable('InlineAura-profiles', LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)	)

	-- Create Blizzard AddOn option frames
	local mainPanel = AceConfigDialog:AddToBlizOptions('InlineAura-main', 'Inline Aura')
	AceConfigDialog:AddToBlizOptions('InlineAura-profiles', 'Profiles', 'Inline Aura')

	-- Chat command line
	SLASH_INLINEAURA1 = "/inlineaura"
	function SlashCmdList.INLINEAURA()
		InterfaceOptionsFrame_OpenToCategory(mainPanel)
	end
end

