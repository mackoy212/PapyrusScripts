Scriptname RFAB_Unlock extends Quest

Perk Property PerkNovice Auto
Perk Property PerkAdept Auto
Perk Property PerkMaster Auto
Spell Property ThiefStone Auto

RFAB_XP_Handler Property XPHandler Auto
UILIB_1 HUD

MiscObject Property Lockpick Auto
MiscObject Property SKey Auto

Sound Property SKeySound Auto
Sound Property LockpickSound Auto
Sound Property KeySound Auto

Int[] Property ExpForLock Auto
Int[] Property LockpickCount Auto
String[] Property LockNames Auto

Int KeyID = 63
Int SkeletonKeyID = 19
Int LockPickID = 76
String IconPath = "skyui/icons_item_psychosteve.swf"
String ArtefactIconPath = "Icons/Artefacts.swf"

Event OnInit()
    HUD = (self as Form) as UILIB_1
EndEvent

Function TryToUnlock(ObjectReference akTargetRef, Actor akActor)
	Key LockKey = akTargetRef.GetKey()

	If akActor.GetItemCount(LockKey) > 0
		Open(akTargetRef, akActor)
		KeySound.Play(akActor)
		if IsKhajiit(akActor)
			ShowKeyMessage("У " + akActor.GetDisplayName() + " есть " + GetKeyName(LockKey) + "!", true)
		else
			ShowKeyMessage("У меня есть " + GetKeyName(LockKey) + "!", true)
		endif
	elseif akActor.GetItemCount(SKey) > 0
		Open(akTargetRef, akActor)
		SKeySound.Play(akActor)

		if IsKhajiit(akActor)
			ShowSkeletonKeyMessage("У " + akActor.GetDisplayName() + " есть Скелетный Ключ!")
		else
			ShowSkeletonKeyMessage("У меня есть Скелетный Ключ!", true)
		endif
	else
		int LockLVL = akTargetRef.GetLockLevel()
		int NeededLockpickCount = GetNeededLockpickCount(LockLVL)

		If LockLVL <= 1 && ((akActor.HasPerk(PerkNovice)) || akActor.HasSpell(ThiefStone))
			LockUnlock(akTargetRef, akActor, NeededLockpickCount, 0)
		elseIf (LockLVL > 0 && LockLVL <= 25) && ((akActor.HasPerk(PerkNovice) && akActor.GetBaseAV("Lockpicking") >= 25) || akActor.HasSpell(ThiefStone))
			LockUnlock(akTargetRef, akActor, NeededLockpickCount, 1) 
		elseIf (LockLVL > 25 && LockLVL <= 50) && ((akActor.HasPerk(PerkAdept)) || akActor.HasSpell(ThiefStone))
			LockUnlock(akTargetRef, akActor, NeededLockpickCount, 2)
		elseIf (LockLVL > 50 && LockLVL <= 75) && ((akActor.HasPerk(PerkAdept) && akActor.GetBaseAV("Lockpicking") >= 75) || akActor.HasSpell(ThiefStone))
			LockUnlock(akTargetRef, akActor, NeededLockpickCount, 3)
		elseIf LockLVL > 75 && ((akActor.HasPerk(PerkMaster)) || akActor.HasSpell(ThiefStone))
			LockUnlock(akTargetRef, akActor, NeededLockpickCount, 4)
		else
			if IsKhajiit(akActor)
				ShowLockpickMessage(akActor.GetDisplayName() + " не может взломать этот замок.")
			else
				ShowLockpickMessage("Я не могу взломать этот замок.")
			endif
		endIf
	endif
EndFunction

function LockUnlock(ObjectReference akLockRef, Actor akActor, Int aiLockpickCount, Int aiLockLevel)
	if akActor.GetItemCount(Lockpick) >= aiLockpickCount
		Open(akLockRef, akActor)
		LockpickSound.Play(akActor)
		akActor.RemoveItem(Lockpick, aiLockpickCount, false, None)

		if IsXPObject(akLockRef.GetDisplayName())
			GiveExperienceForUnlock(ExpForLock[aiLockLevel])
		else
			if IsKhajiit(akActor)
				if akActor.GetActorBase().GetSex() == 0
					ShowLockpickMessage(akActor.GetDisplayName() + " смог взломать замок!", true)
				else
					ShowLockpickMessage(akActor.GetDisplayName() + " смогла взломать замок!", true)
				endif
			else
				ShowLockpickMessage("Мне удалось взломать замок!", true)
			endif
		endIf
	else
		string Prefix = "Мне"
		if IsKhajiit(akActor)
		    Prefix = akActor.GetDisplayName()
		endif
		if aiLockpickCount == 1
		    ShowLockpickMessage(Prefix + " нужна 1 отмычка.")
		elseif aiLockpickCount >= 2 && aiLockpickCount <= 4
		    ShowLockpickMessage(Prefix + " нужно " + aiLockpickCount + " отмычки.")
		else
		    ShowLockpickMessage(Prefix + " нужно " + aiLockpickCount + " отмычек.")
		endif
	endIf
endFunction

bool Function IsKhajiit(Actor akActor)
	return StringUtil.Find(akActor.GetRace().GetName(), "Каджит") != -1
EndFunction

string Function GetKeyName(Key akKey)
	string KeyName = akKey.GetName()
	string FirstWord = StringUtil.Split(KeyName, " ")[0]
	return RFAB_PapyrusFunctions.ToLowerCase(FirstWord) + StringUtil.Substring(KeyName, StringUtil.GetLength(FirstWord))
EndFunction

bool Function IsXPObject(string asObjectName)
	int i = 0
	while i < LockNames.Length
		if StringUtil.Find(asObjectName, LockNames[i]) != -1
			return true
		endif
		i += 1
	endwhile
	return false
EndFunction

int Function GetNeededLockpickCount(int LevelLock)
	if     LevelLock <= 1 
		return LockpickCount[0]
	elseif LevelLock <= 25
		return LockpickCount[1]
	elseif LevelLock <= 50
		return LockpickCount[2]
	elseif LevelLock <= 75
		return LockpickCount[3]
	else
		return LockpickCount[4]
	endIf
EndFunction

Function GiveExperienceForUnlock(int aiXP)
	int GainedXP = XPHandler.CalculateXP(aiXP)
	XPHandler.ModXP(GainedXP)
	HUD.ShowNotificationIcon("Замок взломан: " + GainedXP + " XP", IconPath, LockPickID, XPHandler.GetXPColor())
EndFunction

Function Open(ObjectReference akLockRef, Actor akActor)
	akLockRef.lock(False)
	akLockRef.Activate(akActor)	
EndFunction

;/
Function SendSteal(ObjectReference akLockRef, Actor akActor)
	if akLockRef.GetGoldValue() <= 0
		akActor.GetParentCell().GetFactionOwner().SendAssaultAlarm()
		akLockRef.GetFactionOwner().SendAssaultAlarm()
	else
		akLockRef.SendStealAlarm(akActor)
	endif
EndFunction
/;

Function ShowKeyMessage(string asMessage, bool abImportant = false)
	if abImportant || GetState() != "Waiting"
		GoToState("Waiting")
		HUD.ShowNotificationIcon(asMessage, IconPath, KeyID)
	endif
	Utility.Wait(2.0)
	GoToState("")
EndFunction

Function ShowSkeletonKeyMessage(string asMessage, bool abImportant = false)
	if abImportant || GetState() != "Waiting"
		GoToState("Waiting")
		HUD.ShowNotificationIcon(asMessage, ArtefactIconPath, SkeletonKeyID)
	endif
	Utility.Wait(2.0)
	GoToState("")
EndFunction

Function ShowLockpickMessage(string asMessage, bool abImportant = false)
	if abImportant || GetState() != "Waiting"
		GoToState("Waiting")
		HUD.ShowNotificationIcon(asMessage, IconPath, LockPickID)
	endif
	Utility.Wait(2.0)
	GoToState("")
EndFunction

State Waiting
	Function ShowKeyMessage(string asMessage, bool abImportant = false)
	EndFunction

	Function ShowSkeletonKeyMessage(string asMessage, bool abImportant = false)
	EndFunction

	Function ShowLockpickMessage(string asMessage, bool abImportant = false)
	EndFunction
EndState