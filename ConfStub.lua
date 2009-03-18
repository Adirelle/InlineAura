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

local InlineAura = InlineAura
local L = InlineAura.L

local fakePanels = {}

function InlineAura.OpenConfig(name)
	-- Remove all fake panels
	for i, panel in pairs(INTERFACEOPTIONS_ADDONCATEGORIES) do
		if fakePanels[panel] then
			INTERFACEOPTIONS_ADDONCATEGORIES[i] = nil
			fakePanels[panel] = nil
		end
	end
	-- Load the config addon
	LoadAddOn('InlineAura_Config')
	-- Open the panel we were asked for
	InterfaceOptionsFrame_OpenToCategory(name)
end

-- Create a fake configuration panel that will load the configuration addon
local function AddFakePanel(name, parent)
	local panel = CreateFrame("Frame")
	panel.name = name
	panel.parent = parent
	panel:SetScript('OnShow', function()
		InlineAura.OpenConfig(name)
	end)
	InterfaceOptions_AddCategory(panel)
	fakePanels[panel] = true
end

-- Create the three fake configuration panel
local mainTitle = L['Inline Aura']
AddFakePanel(mainTitle)
AddFakePanel(L['Spell specific settings'], mainTitle)
AddFakePanel(L['Profiles'], mainTitle)

-- Chat command line
SLASH_INLINEAURA1 = "/inlineaura"
function SlashCmdList.INLINEAURA()
	InlineAura.OpenConfig(mainTitle)
end

