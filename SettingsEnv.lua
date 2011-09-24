--[[
Inline Aura - displays aura information inside action buttons
Copyright (C) 2009-2011 Adirelle (adirelle@tagada-team.net)

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

-- Make often-used globals local
--<GLOBALS
local _G = _G
local debugstack = _G.debugstack
local format = _G.format
local geterrorhandler = _G.geterrorhandler
local GetItemInfo = _G.GetItemInfo
local GetSpellInfo = _G.GetSpellInfo
local gsub = _G.gsub
local setfenv = _G.setfenv
local IsPassiveSpell = _G.IsPassiveSpell
local IsSpellKnown = _G.IsSpellKnown
local pairs = _G.pairs
local select = _G.select
local setmetatable = _G.setmetatable
local strmatch = _G.strmatch
local strtrim = _G.strtrim
local tinsert = _G.tinsert
local tonumber = _G.tonumber
local tostringall = _G.tostringall
local type = _G.type
local UnitClass = _G.UnitClass
local UnitFactionGroup = _G.UnitFactionGroup
local unpack = _G.unpack
local wipe = _G.wipe
--GLOBALS>

------------------------------------------------------------------------------
-- Build the settings env
------------------------------------------------------------------------------

local function BuildEnv(self, presets, statuses)

	local _

	local function AddFuncs()

		-- GLOBALS: class
		_, class = UnitClass('player')

		-- GLOBALS: version
		version = "@file-hash@/@project-version@"
		--@debug@
		version = "developer"
		--@end-debug@

		local reported = {}

		-- GLOBALS: GetSpellName
		-- Get the spell name, throwing error if not found
		function GetSpellName(id, level, noStrict)
			local name
			local input = id
			if type(id) == "string" then
				id = strtrim(id)
				if strmatch(id, "%s*#.*$") then
					id = gsub(id, "%s*#.*$", "")
					id = tonumber(id) or id
				end
			end
			if type(id) == "number" then
				-- Numeric spell id
				name = GetSpellInfo(tonumber(id))
			elseif type(id) == "string" then
				if strmatch(id, "^item:%d+") then
					-- "item:itemId" form
					name = GetItemInfo(id)
					if not name then
						-- May be missing from the item cache, don't warn the user
						return
					end
				elseif self.allKeywords[id] and noStrict then
					-- Keyword
					name = id
				end
			end
			if name then
				return name
			elseif not reported[input] then
				local source = debugstack((level or 0)+2, 1,0):match(":(%d+)")
				geterrorhandler()(format("Wrong spell id. Please report this error with the following information: id=%s, class=%s, version=%s, line=%s", tostringall(input, class, version, source)))
				reported[input] = true
			end
		end

		do
			local proto = {}
			local obj = setmetatable({ids = {}, spells = {}}, {__index=proto})

			local function GetSpell(id, level)
				local name = GetSpellName(id, (level or 0) + 2)
				if name then
					if not presets[name] then
						presets[name] = {
							id = id,
							auraType = 'regular',
							highlight = 'border',
							hideStack = true,
						}
						statuses[name] = 'preset'
					end
					return presets[name], name
				end
			end

			-- GLOBALS: Spells
			function Spells(...)
				wipe(obj.spells)
				wipe(obj.ids)
				for i = 1, select('#', ...) do
					local id = select(i, ...)
					local data = GetSpell(id)
					if data then
						obj.spells[id] = data
						tinsert(obj.ids, id)
					end
				end
				return obj
			end

			-- GLOBALS: SpellsByClass
			function SpellsByClass(...)
				wipe(obj.spells)
				wipe(obj.ids)
				for i = 1, select('#', ...), 2 do
					local spellClass, id = select(i, ...)
					if GetSpellName(id, 1) then
						if (spellClass == class or IsSpellKnown(id)) and not IsPassiveSpell(id) then
							obj.spells[id] = GetSpell(id)
						end
						tinsert(obj.ids, id)
					end
				end
				return obj
			end

			function proto:ForEach(func, ...)
				for id, spell in pairs(self.spells) do
					func(spell, ...)
				end
				return self
			end

			function proto:AreMutualAliases()
				return self:Aliases(unpack(self.ids))
			end

			local singleMethods

			singleMethods = {
				-- Stack display
				WithStack = function(spell) spell.hideStack = false end,
				NoStack = function(spell) spell.hideStack = true end,
				-- Countdown display
				WithCountdown = function(spell) spell.hideCountdown = false end,
				NoCountdown = function(spell) spell.hideCountdown = true end,
				-- Mine/others display
				OnlyMine = function(spell) spell.onlyMine = true end,
				ShowOthers = function(spell) spell.onlyMine = false end,
				-- Aura type
				IsRegular = function(spell) spell.auraType = "regular" end,
				OnSelf = function(spell) spell.auraType = "self" end,
				OnPet = function(spell) spell.auraType = "pet" end,
				ShowSpecial = function(spell, keyword)
					spell.auraType = "special"
					spell.special = keyword
				end,
				-- Highlight
				Glowing = function(spell) spell.highlight = "glowing" end,
				ColoredBorder = function(spell) spell.highlight = "border" end,
				NoHighlight = function(spell) spell.highlight = "none" end,
			}

			-- Aliases
			function singleMethods.Aliases(spell, ...)
				for i = 1, select('#', ...) do
					local id = select(i, ...)
					if id ~= spell.id then
						local name = GetSpellName(id, 1, true)
						if name then
							if not spell.aliases then
								spell.aliases = {}
							end
							if not spell.aliases[name] then
								tinsert(spell.aliases, name)
								spell.aliases[name] = true
							end
						end
					end
				end
			end

			for name, func in pairs(singleMethods) do
				local func = func
				proto[name] = function(self, ...) return self:ForEach(func, ...) end
			end
		end

		-- GLOBALS: Aliases
		-- Defines spell type and aliases
		function Aliases(mainId, ...) return Spells(mainId):Aliases(...) end

		-- GLOBALS: SelfBuffs
		-- Defines buffs that only apply to the player
		function SelfBuffs(...) return Spells(...):OnSelf():OnlyMine() end

		-- GLOBALS: PetBuffs
		-- Define pet buffs
		function PetBuffs(...) return Spells(...):OnPet() end

		-- GLOBALS: ShowSpecial
		-- Add special display
		function ShowSpecial(special, ...) return Spells(...):WithStack():Glowing():ShowSpecial(special) end

		-- GLOBALS: SelfTalentProc
		-- Defines auras that appear on the player and modify another spell
		function SelfTalentProc(spellId, ...) return Spells(spellId):Aliases(...):OnSelf():OnlyMine():Glowing() end

		-- GLOBALS: GroupBuffs
		-- Declare a category of group-wide buffs
		function GroupBuffs(...) return Spells(...):AreMutualAliases():OnSelf():ShowOthers() end

		-- GLOBALS: GroupDebuffs
		-- Declare a category of group-wide debuffs
		function GroupDebuffs(...) return Spells(...):AreMutualAliases():ShowOthers() end

		-- GLOBALS: SharedAuras
		-- Declare (de)buffs that are brought by several classes
		function SharedAuras(...) return SpellsByClass(...):AreMutualAliases():ShowOthers()	end

		-- GLOBALS: __cleanup
		function __cleanup()
			for name, spell in pairs(presets) do
				spell.id = nil
				if spell.aliases and #(spell.aliases) > 0 then
					spell.aliases = { unpack(spell.aliases) }
				else
					spell.aliases = nil
				end
			end
		end

	end

	-- Create an func environment
	local env = setmetatable({}, { __index = _G })

	-- Define our special functions in this environment
	setfenv(AddFuncs, env)
	AddFuncs()

	-- Returns a metatable to use it
	return { __index = env }
end

local EnvMeta

function addon:InitSettingsEnvironment(presets, statuses)
	if EnvMeta then return end
	EnvMeta = BuildEnv(addon, presets, statuses)
	BuildEnv = nil
end

function addon:LoadSettings(f)
	assert(EnvMeta)
	if not f then return end

	-- Create a private environment and execute the function inside it
	local privateEnv = setmetatable({}, EnvMeta)
	privateEnv._G = privateEnv
	setfenv(f, privateEnv)
	f()
	privateEnv.__cleanup()
end

