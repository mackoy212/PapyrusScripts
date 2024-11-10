Scriptname RFAB_PerksMenu extends SKI_ConfigBase  

Actor Property Player Auto

RFAB_XP_Handler Property XP Auto

Formlist Property CurrentPerks Auto

string[] Skills
string[] SkillsNames

string[] CustomSkillsFiles
string[] CustomSkillsNames

string[] Resists
string[] ResistsNames

int[] PerksIDs
int[] ResistsIDs

string CustomSkillsPath = "Data/NetScriptFramework/plugins"

Event OnConfigInit()	
	ModName = " RFAB Perks Menu"

	InitResists()
	InitSkills()
	InitCustomSkills()

	Pages = new string[1]
	Pages[0] = "Навыки и характеристики"
	Pages = PapyrusUtil.MergeStringArray(Pages, SkillsNames)
	Pages = PapyrusUtil.MergeStringArray(Pages, CustomSkillsNames)	
EndEvent

Event OnPageReset(string page)
	InitResists()
	InitSkills()
	InitCustomSkills()

	Pages = new string[1]
	Pages[0] = "Навыки и характеристики"
	Pages = PapyrusUtil.MergeStringArray(Pages, SkillsNames)
	Pages = PapyrusUtil.MergeStringArray(Pages, CustomSkillsNames)	

	int iSkillID = SkillsNames.Find(page)
	if (iSkillID != - 1)
		ShowSkill(Skills[iSkillID])
		return
	endif
	iSkillID = CustomSkillsNames.Find(page)
	if (iSkillID != - 1)
		ShowCustomSkill(CustomSkillsFiles[iSkillID])
		return
	endif
	ShowMain()
Endevent

Function ShowSkill(string asSkill)
	AddToggleOptionST("Skill_AddAllPerks", "Выбрать все навыки", false)
	AddToggleOptionST("Skill_RemoveAllPerks", "Убрать все навыки", false)
	AddInputOptionST("Skill_Value", SkillsNames[Skills.Find(asSkill)], Player.GetActorValue(asSkill) as int)
	AddEmptyOption()
	AddEmptyOption()
	AddEmptyOption()

	CurrentPerks.Revert()
	ActorValueInfo.GetActorValueInfoByName(asSkill).GetPerkTree(CurrentPerks, None, false, true)

	int iPerksCounts = CurrentPerks.GetSize()
	PerksIDs = Utility.CreateIntArray(iPerksCounts)

	int i = 0
	while (i < iPerksCounts)
		Perk kPerk = CurrentPerks.GetAt(i) as Perk
		PerksIDs[i] = AddToggleOption(kPerk.GetName(), Player.HasPerk(kPerk))
		i += 1
	endwhile
EndFunction

Function ShowCustomSkill(string asPath)
	AddToggleOptionST("Skill_AddAllPerks", "Выбрать все навыки", false)
	AddToggleOptionST("Skill_RemoveAllPerks", "Убрать все навыки", false)
	AddEmptyOption()
	AddEmptyOption()

	Form[] kPerks = GetFrameworkPerks(asPath)
	CurrentPerks.Revert()
	CurrentPerks.AddForms(kPerks)
	PerksIDs = Utility.CreateIntArray(kPerks.Length)

	int i = 0
	while (i < kPerks.Length)
		Perk kPerk = kPerks[i] as Perk
		PerksIDs[i] = AddToggleOption(kPerk.GetName(), Player.HasPerk(kPerk))
		i += 1
	endwhile
EndFunction

Form[] Function GetFrameworkPerks(string asPath)
	string sContent = MiscUtil.ReadFromFile(asPath)
	string[] sLines = PapyrusUtil.StringSplit(sContent, "\n")
	Form[] kPerks = new Form[128]

	int i = 1
	while (StringUtil.Find(sContent, "Node" + i) != -1)
		string sNextNode = "Node" + i

		string sFile = GetFrameworkValue(sLines, sNextNode + ".PerkFile")
		int iStart = StringUtil.Find(sFile, "\"") + 1
		int iEnd = StringUtil.Find(sFile, "\"", iStart)
		sFile = StringUtil.Substring(sFile, iStart, iEnd - 1)

		int iFormID = PO3_SKSEFunctions.StringToInt(GetFrameworkValue(sLines, sNextNode + ".PerkId"))

		kPerks[i - 1] = Game.GetFormFromFile(iFormID, sFile)
		i += 1
	endwhile
	return Utility.ResizeFormArray(kPerks, i - 1)
EndFunction

string Function GetFrameworkName(string asPath)
	string[] sLines = PapyrusUtil.StringSplit(MiscUtil.ReadFromFile(asPath), "\n")
	return GetFrameworkValue(sLines, "Name")
EndFunction

string Function GetFrameworkValue(string[] asLines, string asKey)
	string sSearched = asKey + " = " 
	int i = 0
	while (i < asLines.Length)
		int iStart = StringUtil.Find(asLines[i], sSearched)
		if (iStart != -1)
			return StringUtil.Substring(asLines[i], iStart + StringUtil.GetLength(sSearched))
		endif
		i += 1
	endwhile
EndFunction

Function ShowMain()
	SetCursorFillMode(LEFT_TO_RIGHT)
	AddHeaderOption("Основное")
	AddHeaderOption("")
	AddSliderOptionST("Main_PlayerLevel", "Уровень", Player.GetLevel())
	AddSliderOptionST("Main_PlayerPerks", "Очки навыков", Game.GetPerkPoints())
	AddSliderOptionST("Main_DragonSouls", "Души драконов", Player.GetActorValue("DragonSouls") as int)
	AddInputOptionST("Main_Experience", "Опыт", XP.PlayerXP.GetValueInt())
	SetCursorFillMode(TOP_TO_BOTTOM)	
	ShowActorValues("Здоровье", "Health", "HealRate", "HealRateMult")
	ShowActorValues("Магия", "Magicka", "MagickaRate", "MagickaRateMult")
	ShowActorValues("Выносливость","Stamina", "StaminaRate", "StaminaRateMult")
	SetCursorPosition(7)
	AddHeaderOption("Сопротивления")
	ShowResists()	
EndFunction

Function ShowActorValues(string asHeader, string asName, string asRate, string asRateMult)
	AddHeaderOption(asHeader)
	AddInputOptionST("Main_" + asName + "_Add", "Добавить", (Player.GetActorValue(asName) - Player.GetBaseActorValue(asName)) as int)
	AddInputOptionST("Main_" + asName + "_Base", "Базовое", Player.GetBaseActorValue(asName) as int)
	AddInputOptionST("Main_" + asName + "_BaseRegen", "Базовая регенерация", Player.GetActorValue(asRate))
	AddInputOptionST("Main_" + asName + "_PercentRegenBonus", "Процент бонусной регенерации", Player.GetActorValue(asRateMult) as int)	
EndFunction

Function ShowResists()
	int i = 0
	while (i < Resists.Length)
		ResistsIDs[i] = AddInputOption(ResistsNames[i], Player.GetActorValue(Resists[i]) as int)
		i += 1
	endwhile
EndFunction

; ====================================================

State Skill_AddAllPerks
	Event OnSelectST()
		SetToggleOptionValueST(true)
		int i = CurrentPerks.GetSize()
		while (i > 0)
			i -= 1
			Player.AddPerk(CurrentPerks.GetAt(i) as Perk)
		endwhile
		ForcePageReset()
	EndEvent
EndState

State Skill_RemoveAllPerks
	Event OnSelectST()
		SetToggleOptionValueST(true)
		int i = CurrentPerks.GetSize()
		while (i > 0)
			i -= 1
			Player.RemovePerk(CurrentPerks.GetAt(i) as Perk)
		endwhile
		ForcePageReset()
	EndEvent
EndState

State Skill_Value
	Event OnInputAcceptST(string asInput)
		string sActorValue = Skills[SkillsNames.Find(CurrentPage)]
		Player.SetActorValue(sActorValue, asInput as int)
		SetInputOptionValueST(Player.GetActorValue(sActorValue) as int)
	EndEvent
EndState

State Main_Experience
	Event OnInputAcceptST(string asInput)
		XP.ModXP(asInput as int - XP.PlayerXP.GetValueInt())
		SetInputOptionValueST(XP.PlayerXP.GetValueInt())
	EndEvent
EndState

State Main_DragonSouls
	Event OnSliderAcceptST(float afValue)
		int iValue = afValue as int
		Player.SetActorValue("DragonSouls", afValue)
		SetSliderOptionValueST(iValue)
	EndEvent
	Event OnSliderOpenST()
		int iValue = Player.GetActorValue("DragonSouls") as int
		SetSliderDialogStartValue(iValue)
		SetSliderDialogDefaultValue(iValue)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(1.0)
	EndEvent
EndState

State Main_PlayerPerks
	Event OnSliderAcceptST(float afValue)
		int iValue = afValue as int
		Game.SetPerkPoints(iValue)
		SetSliderOptionValueST(iValue)
	EndEvent
	Event OnSliderOpenST()
		int iValue = Game.GetPerkPoints()
		SetSliderDialogStartValue(iValue)
		SetSliderDialogDefaultValue(iValue)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(1.0)
	EndEvent
EndState

State Main_PlayerLevel
	Event OnSliderAcceptST(float afValue)
		int iValue = afValue as int
		Game.SetPlayerLevel(iValue)
		SetSliderOptionValueST(iValue)
	EndEvent
	Event OnSliderOpenST()
		int iValue = Player.GetLevel()
		SetSliderDialogStartValue(iValue)
		SetSliderDialogDefaultValue(iValue)
		SetSliderDialogRange(1.0, 100.0)
		SetSliderDialogInterval(1.0)
	EndEvent
EndState

State Main_Stamina_PercentRegenBonus
	Event OnInputAcceptST(string asInput)
		Player.SetActorValue("StaminaRateMult", asInput as int)
		SetInputOptionValueST(Player.GetActorValue("StaminaRateMult") as int)
	EndEvent
EndState

State Main_Magicka_PercentRegenBonus
	Event OnInputAcceptST(string asInput)
		Player.SetActorValue("MagickaRateMult", asInput as int)
		SetInputOptionValueST(Player.GetActorValue("MagickaRateMult") as int)
	EndEvent
EndState

State Main_Health_PercentRegenBonus
	Event OnInputAcceptST(string asInput)
		Player.SetActorValue("HealRateMult", asInput as int)
		SetInputOptionValueST(Player.GetActorValue("HealRateMult") as int)
	EndEvent
EndState

State Main_Stamina_BaseRegen
	Event OnInputAcceptST(string asInput)
		Player.SetActorValue("StaminaRate", asInput as float)
		SetInputOptionValueST(Player.GetActorValue("StaminaRate"))
	EndEvent
EndState

State Main_Magicka_BaseRegen
	Event OnInputAcceptST(string asInput)
		Player.SetActorValue("MagickaRate", asInput as float)
		SetInputOptionValueST(Player.GetActorValue("MagickaRate"))
	EndEvent
EndState

State Main_Health_BaseRegen
	Event OnInputAcceptST(string asInput)
		Player.SetActorValue("HealRate", asInput as float)
		SetInputOptionValueST(Player.GetActorValue("HealRate"))
	EndEvent
EndState

State Main_Stamina_Base
	Event OnInputAcceptST(string asInput)
		Player.SetActorValue("Stamina", asInput as int)
		SetInputOptionValueST(Player.GetBaseActorValue("Stamina") as int)
	EndEvent
EndState

State Main_Magicka_Base
	Event OnInputAcceptST(string asInput)
		Player.SetActorValue("Magicka", asInput as int)
		SetInputOptionValueST(Player.GetBaseActorValue("Magicka") as int)
	EndEvent
EndState

State Main_Health_Base
	Event OnInputAcceptST(string asInput)
		Player.SetActorValue("Health", asInput as int)
		SetInputOptionValueST(Player.GetBaseActorValue("Health") as int)
	EndEvent
EndState

State Main_Stamina_Add
	Event OnInputAcceptST(string asInput)
		ActorValueAdd("Stamina", asInput as int)
	EndEvent
EndState

State Main_Magicka_Add
	Event OnInputAcceptST(string asInput)
		ActorValueAdd("Magicka", asInput as int)
	EndEvent
EndState

State Main_Health_Add
	Event OnInputAcceptST(string asInput)
		ActorValueAdd("Health", asInput as int)
	EndEvent
EndState

Function ActorValueAdd(string asAV, int aiValue)
	Player.ModActorValue(asAV, aiValue - (Player.GetActorValue(asAV) - Player.GetBaseActorValue(asAV)) as int)
	SetInputOptionValueST((Player.GetActorValue(asAV) - Player.GetBaseActorValue(asAV)) as int)	
EndFunction

Event OnOptionInputAccept(int aiOption, string asInput)
	int iResistID = ResistsIDs.Find(aiOption)
	if (iResistID != -1)
		Player.ModActorValue(Resists[iResistID], (asInput as int) - Player.GetActorValue(Resists[iResistID]))
		SetInputOptionValue(aiOption, Player.GetActorValue(Resists[iResistID]) as int)
	endif
EndEvent

Event OnOptionSelect(int aiOption)
	int iPerkID = PerksIDs.Find(aiOption)
	if (iPerkID != -1)
		Perk kPerk = CurrentPerks.GetAt(iPerkID) as Perk
		bool bHasPerk = Player.HasPerk(kPerk)
		if (bHasPerk)
			Player.RemovePerk(kPerk)
		else
			Player.AddPerk(kPerk)
		endif
		SetToggleOptionValue(aiOption, !bHasPerk)
	endif
EndEvent

; ====================================================


Function InitSkills()
	Skills = new string[18]
	Skills[0]  = "Block"
	Skills[1]  = "HeavyArmor"
	Skills[2]  = "OneHanded"
	Skills[3]  = "Smithing"
	Skills[4]  = "TwoHanded"
	Skills[5]  = "Alteration"
	Skills[6]  = "Conjuration"
	Skills[7]  = "Destruction"
	Skills[8]  = "Enchanting"
	Skills[9]  = "Illusion"
	Skills[10] = "Restoration"
	Skills[11] = "Marksman"
	Skills[12] = "Alchemy"
	Skills[13] = "LightArmor"
	Skills[14] = "Lockpicking"
	Skills[15] = "Pickpocket"
	Skills[16] = "Sneak"
	Skills[17] = "Speechcraft"

	SkillsNames = new string[18]
	int i = 0
	while (i < Skills.Length)
		SkillsNames[i] = ActorValueInfo.GetActorValueInfoByName(Skills[i]).GetName()
		i += 1
	endwhile
EndFunction

Function InitCustomSkills()
	string[] sFiles = MiscUtil.FilesInFolder(CustomSkillsPath, ".txt")
	CustomSkillsFiles = Utility.CreateStringArray(sFiles.Length)

	int j = 0
	int i = 0
	while (i < sFiles.Length)
		if (StringUtil.Find(sFiles[i], "customskill") != -1)
			CustomSkillsFiles[j] = CustomSkillsPath + "/" + sFiles[i]
			j += 1
		endif
		i += 1
	endwhile

	CustomSkillsFiles = Utility.ResizeStringArray(CustomSkillsFiles, j)
	CustomSkillsNames = Utility.CreateStringArray(CustomSkillsFiles.Length)

	i = 0
	while (i < CustomSkillsFiles.Length)
		CustomSkillsNames[i] = GetFrameworkName(CustomSkillsFiles[i])
		i += 1
	endwhile
EndFunction

Function InitResists()
	Resists = new string[9]
	Resists[0] = "DamageResist"
	Resists[1] = "MagicResist"
	Resists[2] = "FireResist"
	Resists[3] = "FrostResist"
	Resists[4] = "ElectricResist"
	Resists[5] = "AbsorbChance"
	Resists[6] = "PoisonResist"
	Resists[7] = "DiseaseResist"
	Resists[8] = "SpeedMult"
	ResistsNames = new string[9]
	ResistsNames[0] = "Броня"
	ResistsNames[1] = "Сопротивление магии"
	ResistsNames[2] = "Сопротивление огню"
	ResistsNames[3] = "Сопротивление холоду"
	ResistsNames[4] = "Сопротивление молниям"
	ResistsNames[5] = "Поглощение"
	ResistsNames[6] = "Сопротивление ядам"
	ResistsNames[7] = "Сопротивление болезням"
	ResistsNames[8] = "Скорость"
	ResistsIDs = new int[9]
EndFunction