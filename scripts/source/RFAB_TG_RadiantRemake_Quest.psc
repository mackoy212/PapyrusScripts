Scriptname RFAB_TG_RadiantRemake_Quest extends Quest  

import PO3_SKSEFunctions

Faction[] Property HoldsCrimeFactions Auto
Location[] Property HoldLocations Auto
GlobalVariable[] Property HoldsTotalCrimeGold Auto
GlobalVariable Property NeededCrimeGoldForQuest Auto

Quest Property RadiantRemakeQuest Auto
{Ссылка на собственный квест}
Quest Property TGRShell Auto
{Квест, который управляет радиантом}
Quest Property TGREnablerHandler Auto
{Квест, который открывает трофеи}

Int[] HoldsPickpocketCrimeGold

Event OnInit()
    HoldsPickpocketCrimeGold = Utility.CreateIntArray(HoldsCrimeFactions.Length, 0)
EndEvent

Function StartQuestDisplay()
	RadiantRemakeQuest.SetCurrentStageID(10)
	SetObjectives()
EndFunction

Function SetObjectives()
	if !RadiantRemakeQuest.IsObjectiveDisplayed(140)
		RadiantRemakeQuest.SetObjectiveDisplayed(40)
	endif
	if !RadiantRemakeQuest.IsObjectiveDisplayed(130)
		RadiantRemakeQuest.SetObjectiveDisplayed(30)
	endif
	if !RadiantRemakeQuest.IsObjectiveDisplayed(120)
		RadiantRemakeQuest.SetObjectiveDisplayed(20)
	endif
	if !RadiantRemakeQuest.IsObjectiveDisplayed(110)
		RadiantRemakeQuest.SetObjectiveDisplayed(10)
	endif
EndFunction

bool WhiterunQuestStarted = False
bool WindhelmQuestStarted = False
bool MarkarthQuestStarted = False
bool SolitudeQuestStarted = False
bool Property QuestStarted = False Auto

Function TryToTryPushQuest()
	if !QuestStarted
    	if TryToPushQuest()
    		QuestStarted = True
    	endif
    endif
EndFunction

bool Function TryToPushQuest()
	if     WhiterunQuestStarted && !TGRShell.GetStageDone(160)
        TGRShell.SetStage(160)
        return true
	elseif WindhelmQuestStarted && !TGRShell.GetStageDone(180)
        TGRShell.SetStage(180)
        return true
	elseif MarkarthQuestStarted && !TGRShell.GetStageDone(190)
        TGRShell.SetStage(190)
        return true
	elseif SolitudeQuestStarted && !TGRShell.GetStageDone(170)
        TGRShell.SetStage(170)
        return true
    endif
    return false
EndFunction

;Начать квест провинции
Function StartHoldQuest(Faction akActorCrimeFaction)
    if     akActorCrimeFaction == HoldsCrimeFactions[0] ; Вайтран
    	WhiterunQuestStarted = True
		RadiantRemakeQuest.SetObjectiveDisplayed(10, false)
        RadiantRemakeQuest.SetObjectiveDisplayed(110)
    elseif akActorCrimeFaction == HoldsCrimeFactions[1] ; Истмарк
    	WindhelmQuestStarted = True
		RadiantRemakeQuest.SetObjectiveDisplayed(20, false)
        RadiantRemakeQuest.SetObjectiveDisplayed(120)
    elseif akActorCrimeFaction == HoldsCrimeFactions[2] ; Предел
    	MarkarthQuestStarted = True
		RadiantRemakeQuest.SetObjectiveDisplayed(30, false)
        RadiantRemakeQuest.SetObjectiveDisplayed(130)
    elseif akActorCrimeFaction == HoldsCrimeFactions[3] ; Хаафингар
    	SolitudeQuestStarted = True
		RadiantRemakeQuest.SetObjectiveDisplayed(40, false)
        RadiantRemakeQuest.SetObjectiveDisplayed(140)
    endif
    if RadiantRemakeQuest.GetCurrentStageID() == 10
    	TryToTryPushQuest()
   	endif
EndFunction

;Попробовать начать квест, если соблюдены условия
Function TryToStartHoldQuest(int akCurrentCrimeGold, Faction akActorCrimeFaction)
    if akCurrentCrimeGold >= NeededCrimeGoldForQuest.GetValue()
        StartHoldQuest(akActorCrimeFaction)
    endif
EndFunction

;Получить индекс криминальной фракции, если он есть в массиве
int Function GetCrimeFactionIndex(Faction akActorCrimeFaction)
	int Iteration = HoldsCrimeFactions.Length
	while Iteration
		Iteration -= 1
		if HoldsCrimeFactions[Iteration] == akActorCrimeFaction
			return Iteration
		endif
	endwhile
    return -1
EndFunction

int Function IsInHold(Actor akActor)
	int Iteration = HoldLocations.Length
	while Iteration
		Iteration -= 1
		if akActor.IsInLocation(HoldLocations[Iteration])
			return Iteration
		endif
	endwhile
    return -1
EndFunction

;Обновить кол-во украденного у фракции золота
int Function UpdateFactionCrimeGold(int akCrimeFactionIndex, int akPickpocketValue = 0)
	HoldsPickpocketCrimeGold[akCrimeFactionIndex] = HoldsPickpocketCrimeGold[akCrimeFactionIndex] + akPickpocketValue
	HoldsTotalCrimeGold[akCrimeFactionIndex].SetValueInt(HoldsCrimeFactions[akCrimeFactionIndex].GetStolenItemValueNoCrime() + HoldsPickpocketCrimeGold[akCrimeFactionIndex])
	UpdateObjectives(akCrimeFactionIndex)
	return HoldsTotalCrimeGold[akCrimeFactionIndex].GetValueInt() 
EndFunction

;Обновить украденное золото в меню квестов
Function UpdateObjectives(int akCrimeFactionIndex)
	RadiantRemakeQuest.UpdateCurrentInstanceGlobal(HoldsTotalCrimeGold[akCrimeFactionIndex])
EndFunction

int TrophyCount = 8
int EnabledTrophyCount = 0
Function TryToEnableTrophy()
	if !(EnabledTrophyCount == TrophyCount)
		EnabledTrophyCount += 1
		TGREnablerHandler.SetStage(EnabledTrophyCount * 10)
		EnabledTrophyCount += 1
		TGREnablerHandler.SetStage(EnabledTrophyCount * 10)
	endif
EndFunction