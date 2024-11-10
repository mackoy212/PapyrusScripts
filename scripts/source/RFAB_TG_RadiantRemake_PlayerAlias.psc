Scriptname RFAB_TG_RadiantRemake_PlayerAlias extends ReferenceAlias  

import PAPER_SKSEFunctions
import PO3_SKSEFunctions
import PO3_Events_Alias

Quest Property TGRShell Auto
{Квест, который управляет радиантом}
Quest Property RadiantRemakeQuest Auto
{Ссылка на собственный квест}
RFAB_TG_RadiantRemake_Quest Property RadiantRemakeScript Auto
Quest Property TG02B Auto
{Квест, после которого это задание будет отображаться}

Quest Property TGTQ01 Auto ; Маркарт
Quest Property TGTQ02 Auto ; Солитьюд
Quest Property TGTQ03 Auto ; Вайтран
Quest Property TGTQ04 Auto ; Виндхельм

Actor Property PlayerRef Auto
FormList Property BlankFormList Auto

Event OnInit()
    Ready()
    AddInventoryEventFilter(BlankFormList)
EndEvent

Event OnPlayerLoadGame()
    Ready()
EndEvent

Event OnQuestStageChange(Quest akQuest, Int aiNewStage)
    if aiNewStage == 30 ; Узнать от Делвина больше о Гильдии воров
        RadiantRemakeScript.StartQuestDisplay()
        RadiantRemakeScript.TryToTryPushQuest()
        RemoveAllInventoryEventFilters()
    endif
EndEvent

Function Ready()
    RegisterForMenu("ContainerMenu")
    RegisterForQuestStage(self as Alias, TG02B)
    RegisterForQuest(self as Alias, TGTQ01)
    RegisterForQuest(self as Alias, TGTQ02)
    RegisterForQuest(self as Alias, TGTQ03)
    RegisterForQuest(self as Alias, TGTQ04)
EndFunction

; Отключает "Поговорить с Делвином"
Event OnQuestStart(Quest akQuest)
    if akQuest == TGTQ03 ; Вайтран
        RadiantRemakeQuest.SetObjectiveCompleted(110)
    endif
    if akQuest == TGTQ04 ; Истмарк
        RadiantRemakeQuest.SetObjectiveCompleted(120)
    endif
    if akQuest == TGTQ01 ; Предел
        RadiantRemakeQuest.SetObjectiveCompleted(130)
    endif
    if akQuest == TGTQ02 ; Хаафингар
        RadiantRemakeQuest.SetObjectiveCompleted(140)
    endif
EndEvent

Event OnQuestStop(Quest akQuest)
    RadiantRemakeScript.TryToEnableTrophy()
    RadiantRemakeScript.QuestStarted = False
    RadiantRemakeScript.TryToTryPushQuest()
    if TGTQ01.IsCompleted() && TGTQ02.IsCompleted() && TGTQ03.IsCompleted() && TGTQ04.IsCompleted()
        RadiantRemakeQuest.SetStage(100)
        RadiantRemakeQuest.Stop()
    endif
EndEvent

; Симуляция карманной кражи 
;==============================================================================================================================================
Event OnMenuOpen(String MenuName)
    if PlayerRef.IsSneaking() && GetMenuContainer() as Actor
        GoToState("Pickpocket")
    endif
EndEvent

Event OnMenuClose(String MenuName)
    GoToState("")
EndEvent

State Pickpocket
    Event OnBatchItemsAdded(Form[] akBaseItems, Int[] aiItemCounts, ObjectReference[] akSourceContainers)
        Actor CurrentActor = akSourceContainers[0] as Actor
        if !CurrentActor
            return
        endif
        Faction ActorCrimeFaction = CurrentActor.GetCrimeFaction()
        int CrimeFactionIndex = RadiantRemakeScript.GetCrimeFactionIndex(ActorCrimeFaction)
        if CrimeFactionIndex == -1
            return
        endif

        int CurrentCrimeGold = CalculateCrimeGold(akBaseItems, aiItemCounts)
        int NewCrimeGold = RadiantRemakeScript.UpdateFactionCrimeGold(CrimeFactionIndex, CurrentCrimeGold)
        RadiantRemakeScript.TryToStartHoldQuest(NewCrimeGold, ActorCrimeFaction)
    EndEvent
EndState
; Возможная кража из открытого мира
;==============================================================================================================================================
Event OnBatchItemsAdded(Form[] akBaseItems, Int[] aiItemCounts, ObjectReference[] akSourceContainers)
    int HoldIndex = RadiantRemakeScript.IsInHold(PlayerRef)
    if HoldIndex != -1
        int NewCrimeGold = RadiantRemakeScript.UpdateFactionCrimeGold(HoldIndex)
        RadiantRemakeScript.TryToStartHoldQuest(NewCrimeGold, RadiantRemakeScript.HoldsCrimeFactions[HoldIndex])
    endif
EndEvent
;==============================================================================================================================================
; Вычисление украденого золота
int Function CalculateCrimeGold(Form[] akBaseItems, Int[] aiItemCounts)
    int Iteration = akBaseItems.Length
    int CurrentCrimeGold = 0
    while Iteration
        Iteration -=1
        if akBaseItems[Iteration] as Armor
            CurrentCrimeGold += akBaseItems[Iteration].GetGoldValue() + (akBaseItems[Iteration] as Armor).GetEnchantment().GetGoldValue() * aiItemCounts[Iteration]
        elseif akBaseItems[Iteration] as Weapon 
            CurrentCrimeGold += akBaseItems[Iteration].GetGoldValue() + (akBaseItems[Iteration] as Weapon).GetEnchantmentValue() * aiItemCounts[Iteration]
        else
            CurrentCrimeGold += akBaseItems[Iteration].GetGoldValue() * aiItemCounts[Iteration]
        endif
    endwhile
    return CurrentCrimeGold
EndFunction