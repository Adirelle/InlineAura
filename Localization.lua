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

local locale = GetLocale()
local L = {}
InlineAura_L = L

--------------------------------------------------------------------------------
-- default: enUS
--------------------------------------------------------------------------------

L['Add spell'] = true
L['Application text color'] = true
L['Aura to lookup'] = true
L['Aura type'] = true
L['Border colors'] = true
L['Buff'] = true
L['Check to have a more accurate countdown display instead of default Blizzard rounding.'] = true
L['Check to hide the aura application count (charges or stacks).'] = true
L['Check to hide the aura countdown.'] = true
L['Check to ignore buffs cast by other characters.'] = true
L['Check to ignore debuffs cast by other characters.'] = true
L['Countdown text color'] = true
L['Debuff'] = true
L["%dh"] = true
L['Disable'] = true
L["%dm"] = true
L['Do you really want to remove these aura specific settings ?'] = true
L['Font name'] = true
L['Inline Aura'] = true
L['My buffs'] = true
L["My debuffs"] = true
L['New spell name'] = true
L['No application count'] = true
L['No countdown'] = true
L['One name per line'] = true
L['Only my buffs'] = true
L['Only my debuffs'] = true
L['Only show mine'] = true
L["Others' buffs"] = true
L["Others' debuffs"] = true
L['Precise countdown'] = true
L['Profiles'] = true
L['Remove spell'] = true
L['Select the colors used to highlight the action button. There are selected based on aura type and caster.'] = true
L['Select the color to use for the buffs cast by other characters.'] = true
L['Select the color to use for the buffs you cast.'] = true
L['Select the color to use for the debuffs cast by other characters.'] = true
L['Select the color to use for the debuffs you cast.'] = true
L['Select the font to be used to display both countdown and application count.'] = true
L['Size of large text'] = true
L['Size of small text'] = true
L['Spell specific settings'] = true
L['Spell to edit'] = true
L['Text appearance'] = true
L['The large font is used to display aura countdowns unless OmniCC is loaded.'] = true
L['The small font is used to display aura application count and also countdown when OmniCC is loaded.'] = true
L["Unknown spell: %s"] = true

-- Replace true value by the key
for k,v in pairs(L) do if v == true then L[k] = k end end

--------------------------------------------------------------------------------
-- frFR
--------------------------------------------------------------------------------

if locale == "frFR" then
	L["Add spell"] = "Ajouter le sort"
	L["Application text color"] = "Couleur du nombre d'applications"
	L["Aura to lookup"] = "Auras \195\160 rechercher"
	L["Aura type"] = "Type d'aura"
	L["Border colors"] = "Couleur des bords"
	L["Buff"] = "Buff"
	L["Check to have a more accurate countdown display instead of default Blizzard rounding."] = "Cochez pour avoir un compte \195\160 rebours plus pr\195\169cis plut\195\180t que l'arrondi de Blizzard."
	L["Check to hide the aura application count (charges or stacks)."] = "Cochez pour cacher l'affichage du nombre de charges ou d'applications."
	L["Check to hide the aura countdown."] = "Cochez pour cacher le compte \195\160 rebours."
	L["Check to ignore buffs cast by other characters."] = "Cochez pour ignorer les buffs lanc\195\169s par les autres personnages."
	L["Check to ignore debuffs cast by other characters."] = "Cochez pour ignorer les debuffs lanc\195\169s par les autres personnages."
	L["Countdown text color"] = "Couleur du compte \195\160 rebours"
	L["Debuff"] = "Debuff"
	L["%dh"] = "%dh"
	L["Disable"] = "D\195\169sactiver"
	L["%dm"] = "%dm"
	L["Do you really want to remove these aura specific settings ?"] = "Voulez-vous vraiment enlever les r\195\169glages sp\195\169cifiques de ce sort ?"
	L["Font name"] = "Nom de la police"
	L["Inline Aura"] = "Inline Aura"
	L["My buffs"] = "Mes buffs"
	L["My debuffs"] = "Mes debuffs"
	L["New spell name"] = "Nom du nouveau sort"
	L["No application count"] = "Cacher le nombre d'applications"
	L["No countdown"] = "Cacher le compte \195\160 rebours"
	L["One name per line"] = "Un nom par ligne"
	L["Only my buffs"] = "Seulement mes buffs"
	L["Only my debuffs"] = "Seulement mes debuffs"
	L["Only show mine"] = "Afficher seulement les miens"
	L["Others' buffs"] = "Les buffs des autres"
	L["Others' debuffs"] = "Les debuffs des autres"
	L["Precise countdown"] = "Compte \195\160 rebours pr\195\169cis"
	L["Profiles"] = "Profils"
	L["Remove spell"] = "Enlever le sort"
	L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "Selectionnez les couleurs utilis\195\169es pour mettre les boutons d'actions en surbrillance. Elles sont choisies en fonction du type d'aura et du lanceur."
	L["Select the color to use for the buffs cast by other characters."] = "S\195\169lectionnez la couleur \195\160 utiliser pour les buffs lanc\195\169s par d'autres personnages."
	L["Select the color to use for the buffs you cast."] = "S\195\169lectionnez la couleur \195\160 utiliser pour les buffs lanc\195\169s par votre personnage."
	L["Select the color to use for the debuffs cast by other characters."] = "S\195\169lectionnez la couleur \195\160 utiliser pour les debuffs lanc\195\169s par d'autres personnages."
	L["Select the color to use for the debuffs you cast."] = "S\195\169lectionnez la couleur \195\160 utiliser pour les debuffs lanc\195\169s par votre personnage."
	L["Select the font to be used to display both countdown and application count."] = "S\195\169lectionnez la police utilis\195\169es pour afficher \195\160 la fois le compte \195\160 rebours et le nombre d'applications."
	L["Size of large text"] = "Taille du grand texte"
	L["Size of small text"] = "Taille du petit texte"
	L["Spell specific settings"] = "R\195\169glages sp\195\169cifiques aux sorts"
	L["Spell to edit"] = "Sort \195\160 \195\169diter"
	L["Text appearance"] = "Apparence du texte"
	L["The large font is used to display aura countdowns unless OmniCC is loaded."] = "Le grand texte est utilis\195\169e pour le compte \195\160 rebours, sauf si OmniCC est charg\195\169."
	L["The small font is used to display aura application count and also countdown when OmniCC is loaded."] = "Le petit texte est utilis\195\169e pour le nombre d'applications et aussi le compte \195\160 rebours quand OmniCC est charg\195\169."
	L["Unknown spell: %s"] = "Sort inconnu : %s"
end

