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

local _, ns = ...

local locale = GetLocale()
local L = setmetatable({}, {__index = function(self, key)
	local value = tostring(key)
	if key ~= nil then self[key] = value end
	--@debug@
	InlineAura.dprint("Missing locale:", value)
	--@end-debug@
	return value
end})
ns.L = L

-- @noloc[[
-- Locales from GlobalStrings.lua
L.LUNAR_ENERGY = BALANCE_NEGATIVE_ENERGY
L.SOLAR_ENERGY = BALANCE_POSITIVE_ENERGY
L.HOLY_POWER = HOLY_POWER
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
L["Add spell"] = true
L["Application count position"] = true
L["Application text color"] = true
L["Aura type"] = true
L["Auras to look up"] = true
L["Border highlight colors"] = true
L["Bottom left"] = true
L["Bottom right"] = true
L["Bottom"] = true
L["Center"] = true
L["Check to have a more accurate countdown display instead of default Blizzard rounding."] = true
L["Check to hide the aura application count (charges or stacks)."] = true
L["Check to hide the aura countdown."] = true
L["Check to hide the aura duration countdown."] = true
L["Check to ignore buffs cast by other characters."] = true
L["Check to ignore debuffs cast by other characters."] = true
L["Check to only show aura you applied. Uncheck to always show aura, even when applied by others. Leave grayed to use default settings."] = true
L["Check to totally disable this spell. No border highlight nor text is displayed for disabled spells."] = true
L["Click to create specific settings for the spell."] = true
L["Colored border"] = true
L["Countdown position"] = true
L["Countdown text color"] = true
L["Decimal countdown threshold"] = true
L["Disable"] = true
L["Do you really want to remove these aura specific settings ?"] = true
L["Either OmniCC or CooldownCount is loaded so aura countdowns are displayed using small font at the bottom of action buttons."] = true
L["Enter additional aura names to check. This allows to check for alternative or equivalent auras. Some spells also apply auras that do not have the same name as the spell."] = true
L["Enter one aura name per line. They are spell-checked ; errors will prevents you to validate."] = true
L["Enter the name of the spell for which you want to add specific settings. Non-existent spell or item names are rejected."] = true
L["Font name"] = true
L["Glowing animation"] = true
L["Highlight effect"] = true
L["Inline Aura"] = true
L["Left"] = true
L["My buffs"] = true
L["My debuffs"] = true
L["New spell name"] = true
L["No application count"] = true
L["No countdown"] = true
L["None"] = true
L["Only my buffs"] = true
L["Only my debuffs"] = true
L["Only show mine"] = true
L["Others' buffs"] = true
L["Others' debuffs"] = true
L["Pet buff or debuff"] = true
L["Precise countdown"] = true
L["Profiles"] = true
L["Regular buff or debuff"] = true
L["Remove spell specific settings."] = true
L["Remove spell"] = true
L["Reset settings to global defaults."] = true
L["Reset settings"] = true
L["Restore default settings of the selected spell."] = true
L["Restore defaults"] = true
L["Right"] = true
L["Select additional units to watch. Disabling those units may save some resource but also prevent proper display of macros using these units."] = true
L["Select how to highlight the button."] = true
L["Select the aura type of this spell. This helps to look up the aura."] = true
L["Select the color to use for the buffs cast by other characters."] = true
L["Select the color to use for the buffs you cast."] = true
L["Select the color to use for the debuffs cast by other characters."] = true
L["Select the color to use for the debuffs you cast."] = true
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = true
L["Select the font to be used to display both countdown and application count."] = true
L["Select the remaining time threshold under which tenths of second are displayed."] = true
L["Select the spell to edit or to remove its specific settings. Spells with specific defaults are written in |cff77ffffcyan|r. Removed spells with specific defaults are written in |cff777777gray|r."] = true
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = true
L["Select where to place a single value."] = true
L["Select where to place the application count text when both values are shown."] = true
L["Select where to place the countdown text when both values are shown."] = true
L["Select which special value should be displayed."] = true
L["Self buff or debuff"] = true
L["Single value position"] = true
L["Size of large text"] = true
L["Size of small text"] = true
L["Special"] = true
L["Spell specific settings"] = true
L["Spell to edit"] = true
L["Text Position"] = true
L["Text appearance"] = true
L["The large font is used to display countdowns."] = true
L["The small font is used to display application count (and countdown when cooldown addons are loaded)."] = true
L["Top left"] = true
L["Top right"] = true
L["Top"] = true
L["Unknown spell: %s"] = true
L["Value to display"] = true
L["Watch additional units"] = true
L["focus"] = true
L["mouseover"] = true

-- Core.lua
L["%dh"] = true
L["%dm"] = true

-- Specials.lua
L["COMBO_POINTS"] = true
L["HOLY_POWER"] = true
L["SOUL_SHARDS"] = true


------------------------ frFR ------------------------
local locale = GetLocale()
if locale == 'frFR' then
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["Add spell"] = "Ajouter le sort"
L["Application count position"] = "Position du nombre de charges"
L["Application text color"] = "Couleur du nombre d'applications"
L["Aura type"] = "Type d'aura"
L["Auras to look up"] = "Aura à rechercher"
L["Border highlight colors"] = "Couleurs des bords"
L["Bottom"] = "Bas"
L["Bottom left"] = "En bas à gauche"
L["Bottom right"] = "En bas à droite"
L["COMBO_POINTS"] = "Points de combo"
L["Center"] = "Centré"
L["Check to have a more accurate countdown display instead of default Blizzard rounding."] = "Cochez pour avoir un compte à rebours plus précis plutôt que l'arrondi de Blizzard."
L["Check to hide the aura application count (charges or stacks)."] = "Cochez pour cacher l'affichage du nombre de charges ou d'applications."
L["Check to hide the aura countdown."] = "Cochez pour cacher le compte à rebours."
L["Check to hide the aura duration countdown."] = "Cochez pour cacher le compte-rebours de l'aura."
L["Check to ignore buffs cast by other characters."] = "Cochez pour ignorer les buffs lancés par les autres personnages."
L["Check to ignore debuffs cast by other characters."] = "Cochez pour ignorer les debuffs lancés par les autres personnages."
L["Check to only show aura you applied. Uncheck to always show aura, even when applied by others. Leave grayed to use default settings."] = "Cochez pour n'afficher que les auras que vous appliquez. Décochez pour toujours afficher les auras, même appliquées par d'autres. Laissez grisé pour utiliser le réglage par défaut."
L["Check to totally disable this spell. No border highlight nor text is displayed for disabled spells."] = "Cochez pour désactiver totalement ce sort. Aucun bord ni texte n'est affiché pour les sorts désactivés."
L["Click to create specific settings for the spell."] = "Cliquer pour créer des réglages spécifiques pour ce sort."
L["Colored border"] = "Bord coloré"
L["Countdown position"] = "Position du compte à rebours"
L["Countdown text color"] = "Couleur du compte à rebours"
L["Decimal countdown threshold"] = "Seuil de compte à rebours décimal"
L["Disable"] = "Désactiver"
L["Do you really want to remove these aura specific settings ?"] = "Voulez-vous vraiment enlever les réglages spécifiques de ce sort ?"
L["Either OmniCC or CooldownCount is loaded so aura countdowns are displayed using small font at the bottom of action buttons."] = "Soit OmniCC soit CooldownCount est chargé donc les comptes à rebourd sont affichés en petit en bas des boutons d'action."
L["Enter additional aura names to check. This allows to check for alternative or equivalent auras. Some spells also apply auras that do not have the same name as the spell."] = "Entrez des noms d'auras supplémentaires à vérifier. Cela permet de vérifier des auras alternatives ou équivalentes. De plus, certains sorts appliquent une aura qui n'a pas le même nom que le sort."
L["Enter one aura name per line. They are spell-checked ; errors will prevents you to validate."] = "Entrez un nom d'aura par ligne. Leur orthographe est vérifié, toute erreur vous empêchera de valider."
L["Enter the name of the spell for which you want to add specific settings. Non-existent spell or item names are rejected."] = "Entrez le nom du sort pour lequel vous voulez définir des réglages spécifiques. Les noms d'objet ou de sort inexistants sont rejetés."
L["Font name"] = "Nom de la police"
L["Glowing animation"] = "Animation brillante"
L["HOLY_POWER"] = "Pouvoir sacré"
L["Highlight effect"] = "Effet de surbrillance"
L["Inline Aura"] = "Inline Aura"
L["Left"] = "A gauche"
L["My buffs"] = "Mes buffs"
L["My debuffs"] = "Mes debuffs"
L["New spell name"] = "Nom du nouveau sort"
L["No application count"] = "Cacher le nombre d'applications"
L["No countdown"] = "Cacher le compte à rebours"
L["None"] = "Aucun"
L["Only my buffs"] = "Seulement mes buffs"
L["Only my debuffs"] = "Seulement mes debuffs"
L["Only show mine"] = "Afficher seulement les miens"
L["Others' buffs"] = "Les buffs des autres"
L["Others' debuffs"] = "Les debuffs des autres"
L["Pet buff or debuff"] = "Buff ou débuff du familier"
L["Precise countdown"] = "Compte à rebours précis"
L["Profiles"] = "Profils"
L["Regular buff or debuff"] = "Buff ou débuff normal"
L["Remove spell"] = "Enlever le sort"
L["Remove spell specific settings."] = "Supprime les réglages spécifiques du sort."
L["Reset settings"] = "R.-à-Z. réglages"
L["Reset settings to global defaults."] = "Réinitialise les réglages "
L["Restore default settings of the selected spell."] = "Restaure les réglages par défaut du sort sélectionné."
L["Restore defaults"] = "Par défaut"
L["Right"] = "A droite"
L["SOUL_SHARDS"] = "Fragments d'âme"
L["Select additional units to watch. Disabling those units may save some resource but also prevent proper display of macros using these units."] = "Sélectionnez des unités supplémentaires à surveiller. Désactiver ces unités peut améliorer les performances mais peut aussi empêcher l'affichage correcte des auras sur les macros les utilisant."
L["Select how to highlight the button."] = "Sélectionnez comment mettre le bouton en surbrillance."
L["Select the aura type of this spell. This helps to look up the aura."] = "Sélectionnez le type d'aura du sort. Cela aide à rechercher l'aura."
L["Select the color to use for the buffs cast by other characters."] = "Sélectionnez la couleur à utiliser pour les buffs lancés par d'autres personnages."
L["Select the color to use for the buffs you cast."] = "Sélectionnez la couleur à utiliser pour les buffs lancés par votre personnage."
L["Select the color to use for the debuffs cast by other characters."] = "Sélectionnez la couleur à utiliser pour les debuffs lancés par d'autres personnages."
L["Select the color to use for the debuffs you cast."] = "Sélectionnez la couleur à utiliser pour les debuffs lancés par votre personnage."
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "Selectionnez les couleurs utilisées pour mettre les boutons d'actions en surbrillance. Elles sont choisies en fonction du type d'aura et du lanceur."
L["Select the font to be used to display both countdown and application count."] = "Sélectionnez la police utilisées pour afficher à la fois le compte à rebours et le nombre d'applications."
L["Select the remaining time threshold under which tenths of second are displayed."] = "Indiquez le seuil du temps restant au-dessous duquel les dixièmes de seconde sont affichés."
L["Select the spell to edit or to remove its specific settings. Spells with specific defaults are written in |cff77ffffcyan|r. Removed spells with specific defaults are written in |cff777777gray|r."] = "Sélecitonner le sort à éditer ou supprimer. Les sorts avec des valeurs par défaut sont indiqués en |cff77ffffcyan|r. Les sorts supprimés qui ont des réglages par défaut sont écrit en |cff777777gris|r."
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = "Sélectionnez où afficher le compte à rebours et le nombre de charges dans le bouton. Lorsqu'une seule valeur est affichée, le réglage \"position d'une valeur seule\" est utilisé."
L["Select where to place a single value."] = "Sélectionnez la position d'une valeur seule."
L["Select where to place the application count text when both values are shown."] = "Sélectionnezla position du nombre de charges quand les deux valeurs sont visibles."
L["Select where to place the countdown text when both values are shown."] = "Sélectionnez la position du compte à rebours quand les deux valeurs sont visibles."
L["Select which special value should be displayed."] = "Sélectionnez la valeur spéciale à afficher."
L["Self buff or debuff"] = "Buff ou débuff personnel"
L["Single value position"] = "Position d'une valeur seule"
L["Size of large text"] = "Taille du grand texte"
L["Size of small text"] = "Taille du petit texte"
L["Special"] = "Spécial"
L["Spell specific settings"] = "Réglages spécifiques aux sorts"
L["Spell to edit"] = "Sort à éditer"
L["Text Position"] = "Position des textes"
L["Text appearance"] = "Apparence du texte"
L["The large font is used to display countdowns."] = "La grande police est utilisée pour afficher les comptes à rebours."
L["The small font is used to display application count (and countdown when cooldown addons are loaded)."] = "La petite police est utilisée pour afficher le nombre d'applications (et le compte à rebours quand un addon de cooldown est chargé.)"
L["Top"] = "Haut"
L["Top left"] = "En haut à gauche"
L["Top right"] = "En haut à droite"
L["Unknown spell: %s"] = "Sort inconnu : %s"
L["Value to display"] = "Valeur à afficher"
L["Watch additional units"] = "Surveiller des unités supplémentaires"
L["focus"] = "Focalisation (focus)"
L["mouseover"] = "Unité sous le pointeur de la souris (mouseover)"

------------------------ deDE ------------------------
elseif locale == 'deDE' then
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["Add spell"] = "Zauber hinzufügen"
L["Application count position"] = "Zählerposition"
L["Application text color"] = "Textfarbe der Anwendung"
L["Aura type"] = "Aurentyp"
L["Auras to look up"] = "Zu suchende Auren"
L["Border highlight colors"] = "Randfarbe"
L["Bottom"] = "Unten"
L["Bottom left"] = "Unten Links"
L["Bottom right"] = "Unten Rechts"
L["Center"] = "Mitte"
L["Check to have a more accurate countdown display instead of default Blizzard rounding."] = "Überprüfung zur Anzeige mehrerer Cooldown als in den Blizzard Standarteinstellungen."
L["Check to hide the aura application count (charges or stacks)."] = "Markieren, um die Zählung der Aurenanwendungen zu verbergen (einzeln oder gestapelt)."
L["Check to hide the aura countdown."] = "Markieren, um den Countdown der Auren zu verbergen."
L["Check to hide the aura duration countdown."] = "Auswahl zum verstecken des Auracooldowns. "
L["Check to ignore buffs cast by other characters."] = "Markieren, um von anderen Charakteren gewirkte Buffs zu ignorieren."
L["Check to ignore debuffs cast by other characters."] = "Markieren, um von anderen Charakteren gewirkte Debuffs zu ignorieren."
L["Check to only show aura you applied. Uncheck to always show aura, even when applied by others. Leave grayed to use default settings."] = "Aktivieren zur Anzeige eigener Auras. Deaktivierung zur Anzeige der Aura unabhängig vom Caster. Für die Standarteinstellungen grau lassen."
L["Check to totally disable this spell. No border highlight nor text is displayed for disabled spells."] = "Aktivieren zum völligen Ignorieren dieses Zaubers. Weder der Hintergrund noch der Text werden bei deaktivieren Zaubern angezeigt."
L["Click to create specific settings for the spell."] = "Anklicken, um spezifische Einstellungen für Zauber zu erstellen."
L["Countdown position"] = "Position des Cooldowns"
L["Countdown text color"] = "Countdown-Textfarbe"
L["Decimal countdown threshold"] = "Nachkommastellen des Countdowns."
L["Disable"] = "Deaktivieren"
L["Do you really want to remove these aura specific settings ?"] = "Möchtest du wirklich diese Auren-spezifischen Einstellungen entfernen?"
L["Either OmniCC or CooldownCount is loaded so aura countdowns are displayed using small font at the bottom of action buttons."] = "OmniCC oder CooldownCount sind aktiviert. Auracooldown werden verkleinert am unteren Rand angezeigt. "
L["Enter additional aura names to check. This allows to check for alternative or equivalent auras. Some spells also apply auras that do not have the same name as the spell."] = "Einfügen alternativen Auranamen zum Aktivieren. Es erlaubt alternative oder spezielle Auren zum überprüfen. Einige Zaubersprüche haben einen anderen Namen als der zugehörige Zauber."
L["Enter one aura name per line. They are spell-checked ; errors will prevents you to validate."] = "Ein Auraname pro Linie. Diese werden überprüft und validiert. "
L["Enter the name of the spell for which you want to add specific settings. Non-existent spell or item names are rejected."] = "Eingabe des Zaubernamens, für den spezifische Einstellungen vorgenommen werden sollen. Nicht existierende Zauber oder Items werden gelöscht. "
L["Font name"] = "Schriftartname"
L["Inline Aura"] = "Inline Aura"
L["Left"] = "Links"
L["My buffs"] = "Meine Buffs"
L["My debuffs"] = "Meine Debuffs"
L["New spell name"] = "Neuer Zaubername"
L["No application count"] = "Keine Zähler."
L["No countdown"] = "Kein Countdown"
L["Only my buffs"] = "Nur meine Buffs"
L["Only my debuffs"] = "Nur meine Debuffs"
L["Only show mine"] = "Nur meine zeigen"
L["Others' buffs"] = "Buffs anderer"
L["Others' debuffs"] = "Debuffs anderer"
L["Precise countdown"] = "Präziser Countdown"
L["Profiles"] = "Profile"
L["Remove spell"] = "Zauber entfernen"
L["Remove spell specific settings."] = "Zauber-spezifische Einstellungen entfernen."
L["Reset settings"] = "Rücksetzen der Einstellungen"
L["Reset settings to global defaults."] = "Rücksetzen der Einstellungen auf globale Grundeinstellungen"
L["Restore default settings of the selected spell."] = "Wiederherstellung der Standarteinstllungen des ausgewählten Zaubers."
L["Restore defaults"] = "Standarteinstellungen wiederherstellen. "
L["Right"] = "Rechts"
L["Select the aura type of this spell. This helps to look up the aura."] = "Auswahl des Auratyps des Zaubers. "
L["Select the color to use for the buffs cast by other characters."] = "Auswahl der Farbe für die gecasteten Buffs anderer Charaktere"
L["Select the color to use for the buffs you cast."] = "Auswahl der Farbe für die eigenen gecasteten Buffs"
L["Select the color to use for the debuffs cast by other characters."] = "Auswahl der Farbe für die gecasteten Debuffs anderer Charaktere"
L["Select the color to use for the debuffs you cast."] = "Farbe für die selbst gewirkten Debuffs auswählen."
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "Auswahl der Farbe zur Hervorhebung des Aktionsbuttons. Die Auswahl basiert auf Zuberer und Auratype"
L["Select the font to be used to display both countdown and application count."] = "Auswahl der Schriftart für den Countdown und Zähler."
L["Select the remaining time threshold under which tenths of second are displayed."] = "Auswahl des Grenzwert unter dem die Zeit angezeigt wird. "
L["Select the spell to edit or to remove its specific settings. Spells with specific defaults are written in |cff77ffffcyan|r. Removed spells with specific defaults are written in |cff777777gray|r."] = "Auswahl des Zaubers zum editieren oder löschen spezifischer Einstellungen. Zauber mit spezifischen Einstellungen sind in |cff77ffffcyan|r geschrieben. Gelöschte Zauber mit spezifischen Einstellungen sind in |cff777777gray|r geschrieben."
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = "Auswahl der Anzeigeposition, wo der Cooldown und der Zähler angezeigt werden. Wenn nur ein Wert angezeigt wird, wird die Primärposition benutzt. "
L["Select where to place a single value."] = "Wähle aus, wo ein einzelner Wert plaziert werden soll."
L["Select where to place the application count text when both values are shown."] = "Auswahl der Position des Zählers, wenn beide anderer Plätze belegt sind. "
L["Select where to place the countdown text when both values are shown."] = "Auswahl des Textposition des Cooldowns, wenn beide anderen Positionen belegt sind. "
L["Single value position"] = "Position einzelner Werte "
L["Size of large text"] = "Große Textgröße"
L["Size of small text"] = "Kleine Textgröße"
L["Spell specific settings"] = "Zauber-spezifische Einstellungen"
L["Spell to edit"] = "Zu bearbeitender Zauber"
L["Text Position"] = "Textposition"
L["Text appearance"] = "Textdarstellung"
L["The large font is used to display countdowns."] = "Die große Schrift wird zur Anzeige von Countdowns verwendet."
L["The small font is used to display application count (and countdown when cooldown addons are loaded)."] = "Die verkleinerte Schriftart wird zur Anzeige des Zählers benutzt (und Cooldowns, wenn ein Cooldownaddon geladen ist)"
L["Top"] = "Oben"
L["Top left"] = "Oben links"
L["Top right"] = "Oben rechts"
L["Unknown spell: %s"] = "Unbekannter Zauber: %s"

------------------------ esMX ------------------------
-- no translation

------------------------ ruRU ------------------------
elseif locale == 'ruRU' then
L["%dh"] = "%dч"
L["%dm"] = "%dм"
L["Add spell"] = "Добавить заклинание"
L["Aura type"] = "Тип ауры"
L["Auras to look up"] = "Отслеживаемые ауры"
L["Check to hide the aura application count (charges or stacks)."] = "Скрывать количество стаков/зарядов ауры"
L["Check to ignore buffs cast by other characters."] = "Игнорировать баффы, накладываемые другими игроками."
L["Check to ignore debuffs cast by other characters."] = "Игнорировать дебаффы, накладываемые другими игроками."
L["Check to only show aura you applied. Uncheck to always show aura, even when applied by others. Leave grayed to use default settings."] = "Отметьте, чтобы показывать только ауру, наложеннуу вами. Снимите отметку, чтобы всегда показывать ауру, даже если она была наложена другими игроками."
L["Click to create specific settings for the spell."] = "Кликните, чтобы создать настройки для этого заклинания."
L["Disable"] = "Отключить"
L["Do you really want to remove these aura specific settings ?"] = "Вы действительно хотите удалить настройки этой ауры ?"
L["Font name"] = "Название шрифта"
L["Inline Aura"] = "Inline Aura"
L["My buffs"] = "Мои баффы"
L["My debuffs"] = "Мои дебаффы"
L["New spell name"] = "Название нового заклинания"
L["Only my buffs"] = "Только мои баффы"
L["Only my debuffs"] = "Только мои дебаффы"
L["Only show mine"] = "Отображать только моё"
L["Others' buffs"] = "Баффы других игроков"
L["Others' debuffs"] = "Дебаффы других игроков"
L["Profiles"] = "Профили"
L["Remove spell"] = "Убрать заклинание"
L["Remove spell specific settings."] = "Удалить настройки заклинания."
L["Select the aura type of this spell. This helps to look up the aura."] = "Выбрать тип ауры для этого заклинания."
L["Select the color to use for the buffs cast by other characters."] = "Выбрать цвет, используемый для баффов, накладываемых другими игроками."
L["Select the color to use for the buffs you cast."] = "Выбрать цвет, используемый для баффов, накладываемых вами."
L["Select the color to use for the debuffs cast by other characters."] = "Выбрать цвет, используемый для дебаффов, накладываемых другими игроками."
L["Select the color to use for the debuffs you cast."] = "Выбрать цвет, используемый для дебаффов, накладываемых вами."
L["Size of large text"] = "Размер большого текста"
L["Size of small text"] = "Размер маленького текста"
L["Spell specific settings"] = "Настройки заклинания"
L["Spell to edit"] = "Изменяемое заклинание"
L["Text appearance"] = "Внешний вид текста"
L["Unknown spell: %s"] = "Неизвестное заклинание: %s"

------------------------ esES ------------------------
elseif locale == 'esES' then
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["Add spell"] = "Añadir hechizo"
L["Aura type"] = "Tipo de aura"
L["Bottom"] = "Abajo"
L["Click to create specific settings for the spell."] = "Click para crear ajustes específicos para el hechizo."
L["Disable"] = "Desactivado"
L["Do you really want to remove these aura specific settings ?"] = "¿Quieres eliminar realmente los ajustes específicos de éste aura?"
L["Font name"] = "Nombre de la fuente"
L["My buffs"] = "Mis buffs"
L["My debuffs"] = "Mis debuffs"
L["New spell name"] = "Nuevo nombre de hechizo"
L["Only my buffs"] = "Solo mis buffs"
L["Only my debuffs"] = "Solo mis debuffs"
L["Others' buffs"] = "Otros buffs"
L["Others' debuffs"] = "Otros debuffs"
L["Profiles"] = "Perfiles"
L["Remove spell"] = "Eliminar hechizo"
L["Remove spell specific settings."] = "Eliminar ajustes específicos del hechizo."
L["Restore default settings of the selected spell."] = "Restaurar ajustes por defecto del hechizo seleccionado."
L["Restore defaults"] = "Restaurar por defecto"
L["Select the color to use for the buffs cast by other characters."] = "Selecciona el color a usar para buffs casteados por otros personajes."
L["Select the color to use for the buffs you cast."] = "Selecciona el color a usar para buffs casteados por ti."
L["Select the color to use for the debuffs cast by other characters."] = "Selecciona el color a usar para debuffs casteados por otros personajes."
L["Select the color to use for the debuffs you cast."] = "Selecciona el color a usar para debuffs casteados por ti."
L["Spell specific settings"] = "Ajustes específicos de hechizo"
L["Spell to edit"] = "Hechizo a editar"
L["Text appearance"] = "Apariencia del texto"
L["Top"] = "Arriba"
L["Unknown spell: %s"] = "Hechizo desconocido: %s"

------------------------ zhTW ------------------------
elseif locale == 'zhTW' then
L["%dh"] = "%d小時"
L["%dm"] = "%d分"
L["Add spell"] = "新增法術"
L["Application count position"] = "疊加計數位置"
L["Application text color"] = "疊加文字顏色"
L["Aura type"] = "光環類型"
L["Auras to look up"] = "光環查看"
L["Border highlight colors"] = "邊緣高亮顏色"
L["Bottom"] = "底部"
L["Bottom left"] = "左下"
L["Bottom right"] = "右下"
L["Center"] = "中央"
L["Check to have a more accurate countdown display instead of default Blizzard rounding."] = "檢查有一個更準確的倒計時顯示，而不是默認的暴雪四捨五入。" -- Needs review
L["Check to hide the aura application count (charges or stacks)."] = "隱藏光環疊加計數(衝能或堆疊)"
L["Check to hide the aura countdown."] = "隱藏光環倒數計時"
L["Check to hide the aura duration countdown."] = "隱藏光環期間冷卻"
L["Check to ignore buffs cast by other characters."] = "忽略其他玩家施放的增益法術"
L["Check to ignore debuffs cast by other characters."] = "忽略其他玩家施放的減益法術"
L["Check to only show aura you applied. Uncheck to always show aura, even when applied by others. Leave grayed to use default settings."] = "檢查只顯示您應用的氣氛。取消選中始終顯示的光環，甚至在其他人使用。給灰色使用默認設置。" -- Needs review
L["Check to totally disable this spell. No border highlight nor text is displayed for disabled spells."] = "檢查完全停用此法術。沒有邊框突出顯示的文本，也為停用法術。" -- Needs review
L["Click to create specific settings for the spell."] = "新建特殊設定的法術"
L["Countdown position"] = "冷卻位置"
L["Countdown text color"] = "冷卻文字顏色"
L["Decimal countdown threshold"] = "小數冷卻門檻"
L["Disable"] = "停用"
L["Do you really want to remove these aura specific settings ?"] = "你確定要刪除這些光環的特殊設定?"
L["Enter additional aura names to check. This allows to check for alternative or equivalent auras. Some spells also apply auras that do not have the same name as the spell."] = "輸入其他光環名稱來檢查。這使得檢查替代或同等學歷光環。也適用於一些魔法光環不具有相同的名稱的拼寫。" -- Needs review
L["Enter one aura name per line. They are spell-checked ; errors will prevents you to validate."] = "輸入一個名稱，每行的光環。他們是拼寫檢查;錯誤將阻止您驗證。" -- Needs review
L["Enter the name of the spell for which you want to add specific settings. Non-existent spell or item names are rejected."] = "輸入的名稱拼寫您要添加特定的設置。不存在的法術或項目名稱被拒絕。" -- Needs review
L["Font name"] = "字型名字"
L["Inline Aura"] = "Inline Aura"
L["Left"] = "左"
L["My buffs"] = "我的增益法術"
L["My debuffs"] = "我的減益法術"
L["New spell name"] = "新建法術名稱"
L["No application count"] = "無疊加計數"
L["No countdown"] = "無冷卻"
L["Only my buffs"] = "僅我的增益法術"
L["Only my debuffs"] = "僅我的減益法術"
L["Only show mine"] = "僅顯示我的"
L["Others' buffs"] = "別人的增益法術"
L["Others' debuffs"] = "別人的減益法術"
L["Precise countdown"] = "精確冷卻"
L["Profiles"] = "設定檔"
L["Remove spell"] = "移除法術"
L["Remove spell specific settings."] = "移除法術特效設定"
L["Reset settings"] = "重置設定"
L["Reset settings to global defaults."] = "重置設定通用預設值"
L["Restore default settings of the selected spell."] = "恢復法術預設值的設定"
L["Restore defaults"] = "恢復預設值"
L["Right"] = "右"
L["Select the color to use for the buffs cast by other characters."] = "選擇其他玩家施放的增益法術顏色"
L["Select the color to use for the buffs you cast."] = "選擇你施放的增益法術顏色"
L["Select the color to use for the debuffs cast by other characters."] = "選擇其他玩家施放的減益法術顏色"
L["Select the color to use for the debuffs you cast."] = "選擇你施放的減益法術顏色"
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "選擇顏色用於強調動作按鈕。有選擇的基礎上的光環類型和連鑄機。" -- Needs review
L["Select the font to be used to display both countdown and application count."] = "選擇用來顯示冷卻&疊加計數的字型"
L["Select the spell to edit or to remove its specific settings. Spells with specific defaults are written in |cff77ffffcyan|r. Removed spells with specific defaults are written in |cff777777gray|r."] = "選擇拼寫編輯或刪除其特定的設置。法術具體違約是用青色。刪除與特定的法術默認是用灰色" -- Needs review
L["Single value position"] = "單個值數位置"
L["Size of large text"] = "大文字尺寸"
L["Size of small text"] = "小文字尺寸"
L["Spell specific settings"] = "法術特定設定"
L["Spell to edit"] = "法術編輯"
L["Text Position"] = "文字位置"
L["Text appearance"] = "文字外觀"
L["Top"] = "頂部"
L["Top left"] = "左上"
L["Top right"] = "右下"
L["Unknown spell: %s"] = "未知法術: %s"

------------------------ zhCN ------------------------
elseif locale == 'zhCN' then
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["Add spell"] = "添加法术"
L["Application text color"] = "叠加文本颜色"
L["Aura type"] = "光环类型"
L["Auras to look up"] = "光环查看"
L["Border highlight colors"] = "边框高亮颜色"
L["Bottom"] = "底部"
L["Check to have a more accurate countdown display instead of default Blizzard rounding."] = "用更准确的倒计时显示来替代暴雪默认的四舍五入"
L["Check to hide the aura application count (charges or stacks)."] = "隐藏光环叠加计数(充能或堆叠)"
L["Check to hide the aura countdown."] = "隐藏光环倒计时"
L["Check to ignore buffs cast by other characters."] = "忽略其他玩家施放的增益法术"
L["Check to ignore debuffs cast by other characters."] = "忽略其他玩家施放的减益法术"
L["Check to only show aura you applied. Uncheck to always show aura, even when applied by others. Leave grayed to use default settings."] = "选中仅显示应用于你的光圈.未选中始终显示光圈,即使应用在别人.留灰为使用默认设置"
L["Check to totally disable this spell. No border highlight nor text is displayed for disabled spells."] = "此法术完全禁用.没有边框高亮和文本显示"
L["Click to create specific settings for the spell."] = "点击创建法术特殊设置"
L["Countdown text color"] = "倒计时文本颜色"
L["Disable"] = "禁用"
L["Do you really want to remove these aura specific settings ?"] = "您确定要删除这些光环的特殊设置?"
L["Either OmniCC or CooldownCount is loaded so aura countdowns are displayed using small font at the bottom of action buttons."] = "加载OmniCC或CooldownCount时,光圈倒计时用小字体显示在动作条按钮底部"
L["Enter additional aura names to check. This allows to check for alternative or equivalent auras. Some spells also apply auras that do not have the same name as the spell."] = "键入其他的光圈名称,允许检查替代或等同的光圈.使一些法术可以应用光圈在名称不同的法术上"
L["Font name"] = "字体"
L["Inline Aura"] = "Inline Aura"
L["My buffs"] = "我的增益法术"
L["My debuffs"] = "我的减益法术"
L["New spell name"] = "新法术名称"
L["No application count"] = "无叠加计数"
L["No countdown"] = "无倒计时"
L["Only my buffs"] = "仅我的增益法术"
L["Only my debuffs"] = "仅我的减益法术"
L["Only show mine"] = "只显示自己的"
L["Others' buffs"] = "别人的增益法术"
L["Others' debuffs"] = "别人的减益法术"
L["Precise countdown"] = "精确倒计时"
L["Profiles"] = "配置文件"
L["Remove spell"] = "移除法术"
L["Remove spell specific settings."] = "移除法术特殊设置"
L["Restore default settings of the selected spell."] = "恢复已选择法术的默认设置。"
L["Restore defaults"] = "恢复默认"
L["Select the aura type of this spell. This helps to look up the aura."] = "为法术选择光圈类型.有助于光圈查看"
L["Select the color to use for the buffs cast by other characters."] = "选择其他玩家施放的增益法术颜色"
L["Select the color to use for the buffs you cast."] = "选择你施放的增益法术颜色"
L["Select the color to use for the debuffs cast by other characters."] = "选择其他玩家施放的减益法术颜色"
L["Select the color to use for the debuffs you cast."] = "选择你施放的减益法术颜色"
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "选择用来高亮动作条按钮的颜色.这些选择以光环类型和施法者为基础."
L["Select the font to be used to display both countdown and application count."] = "选择用来显示倒计时和叠加计数的字体"
L["Size of large text"] = "大文本尺寸"
L["Size of small text"] = "小文本尺寸"
L["Spell specific settings"] = "特定法术设置"
L["Spell to edit"] = "法术编辑"
L["Text appearance"] = "文本外观"
L["The large font is used to display countdowns."] = "大字体用来显示倒计时"
L["The small font is used to display application count (and countdown when cooldown addons are loaded)."] = "小字体用来显示倒计时(当加载冷却计时插件时)和叠加计数"
L["Top"] = "顶部"
L["Unknown spell: %s"] = "未知法术: %s"

------------------------ koKR ------------------------
elseif locale == 'koKR' then
L["%dh"] = "%dh"
L["%dm"] = "%dm"
L["Add spell"] = "주문 추가"
L["Application count position"] = "효과 카운트 위치"
L["Application text color"] = "효과 글자색"
L["Aura type"] = "오라 형태"
L["Auras to look up"] = "찾을 오라"
L["Border highlight colors"] = "테두리 강조색"
L["Bottom"] = "아래쪽"
L["Bottom left"] = "왼쪽 아래"
L["Bottom right"] = "오른쪽 아래"
L["Center"] = "가운데"
L["Check to have a more accurate countdown display instead of default Blizzard rounding."] = "기본 블리자드 어림수 대신 더 정확한 카운트다운을 표시하려면 체크합니다."
L["Check to hide the aura application count (charges or stacks)."] = "오라 효과 카운트 (중첩이나 사용 여부)을(를) 숨기려면 체크."
L["Check to hide the aura countdown."] = "오라 카운트 다운을 숨기려면 체크."
L["Check to hide the aura duration countdown."] = "오라 지속시간 카운트다운을 숨기려면 체크."
L["Check to ignore buffs cast by other characters."] = "다른 캐릭터가 시전한 강화 효과를 무시하려면 체크."
L["Check to ignore debuffs cast by other characters."] = "다른 캐릭터가 시전한 약화 효과를 무시하려면 체크."
L["Check to only show aura you applied. Uncheck to always show aura, even when applied by others. Leave grayed to use default settings."] = "적용된 효과중 표시하고 싶은 것을 선택합니다. 선택하지 않으면 모든 효과에 대하여 표시합니다. "
L["Check to totally disable this spell. No border highlight nor text is displayed for disabled spells."] = "현재 주문을 사용하지 않습니다. 사용하지 않는 주문은 화면에 표시되지 않습니다."
L["Click to create specific settings for the spell."] = "클릭하면 주문을 추가합니다."
L["Countdown position"] = "카운트다운 위치"
L["Countdown text color"] = "카운트다운 글자색"
L["Decimal countdown threshold"] = "십진 카운트 한계" -- Needs review
L["Disable"] = "사용 안함"
L["Do you really want to remove these aura specific settings ?"] = "정말로 이 오라 특정 설정을 삭제하시겠습니까?"
L["Either OmniCC or CooldownCount is loaded so aura countdowns are displayed using small font at the bottom of action buttons."] = "OmniCC든 CooldownCount든 행동 단축 버튼 아래쪽에 작은 글꼴로 표시되는 오라 카운트다운으로 로드됩니다."
L["Enter additional aura names to check. This allows to check for alternative or equivalent auras. Some spells also apply auras that do not have the same name as the spell."] = "추가된 효과의 이름을 입력하십시오. 이것은 동일한 효과의 다른 오라를 사용가능하게 합니다. 혹여 같은 이름의 다른 주문이 적용될 수도 있습니다."
L["Enter one aura name per line. They are spell-checked ; errors will prevents you to validate."] = "효과 이름을 입력하세요. 직업 주문으로 선택되었습니다. 에러가 발생하면 거부할 것입니다."
L["Enter the name of the spell for which you want to add specific settings. Non-existent spell or item names are rejected."] = "원하는 주문의 이름을 입력하세요. 존재하지 않는 주문이나 아이템의 이름은 거부합니다."
L["Font name"] = "글꼴 이름"
L["Inline Aura"] = "Inline Aura"
L["Left"] = "왼쪽"
L["My buffs"] = "내 강화 효과"
L["My debuffs"] = "내 약화 효과"
L["New spell name"] = "새로운 주문 이름"
L["No application count"] = "효과 카운트 안 함"
L["No countdown"] = "카운트다운 안 함"
L["Only my buffs"] = "내 강화 효과만"
L["Only my debuffs"] = "내 약화 효과만"
L["Only show mine"] = "내 것만"
L["Others' buffs"] = "다른 플레이어의 강화 효과"
L["Others' debuffs"] = "다른 플레이어의 약화 효과"
L["Precise countdown"] = "정밀한 카운트다운"
L["Profiles"] = "프로필"
L["Remove spell"] = "주문 제거"
L["Remove spell specific settings."] = "주문 특정 설정 제거."
L["Reset settings"] = "초기화 설정"
L["Reset settings to global defaults."] = "기본값으로 재설정"
L["Restore default settings of the selected spell."] = "선택한 주문의 기본 설정값을 불러옵니다."
L["Restore defaults"] = "기본값 불러오기"
L["Right"] = "오른쪽"
L["Select the aura type of this spell. This helps to look up the aura."] = "이 주문의 오라 형태를 선택합니다. 이는 오라 찾기를 돕습니다."
L["Select the color to use for the buffs cast by other characters."] = "다른 캐릭터가 시전한 강화 효과에 사용할 색을 선택합니다."
L["Select the color to use for the buffs you cast."] = "당신이 시전한 강화 효과에 사용할 색을 선택합니다."
L["Select the color to use for the debuffs cast by other characters."] = "다른 캐릭터가 시전한 약화 효과에 사용할 색을 선택합니다."
L["Select the color to use for the debuffs you cast."] = "당신이 시전한 약화 효과에 사용할 색을 선택합니다."
L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "행동 단축 버튼 강조에 쓰일 색을 선택합니다. 오라 형태와 시전자를 기초로 선택됩니다."
L["Select the font to be used to display both countdown and application count."] = "카운트다운과 효과 카운트 표시에 쓰일 글꼴을 선택합니다."
L["Select the remaining time threshold under which tenths of second are displayed."] = "10초 이하를 표시할때 시간 한계 기억을 선택합니다." -- Needs review
L["Select the spell to edit or to remove its specific settings. Spells with specific defaults are written in |cff77ffffcyan|r. Removed spells with specific defaults are written in |cff777777gray|r."] = "변경하거나 삭제할 주문을 선택합니다. 직업별 주문은 기본적으로 |cff77ffff하늘색|r 입니다. 삭제된 주문은 |cff777777회색|r 입니다."
L["Select where to display countdown and application count in the button. When only one value is displayed, the \"single value position\" is used instead of the regular one."] = "효과 카운트나 카운트다운 글자가 표시될 곳을 선택합니다. 하나의 값만 표시되는 경우는 '값이 하나일 때 위치'에서 위치를 선택해야 합니다."
L["Select where to place a single value."] = "값이 하나만 보일 때 글자가 놓일 곳 선택"
L["Select where to place the application count text when both values are shown."] = "두 값이 보일 때 효과 카운트 글자가 놓일 곳 선택."
L["Select where to place the countdown text when both values are shown."] = "두 값이 보일 때 효과 카운트다운 글자가 놓일 곳 선택."
L["Single value position"] = "값이 하나일 때 위치"
L["Size of large text"] = "큰 글자 크기"
L["Size of small text"] = "작은 글자 크기"
L["Spell specific settings"] = "특정 주문 설정"
L["Spell to edit"] = "편집할 주문"
L["Text Position"] = "글자 위치"
L["Text appearance"] = "글자 겉모양"
L["The large font is used to display countdowns."] = "카운트다운 표시에 쓰이는 큰 글꼴."
L["The small font is used to display application count (and countdown when cooldown addons are loaded)."] = "작은 글자는 효과 카운트에 사용됩니다(재사용 대기시간 애드온이 있다면 재사용 대기시간도 포함)."
L["Top"] = "위쪽"
L["Top left"] = "왼쪽 위"
L["Top right"] = "오른쪽 위"
L["Unknown spell: %s"] = "알 수 없는 주문: %s"
end

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end
