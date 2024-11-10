Scriptname RFAB_XP_Handler extends Quest

GlobalVariable Property PlayerXP Auto
Sound Property QuestCompletedSound Auto

Actor Property Player Auto

bool Property ShowLevelUp Auto
int[] Property Experience Auto Hidden

UIlib_1 UILib

string IconPath = "skyui/icons_item_psychosteve.swf"
int Icon_Book = 52
int Icon_Map = 58

Event OnInit()
    FillExperienceArray()

    Game.SetGameSettingFloat("fXPLevelUpMult", 0.0) ; Отключаем множитель уровня
    Game.SetPlayerLevel(0) 
	Game.SetGameSettingFloat("fXPLevelUpBase", Experience[0]) ; Выставляем опыт за первый уровень
	Game.SetPlayerLevel(1)
	; Изменение уровня игрока нужно для того, чтобы игра пересчитала нужное кол-во опыта для 1 уровня, иначе будет изначальное значение - 75

    UILib = (self as Form) as UIlib_1
EndEvent

Event OnKill(Actor akVictim)
	String VictimName = akVictim.GetDisplayName()
	int VictimLevel = akVictim.GetLevel()

	int GainedXP = JSONUtil.GetIntValue("BossList.json", VictimName, -1)
	if GainedXP == -1
		GainedXP = VictimLevel * JSONUtil.GetIntValue("RaceList.json", akVictim.GetRace().GetName())
	endif

	if GainedXP != 0
		GainedXP = CalculateXP(GainedXP)
		UILib.ShowNotification(VictimName + " (" + VictimLevel + " уровень): " + GainedXP + " XP", GetXPColor())
		ModXP(GainedXP)
	endif
EndEvent

Event OnBookRead()
	int BaseBookXP = JSONUtil.GetIntValue("RFAB_XP_Settings.json", "BaseBookXP")
	Int GainedXP = (Player.GetLevel() - 10) * 20 + BaseBookXP
	if GainedXP < 200
		GainedXP = 200
	endIf
	if GainedXP > 600
		GainedXP = 600
	endIf
	GainedXP = CalculateXP(GainedXP)

	UILib.ShowNotificationIcon("Книга навыка: " + GainedXP + " XP", IconPath, Icon_Book, GetXPColor())
	ModXP(GainedXP)
EndEvent

Event OnQuestComplete(Quest akQuest)
	string Path = "Data/SKSE/Plugins/StorageUtilData/Quests.ini"
	string Section = "Experience Count"

	string QuestName = akQuest.GetName()
	int GainedXP = CalculateXP(PapyrusIniManipulator.PullIntFromIni(Path, QuestName, "XP"))

	string IconInfo = PapyrusIniManipulator.PullStringFromIni(Path, QuestName, "Icon")
	string _IconPath = StringUtil.Split(IconInfo, " | ")[0]
	int _IconID = StringUtil.Split(IconInfo, " | ")[1] as int

	ModXP(GainedXP)

	UILib.ShowNotificationIcon(QuestName + ": " + GainedXP + " XP", _IconPath, _IconID, GetXPColor())
EndEvent

Function CustomReward(string asText, int aiXP)
	int GainedXP = CalculateXP(aiXP)
	ModXP(GainedXP)
	UILib.ShowNotificationIcon(asText + ": " + GainedXP + " XP", IconPath, Icon_Map, GetXPColor())
EndFunction

Function ModXP(int aiXP)
	PlayerXP.Mod(aiXP)
	VanilaXPGain(aiXP)
EndFunction

string Function GetXPColor()
	return JSONUtil.GetStringValue("RFAB_XP_Settings.json", "Notification Color")
EndFunction

UIlib_1 Function GetUI()
	return UILib
EndFunction

int function CalculateXP(Int GainedXP)
	return GainedXP - (GainedXP % 5)
endFunction

Function VanilaXPGain(int aiXPAmount)
	float _PlayerXP = Game.GetPlayerExperience() + aiXPAmount
	Game.SetPlayerExperience(_PlayerXP)
	if _PlayerXP >= Game.GetExperienceForLevel(Player.GetLevel()) && ShowLevelUp
		ShowLevelUp = false
		ShowLevelUp()
	endif
EndFunction

Function ShowLevelUp()
	UI.InvokeString("HUD Menu", "_global.QuestNotification.AnimLetter.ShowQuestUpdate", "Новый уровень")
	UI.InvokeString("HUD Menu", "_global.QuestNotification.Instance.LevelMeterBaseInstance.gotoAndPlay", "FadeIn")
	UI.InvokeFloat("HUD Menu", "_global.QuestNotification.Instance.LevelUpMeter.SetPercent", 85)
	UI.InvokeFloat("HUD Menu", "_global.QuestNotification.Instance.LevelUpMeter.SetTargetPercent", 100)
	UI.InvokeString("HUD Menu", "_global.QuestNotification.Instance.LevelMeterBaseInstance.LevelTextBaseInstance.levelValue.SetText", (Player.GetLevel() + 1))
	Utility.Wait(3.0)
	UI.InvokeString("HUD Menu", "_global.QuestNotification.Instance.LevelMeterBaseInstance.gotoAndPlay", "FadeOut")
EndFunction

Function FillExperienceArray()
	Experience = Utility.CreateIntArray(100)
	string Path = "Data/SKSE/Plugins/StorageUtilData/Experience.ini"
	string Section = "Experience Count"
	string[] Keys = PapyrusIniManipulator.GetIniData(1, Path, Section)

	int i = 0
	while i < Keys.Length
		Experience[i] = PapyrusIniManipulator.PullIntFromIni(Path, Section, Keys[i])
		i += 1
	endwhile
EndFunction