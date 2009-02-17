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
	
--------------------------------------------------------------------------------
-- zhCN by aimless05
--------------------------------------------------------------------------------

elseif locale == 'zhCN' then

	L["Add spell"] = "添加技能"
	L["Application text color"] = "计数文本颜色"
	L["Aura to lookup"] = "光环查找"
	L["Aura type"] = "光环类型"
	L["Border colors"] = "边框颜色"
	L["Buff"] = "增益法术"
	L["Check to have a more accurate countdown display instead of default Blizzard rounding."] = "显示一个更准确的倒计时而非暴雪默认的四舍五入"
	L["Check to hide the aura application count (charges or stacks)."] = "隐藏光环计数(消耗或叠加)"
	L["Check to hide the aura countdown."] = "隐藏光环倒计时"
	L["Check to ignore buffs cast by other characters."] = "忽略其他玩家施放的增益法术"
	L["Check to ignore debuffs cast by other characters."] = "忽略其他玩家施放的减益法术"
	L["Countdown text color"] = "倒计时文本颜色"
	L["Debuff"] = "减益法术"
	L["%dh"] = "%dh"
	L["Disable"] = "禁用"
	L["%dm"] = "%dm"
	L["Do you really want to remove these aura specific settings ?"] = "你确定要删除这些光环的具体设置?"
	L["Font name"] = "字体名称"
	L["Inline Aura"] = "内嵌光环"
	L["My buffs"] = "我的增益法术"
	L["My debuffs"] = "我的减益法术"
	L["New spell name"] = "新技能名称"
	L["No application count"] = "不计数"
	L["No countdown"] = "不计时"
	L["One name per line"] = "每行一个名字"
	L["Only my buffs"] = "仅自己的增益法术"
	L["Only my debuffs"] = "仅自己的减益法术"
	L["Only show mine"] = "仅显示自己的"
	L["Others' buffs"] = "别人的增益法术"
	L["Others' debuffs"] = "别人的减益法术"
	L["Precise countdown"] = "精确倒计时"
	L["Profiles"] = "配置文件"
	L["Remove spell"] = "移除法术"
	L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "选择用来高亮动作条按钮的颜色.这些选择以光环类型和施法者为基础."
	L["Select the color to use for the buffs cast by other characters."] = "选择其他玩家施放的增益法术颜色"
	L["Select the color to use for the buffs you cast."] = "选择你施放的增益法术颜色"
	L["Select the color to use for the debuffs cast by other characters."] = "选择其他玩家施放的减益法术颜色"
	L["Select the color to use for the debuffs you cast."] = "选择你施放的减益法术颜色"
	L["Select the font to be used to display both countdown and application count."] = "选择用来显示倒计时和计数的字体"
	L["Size of large text"] = "大字体尺寸"
	L["Size of small text"] = "大字体尺寸"
	L["Spell specific settings"] = "特定法术设置"
	L["Spell to edit"] = "法术编辑"
	L["Text appearance"] = "文字外观"
	L["The large font is used to display aura countdowns unless OmniCC is loaded."] = "大字体显示倒计时,除非OmniCC已加载"
	L["The small font is used to display aura application count and also countdown when OmniCC is loaded."] = "小字体显示计数和倒计时当OmniCC已加载"
	L["Unknown spell: %s"] = "未知法术: %s"

--------------------------------------------------------------------------------
-- koKR by Sayclub
--------------------------------------------------------------------------------

elseif locale == 'koKR' then

	L["Add spell"] = "주문 추가"
	L["Application text color"] = "문자 색상 적용"
	L["Aura to lookup"] = "오오라 찾기"
	L["Aura type"] = "오오라 형태"
	L["Border colors"] = "테두리 색상"
	L["Buff"] = "강화효과"
	L["Check to have a more accurate countdown display instead of default Blizzard rounding."] = "기본 블리자드 대기시간 대신 더 정확한 재사용 대기시간을 적용합니다."
	L["Check to hide the aura application count (charges or stacks)."] = "지속 갯수(중첩이나 사용여부)를 숨깁니다."
	L["Check to hide the aura countdown."] = "지속 재사용 대기시간을 숨깁니다."
	L["Check to ignore buffs cast by other characters."] = "다른 캐릭터가 시전한 강화효과를 무시합니다."
	L["Check to ignore debuffs cast by other characters."] = "다른 캐릭터가 시전한 약화효과를 무시합니다."
	L["Countdown text color"] = "재사용 대기시간 문자 색상"
	L["Debuff"] = "약화효과"
	L["%dh"] = "%dh"
	L["Disable"] = "사용 안함"
	L["%dm"] = "%dm"
	L["Do you really want to remove these aura specific settings ?"] = "정말 당신은 이 오오라 설정을 삭제하시겠습니까?"
	L["Font name"] = "글꼴 이름"
	L["Inline Aura"] = "Inline Aura"
	L["My buffs"] = "나의 강화효과"
	L["My debuffs"] = "나의 약화효과"
	L["New spell name"] = "새로운 주문 이름"
	L["No application count"] = "갯수 적용 안함"
	L["No countdown"] = "재사용 대기시간 사용 안함"
	L["One name per line"] = "라인당 이름"
	L["Only my buffs"] = "나의 강화효과만"
	L["Only my debuffs"] = "나의 약화효과만"
	L["Only show mine"] = "나의 것만"
	L["Others' buffs"] = "다른 플레이어어 강화효과"
	L["Others' debuffs"] = "다른 플레이어의 약화효과"
	L["Precise countdown"] = "정확한 재사용 대기시간"
	L["Profiles"] = "Profiles"
	L["Remove spell"] = "주문 제거"
	L["Select the colors used to highlight the action button. There are selected based on aura type and caster."] = "액션 버튼을 강조할 색상을 선택합니다. 오오라의 형태와 시전에 따라 선택됩니다."
	L["Select the color to use for the buffs cast by other characters."] = "다른 캐릭터가 시전한 강화효과의 사용 색상은 선택합니다."
	L["Select the color to use for the buffs you cast."] = "당신이 시전한 강화효과의 사용 색상을 선택합니다."
	L["Select the color to use for the debuffs cast by other characters."] = "다른 캐릭터가 시전한 약화효과의 사용 색상은 선택합니다."
	L["Select the color to use for the debuffs you cast."] = "당신이 시전한 약화효과의 사용 색상을 선택합니다."
	L["Select the font to be used to display both countdown and application count."] = "재사용 대기시간과 갯수 적용에 사용될 폰트를 선택합니다."
	L["Size of large text"] = "큰 문자 크기"
	L["Size of small text"] = "작은 문자 크기"
	L["Spell specific settings"] = "특정 주문 설정"
	L["Spell to edit"] = "주문 편집"
	L["Text appearance"] = "문자 적용"
	L["The large font is used to display aura countdowns unless OmniCC is loaded."] = "OmniCC이 불려질때 큰 글꼴은 오오라 재사용 대기시간을 표시하는데 사용됩니다."
	L["The small font is used to display aura application count and also countdown when OmniCC is loaded."] = "OmniCC가 불려질때 작은 글꼴은 오오라 갯수와 재사용 대기시간을 표시하는데 사용됩니다"
	L["Unknown spell: %s"] = "알수없는 주문: %s"

end

