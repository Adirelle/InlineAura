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

local _, addon = ...

local locale = GetLocale()
local L = setmetatable({}, {__index = function(self, key)
	local value = tostring(key)
	if key ~= nil then self[key] = value end
	--@debug@
	addon.dprint("Missing locale:", value)
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
-- THE END OF THE FILE IS UPDATED BY A SCRIPT
-- ANY CHANGE BELOW THESES LINES WILL BE LOST
-- CHANGES SHOULD BE MADE USING http://www.wowace.com/addons/inline-aura/localization/

-- @noloc[[

------------------------ enUS ------------------------


-- Config.lua
L["(De)buff type"] = true
L["Additional (de)buffs"] = true
L["Adjust the font size of countdown and application count texts."] = true
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
L["Only display the (de)buff if it has been applied by yourself, your pet or your vehicle."] = true
L["Only my buffs"] = true
L["Only my debuffs"] = true
L["Only show mine"] = true
L["Options related to the units to watch and the way to select them depending on the spells."] = true
L["Others' buffs"] = true
L["Others' debuffs"] = true
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
L["Totem timers"] = true


------------------------ frFR ------------------------
local locale = GetLocale()
if locale == 'frFR' then
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["(De)buff type"] = "Type de (dé)buff"
L["ABOVE20"] = "Au dessus de 20% de vie"
L["ABOVE25"] = "Au-dessus de 25% de vie"
L["ABOVE35"] = "Au-dessus de 35% de vie"
L["ABOVE80"] = "Au-dessus de 80% de vie"
L["Additional (de)buffs"] = "(Dé)buffs supplémentaires"
L["Adjust the font size of countdown and application count texts."] = "Ajuster la taille des polices du texte des comptes à rebours et du nombre d'application."
L["Application count position"] = "Position du nombre de charges"
L["Application text color"] = "Couleur du nombre d'applications"
L["BELOW20"] = "Au-dessous de 20% de vie"
L["BELOW25"] = "Au-dessous de 25% de vie"
L["BELOW35"] = "Au-dessous de 35% de vie"
L["BELOW80"] = "Au-dessous de 80% de vie"
L[ [=[Behave as if the interface option "Auto self cast" was enabled, e.g. test helpful spells on yourself when you are not targeting a friendly unit.
Note: this enables the old Inline Aura behavior with friendly spells.]=] ] = [=[Fonctionner comme si l'option d'interface "Auto self cast" était cochée, c'est-à-dire tester les sorts amicaux sur vous-même quand vous ne ciblez pas une unité amie.
Note : Ceci active l'ancien fonctionnement d'Inline Aura avec les sorts amicaux.]=] -- Needs review
L["Border highlight colors"] = "Couleurs des bords"
L["Bottom"] = "Bas"
L["Bottom left"] = "En bas à gauche"
L["Bottom right"] = "En bas à droite"
L["COMBO_POINTS"] = "Points de combo"
L["Center"] = "Centré"
L["Colored border"] = "Bord coloré"
L["Countdown position"] = "Position du compte à rebours"
L["Countdown text color"] = "Couleur du compte à rebours"
L["Current module"] = "Module actuel"
L["Current spell"] = "Sort actuel"
L["DISPELLABLE"] = "(Dé)buffs que vous pouvez dissiper"
L["Decimal countdown threshold"] = "Seuil de compte à rebours décimal"
L["Dim"] = "Assombrir"
L["Dim the button when the (de)buff is NOT found (reversed logic)."] = "Assombrit le bouton quand le (dé)buff n'est PAS trouvé (logique inverse)."
L["Dispel"] = "Dissiper" -- Needs review
L["Display a colored border. Its color depends on the kind and owner of the (de)buff."] = "Afficher une bordure colorée. Sa couleur dépend du type et de l'unité portant le (dé)buff."
L["Display the Blizzard shiny, animated border."] = "Afficher la bordure brillante animée de Blizzard."
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
L["INTERRUPTIBLE"] = "Incantation pouvant être interrompue"
L["Ignore buffs cast by other characters."] = "Ignorer les buffs lancés pas d'autres personnages."
L["Ignore debuffs cast by other characters."] = "Ignorer les débuffs lancés pas d'autres personnages."
L["Ignored"] = "Ignorés" -- Needs review
L["Inline Aura"] = "Inline Aura"
L["Inline Aura can highlight the action button when the (de)buff is found."] = "Inline Aura peut mettre en évidence le bouton d'action quand le (dé)buff est trouvé."
L["Interrupt"] = "Interruption" -- Needs review
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
L["Module settings"] = "Paramètres du module" -- Needs review
L["Modules"] = "Modules"
L["My buffs"] = "Mes buffs"
L["My debuffs"] = "Mes debuffs"
L["No application count"] = "Cacher le nombre d'applications"
L["No countdown"] = "Cacher le compte à rebours"
L["Only display the (de)buff if it has been applied by yourself, your pet or your vehicle."] = "N'afficher le (dé)buff que si il a été lancé par vous, votre familier ou votre véhicule."
L["Only my buffs"] = "Seulement mes buffs"
L["Only my debuffs"] = "Seulement mes debuffs"
L["Only show mine"] = "Afficher seulement les miens"
L["Options related to the units to watch and the way to select them depending on the spells."] = "Options en rapport avec les unités à surveiller et la façon de les sélectionner selon les sorts."
L["Others' buffs"] = "Les buffs des autres"
L["Others' debuffs"] = "Les debuffs des autres"
L["Outline"] = "Bordure"
L["Precise countdown"] = "Compte à rebours précis"
L["Preset"] = "Préréglé" -- Needs review
L["Presets"] = "Préréglages" -- Needs review
L["Profiles"] = "Profils"
L["Regular"] = "Standard" -- Needs review
L["Reset"] = "Réinitialiser" -- Needs review
L["Right"] = "A droite"
L["SOUL_SHARDS"] = "Fragments d'âme"
L["Select an effect to enhance the readability of the texts."] = "Sélectionnez un effet pour améliorer la visibilité des textes"
L["Select the color to use for the buffs cast by other characters."] = "Sélectionnez la couleur à utiliser pour les buffs lancés par d'autres personnages."
L["Select the color to use for the buffs you cast."] = "Sélectionnez la couleur à utiliser pour les buffs lancés par votre personnage."
L["Select the color to use for the debuffs cast by other characters."] = "Sélectionnez la couleur à utiliser pour les debuffs lancés par d'autres personnages."
L["Select the color to use for the debuffs you cast."] = "Sélectionnez la couleur à utiliser pour les debuffs lancés par votre personnage."
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "Selectionnez les couleurs utilisées pour mettre les boutons d'actions en surbrillance. Elles sont choisies en fonction du type d'aura et du lanceur."
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
L["Single value position"] = "Position d'une valeur seule"
L["Size of large text"] = "Taille du grand texte"
L["Size of small text"] = "Taille du petit texte"
L["Special"] = "Spécial"
L["Targeting settings"] = "Réglages de ciblage"
L["Text Position"] = "Position des textes"
L["Text appearance"] = "Apparence du texte"
L["The large font is used to display countdowns."] = "La grande police est utilisée pour afficher les comptes à rebours."
L["The small font is used to display application count."] = "La petite police est utilisée pour afficher le nombre d'application"
L["Thick outline"] = "Bordure épaisse"
L["Top"] = "Haut"
L["Top left"] = "En haut à gauche"
L["Top right"] = "En haut à droite"
L["Value to display"] = "Valeur à afficher"
L["Watch focus"] = "Surveiller la focalisation"
L["Watch unit under mouse cursor"] = "Surveiller l'unité sous la souris"

------------------------ deDE ------------------------
elseif locale == 'deDE' then
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["(De)buff type"] = "(De)bufftyp"
L["ABOVE20"] = "Unter 20% Lebenspunkte"
L["Application count position"] = "Zählerposition"
L["Application text color"] = "Textfarbe der Anwendung"
L["BELOW35"] = "Unter 35% Lebensenergie"
L["BELOW80"] = "Unter 80% Lebensenergie"
L[ [=[Behave as if the interface option "Auto self cast" was enabled, e.g. test helpful spells on yourself when you are not targeting a friendly unit.
Note: this enables the old Inline Aura behavior with friendly spells.]=] ] = [=[Verhaltet sich als ob die Interfaceoption "Automatischer Selbstzauber" aktiviert ist. Es testet Zauber an sich selbst, wenn man nicht eine befreundete Einheit im Target hat. 
Notiz: Es aktiviert das alte Inline aura verhalten von freundlichen Zaubern.]=]
L["Border highlight colors"] = "Randfarbe"
L["Bottom"] = "Unten"
L["Bottom left"] = "Unten Links"
L["Bottom right"] = "Unten Rechts"
L["COMBO_POINTS"] = "Kombopunkte"
L["Center"] = "Mitte"
L["Colored border"] = "Eingefärbter Rand"
L["Countdown position"] = "Position des Cooldowns"
L["Countdown text color"] = "Countdown-Textfarbe"
L["Current module"] = "Aktuelles Modul"
L["Current spell"] = "Aktueller Zauber"
L["DISPELLABLE"] = "Aufhebbar"
L["Decimal countdown threshold"] = "Nachkommastellen des Countdowns."
L["Dim"] = "Verdunkeln"
L["Dim the button when the (de)buff is NOT found (reversed logic)."] = "Verdunkelt dne Button, wenn der (de)buff nicht gefunden wurde"
L["Do not highlight the button."] = "Den button nicht hervorheben"
L["Dynamic countdown"] = "Dynamischer Countdown"
L["Eclipse energy"] = "Eclipse Energie"
L["Effect"] = "Effekt"
L["Either OmniCC or CooldownCount is loaded so aura countdowns are displayed using small font only."] = "Wenn OmniCC oder Coldowncount geladen sind werden die Aurencooldowns nur in einer kleineren Schrift angezeigt"
L["Emulate auto self cast"] = "automatischen selbstzauber emulieren"
L["Enabled"] = "Aktiviert"
L["Font effect"] = "Schrifteffekt"
L["Font name"] = "Schriftartname"
L["Font size"] = "Schriftgröße"
L["Glowing animation"] = "Leuchtende Animation"
L["Highlight"] = "Hervorheben"
L["INTERRUPTIBLE"] = "Unterbrechbar"
L["Ignore buffs cast by other characters."] = "Ignoriere Buffs die von anderen Charakteren gezaubert wurden"
L["Ignore debuffs cast by other characters."] = "Ignoriere Debuffs die von anderen Charakteren gezaubert wurden"
L["Ignored"] = "Ignoriert"
L["Inline Aura"] = "Inline Aura"
L["Inline Aura can highlight the action button when the (de)buff is found."] = "Inline Aura kann dne Button betohnen, wenn der (de)buff vorhanden ist"
L["Interrupt"] = "Unerbrochen"
L[ [=[Invalid spell names:
%s.]=] ] = "Ungültiger Zaubername %s"
L["Invert"] = "Umkehren"
L["Left"] = "Links"
L["Lists spells from ..."] = "List Zauber aus ..."
L["Make the countdown color, and size if possible, depends on remaining time."] = "Falls möglich, sollen die Countdown-Farbe und -Größe abhängig von der verbleibenden Zeit dargestellt werden."
L["Modified settings"] = "Modifizierte Eigenschaften"
L["Module settings"] = "Moduleigenschaften"
L["Modules"] = "Module"
L["My buffs"] = "Meine Buffs"
L["My debuffs"] = "Meine Debuffs"
L["No application count"] = "Keine Zähler."
L["No countdown"] = "Kein Countdown"
L["Only my buffs"] = "Nur meine Buffs"
L["Only my debuffs"] = "Nur meine Debuffs"
L["Only show mine"] = "Nur meine zeigen"
L["Options related to the units to watch and the way to select them depending on the spells."] = "Stückzahl optionen und Einstellungen um die abhängig von Zaubern auszuwählen." -- Needs review
L["Others' buffs"] = "Buffs anderer"
L["Others' debuffs"] = "Debuffs anderer"
L["Outline"] = "Schrifthintergrund"
L["Precise countdown"] = "Präziser Countdown"
L["Profiles"] = "Profile"
L["Right"] = "Rechts"
L["SOUL_SHARDS"] = "Seelensplitter"
L["Select the color to use for the buffs cast by other characters."] = "Auswahl der Farbe für die gecasteten Buffs anderer Charaktere"
L["Select the color to use for the buffs you cast."] = "Auswahl der Farbe für die eigenen gecasteten Buffs"
L["Select the color to use for the debuffs cast by other characters."] = "Auswahl der Farbe für die gecasteten Debuffs anderer Charaktere"
L["Select the color to use for the debuffs you cast."] = "Farbe für die selbst gewirkten Debuffs auswählen."
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "Auswahl der Farbe zur Hervorhebung des Aktionsbuttons. Die Auswahl basiert auf Zuberer und Auratype"
L["Select the font to be used to display both countdown and application count."] = "Auswahl der Schriftart für den Countdown und Zähler."
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = "Auswahl der Anzeigeposition, wo der Cooldown und der Zähler angezeigt werden. Wenn nur ein Wert angezeigt wird, wird die Primärposition benutzt. "
L["Select where to place a single value."] = "Wähle aus, wo ein einzelner Wert plaziert werden soll."
L["Select where to place the application count text when both values are shown."] = "Auswahl der Position des Zählers, wenn beide anderer Plätze belegt sind. "
L["Select where to place the countdown text when both values are shown."] = "Auswahl des Textposition des Cooldowns, wenn beide anderen Positionen belegt sind. "
L["Select which special value should be displayed."] = "Wähle welcher spezielle Wert angezeigt werden soll."
L["Self"] = "Selbst"
L["Should the module be used ?"] = "Soll das Modul benutzt werden ?"
L["Show countdown"] = "Cooldown anzeigen"
L["Show stack count"] = "Stackzähler anzeigen"
L["Single value position"] = "Position einzelner Werte "
L["Size of large text"] = "Große Textgröße"
L["Size of small text"] = "Kleine Textgröße"
L["Special"] = "Speziell"
L["Spells"] = "Zauber"
L["Targeting settings"] = "Angriffsziel Optionen"
L["Text Position"] = "Textposition"
L["Text appearance"] = "Textdarstellung"
L["The large font is used to display countdowns."] = "Die große Schrift wird zur Anzeige von Countdowns verwendet."
L["Top"] = "Oben"
L["Top left"] = "Oben links"
L["Top right"] = "Oben rechts"
L["Use global setting"] = "Globale Eigenschaften nutzen"
L["User-defined"] = "Benutzerdefiniert"
L["Value to display"] = "Anzuzeigender Wert"
L["Watch focus"] = "beachte Fokus"
L["Watch unit under mouse cursor"] = "beachte Einheit unterm dem Mauszeiger"
L["all settings that differ from default ones."] = "Alle Einstellungen die sich von den Standardeinstellungen differenzieren"
L["all the predefined settings, be them in use or not."] = "Alle Voreinstellungen ob genutzt oder nicht"
L["no specific settings for this spell ; use global ones."] = "Keine spezifischen Einstellungen für den Zauber - Standardeinstellungen benutzen"
L["spells and items visible on the action bars."] = "Zauber und Items in der Aktionsleiste sichtbar"
L["totally ignore the spell ; do not show any countdown or highlight."] = "Ignoriere den Zauber  - Zeige keinen Cooldown oder Hervorhebung"
L["use the predefined settings shipped with Inline Aura."] = "Die Voreinstellungen von Inline auras nutzen"
L["use your own settings."] = "Eigene Einstellungen benutzen"

------------------------ esMX ------------------------
-- no translation

------------------------ ruRU ------------------------
elseif locale == 'ruRU' then
L["%dh"] = "%dч"
L["%dm"] = "%dм"
L["Font name"] = "Название шрифта"
L["Inline Aura"] = "Inline Aura"
L["My buffs"] = "Мои баффы"
L["My debuffs"] = "Мои дебаффы"
L["Only my buffs"] = "Только мои баффы"
L["Only my debuffs"] = "Только мои дебаффы"
L["Only show mine"] = "Отображать только моё"
L["Others' buffs"] = "Баффы других игроков"
L["Others' debuffs"] = "Дебаффы других игроков"
L["Profiles"] = "Профили"
L["Select the color to use for the buffs cast by other characters."] = "Выбрать цвет, используемый для баффов, накладываемых другими игроками."
L["Select the color to use for the buffs you cast."] = "Выбрать цвет, используемый для баффов, накладываемых вами."
L["Select the color to use for the debuffs cast by other characters."] = "Выбрать цвет, используемый для дебаффов, накладываемых другими игроками."
L["Select the color to use for the debuffs you cast."] = "Выбрать цвет, используемый для дебаффов, накладываемых вами."
L["Size of large text"] = "Размер большого текста"
L["Size of small text"] = "Размер маленького текста"
L["Text appearance"] = "Внешний вид текста"

------------------------ esES ------------------------
elseif locale == 'esES' then
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["Application count position"] = "Posicion del contador de aplicacion"
L["Application text color"] = "Color del texto de aplicacion"
L["Border highlight colors"] = "Color del resalte del borde"
L["Bottom"] = "Abajo"
L["Bottom left"] = "Abajo izquierda"
L["Bottom right"] = "Abajo derecha"
L["COMBO_POINTS"] = "Puntos de combo"
L["Center"] = "Centro"
L["Colored border"] = "Borde coloreado"
L["Countdown position"] = "Posicion de la cuenta atras"
L["Countdown text color"] = "Color del texto de la cuenta atras"
L["Decimal countdown threshold"] = "Umbral de la cuenta atras decimal"
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
L["SOUL_SHARDS"] = "Fragmentos de alma"
L["Select the color to use for the buffs cast by other characters."] = "Selecciona el color a usar para beneficios casteados por otros personajes."
L["Select the color to use for the buffs you cast."] = "Selecciona el color a usar para perjuicios casteados por ti."
L["Select the color to use for the debuffs cast by other characters."] = "Selecciona el color a usar para beneficios casteados por otros personajes."
L["Select the color to use for the debuffs you cast."] = "Selecciona el color a usar para perjuicios casteados por ti."
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "Selecciona los colores a usar para resaltar el boton de acción. Estan basados en el tipo de hechizo"
L["Select the font to be used to display both countdown and application count."] = "Selecciona la fuente usada para mostrar la cuenta atras y la cuenta de aplicación"
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = "Selecciona donde mostrar la cuenta atras y la cuenta de aplicacion en el boton. Cuando solo se muestra un valor, se usa \"posicion valor unico\" en vez del normal"
L["Select where to place a single value."] = "Selecciona donde poner el valor unico"
L["Select where to place the application count text when both values are shown."] = "Selecciona donde poner el texto del contador de aplicacion cuando ambos valores se muestran"
L["Select where to place the countdown text when both values are shown."] = "Selecciona donde poner el texto de cuenta atras cuando ambas valores se muestran"
L["Select which special value should be displayed."] = "Selecciona que valor especial debe ser mostrado"
L["Single value position"] = "Posicion valor unico"
L["Size of large text"] = "Tamaño del texto grande"
L["Size of small text"] = "Tañaño del texto pequeño"
L["Special"] = "Especial"
L["Text Position"] = "Posicion del texto"
L["Text appearance"] = "Apariencia del texto"
L["The large font is used to display countdowns."] = "Se esta usando fuente grande para mostrar la cuenta atras"
L["Top"] = "Arriba"
L["Top left"] = "Arriba izquierda"
L["Top right"] = "Arriba derecha"
L["Value to display"] = "Valor a mostrar"

------------------------ zhTW ------------------------
elseif locale == 'zhTW' then
L["%dh"] = "%d小時"
L["%dm"] = "%d分"
L["(De)buff type"] = "(減)增益類型"
L["ABOVE20"] = "高於 20% 生命"
L["ABOVE25"] = "高於 25% 生命"
L["ABOVE35"] = "高於 35% 生命"
L["ABOVE80"] = "高於 80% 生命"
L["Additional (de)buffs"] = "附(減)增益"
L["Application count position"] = "疊加計數位置"
L["Application text color"] = "疊加文字顏色"
L["BELOW20"] = "低於 20% 生命"
L["BELOW25"] = "低於 25% 生命"
L["BELOW35"] = "低於 35% 生命"
L["BELOW80"] = "低於 85% 生命"
L["Border highlight colors"] = "邊緣高亮顏色"
L["Bottom"] = "底部"
L["Bottom left"] = "左下"
L["Bottom right"] = "右下"
L["COMBO_POINTS"] = "連擊點數"
L["Center"] = "中央"
L["Colored border"] = "彩色邊框"
L["Countdown position"] = "冷卻位置"
L["Countdown text color"] = "冷卻文字顏色"
L["Current module"] = "目前模組"
L["Current spell"] = "目前法術"
L["DISPELLABLE"] = "(減)增益你可以驅散"
L["Decimal countdown threshold"] = "小數冷卻門檻"
L["Dim"] = "暗淡"
L["Dim the button when the (de)buff is NOT found (reversed logic)."] = "(減)增益找不到(顛倒邏輯)時暗淡按鈕。"
L["Dispel"] = "驅散"
L["Display the Blizzard shiny, animated border."] = "顯示暴雪發光, 動畫邊框。"
L["Do not highlight the button."] = "不要高亮按鈕。"
L["Dynamic countdown"] = "動態冷卻時間"
L["Eclipse energy"] = "蝕星蔽月能量"
L["Effect"] = "效果"
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
L["INTERRUPTIBLE"] = "可中斷施法"
L["Ignore buffs cast by other characters."] = "忽略增益施放由其他角色。"
L["Ignore debuffs cast by other characters."] = "忽略減益施放由其他角色。"
L["Ignored"] = "忽略"
L["Inline Aura"] = "Inline Aura"
L["Interrupt"] = "中斷"
L[ [=[Invalid spell names:
%s.]=] ] = [=[無效的法術名稱:
%s。]=]
L["Invert"] = "顛倒"
L["Left"] = "左"
L["Lists spells from ..."] = "列表法術來自..."
L["Lookup"] = "查找"
L["Modified settings"] = "修改設定"
L["Module settings"] = "模組設定"
L["Modules"] = "模組"
L["My buffs"] = "我的增益法術"
L["My debuffs"] = "我的減益法術"
L["No application count"] = "無疊加計數"
L["No countdown"] = "無冷卻"
L["Only my buffs"] = "僅我的增益法術"
L["Only my debuffs"] = "僅我的減益法術"
L["Only show mine"] = "僅顯示我的"
L["Others' buffs"] = "別人的增益法術"
L["Others' debuffs"] = "別人的減益法術"
L["Outline"] = "輪廓"
L["Precise countdown"] = "精確冷卻"
L["Preset"] = "事先調整"
L["Presets"] = "事先調整"
L["Profiles"] = "設定檔"
L["Regular"] = "規則"
L["Reset"] = "重設"
L["Right"] = "右"
L["SOUL_SHARDS"] = "靈魂碎片"
L["Select the color to use for the buffs cast by other characters."] = "選擇其他玩家施放的增益法術顏色"
L["Select the color to use for the buffs you cast."] = "選擇你施放的增益法術顏色"
L["Select the color to use for the debuffs cast by other characters."] = "選擇其他玩家施放的減益法術顏色"
L["Select the color to use for the debuffs you cast."] = "選擇你施放的減益法術顏色"
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "選擇顏色用於強調動作按鈕。這是選擇是基於光環類型和施法者。"
L["Select the font to be used to display both countdown and application count."] = "選擇用來顯示冷卻&疊加計數的字型"
L["Self"] = "自己"
L["Should the module be used ?"] = "應該模組使用?"
L["Should this module highlight the button ?"] = "應該模組高亮按鈕?"
L["Show countdown"] = "顯示冷卻時間"
L["Show stack count"] = "顯示堆疊計數"
L["Single value position"] = "單個值數位置"
L["Size of large text"] = "大文字尺寸"
L["Size of small text"] = "小文字尺寸"
L["Special"] = "特別"
L["Spells"] = "法術"
L["Targeting settings"] = "目標設定"
L["Text Position"] = "文字位置"
L["Text appearance"] = "文字外觀"
L["The large font is used to display countdowns."] = "大字型用於顯示冷卻時間。"
L["Thick outline"] = "粗線"
L["Top"] = "頂部"
L["Top left"] = "左上"
L["Top right"] = "右下"
L["Totem timers"] = "圖騰計時器"
L["Type of settings"] = "設定類型"
L["Use global setting"] = "使用通用設定"
L["User-defined"] = "用戶定義"
L["Value to display"] = "數值至顯示"
L["Watch focus"] = [=[觀看焦點
]=]
L["Watch unit under mouse cursor"] = "監視單位在滑鼠游標下"
L["no specific settings for this spell ; use global ones."] = "沒有具體設定此法術 ; 使用通用任何人。"
L["spells and items visible on the action bars."] = "法術和物品可見的動作條。"
L["spells from matching spellbooks."] = "法術來自相同的法術書。"
L["use your own settings."] = "使用你自己設定。"
L["watch pet (de)buffs in any case."] = "監視寵物的(減)增益在任何情況下。"
L["watch your (de)buffs in any case."] = "監視你的(減)增益在任何情況下。"

------------------------ zhCN ------------------------
elseif locale == 'zhCN' then
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["Application text color"] = "叠加文本颜色"
L["Border highlight colors"] = "边框高亮颜色"
L["Bottom"] = "底部"
L["Countdown text color"] = "倒计时文本颜色"
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
L["Select the color to use for the buffs cast by other characters."] = "选择其他玩家施放的增益法术颜色"
L["Select the color to use for the buffs you cast."] = "选择你施放的增益法术颜色"
L["Select the color to use for the debuffs cast by other characters."] = "选择其他玩家施放的减益法术颜色"
L["Select the color to use for the debuffs you cast."] = "选择你施放的减益法术颜色"
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "选择用来高亮动作条按钮的颜色.这些选择以光环类型和施法者为基础."
L["Select the font to be used to display both countdown and application count."] = "选择用来显示倒计时和叠加计数的字体"
L["Size of large text"] = "大文本尺寸"
L["Size of small text"] = "小文本尺寸"
L["Text appearance"] = "文本外观"
L["The large font is used to display countdowns."] = "大字体用来显示倒计时"
L["Top"] = "顶部"

------------------------ koKR ------------------------
elseif locale == 'koKR' then
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["(De)buff type"] = "강(약)화 효과 형태"
L["ABOVE20"] = "생명력 20% 이상"
L["ABOVE25"] = "생명력 25% 이상"
L["ABOVE35"] = "생명력 35% 이상"
L["ABOVE80"] = "생명력 80% 이상"
L["Additional (de)buffs"] = "추가 강(약)화 효과"
L["Application count position"] = "효과 카운트 위치"
L["Application text color"] = "효과 글자색"
L["BELOW20"] = "생명력 20% 미만"
L["BELOW25"] = "생명력 25% 미만"
L["BELOW35"] = "생명력 35% 미만"
L["BELOW80"] = "생명력 80% 미만"
L["Border highlight colors"] = "테두리 강조색"
L["Bottom"] = "아래쪽"
L["Bottom left"] = "왼쪽 아래"
L["Bottom right"] = "오른쪽 아래"
L["COMBO_POINTS"] = "연계 점수"
L["Center"] = "가운데"
L["Colored border"] = "색칠된 테두리"
L["Countdown position"] = "카운트다운 위치"
L["Countdown text color"] = "카운트다운 글자색"
L["Current module"] = "현재 모듈"
L["Current spell"] = "현재 주문"
L["DISPELLABLE"] = "해제 가능한 강(약)화 효과"
L["Decimal countdown threshold"] = "십진 카운트 한계" -- Needs review
L["Dim the button when the (de)buff is NOT found (reversed logic)."] = "강(약)화 효과가 발견되지 않았을 때 버튼을 흐리게 함 (반대 논리)."
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
L["INTERRUPTIBLE"] = "방해 가능한 주문 시전"
L["Inline Aura"] = "Inline Aura"
L["Inline Aura can highlight the action button when the (de)buff is found."] = "Inline Aura가 강(약)화 효과가 발견되었을 때 행동 단축 버튼을 강조할 수 있습니다."
L["Interrupt"] = "방해"
L["Invert"] = "반전"
L["Invert the highlight condition, highlightning when the (de)buff is not found."] = "강조 조건을 거꾸로 강(약)화 효과가 발견되지 않을 때로 바꿈."
L["Left"] = "왼쪽"
L["Module settings"] = "모듈 설정"
L["Modules"] = "모듈"
L["My buffs"] = "내 강화 효과"
L["My debuffs"] = "내 약화 효과"
L["No application count"] = "효과 카운트 안 함"
L["No countdown"] = "카운트다운 안 함"
L["Only my buffs"] = "내 강화 효과만"
L["Only my debuffs"] = "내 약화 효과만"
L["Only show mine"] = "내 것만 표시"
L["Others' buffs"] = "다른 플레이어의 강화 효과"
L["Others' debuffs"] = "다른 플레이어의 약화 효과"
L["Outline"] = "외곽선"
L["Precise countdown"] = "정밀한 카운트다운"
L["Profiles"] = "프로필"
L["Reset"] = "초기화"
L["Right"] = "오른쪽"
L["SOUL_SHARDS"] = "영혼의 조각"
L["Select the color to use for the buffs cast by other characters."] = "다른 캐릭터가 시전한 강화 효과에 사용할 색을 선택합니다."
L["Select the color to use for the buffs you cast."] = "당신이 시전한 강화 효과에 사용할 색을 선택합니다."
L["Select the color to use for the debuffs cast by other characters."] = "다른 캐릭터가 시전한 약화 효과에 사용할 색을 선택합니다."
L["Select the color to use for the debuffs you cast."] = "당신이 시전한 약화 효과에 사용할 색을 선택합니다."
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "행동 단축 버튼 강조에 쓰일 색을 선택합니다. 오라 형태와 시전자를 기초로 선택됩니다."
L["Select the font to be used to display both countdown and application count."] = "카운트다운과 효과 카운트 표시에 쓰일 글꼴을 선택합니다."
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = "효과 카운트나 카운트다운 글자가 표시될 곳을 선택합니다. 하나의 값만 표시되는 경우는 '값이 하나일 때 위치'에서 위치를 선택해야 합니다."
L["Select where to place a single value."] = "값이 하나만 보일 때 글자가 놓일 곳 선택"
L["Select where to place the application count text when both values are shown."] = "두 값이 보일 때 효과 카운트 글자가 놓일 곳 선택."
L["Select where to place the countdown text when both values are shown."] = "두 값이 보일 때 효과 카운트다운 글자가 놓일 곳 선택."
L["Select which special value should be displayed."] = "버튼을 강조할 수 있는 효과를 선택합니다."
L["Show countdown"] = "카운트다운 보기"
L["Show stack count"] = "중첩 카운트 보임"
L["Single value position"] = "값이 하나일 때 위치"
L["Size of large text"] = "큰 글자 크기"
L["Size of small text"] = "작은 글자 크기"
L["Special"] = "특별함"
L["Spells"] = "주문"
L["Targeting settings"] = "대상지정 설정"
L["Text Position"] = "글자 위치"
L["Text appearance"] = "글자 겉모양"
L["The large font is used to display countdowns."] = "카운트다운 표시에 쓰이는 큰 글꼴."
L["The small font is used to display application count."] = "작은 글꼴이 효과 카운트 표시에 쓰입니다."
L["Thick outline"] = "굵은 외곽선"
L["Top"] = "위쪽"
L["Top left"] = "왼쪽 위"
L["Top right"] = "오른쪽 위"
L["Totem timers"] = "토템 타이머"
L["Type of settings"] = "설정의 형태"
L["Value to display"] = "값을 표시" -- Needs review
end

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end
