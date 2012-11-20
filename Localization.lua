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

local _, addon = ...

------------------------------------------------------------------------------
-- Make often-used globals local
------------------------------------------------------------------------------

--<GLOBALS
local _G = _G
local BALANCE_NEGATIVE_ENERGY = _G.BALANCE_NEGATIVE_ENERGY
local BALANCE_POSITIVE_ENERGY = _G.BALANCE_POSITIVE_ENERGY
local format = _G.format
local GetLocale = _G.GetLocale
local HEALTH = _G.HEALTH
local HOLY_POWER = _G.HOLY_POWER
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local strlower = _G.strlower
local tostring = _G.tostring
local UnitPowerType = _G.UnitPowerType
--GLOBALS>

local locale = GetLocale()
local L = setmetatable({}, {__index = function(self, key)
	local value = tostring(key)
	if key ~= nil then self[key] = value end
	--@debug@
	addon:Debug("Missing locale:", value)
	--@end-debug@
	return value
end})
addon.L = L

-- Hard-coded locales using keywords
L["COMBO_POINTS"] = "Combo points"
L["SOUL_SHARDS"] = "Soul shards"
L["BELOWxx"] = "Below %d%% %s"
L["ABOVExx"] = "Above %d%% %s"
L["DISPELLABLE"] = "(De)buff you can dispell"
L["INTERRUPTIBLE"] = "Interruptible spellcast"

--@noloc[[
-- Using locales from GlobalStrings.lua
do
	for _, value in pairs{ 20, 25, 35, 80 } do
		L["BELOW"..value] = format(L["BELOWxx"], value, HEALTH)
		L["ABOVE"..value] = format(L["ABOVExx"], value, HEALTH)
	end
	local _, powerToken = UnitPowerType("player")
	local power = strlower(_G[powerToken] or powerToken)
	for _, value in pairs{ 40, 60, 80 } do
		L["PWBELOW"..value] = format(L["BELOWxx"], value, power)
		L["PWABOVE"..value] = format(L["ABOVExx"], value, power)
	end
end
L["LUNAR_ENERGY"] = BALANCE_NEGATIVE_ENERGY
L["SOLAR_ENERGY"] = BALANCE_POSITIVE_ENERGY
L["HOLY_POWER"] = HOLY_POWER
-- @noloc]]

--------------------------------------------------------------------------------
-- Locales from localization system
--------------------------------------------------------------------------------

-- %Localization: inline-aura
-- THE END OF THE FILE IS UPDATED BY https://github.com/Adirelle/wowaceTools/#updatelocalizationphp.
-- ANY CHANGE BELOW THESES LINES WILL BE LOST.
-- UPDATE THE TRANSLATIONS AT http://www.wowace.com/addons/inline-aura/localization/
-- AND ASK THE AUTHOR TO UPDATE THIS FILE.

-- @noloc[[

------------------------ enUS ------------------------


-- Config.lua
L["(De)buff type"] = true
L["Additional (de)buffs"] = true
L["Adjust the font size of countdown and application count texts."] = true
L["Allow you to disable glowing highlight in certain situations."] = true
L["Application count position"] = true
L["Application text color"] = true
L["Behave as if the interface option \"Auto self cast\" was enabled, e.g. test helpful spells on yourself when you are not targeting a friendly unit.\nNote: this enables the old Inline Aura behavior with friendly spells."] = true
L["Border highlight colors"] = true
L["Bottom left"] = true
L["Bottom right"] = true
L["Bottom"] = true
L["Center"] = true
L["Colored border"] = true
L["Countdown position"] = true
L["Countdown text color"] = true
L["Current module"] = true
L["Current spell"] = true
L["Decimal countdown threshold"] = true
L["Dim the button when the (de)buff is NOT found (reversed logic)."] = true
L["Dim"] = true
L["Display a colored border. Its color depends on the kind and owner of the (de)buff."] = true
L["Display the Blizzard shiny, animated border."] = true
L["Do not display (de)buff application count in the action buttons."] = true
L["Do not display the remaining time countdown in the action buttons."] = true
L["Do not highlight the button."] = true
L["Dynamic countdown"] = true
L["Effect"] = true
L["Either OmniCC or CooldownCount is loaded so aura countdowns are displayed using small font only."] = true
L["Emulate auto self cast"] = true
L["Enabled"] = true
L["Enter additional names to test. This allows to detect alternative or equivalent (de)buffs. Some spells also apply (de)buffs that do not have the same name.\nNote: both buffs and debuffs are tested whether the base spell is harmlful or helpful."] = true
L["Enter one name per line. They are spell-checked ; errors will prevents you to validate."] = true
L["Font effect"] = true
L["Font name"] = true
L["Font size"] = true
L["Glowing animation"] = true
L["Glowing highlight"] = true
L["Hide the application count text for this spell."] = true
L["Hide the countdown text for this spell."] = true
L["Highlight threshold"] = true
L["Highlight"] = true
L["Ignore buffs cast by other characters."] = true
L["Ignore debuffs cast by other characters."] = true
L["Ignored"] = true
L["Inline Aura can highlight the action button when the (de)buff is found."] = true
L["Inline Aura"] = true
L["Invalid spell names:\n%s."] = true
L["Invert the highlight condition, highlightning when the (de)buff is not found."] = true
L["Invert"] = true
L["Left"] = true
L["Lists spells from ..."] = true
L["Lookup"] = true
L["Make the countdown color, and size if possible, depends on remaining time."] = true
L["Modified settings"] = true
L["Module settings"] = true
L["Modules"] = true
L["My buffs"] = true
L["My debuffs"] = true
L["No application count"] = true
L["No countdown"] = true
L["On cooldown"] = true
L["Only display the (de)buff if it has been applied by yourself, your pet or your vehicle."] = true
L["Only my buffs"] = true
L["Only my debuffs"] = true
L["Only show mine"] = true
L["Options related to the units to watch and the way to select them depending on the spells."] = true
L["Others' buffs"] = true
L["Others' debuffs"] = true
L["Out of combat"] = true
L["Outline"] = true
L["Precise countdown"] = true
L["Preset"] = true
L["Presets"] = true
L["Profiles"] = true
L["Regular"] = true
L["Reset"] = true
L["Right"] = true
L["Select an effect to enhance the readability of the texts."] = true
L["Select the color to use for the buffs cast by other characters."] = true
L["Select the color to use for the buffs you cast."] = true
L["Select the color to use for the debuffs cast by other characters."] = true
L["Select the color to use for the debuffs you cast."] = true
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = true
L["Select the font to be used to display both countdown and application count."] = true
L["Select the spell to edit. The color of the name is based on the setting type for the spell (see Type option below)."] = true
L["Select the type of (de)buff of this spell. This is used to select the unit to watch for this spell."] = true
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = true
L["Select where to place a single value."] = true
L["Select where to place the application count text when both values are shown."] = true
L["Select where to place the countdown text when both values are shown."] = true
L["Select which special value should be displayed."] = true
L["Self"] = true
L["Should the countdown provided by this module be displayed ?"] = true
L["Should the module be used ?"] = true
L["Should the stack count provided by this module be displayed ?"] = true
L["Should this module highlight the button ?"] = true
L["Show countdown"] = true
L["Show only aliases"] = true
L["Show stack count"] = true
L["Single value position"] = true
L["Size of large text"] = true
L["Size of small text"] = true
L["Sources of spells to show in the \"Current spell\" dropdown. Use this to reduce that list of spells."] = true
L["Special"] = true
L["Spells"] = true
L["Targeting settings"] = true
L["Text Position"] = true
L["Text appearance"] = true
L["The kind of settings to use for the spell."] = true
L["The large font is used to display countdowns."] = true
L["The small font is used to display application count."] = true
L["Thick outline"] = true
L["This is the threshold under which tenths of second are displayed."] = true
L["This module only cause highlighting if the stack count is equal or above this threshold."] = true
L["This module provides the following keyword(s) for use as an alias: %s."] = true
L["Top left"] = true
L["Top right"] = true
L["Top"] = true
L["Type of settings"] = true
L["Uncheck this to disable highlight for actions in cooldown."] = true
L["Uncheck this to disable highlight for unusable actions."] = true
L["Uncheck this to disable highlight out of combat."] = true
L["Unusable"] = true
L["Use a more accurate rounding, down to tenths of second, instead of the default Blizzard rounding."] = true
L["Use global setting"] = true
L["User-defined"] = true
L["Value to display"] = true
L["Watch (de)buff changes on the unit under the mouse cursor. Required only to properly update macros that uses @mouseover targeting."] = true
L["Watch (de)buff changes on your focus. Required only to properly update macros that uses @focus targeting."] = true
L["Watch focus"] = true
L["Watch unit under mouse cursor"] = true
L["all settings that differ from default ones."] = true
L["all the predefined settings, be them in use or not."] = true
L["display special values that are not (de)buffs."] = true
L["no specific settings for this spell ; use global ones."] = true
L["spells and items visible on the action bars."] = true
L["spells from matching spellbooks."] = true
L["totally ignore the spell ; do not show any countdown or highlight."] = true
L["use the predefined settings shipped with Inline Aura."] = true
L["use your own settings."] = true
L["watch hostile units for harmful spells and friendly units for helpful spells."] = true
L["watch pet (de)buffs in any case."] = true
L["watch your (de)buffs in any case."] = true

-- Display.lua
L["%dh"] = true
L["%dm"] = true

-- StateModules.lua
L["Dispel"] = true
L["Eclipse energy"] = true
L["Health threshold"] = true
L["Interrupt"] = true
L["Power threshold"] = true
L["Totem timers"] = true


------------------------ frFR ------------------------
local locale = GetLocale()
if locale == 'frFR' then
L["ABOVExx"] = "Plus de %d%% de %s"
L["Additional (de)buffs"] = "(Dé)buffs supplémentaires"
L["Adjust the font size of countdown and application count texts."] = "Ajuster la taille des polices du texte des comptes à rebours et du nombre d'application."
L["Allow you to disable glowing highlight in certain situations."] = "Vous permet de désactiver la surbrillance dans certaines situations." -- Needs review
L["Application count position"] = "Position du nombre de charges"
L["Application text color"] = "Couleur du nombre d'applications"
L[ [=[Behave as if the interface option "Auto self cast" was enabled, e.g. test helpful spells on yourself when you are not targeting a friendly unit.
Note: this enables the old Inline Aura behavior with friendly spells.]=] ] = [=[Fonctionner comme si l'option d'interface "Auto self cast" était cochée, c'est-à-dire tester les sorts amicaux sur vous-même quand vous ne ciblez pas une unité amie.
Note : Ceci active l'ancien fonctionnement d'Inline Aura avec les sorts amicaux.]=] -- Needs review
L["BELOWxx"] = "Moins de %d%% de %s"
L["Border highlight colors"] = "Couleurs des bords"
L["Bottom"] = "Bas"
L["Bottom left"] = "En bas à gauche"
L["Bottom right"] = "En bas à droite"
L["Center"] = "Centré"
L["Colored border"] = "Bord coloré"
L["COMBO_POINTS"] = "Points de combo"
L["Countdown position"] = "Position du compte à rebours"
L["Countdown text color"] = "Couleur du compte à rebours"
L["Current module"] = "Module actuel"
L["Current spell"] = "Sort actuel"
L["(De)buff type"] = "Type de (dé)buff"
L["Decimal countdown threshold"] = "Seuil de compte à rebours décimal"
L["%dh"] = "%dh"
L["Dim"] = "Assombrir"
L["Dim the button when the (de)buff is NOT found (reversed logic)."] = "Assombrit le bouton quand le (dé)buff n'est PAS trouvé (logique inverse)."
L["Dispel"] = "Dissiper" -- Needs review
L["DISPELLABLE"] = "(Dé)buffs que vous pouvez dissiper"
L["Display a colored border. Its color depends on the kind and owner of the (de)buff."] = "Afficher une bordure colorée. Sa couleur dépend du type et de l'unité portant le (dé)buff."
L["Display the Blizzard shiny, animated border."] = "Afficher la bordure brillante animée de Blizzard."
L["%dm"] = "%dm"
L["Do not display (de)buff application count in the action buttons."] = "Ne pas afficher le nombre d'application de (dé)buffs sur les boutons d'action."
L["Do not display the remaining time countdown in the action buttons."] = "Ne pas afficher le temps restant sur les boutons d'action."
L["Do not highlight the button."] = "Ne pas mettre en évidence le bouton."
L["Dynamic countdown"] = "Décompte dynamique"
L["Eclipse energy"] = "Éclipse" -- Needs review
L["Effect"] = "Effet"
L["Either OmniCC or CooldownCount is loaded so aura countdowns are displayed using small font only."] = "Soit OmniCC, soit CooldownCount est chargé, donc les comptes à rebours des auras seront affichées avec des petites polices uniquement."
L["Emulate auto self cast"] = "Emuler \"soi-même par défaut\"."
L["Enabled"] = "Activé" -- Needs review
L[ [=[Enter additional names to test. This allows to detect alternative or equivalent (de)buffs. Some spells also apply (de)buffs that do not have the same name.
Note: both buffs and debuffs are tested whether the base spell is harmlful or helpful.]=] ] = [=[Tapez les noms supplémentaires à tester. Ceci permet de détecter les (dé)buffs équivalents ou alternatifs. Il arrive aussi que certains sorts appliquent des (dé)buffs qui n'ont pas le même nom.
Note : les buffs et les débuffs sont testés, que le sort de base soit amical ou agressif.]=] -- Needs review
L["Enter one name per line. They are spell-checked ; errors will prevents you to validate."] = "Tapez un nom par ligne. Ils sont vérifiés, des erreurs vous empêcheront de valider."
L["Font effect"] = "Effet de police"
L["Font name"] = "Nom de la police"
L["Font size"] = "Taille de police"
L["Glowing animation"] = "Animation brillante"
L["Health threshold"] = "Seuil de vie"
L["Hide the application count text for this spell."] = "Cacher le texte du nombre d'application pour ce sort."
L["Hide the countdown text for this spell."] = "Cacher le texte du temps restant pour ce sort."
L["Highlight"] = "Mettre en évidence"
L["Highlight threshold"] = "Seuil de mise en évidence"
L["Ignore buffs cast by other characters."] = "Ignorer les buffs lancés pas d'autres personnages."
L["Ignored"] = "Ignorés" -- Needs review
L["Ignore debuffs cast by other characters."] = "Ignorer les débuffs lancés pas d'autres personnages."
L["Inline Aura"] = "Inline Aura"
L["Inline Aura can highlight the action button when the (de)buff is found."] = "Inline Aura peut mettre en évidence le bouton d'action quand le (dé)buff est trouvé."
L["Interrupt"] = "Interruption" -- Needs review
L["INTERRUPTIBLE"] = "Incantation pouvant être interrompue"
L[ [=[Invalid spell names:
%s.]=] ] = [=[Noms de sort invalides :
%s.]=]
L["Invert"] = "Inverser" -- Needs review
L["Invert the highlight condition, highlightning when the (de)buff is not found."] = "Inverser la condition de mise en évidence, mette en évidence que quand le (dé)buff n'est pas trouvé."
L["Left"] = "A gauche"
L["Lists spells from ..."] = "Liste les sorts provenant de ..." -- Needs review
L["Lookup"] = "Recherche" -- Needs review
L["Make the countdown color, and size if possible, depends on remaining time."] = "Fait varier la couleur du décompte, et la taille si possible, en fonction du temps restant."
L["Modified settings"] = "Paramètres modifiés" -- Needs review
L["Modules"] = "Modules"
L["Module settings"] = "Paramètres du module" -- Needs review
L["My buffs"] = "Mes buffs"
L["My debuffs"] = "Mes debuffs"
L["No application count"] = "Cacher le nombre d'applications"
L["No countdown"] = "Cacher le compte à rebours"
L["On cooldown"] = "En cooldown" -- Needs review
L["Only display the (de)buff if it has been applied by yourself, your pet or your vehicle."] = "N'afficher le (dé)buff que si il a été lancé par vous, votre familier ou votre véhicule."
L["Only my buffs"] = "Seulement mes buffs"
L["Only my debuffs"] = "Seulement mes debuffs"
L["Only show mine"] = "Afficher seulement les miens"
L["Options related to the units to watch and the way to select them depending on the spells."] = "Options en rapport avec les unités à surveiller et la façon de les sélectionner selon les sorts."
L["Others' buffs"] = "Les buffs des autres"
L["Others' debuffs"] = "Les debuffs des autres"
L["Outline"] = "Bordure"
L["Out of combat"] = "Hors de combat" -- Needs review
L["Power threshold"] = "Seuil de resource"
L["Precise countdown"] = "Compte à rebours précis"
L["Preset"] = "Préréglé" -- Needs review
L["Presets"] = "Préréglages" -- Needs review
L["Profiles"] = "Profils"
L["Regular"] = "Standard" -- Needs review
L["Reset"] = "Réinitialiser" -- Needs review
L["Right"] = "A droite"
L["Select an effect to enhance the readability of the texts."] = "Sélectionnez un effet pour améliorer la visibilité des textes"
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "Selectionnez les couleurs utilisées pour mettre les boutons d'actions en surbrillance. Elles sont choisies en fonction du type d'aura et du lanceur."
L["Select the color to use for the buffs cast by other characters."] = "Sélectionnez la couleur à utiliser pour les buffs lancés par d'autres personnages."
L["Select the color to use for the buffs you cast."] = "Sélectionnez la couleur à utiliser pour les buffs lancés par votre personnage."
L["Select the color to use for the debuffs cast by other characters."] = "Sélectionnez la couleur à utiliser pour les debuffs lancés par d'autres personnages."
L["Select the color to use for the debuffs you cast."] = "Sélectionnez la couleur à utiliser pour les debuffs lancés par votre personnage."
L["Select the font to be used to display both countdown and application count."] = "Sélectionnez la police utilisées pour afficher à la fois le compte à rebours et le nombre d'applications."
L["Select the spell to edit. The color of the name is based on the setting type for the spell (see Type option below)."] = "Sélectionnez le sort à éditer. La couleur du nom est basée sur le type de réglage pour le sort (voir les options plus bas)." -- Needs review
L["Select the type of (de)buff of this spell. This is used to select the unit to watch for this spell."] = "Sélectionnez le type de (dé)buff de ce sort. Ceci est utilisé pour sélectionner l'unité à regarder."
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = "Sélectionnez où afficher le compte à rebours et le nombre de charges dans le bouton. Lorsqu'une seule valeur est affichée, le réglage \"position d'une valeur seule\" est utilisé."
L["Select where to place a single value."] = "Sélectionnez la position d'une valeur seule."
L["Select where to place the application count text when both values are shown."] = "Sélectionnezla position du nombre de charges quand les deux valeurs sont visibles."
L["Select where to place the countdown text when both values are shown."] = "Sélectionnez la position du compte à rebours quand les deux valeurs sont visibles."
L["Select which special value should be displayed."] = "Sélectionnez la valeur spéciale à afficher."
L["Self"] = "Soi-même"
L["Should the countdown provided by this module be displayed ?"] = "Est-ce que le compte à rebours de ce module sera affiché ?" -- Needs review
L["Should the module be used ?"] = "Est-ce que le module doit-être utilisé ?" -- Needs review
L["Should the stack count provided by this module be displayed ?"] = "Le compte à rebours de ce module doit-il être affiché ?" -- Needs review
L["Should this module highlight the button ?"] = "Ce module doit-il mettre le bouton en surbrillance ?" -- Needs review
L["Show countdown"] = "Afficher le compte à rebours." -- Needs review
L["Show stack count"] = "Afficher le nombre d'applications." -- Needs review
L["Single value position"] = "Position d'une valeur seule"
L["Size of large text"] = "Taille du grand texte"
L["Size of small text"] = "Taille du petit texte"
L["SOUL_SHARDS"] = "Fragments d'âme"
L["Sources of spells to show in the \"Current spell\" dropdown. Use this to reduce that list of spells."] = "Source de sorts à afficher dans le menu \"sort courant\". Utiliser ceci pour réduire cette liste." -- Needs review
L["Special"] = "Spécial"
L["Spells"] = "Sorts"
L["Targeting settings"] = "Réglages de ciblage"
L["Text appearance"] = "Apparence du texte"
L["Text Position"] = "Position des textes"
L["The kind of settings to use for the spell."] = "Le type de réglage à utiliser pour ce sort." -- Needs review
L["The large font is used to display countdowns."] = "La grande police est utilisée pour afficher les comptes à rebours."
L["The small font is used to display application count."] = "La petite police est utilisée pour afficher le nombre d'application"
L["Thick outline"] = "Bordure épaisse"
L["This is the threshold under which tenths of second are displayed."] = "Ceci est le seuil en-dessous duquel les dixièmes de seconde sont affichés." -- Needs review
L["This module only cause highlighting if the stack count is equal or above this threshold."] = "Ce module met en surbrillance uniquement si le nombre d'applications est égal ou supérieur à ce seuil." -- Needs review
L["This module provides the following keyword(s) for use as an alias: %s."] = "Ce module fournit le(s) mot(s)-clef(s) suivant(s) à utiliser comme alias : %s." -- Needs review
L["Top"] = "Haut"
L["Top left"] = "En haut à gauche"
L["Top right"] = "En haut à droite"
L["Totem timers"] = "Chronomètres de totem" -- Needs review
L["Type of settings"] = "Type de réglages"
L["Unusable"] = "Inutilisable" -- Needs review
L["Use global setting"] = "Utiliser le réglage global"
L["User-defined"] = "Défini par l'utilisateur"
L["use the predefined settings shipped with Inline Aura."] = "utilise les réglages prédéfinies founirs par Inline Aura." -- Needs review
L["use your own settings."] = "utilise vos propres réglages." -- Needs review
L["Value to display"] = "Valeur à afficher"
L["Watch focus"] = "Surveiller la focalisation"
L["watch hostile units for harmful spells and friendly units for helpful spells."] = "considère les ennemis pour les sorts offensifs et les alliés pour les sorts bénéfiques." -- Needs review
L["watch pet (de)buffs in any case."] = "surveille les (de)buffs du familier dans tous les cas." -- Needs review
L["Watch unit under mouse cursor"] = "Surveiller l'unité sous la souris"
L["watch your (de)buffs in any case."] = "surveille vos (de)buffs dans tous les cas." -- Needs review

------------------------ deDE ------------------------
elseif locale == 'deDE' then
L["ABOVExx"] = "Über %d%% %s"
L["Additional (de)buffs"] = "Zusätzliche (De)buffs"
L["Adjust the font size of countdown and application count texts."] = "Größe der Schriftart des Countdowns und der Stapelzähler anpassen."
L["Allow you to disable glowing highlight in certain situations."] = "Erlaubt die leuchtende Hervorhebung in gewissen Situationen zu deaktivieren."
L["all settings that differ from default ones."] = "Alle Einstellungen die von den Standardeinstellungen abweichen."
L["all the predefined settings, be them in use or not."] = "Alle Voreinstellungen, ob genutzt oder nicht."
L["Application count position"] = "Zählerposition"
L["Application text color"] = "Textfarbe der Anwendung"
L[ [=[Behave as if the interface option "Auto self cast" was enabled, e.g. test helpful spells on yourself when you are not targeting a friendly unit.
Note: this enables the old Inline Aura behavior with friendly spells.]=] ] = [=[Verhält sich, als ob die Interfaceoption "Autom. Selbstzauber" aktiviert ist. Es testet Zauber am Spieler, wenn sich keine befreundete Einheit im Ziel befindet.
Notiz: Es aktiviert das alte Verhalten von Inline Aura bei freundlichen Zaubern.]=]
L["BELOWxx"] = "Unter %d%% %s"
L["Border highlight colors"] = "Randfarbe"
L["Bottom"] = "Unten"
L["Bottom left"] = "Unten Links"
L["Bottom right"] = "Unten Rechts"
L["Center"] = "Mitte"
L["Colored border"] = "Eingefärbter Rand"
L["COMBO_POINTS"] = "Kombopunkte"
L["Countdown position"] = "Position des Cooldowns"
L["Countdown text color"] = "Countdown-Textfarbe"
L["Current module"] = "Aktuelles Modul"
L["Current spell"] = "Aktueller Zauber"
L["(De)buff type"] = "(De)bufftyp"
L["Decimal countdown threshold"] = "Nachkommastellen des Countdowns"
L["%dh"] = "%dh"
L["Dim"] = "Verdunkeln"
L["Dim the button when the (de)buff is NOT found (reversed logic)."] = "Verdunkelt den Button, wenn der (De)buff NICHT gefunden wurde (umgekehrte Logik)."
L["Dispel"] = "Entzaubern"
L["DISPELLABLE"] = "(De)buff, der bannbar ist"
L["Display a colored border. Its color depends on the kind and owner of the (de)buff."] = "Zeige einen eingefärbten Rand. Die Farbe basiert auf der Art und dem Besitzer des (De)buffs."
L["display special values that are not (de)buffs."] = "Zeige spezielle Werte, die keine (De)buffs sind."
L["Display the Blizzard shiny, animated border."] = "Zeige den animierten und leuchtenden Aktionsbuttonrand von Blizzard an."
L["%dm"] = "%dm"
L["Do not display (de)buff application count in the action buttons."] = "Zeige keinen Stapelzähler für den (De)buff in den Aktionsbuttons an."
L["Do not display the remaining time countdown in the action buttons."] = "Zeige nicht die restliche Zeit des Countdowns im Aktionsbutton an."
L["Do not highlight the button."] = "Den Button nicht hervorheben."
L["Dynamic countdown"] = "Dynamischer Countdown"
L["Eclipse energy"] = "Eclipse Energie"
L["Effect"] = "Effekt"
L["Either OmniCC or CooldownCount is loaded so aura countdowns are displayed using small font only."] = "Wenn OmniCC oder CooldownCount geladen sind, werden die Countdowns von Auren nur in einer kleineren Schrift angezeigt."
L["Emulate auto self cast"] = "Autom. Selbstzauber emulieren"
L["Enabled"] = "Aktiviert"
L[ [=[Enter additional names to test. This allows to detect alternative or equivalent (de)buffs. Some spells also apply (de)buffs that do not have the same name.
Note: both buffs and debuffs are tested whether the base spell is harmlful or helpful.]=] ] = [=[Weitere Namen zum Überprüfen eintragen. Dies erlaubt alternative oder gleichwertige (De)buffs zu erkennen. Einige Zauber haben auch (De)buffs mit anderen Namen.
Notiz: Für beide Buffs und Debuffs wird getestet, ob der Grundzauber schädlich oder hilfreich ist.]=]
L["Enter one name per line. They are spell-checked ; errors will prevents you to validate."] = "Einen Name pro Zeile eingeben. Zauber werden überprüft; Fehler werden zur Korrektur angezeigt."
L["Font effect"] = "Schrifteffekt"
L["Font name"] = "Schriftartname"
L["Font size"] = "Schriftgröße"
L["Glowing animation"] = "Leuchtende Animation"
L["Glowing highlight"] = "Leuchtende Hervorhebung"
L["Health threshold"] = "Gesundheitsschwelle"
L["Hide the application count text for this spell."] = "Verstecke den Stapelzähler für diesen Zauber."
L["Hide the countdown text for this spell."] = "Verstecke den Countdowntext für diesen Zauber."
L["Highlight"] = "Hervorheben"
L["Highlight threshold"] = "Schwelle hervorheben"
L["Ignore buffs cast by other characters."] = "Ignoriere Buffs, die von anderen Charakteren gezaubert wurden."
L["Ignored"] = "Ignoriert"
L["Ignore debuffs cast by other characters."] = "Ignoriere Debuffs, die von anderen Charakteren gezaubert wurden."
L["Inline Aura"] = "Inline Aura"
L["Inline Aura can highlight the action button when the (de)buff is found."] = "Inline Aura kann den Button hervorheben, wenn der (De)buff gefunden wurde."
L["Interrupt"] = "Unterbrechen"
L["INTERRUPTIBLE"] = "Unterbrechbarer Zauber"
L[ [=[Invalid spell names:
%s.]=] ] = [=[Ungültige Zaubernamen:
%s]=]
L["Invert"] = "Umkehren"
L["Invert the highlight condition, highlightning when the (de)buff is not found."] = "Kehre die Hervorhebungsbedingungen um. Hervorheben, wenn der (De)buff nicht gefunden wurde."
L["Left"] = "Links"
L["Lists spells from ..."] = "Liste Zauber aus ..."
L["Lookup"] = "Nachschlagen"
L["Make the countdown color, and size if possible, depends on remaining time."] = "Falls möglich, sollen die Countdown-Farbe und -Größe abhängig von der verbleibenden Zeit dargestellt werden."
L["Modified settings"] = "Modifizierte Eigenschaften"
L["Modules"] = "Module"
L["Module settings"] = "Moduleigenschaften"
L["My buffs"] = "Meine Buffs"
L["My debuffs"] = "Meine Debuffs"
L["No application count"] = "Keine Zähler"
L["No countdown"] = "Kein Countdown"
L["no specific settings for this spell ; use global ones."] = "Keine spezifischen Einstellungen für den Zauber - Standardeinstellungen benutzen."
L["On cooldown"] = "Auf Abklingzeit"
L["Only display the (de)buff if it has been applied by yourself, your pet or your vehicle."] = "Zeige nur (De)buffs an, die durch dich, deinen Begleiter oder dein Fahrzeug verursacht wurden."
L["Only my buffs"] = "Nur meine Buffs"
L["Only my debuffs"] = "Nur meine Debuffs"
L["Only show mine"] = "Nur meine zeigen"
L["Options related to the units to watch and the way to select them depending on the spells."] = "Einstellungen abhängig von beobachteter Einheit und wie diese basierend auf Zaubern ausgewählt wird."
L["Others' buffs"] = "Buffs anderer"
L["Others' debuffs"] = "Debuffs anderer"
L["Outline"] = "Schrifthintergrund"
L["Out of combat"] = "Außerhalb des Kampfes"
L["Power threshold"] = "Energieschwelle"
L["Precise countdown"] = "Präziser Countdown"
L["Preset"] = "Voreinstellung"
L["Presets"] = "Voreinstellungen"
L["Profiles"] = "Profile"
L["Regular"] = "Regulär"
L["Reset"] = "Zurücksetzen"
L["Right"] = "Rechts"
L["Select an effect to enhance the readability of the texts."] = "Effekt zur besseren Lesbarkeit von Texten auswählen."
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "Farbe zur Hervorhebung des Aktionsbuttons auswählen. Die Auswahl basiert auf Zauberer und Aurentyp."
L["Select the color to use for the buffs cast by other characters."] = "Farbe für die gewirkten Buffs anderer Charaktere auswählen."
L["Select the color to use for the buffs you cast."] = "Farbe für die eigenen gewirkten Buffs auswählen."
L["Select the color to use for the debuffs cast by other characters."] = "Farbe für die gewirkten Debuffs anderer Charaktere auswählen."
L["Select the color to use for the debuffs you cast."] = "Farbe für die selbst gewirkten Debuffs auswählen."
L["Select the font to be used to display both countdown and application count."] = "Schriftart für die Darstellung von Countdown und Zähler auswählen."
L["Select the spell to edit. The color of the name is based on the setting type for the spell (see Type option below)."] = "Zauber zur Bearbeitung auswählen. Die Farbe des Namens basiert auf den Einstellungen für den Zauber (siehe Typoptionen unterhalb)."
L["Select the type of (de)buff of this spell. This is used to select the unit to watch for this spell."] = "(De)bufftyp von diesem Zauber auswählen. Dies wird zur Wahl der beobachteten Einheit für den Zauber genutzt."
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = "Anzeigeposition von Countdown und Zähler auf dem Button auswählen. Wenn nur ein Wert angezeigt wird, wird die Primärposition benutzt. "
L["Select where to place a single value."] = "Platzierung eines einzelnen Wertes auswählen."
L["Select where to place the application count text when both values are shown."] = "Position des Zählers, wenn beide Werte angezeigt werden, auswählen."
L["Select where to place the countdown text when both values are shown."] = "Position des Cooldowns, wenn beide Werte angezeigt werden, auswählen."
L["Select which special value should be displayed."] = "Wähle welcher spezielle Wert angezeigt werden soll."
L["Self"] = "Selbst"
L["Should the countdown provided by this module be displayed ?"] = "Soll der Countdown, der von diesem Modul bereitgestellt wird, angezeigt werden?"
L["Should the module be used ?"] = "Soll das Modul benutzt werden?"
L["Should the stack count provided by this module be displayed ?"] = "Soll der Stapelzähler, der von diesem Modul bereitgestellt wird, angezeigt werden?"
L["Should this module highlight the button ?"] = "Soll das Modul den Button hervorheben?"
L["Show countdown"] = "Countdown anzeigen"
L["Show stack count"] = "Stapelzähler anzeigen"
L["Single value position"] = "Position einzelner Werte "
L["Size of large text"] = "Große Textgröße"
L["Size of small text"] = "Kleine Textgröße"
L["SOUL_SHARDS"] = "Seelensplitter"
L["Sources of spells to show in the \"Current spell\" dropdown. Use this to reduce that list of spells."] = "Herkunft der Zauber zur Anzeige im Aufklappmenü \"Aktueller Zauber\". Nutze dies zur Verkleinerung der Liste der Zauber."
L["Special"] = "Speziell"
L["Spells"] = "Zauber"
L["spells and items visible on the action bars."] = "Zauber und Gegenstände, die in der Aktionsleiste sichtbar sind."
L["spells from matching spellbooks."] = "Zauber vom entsprechenden Zauberbuch."
L["Targeting settings"] = "Angriffsziel Optionen"
L["Text appearance"] = "Textdarstellung"
L["Text Position"] = "Textposition"
L["The kind of settings to use for the spell."] = "Die Art der Einstellungen, die für diesen Zauber genutzt werden."
L["The large font is used to display countdowns."] = "Die große Schrift wird zur Anzeige von Countdowns verwendet."
L["The small font is used to display application count."] = "Die kleine Schriftart wird zur Anzeige des Stapelzählers genutzt."
L["Thick outline"] = "Umrandungsdicke"
L["This is the threshold under which tenths of second are displayed."] = "Dies ist die Schwelle unter der Zehntelsekunden angezeigt werden."
L["This module only cause highlighting if the stack count is equal or above this threshold."] = "Dieses Modul hebt nur hervor, wenn der Stapelzähler größer oder gleich der Schwelle ist."
L["This module provides the following keyword(s) for use as an alias: %s."] = "Dieses Modul stellt folgende Schlüsselwörter als Alias zur Verfügung: %s."
L["Top"] = "Oben"
L["Top left"] = "Oben Links"
L["Top right"] = "Oben Rechts"
L["totally ignore the spell ; do not show any countdown or highlight."] = "Ignoriere den Zauber vollständig - Zeige weder Countdown noch Hervorhebung."
L["Totem timers"] = "Totem Timers"
L["Type of settings"] = "Art der Einstellungen"
L["Uncheck this to disable highlight for actions in cooldown."] = "Hervorhebung von Aktionen, die noch Abklingzeit haben."
L["Uncheck this to disable highlight for unusable actions."] = "Hervorhebung von nicht nutzbaren Aktionen."
L["Uncheck this to disable highlight out of combat."] = "Hervorhebung von Aktionen außerhalb des Kampfes."
L["Unusable"] = "Nicht nutzbar"
L["Use a more accurate rounding, down to tenths of second, instead of the default Blizzard rounding."] = "Nutze eine präzisere Rundung, bis auf Zehntelsekunden genau, anstatt die Standardrundung von Blizzard."
L["Use global setting"] = "Globale Einstellungen nutzen"
L["User-defined"] = "Benutzerdefiniert"
L["use the predefined settings shipped with Inline Aura."] = "Die Voreinstellungen von Inline Aura nutzen."
L["use your own settings."] = "Eigene Einstellungen nutzen."
L["Value to display"] = "Anzuzeigender Wert"
L["Watch (de)buff changes on the unit under the mouse cursor. Required only to properly update macros that uses @mouseover targeting."] = "Beobachte (De)buffänderungen an den über Maus anvisierten Einheiten. Wird nur für Makros, die über @mouseover anvisieren, benötigt."
L["Watch (de)buff changes on your focus. Required only to properly update macros that uses @focus targeting."] = "Beobachte  (De)buffänderungen auf deinem Fokusziel. Wird nur für Makros, die über @focus anvisieren, benötigt."
L["Watch focus"] = "Beobachte Fokus"
L["watch hostile units for harmful spells and friendly units for helpful spells."] = "Beobachte feindliche Einheiten auf schädliche Zauber und befreundete Einheiten auf hilfreiche Zauber."
L["watch pet (de)buffs in any case."] = "Beobachte (De)buffs vom Begleiter in jedem Fall."
L["Watch unit under mouse cursor"] = "Beobachte Einheit unter dem Mauszeiger"
L["watch your (de)buffs in any case."] = "Beobachte eigene (De)buffs in jedem Fall."

------------------------ esMX ------------------------
-- no translation

------------------------ ruRU ------------------------
elseif locale == 'ruRU' then
L["Additional (de)buffs"] = "Дополнительные (де)баффы" -- Needs review
L["Application text color"] = "Цвет текста"
L["Border highlight colors"] = "Цвета подсветки границы" -- Needs review
L["Bottom"] = "Кнопка"
L["Bottom left"] = "Внизу слева" -- Needs review
L["Bottom right"] = "Внизу справа" -- Needs review
L["Center"] = "Центр"
L["Colored border"] = "Цветная кайма"
L["COMBO_POINTS"] = "Комбо-очки"
L["Countdown position"] = "Позиция перезагрузки"
L["Countdown text color"] = "Цвет текста перезагрузки"
L["Current module"] = "Текущий модуль" -- Needs review
L["Decimal countdown threshold"] = "Порог знаков после запятой у отсчета" -- Needs review
L["%dh"] = "%dч"
L["Dim"] = "Тусклый." -- Needs review
L["Dim the button when the (de)buff is NOT found (reversed logic)."] = "Затемнить кнопку, когда (де)бафф НЕ найден." -- Needs review
L["Dispel"] = "Рассеивание" -- Needs review
L["Display a colored border. Its color depends on the kind and owner of the (de)buff."] = "Отображать цветную границу. Её цвет зависит от типа и владельца (де)баффа." -- Needs review
L["Display the Blizzard shiny, animated border."] = "Отображать стандартные анимированные границы Близзард " -- Needs review
L["%dm"] = "%dм"
L["Do not display the remaining time countdown in the action buttons."] = "Не отображать текущее время перезарядки способности на кнопке " -- Needs review
L["Dynamic countdown"] = "Динамический отсчет" -- Needs review
L["Effect"] = "Эффект " -- Needs review
L["Font effect"] = "Эффекты шрифта"
L["Font name"] = "Название шрифта"
L["Font size"] = "Размер шрифта"
L["Glowing animation"] = "Анимация блеска"
L["Inline Aura"] = "Inline Aura"
L["Left"] = "Слева"
L["My buffs"] = "Мои баффы"
L["My debuffs"] = "Мои дебаффы"
L["No countdown"] = "КД отсутствует"
L["Only my buffs"] = "Только мои баффы"
L["Only my debuffs"] = "Только мои дебаффы"
L["Only show mine"] = "Отображать только моё"
L["Others' buffs"] = "Баффы других игроков"
L["Others' debuffs"] = "Дебаффы других игроков"
L["Outline"] = "Вне видимости"
L["Precise countdown"] = "Точный отсчет" -- Needs review
L["Profiles"] = "Профили"
L["Right"] = "Справа"
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "Выберите цвета, использующиеся для подсветки кнопок действия. Выбираются, базируясь на типе ауры и кастера." -- Needs review
L["Select the color to use for the buffs cast by other characters."] = "Выбрать цвет, используемый для баффов, накладываемых другими игроками."
L["Select the color to use for the buffs you cast."] = "Выбрать цвет, используемый для баффов, накладываемых вами."
L["Select the color to use for the debuffs cast by other characters."] = "Выбрать цвет, используемый для дебаффов, накладываемых другими игроками."
L["Select the color to use for the debuffs you cast."] = "Выбрать цвет, используемый для дебаффов, накладываемых вами."
L["Select where to place a single value."] = "Выберите где поставить одиночное значение." -- Needs review
L["Select where to place the countdown text when both values are shown."] = "Выберите где поставить текст отсчета когда видны оба значения." -- Needs review
L["Single value position"] = "Положение одиночного значения" -- Needs review
L["Size of large text"] = "Размер большого текста"
L["Size of small text"] = "Размер маленького текста"
L["SOUL_SHARDS"] = "Камни душ"
L["Special"] = "Специальные"
L["Targeting settings"] = "Настройки цели"
L["Text appearance"] = "Внешний вид текста"
L["Text Position"] = "Позиция текста"
L["The large font is used to display countdowns."] = "Большой шрифт используется для отображения отсчета." -- Needs review
L["Top"] = "Верх" -- Needs review
L["Top left"] = "Сверху-слева"
L["Top right"] = "Сверху-справа"
L["Value to display"] = "Показываемое значение" -- Needs review

------------------------ esES ------------------------
elseif locale == 'esES' then
L["Application count position"] = "Posicion del contador de aplicacion"
L["Application text color"] = "Color del texto de aplicacion"
L["Border highlight colors"] = "Color del resalte del borde"
L["Bottom"] = "Abajo"
L["Bottom left"] = "Abajo izquierda"
L["Bottom right"] = "Abajo derecha"
L["Center"] = "Centro"
L["Colored border"] = "Borde coloreado"
L["COMBO_POINTS"] = "Puntos de combo"
L["Countdown position"] = "Posicion de la cuenta atras"
L["Countdown text color"] = "Color del texto de la cuenta atras"
L["Decimal countdown threshold"] = "Umbral de la cuenta atras decimal"
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["Dynamic countdown"] = "Cuenta atras dinamica"
L["Font name"] = "Nombre de la fuente"
L["Glowing animation"] = "Brillo de animacion"
L["Inline Aura"] = "Inline Aura"
L["Left"] = "Izquierda"
L["Make the countdown color, and size if possible, depends on remaining time."] = "Hace que el color de la cuenta atras, y el tamaño si es posible, cambie dependiendo del tiempo restante"
L["My buffs"] = "Mis beneficios"
L["My debuffs"] = "Mis perjuicios"
L["No application count"] = "Desactivar contador de aplicacion"
L["No countdown"] = "Desactivar cuenta atras"
L["Only my buffs"] = "Solo mis beneficios"
L["Only my debuffs"] = "Solo mis perjuicios"
L["Only show mine"] = "Mostrar solo lo propio"
L["Others' buffs"] = "Otros beneficios"
L["Others' debuffs"] = "Otros perjuicios"
L["Precise countdown"] = "Cuenta atras precisa"
L["Profiles"] = "Perfiles"
L["Right"] = "Derecha"
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "Selecciona los colores a usar para resaltar el boton de acción. Estan basados en el tipo de hechizo"
L["Select the color to use for the buffs cast by other characters."] = "Selecciona el color a usar para beneficios casteados por otros personajes."
L["Select the color to use for the buffs you cast."] = "Selecciona el color a usar para perjuicios casteados por ti."
L["Select the color to use for the debuffs cast by other characters."] = "Selecciona el color a usar para beneficios casteados por otros personajes."
L["Select the color to use for the debuffs you cast."] = "Selecciona el color a usar para perjuicios casteados por ti."
L["Select the font to be used to display both countdown and application count."] = "Selecciona la fuente usada para mostrar la cuenta atras y la cuenta de aplicación"
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = "Selecciona donde mostrar la cuenta atras y la cuenta de aplicacion en el boton. Cuando solo se muestra un valor, se usa \"posicion valor unico\" en vez del normal"
L["Select where to place a single value."] = "Selecciona donde poner el valor unico"
L["Select where to place the application count text when both values are shown."] = "Selecciona donde poner el texto del contador de aplicacion cuando ambos valores se muestran"
L["Select where to place the countdown text when both values are shown."] = "Selecciona donde poner el texto de cuenta atras cuando ambas valores se muestran"
L["Select which special value should be displayed."] = "Selecciona que valor especial debe ser mostrado"
L["Single value position"] = "Posicion valor unico"
L["Size of large text"] = "Tamaño del texto grande"
L["Size of small text"] = "Tañaño del texto pequeño"
L["SOUL_SHARDS"] = "Fragmentos de alma"
L["Special"] = "Especial"
L["Text appearance"] = "Apariencia del texto"
L["Text Position"] = "Posicion del texto"
L["The large font is used to display countdowns."] = "Se esta usando fuente grande para mostrar la cuenta atras"
L["Top"] = "Arriba"
L["Top left"] = "Arriba izquierda"
L["Top right"] = "Arriba derecha"
L["Value to display"] = "Valor a mostrar"

------------------------ zhTW ------------------------
elseif locale == 'zhTW' then
L["Additional (de)buffs"] = "附(減)增益"
L["Adjust the font size of countdown and application count texts."] = "調整倒數計時和疊加數的文字字體。"
L["all settings that differ from default ones."] = "所有和默認不同的設定。"
L["all the predefined settings, be them in use or not."] = "所有預設的定義，它們是否在使用中。"
L["Application count position"] = "疊加計數位置"
L["Application text color"] = "疊加文字顏色"
L[ [=[Behave as if the interface option "Auto self cast" was enabled, e.g. test helpful spells on yourself when you are not targeting a friendly unit.
Note: this enables the old Inline Aura behavior with friendly spells.]=] ] = [=[當介面選項中啟用了"自動自我施法"選項將會表現出來。如：當你的目標不是友善時，對自己施放一個友善法術來測試。

註：當友善法術作用時，將使用舊的Inline Aura行為。]=]
L["Border highlight colors"] = "邊緣高亮顏色"
L["Bottom"] = "底部"
L["Bottom left"] = "左下"
L["Bottom right"] = "右下"
L["Center"] = "中央"
L["Colored border"] = "彩色邊框"
L["COMBO_POINTS"] = "連擊點數"
L["Countdown position"] = "冷卻位置"
L["Countdown text color"] = "冷卻文字顏色"
L["Current module"] = "目前模組"
L["Current spell"] = "目前法術"
L["(De)buff type"] = "(減)增益類型"
L["Decimal countdown threshold"] = "小數冷卻門檻"
L["%dh"] = "%d小時"
L["Dim"] = "暗淡"
L["Dim the button when the (de)buff is NOT found (reversed logic)."] = "(減)增益找不到(顛倒邏輯)時暗淡按鈕。"
L["Dispel"] = "驅散"
L["DISPELLABLE"] = "(減)增益你可以驅散"
L["Display a colored border. Its color depends on the kind and owner of the (de)buff."] = "顯示一個彩色邊框，它的顏色取決於種類和(de)buff的擁有者。"
L["display special values that are not (de)buffs."] = "顯示不是(de)buffs的特殊值。"
L["Display the Blizzard shiny, animated border."] = "顯示暴雪發光, 動畫邊框。"
L["%dm"] = "%d分"
L["Do not display (de)buff application count in the action buttons."] = "不要在動作按鈕中顯示(de)buff的疊加數。"
L["Do not display the remaining time countdown in the action buttons."] = "不要在動作按鈕中顯示剩於的冷卻倒數時間。"
L["Do not highlight the button."] = "不要高亮按鈕。"
L["Dynamic countdown"] = "動態冷卻時間"
L["Eclipse energy"] = "蝕星蔽月能量"
L["Effect"] = "效果"
L["Either OmniCC or CooldownCount is loaded so aura countdowns are displayed using small font only."] = "無論OmniCC或CooldownCount是否被載入，一律在光環的倒數計時使用小字體。"
L["Emulate auto self cast"] = "模擬自動自己施放"
L["Enabled"] = "已啟用"
L["Font effect"] = "字型效果"
L["Font name"] = "字型名稱"
L["Font size"] = "字型尺寸"
L["Glowing animation"] = "發光動畫"
L["Health threshold"] = "生命界限"
L["Hide the application count text for this spell."] = "隱藏應用計數文字此文字法術。"
L["Hide the countdown text for this spell."] = "隱藏冷卻時間文字此法術。"
L["Highlight"] = "高亮"
L["Highlight threshold"] = "高亮界限"
L["Ignore buffs cast by other characters."] = "忽略增益施放由其他角色。"
L["Ignored"] = "忽略"
L["Ignore debuffs cast by other characters."] = "忽略減益施放由其他角色。"
L["Inline Aura"] = "Inline Aura"
L["Inline Aura can highlight the action button when the (de)buff is found."] = "當發現一個(de)buff可以施放時，允許Inline Aura高亮此動作按鈕。"
L["Interrupt"] = "中斷"
L["INTERRUPTIBLE"] = "可中斷施法"
L[ [=[Invalid spell names:
%s.]=] ] = [=[無效的法術名稱:
%s。]=]
L["Invert"] = "顛倒"
L["Invert the highlight condition, highlightning when the (de)buff is not found."] = "顛倒高亮狀態，當沒有發現(de)buff時。"
L["Left"] = "左"
L["Lists spells from ..."] = "列表法術來自..."
L["Lookup"] = "查找"
L["Make the countdown color, and size if possible, depends on remaining time."] = "可能的話，取決於時間讓倒數計時上色並且更動大小。"
L["Modified settings"] = "修改設定"
L["Modules"] = "模組"
L["Module settings"] = "模組設定"
L["My buffs"] = "我的增益法術"
L["My debuffs"] = "我的減益法術"
L["No application count"] = "無疊加計數"
L["No countdown"] = "無冷卻"
L["no specific settings for this spell ; use global ones."] = "沒有具體設定此法術 ; 使用通用任何人。"
L["Only display the (de)buff if it has been applied by yourself, your pet or your vehicle."] = "僅顯示由你自己或寵物或載具所施放的(de)buff。"
L["Only my buffs"] = "僅我的增益法術"
L["Only my debuffs"] = "僅我的減益法術"
L["Only show mine"] = "僅顯示我的"
L["Others' buffs"] = "別人的增益法術"
L["Others' debuffs"] = "別人的減益法術"
L["Outline"] = "輪廓"
L["Power threshold"] = "能量門檻。" -- Needs review
L["Precise countdown"] = "精確冷卻"
L["Preset"] = "事先調整"
L["Presets"] = "事先調整"
L["Profiles"] = "設定檔"
L["Regular"] = "規則"
L["Reset"] = "重設"
L["Right"] = "右"
L["Select an effect to enhance the readability of the texts."] = "選擇一個效果來提高文字的可讀性。"
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "選擇顏色用於強調動作按鈕。這是選擇是基於光環類型和施法者。"
L["Select the color to use for the buffs cast by other characters."] = "選擇其他玩家施放的增益法術顏色"
L["Select the color to use for the buffs you cast."] = "選擇你施放的增益法術顏色"
L["Select the color to use for the debuffs cast by other characters."] = "選擇其他玩家施放的減益法術顏色"
L["Select the color to use for the debuffs you cast."] = "選擇你施放的減益法術顏色"
L["Select the font to be used to display both countdown and application count."] = "選擇用來顯示冷卻&疊加計數的字型"
L["Select the spell to edit. The color of the name is based on the setting type for the spell (see Type option below)."] = "選擇要編輯的法術。名稱的顏色是根據你所設定的法術類型（類型選項在下方）。"
L["Select the type of (de)buff of this spell. This is used to select the unit to watch for this spell."] = "選擇這個法術的(de)buff類型。這是用來選擇監視此法術的單位。"
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = "選擇在按鈕的哪裡顯示倒數計時和疊加數，當只有一個數值在顯示時，\"單一數值位置\"將會用來取代原本預設的位置。"
L["Select where to place a single value."] = "選擇在按鈕的哪裡放置單一數值。"
L["Select where to place the application count text when both values are shown."] = "在兩個值都顯示時，選擇在按鈕的哪裡放置疊加數。"
L["Select where to place the countdown text when both values are shown."] = "在兩個值都顯示時，選擇在按鈕的哪裡放置倒數文字。"
L["Select which special value should be displayed."] = "選擇要顯示哪一個特定的數值。"
L["Self"] = "自己"
L["Should the countdown provided by this module be displayed ?"] = "是否要使用此模組提供的冷卻倒數計時？"
L["Should the module be used ?"] = "應該模組使用?"
L["Should the stack count provided by this module be displayed ?"] = "是否要使用此模組提供的狀態疊加功能？"
L["Should this module highlight the button ?"] = "應該模組高亮按鈕?"
L["Show countdown"] = "顯示冷卻時間"
L["Show stack count"] = "顯示堆疊計數"
L["Single value position"] = "單個值數位置"
L["Size of large text"] = "大文字尺寸"
L["Size of small text"] = "小文字尺寸"
L["SOUL_SHARDS"] = "靈魂碎片"
L["Sources of spells to show in the \"Current spell\" dropdown. Use this to reduce that list of spells."] = "\"現有法術\"的下拉選單中顯示各來源法術，用它來減少該法術清單。"
L["Special"] = "特別"
L["Spells"] = "法術"
L["spells and items visible on the action bars."] = "法術和物品可見的動作條。"
L["spells from matching spellbooks."] = "法術來自相同的法術書。"
L["Targeting settings"] = "目標設定"
L["Text appearance"] = "文字外觀"
L["Text Position"] = "文字位置"
L["The kind of settings to use for the spell."] = "使用於該法術的設定種類。"
L["The large font is used to display countdowns."] = "大字型用於顯示冷卻時間。"
L["The small font is used to display application count."] = "用於顯示疊加數的小字體。"
L["Thick outline"] = "粗線"
L["This module only cause highlighting if the stack count is equal or above this threshold."] = "此模組只有在堆疊數高於或等於這個門檻時會引發高亮。"
L["This module provides the following keyword(s) for use as an alias: %s."] = "這麼模組提供了下面這個關鍵自來當做別名 : %s"
L["Top"] = "頂部"
L["Top left"] = "左上"
L["Top right"] = "右下"
L["totally ignore the spell ; do not show any countdown or highlight."] = "完全忽視法術，不顯示任何倒數或明亮顯示。"
L["Totem timers"] = "圖騰計時器"
L["Type of settings"] = "設定類型"
L["Use a more accurate rounding, down to tenths of second, instead of the default Blizzard rounding."] = "使用更精確的四捨五入，下降到十分之一秒，用來取代Blizzard內建的四捨五入。" -- Needs review
L["Use global setting"] = "使用通用設定"
L["User-defined"] = "用戶定義"
L["use the predefined settings shipped with Inline Aura."] = "在Inline Aura內使用預設的定義。"
L["use your own settings."] = "使用你自己設定。"
L["Value to display"] = "數值至顯示"
L["Watch (de)buff changes on the unit under the mouse cursor. Required only to properly update macros that uses @mouseover targeting."] = "將目標的Buff和Debuff變化顯示於滑鼠游標下方。此功能需使用正確的更新Macro(@mouseover)。"
L["Watch (de)buff changes on your focus. Required only to properly update macros that uses @focus targeting."] = "監控專注目標的Buff和Debuff變化。此功能需使用正確的更新Macro(@focus)。"
L["Watch focus"] = [=[觀看焦點
]=]
L["watch hostile units for harmful spells and friendly units for helpful spells."] = "觀看敵對單位的傷害性法術和友方單位的幫助性法術。"
L["watch pet (de)buffs in any case."] = "監視寵物的(減)增益在任何情況下。"
L["Watch unit under mouse cursor"] = "監視單位在滑鼠游標下"
L["watch your (de)buffs in any case."] = "監視你的(減)增益在任何情況下。"

------------------------ zhCN ------------------------
elseif locale == 'zhCN' then
L["Application text color"] = "叠加文本颜色"
L["Border highlight colors"] = "边框高亮颜色"
L["Bottom"] = "底部"
L["Countdown text color"] = "倒计时文本颜色"
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["Font name"] = "字体"
L["Inline Aura"] = "Inline Aura"
L["My buffs"] = "我的增益法术"
L["My debuffs"] = "我的减益法术"
L["No application count"] = "无叠加计数"
L["No countdown"] = "无倒计时"
L["Only my buffs"] = "仅我的增益法术"
L["Only my debuffs"] = "仅我的减益法术"
L["Only show mine"] = "只显示自己的"
L["Others' buffs"] = "别人的增益法术"
L["Others' debuffs"] = "别人的减益法术"
L["Precise countdown"] = "精确倒计时"
L["Profiles"] = "配置文件"
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "选择用来高亮动作条按钮的颜色.这些选择以光环类型和施法者为基础."
L["Select the color to use for the buffs cast by other characters."] = "选择其他玩家施放的增益法术颜色"
L["Select the color to use for the buffs you cast."] = "选择你施放的增益法术颜色"
L["Select the color to use for the debuffs cast by other characters."] = "选择其他玩家施放的减益法术颜色"
L["Select the color to use for the debuffs you cast."] = "选择你施放的减益法术颜色"
L["Select the font to be used to display both countdown and application count."] = "选择用来显示倒计时和叠加计数的字体"
L["Size of large text"] = "大文本尺寸"
L["Size of small text"] = "小文本尺寸"
L["Text appearance"] = "文本外观"
L["The large font is used to display countdowns."] = "大字体用来显示倒计时"
L["Top"] = "顶部"

------------------------ koKR ------------------------
elseif locale == 'koKR' then
L["Additional (de)buffs"] = "추가 강(약)화 효과"
L["Adjust the font size of countdown and application count texts."] = "카운트다운과 효과 카운트 글자의 글꼴 크기 조정." -- Needs review
L["Application count position"] = "효과 카운트 위치"
L["Application text color"] = "효과 글자색"
L["Border highlight colors"] = "테두리 강조색"
L["Bottom"] = "아래쪽"
L["Bottom left"] = "왼쪽 아래"
L["Bottom right"] = "오른쪽 아래"
L["Center"] = "가운데"
L["Colored border"] = "색칠된 테두리"
L["COMBO_POINTS"] = "연계 점수"
L["Countdown position"] = "카운트다운 위치"
L["Countdown text color"] = "카운트다운 글자색"
L["Current module"] = "현재 모듈"
L["Current spell"] = "현재 주문"
L["(De)buff type"] = "강(약)화 효과 형태"
L["Decimal countdown threshold"] = "십진 카운트 한계" -- Needs review
L["%dh"] = "%dh"
L["Dim the button when the (de)buff is NOT found (reversed logic)."] = "강(약)화 효과가 발견되지 않았을 때 버튼을 흐리게 함 (반대 논리)."
L["Dispel"] = "해제"
L["DISPELLABLE"] = "해제 가능한 강(약)화 효과"
L["Display a colored border. Its color depends on the kind and owner of the (de)buff."] = "색칠된 테두리를 표시합니다. 색은 강(약)화 효과의 소유자와 종류에 따라 다릅니다." -- Needs review
L["display special values that are not (de)buffs."] = "강(약)화 효과가 아닌 특수값을 표시." -- Needs review
L["Display the Blizzard shiny, animated border."] = "블리자드 반짝임과 움직이는 테두리를 표시합니다."
L["%dm"] = "%dm"
L["Do not display (de)buff application count in the action buttons."] = "행동 단축 버튼에 강(약)화 효과 카운트를 표시하지 않음."
L["Do not display the remaining time countdown in the action buttons."] = "행동 단축 버튼에 남은 시간 카운트다운을 표시하지 않음."
L["Do not highlight the button."] = "버튼 강조하지 않음."
L["Effect"] = "효과"
L["Font effect"] = "글꼴 효과"
L["Font name"] = "글꼴 이름"
L["Font size"] = "글꼴 크기"
L["Glowing animation"] = "버튼 움직임"
L["Hide the application count text for this spell."] = "이 주문은 효과 카운트 글자 숨김."
L["Hide the countdown text for this spell."] = "이 주문은 카운트다운 글자 숨김."
L["Highlight"] = "강조"
L["Highlight threshold"] = "한계 강조"
L["Ignore buffs cast by other characters."] = "다른 플레이어의 강화 효과 시전을 무시합니다."
L["Ignored"] = "무시"
L["Ignore debuffs cast by other characters."] = "다른 플레이어의 약화 효과 시전을 무시합니다."
L["Inline Aura"] = "Inline Aura"
L["Inline Aura can highlight the action button when the (de)buff is found."] = "Inline Aura가 강(약)화 효과가 발견되었을 때 행동 단축 버튼을 강조할 수 있습니다."
L["Interrupt"] = "방해"
L["INTERRUPTIBLE"] = "방해 가능한 주문 시전"
L[ [=[Invalid spell names:
%s.]=] ] = [=[잘못된 주문 이름:
%s]=]
L["Invert"] = "반전"
L["Invert the highlight condition, highlightning when the (de)buff is not found."] = "강조 조건을 거꾸로 강(약)화 효과가 발견되지 않을 때로 바꿈."
L["Left"] = "왼쪽"
L["Make the countdown color, and size if possible, depends on remaining time."] = "카운트다운 색 및 크기는 가능하다면, 남은 시간에 따라 달라짐." -- Needs review
L["Modules"] = "모듈"
L["Module settings"] = "모듈 설정"
L["My buffs"] = "내 강화 효과"
L["My debuffs"] = "내 약화 효과"
L["No application count"] = "효과 카운트 안 함"
L["No countdown"] = "카운트다운 안 함"
L["Only display the (de)buff if it has been applied by yourself, your pet or your vehicle."] = "오직 자신과 소환수, 탈것에 적용된 강(약)화 효과만 표시." -- Needs review
L["Only my buffs"] = "내 강화 효과만"
L["Only my debuffs"] = "내 약화 효과만"
L["Only show mine"] = "내 것만 표시"
L["Others' buffs"] = "다른 플레이어의 강화 효과"
L["Others' debuffs"] = "다른 플레이어의 약화 효과"
L["Outline"] = "외곽선"
L["Precise countdown"] = "정밀한 카운트다운"
L["Preset"] = "프리셋"
L["Presets"] = "프리셋"
L["Profiles"] = "프로필"
L["Regular"] = "일반"
L["Reset"] = "초기화"
L["Right"] = "오른쪽"
L["Select an effect to enhance the readability of the texts."] = "글자 가독성을 높이는 효과 선택." -- Needs review
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "행동 단축 버튼 강조에 쓰일 색을 고릅니다. 오라 형태와 시전자에 따라 선택됩니다." -- Needs review
L["Select the color to use for the buffs cast by other characters."] = "다른 캐릭터가 시전한 강화 효과에 사용할 색을 선택합니다."
L["Select the color to use for the buffs you cast."] = "당신이 시전한 강화 효과에 사용할 색을 선택합니다."
L["Select the color to use for the debuffs cast by other characters."] = "다른 캐릭터가 시전한 약화 효과에 사용할 색을 선택합니다."
L["Select the color to use for the debuffs you cast."] = "당신이 시전한 약화 효과에 사용할 색을 선택합니다."
L["Select the font to be used to display both countdown and application count."] = "카운트다운과 효과 카운트 표시에 쓰일 글꼴을 선택합니다."
L["Select the spell to edit. The color of the name is based on the setting type for the spell (see Type option below)."] = "편집할 주문을 고릅니다. 이름의 색은 주문을 위한 설정 형태를 따릅니다(아래 형태 옵션 참조)." -- Needs review
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = "행동 단축 버튼에 카운트다운 및 효과 카운트를 표시할 곳을 고릅니다. 한 값만 표시되는 경우는, 단일 값 위치'가 일반 위치 대신 쓰입니다." -- Needs review
L["Select where to place a single value."] = "값이 하나만 보일 때 글자가 놓일 곳 선택"
L["Select where to place the application count text when both values are shown."] = "두 값이 보일 때 효과 카운트 글자가 놓일 곳 선택."
L["Select where to place the countdown text when both values are shown."] = "두 값이 보일 때 효과 카운트다운 글자가 놓일 곳 선택."
L["Select which special value should be displayed."] = "버튼을 강조할 수 있는 효과를 선택합니다."
L["Self"] = "자신"
L["Show countdown"] = "카운트다운 보기"
L["Show stack count"] = "중첩 카운트 보임"
L["Single value position"] = "값이 하나일 때 위치"
L["Size of large text"] = "큰 글자 크기"
L["Size of small text"] = "작은 글자 크기"
L["SOUL_SHARDS"] = "영혼의 조각"
L["Sources of spells to show in the \"Current spell\" dropdown. Use this to reduce that list of spells."] = "\"현재 주문\" 드롭다운에 표시할 주문의 소스. 주문 목록을 줄이는 데 이 소스를 사용." -- Needs review
L["Special"] = "특별함"
L["Spells"] = "주문"
L["Targeting settings"] = "대상지정 설정"
L["Text appearance"] = "글자 겉모양"
L["Text Position"] = "글자 위치"
L["The kind of settings to use for the spell."] = "주문에 쓰일 설정의 종류." -- Needs review
L["The large font is used to display countdowns."] = "카운트다운 표시에 쓰이는 큰 글꼴."
L["The small font is used to display application count."] = "작은 글꼴이 효과 카운트 표시에 쓰입니다."
L["Thick outline"] = "굵은 외곽선"
L["Top"] = "위쪽"
L["Top left"] = "왼쪽 위"
L["Top right"] = "오른쪽 위"
L["Totem timers"] = "토템 타이머"
L["Type of settings"] = "설정의 형태"
L["Use global setting"] = "전역 설정 사용" -- Needs review
L["User-defined"] = "사용자 정의" -- Needs review
L["use the predefined settings shipped with Inline Aura."] = "Inline Aura에 실린 미리 정의된 설정을 사용." -- Needs review
L["Value to display"] = "값을 표시" -- Needs review

------------------------ ptBR ------------------------
-- no translation
end

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end
