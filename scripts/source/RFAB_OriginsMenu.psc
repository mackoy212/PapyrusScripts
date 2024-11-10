Scriptname RFAB_OriginsMenu extends Quest  

RFAB_Origin[] Property Altmer Auto
RFAB_Origin[] Property Argonian Auto
RFAB_Origin[] Property Bosmer Auto
RFAB_Origin[] Property Breton Auto
RFAB_Origin[] Property Dunmer Auto
RFAB_Origin[] Property Imperial Auto
RFAB_Origin[] Property Khajiit Auto
RFAB_Origin[] Property Nord Auto
RFAB_Origin[] Property Orsimer Auto
RFAB_Origin[] Property RedGuard Auto

string IniPath = "Data/SKSE/Plugins/[RFAB] Origins.ini"

Race[] Races
Actor Player

RFAB_Origin[] CurrentOrigins
int CurrentOriginID = 0

Event OnInit()
	Player = Game.GetPlayer()
	Races = new Race[10]
    Races[0] = Race.GetRace("HighElfRace")
    Races[1] = Race.GetRace("ArgonianRace")
    Races[2] = Race.GetRace("WoodElfRace")
    Races[3] = Race.GetRace("BretonRace")
    Races[4] = Race.GetRace("DarkElfRace")
    Races[5] = Race.GetRace("ImperialRace")
    Races[6] = Race.GetRace("KhajiitRace")
    Races[7] = Race.GetRace("NordRace")
    Races[8] = Race.GetRace("OrcRace")
    Races[9] = Race.GetRace("RedguardRace")
EndEvent

Function Open()
	RFAB_PapyrusFunctions.LookAtYourself()

	int RaceID = GetPlayerRaceID()
	CurrentOrigins = GetOriginsByID(RaceID)

	string[] OriginsNames = GetOriginsNames(CurrentOrigins)
	string[] OriginsImmersive = GetOriginsImmersive(CurrentOrigins)
	string[] OriginsBonus = GetOriginsBonus(CurrentOrigins)

	RegisterForModEvent("RFAB_ChangeOrigin", "OnOriginChange")
	int	ResultIndex = ShowMenu(OriginsNames, ReplaceArraysEnters(OriginsImmersive), ReplaceArraysEnters(OriginsBonus))
	if ResultIndex == -1
		CurrentOrigins[0].Choose()
	else
		CurrentOrigins[ResultIndex].Choose()
	endif
	RFAB_PapyrusFunctions.SetCameraDefaultSettings()
	UnregisterForAllModEvents()
EndFunction

Event OnOriginChange(string eventName, string strArg, float numArg, Form formArg)
	int iCurrentID = numArg as int
	if iCurrentID != CurrentOriginID
		RFAB_PapyrusFunctions.SetOutfitAndRefresh(Player, CurrentOrigins[iCurrentID].Equipment)
		CurrentOriginID = iCurrentID
	endif
EndEvent

string[] Function ReplaceArraysEnters(string[] asArray)
	string[] Result = Utility.CreateStringArray(asArray.Length)
	int i = 0
	while i < asArray.Length
		Result[i] = ReplaceEnters(asArray[i])
		i += 1
	endwhile
	return Result
EndFunction

string Function ReplaceEnters(string asString)
	return PapyrusUtil.StringJoin(StringUtil.Split(asString, "|"), "\n") 
EndFunction

string[] Function GetOriginsNames(RFAB_Origin[] Origins)
	string[] Names = Utility.CreateStringArray(Origins.Length)
	int i = 0 
	while i < Origins.Length
		Names[i] = Origins[i].GetName()
		i += 1
	endwhile
	return Names
EndFunction

string[] Function GetOriginsImmersive(RFAB_Origin[] Origins)
	string[] ImmersiveText = Utility.CreateStringArray(Origins.Length)
	int i = 0 
	while i < Origins.Length
		ImmersiveText[i] = PapyrusIniManipulator.PullStringFromIni(IniPath, Origins[i].GetName(), "Immersive Text")
		i += 1
	endwhile
	return ImmersiveText
EndFunction

string[] Function GetOriginsBonus(RFAB_Origin[] Origins)
	string[] BonusText = Utility.CreateStringArray(Origins.Length)
	int i = 0 
	while i < Origins.Length
		BonusText[i] = PapyrusIniManipulator.PullStringFromIni(IniPath, Origins[i].GetName(), "Bonus Text")
		i += 1
	endwhile
	return BonusText
EndFunction

int Function ShowMenu(string[] Buttons, string[] ImmersiveText, string[] BonusText)
	if UI.IsMenuOpen("CustomMenu")
		UI.CloseCustomMenu()
		return -1
	else
		UI.OpenCustomMenu("RFAB_OriginsMenu", 0)
		UI.Invoke("CustomMenu", "_root.RFAB_MessageBoxMC.InitMessageBox")
		UI.InvokeStringA("CustomMenu", "_root.RFAB_MessageBoxMC.SetButtons", Buttons)
		UI.InvokeStringA("CustomMenu", "_root.RFAB_MessageBoxMC.SetImmersiveText", ImmersiveText)
		UI.InvokeStringA("CustomMenu", "_root.RFAB_MessageBoxMC.SetBonusText", BonusText)
		RFAB_PapyrusFunctions.SetOutfitAndRefresh(Player, CurrentOrigins[0].Equipment)
		return GetMenuResult()
	endIf
EndFunction

int Function GetMenuResult()
	while UI.IsMenuOpen("CustomMenu") && UI.GetInt("CustomMenu", "_root.RFAB_MessageBoxMC.Status") < 9
		Utility.Wait(0.2)
	endWhile
	if UI.GetInt("CustomMenu", "_root.RFAB_MessageBoxMC.Status") == 9
		int result = UI.GetInt("CustomMenu", "_root.RFAB_MessageBoxMC.akCurrentFocusIndex")
		UI.CloseCustomMenu()
		return result
	else
		UI.CloseCustomMenu()
		return -1
	endif
EndFunction

int Function GetPlayerRaceID()
	Race PlayerRace = Player.GetRace()
	int i = 0
	while i < Races.Length
		if (PlayerRace == Races[i])
			return i 
		endif
		i += 1
	endwhile
	return -1
EndFunction

RFAB_Origin[] Function GetOriginsByID(int aiID)
	if (aiID == 0)
		return Altmer
	elseif (aiID == 1)
		return Argonian
	elseif (aiID == 2)
		return Bosmer
	elseif (aiID == 3)
		return Breton
	elseif (aiID == 4)
		return Dunmer
	elseif (aiID == 5)
		return Imperial
	elseif (aiID == 6)
		return Khajiit
	elseif (aiID == 7)
		return Nord
	elseif (aiID == 8)
		return Orsimer
	elseif (aiID == 9)
		return RedGuard
	endif
EndFunction
