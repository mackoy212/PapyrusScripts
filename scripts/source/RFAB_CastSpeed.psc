Scriptname RFAB_CastSpeed extends ReferenceAlias  

Keyword Property ArmorHeavy Auto
Keyword Property ArmorLight Auto

Perk[] Property HeavyPerks Auto
float[] Property HeavyFactors Auto

Perk[] Property LightPerks Auto
float[] Property LightFactors Auto

float Property HeavyArmorStartPenalty = 2.0 Auto
float Property LightArmorStartPenalty = 2.0 Auto

float HeavyArmorPenalty = 0.0
float LightArmorPenalty = 0.0

float Property CastPenalty = 0.0 Auto Hidden

Actor Player

string CastSpeedAV = "AlterationSkillAdvance"

bool IsNeedUpdate = false

Event OnInit()
    Player = Game.GetPlayer()
    RegisterForMenu("StatsMenu")
    UpdateRatios()
    GoToState("")
EndEvent

Event OnMenuClose(string asMenuName)
	UpdateRatios()
	Evaluate()
EndEvent

Auto State Busy
	Event OnObjectEquipped(Form akObject, ObjectReference akReference)
		IsNeedUpdate = true
	EndEvent

	Event OnObjectUnEquipped(Form akObject, ObjectReference akReference)
		IsNeedUpdate = true
	EndEvent
EndState

Event OnBeginState()
    if IsNeedUpdate
    	IsNeedUpdate = false
		GoToState("Busy")
		Evaluate()
		GoToState("")
    endif
EndEvent

Event OnObjectEquipped(Form akObject, ObjectReference akReference)
	if (akObject as Armor || akObject as Spell)
		GoToState("Busy")
		Evaluate()
		GoToState("")
	endif
EndEvent

Event OnObjectUnEquipped(Form akObject, ObjectReference akReference)
	if (akObject as Armor || akObject as Spell)
		GoToState("Busy")
		Evaluate()
		GoToState("")
	endif
EndEvent

Function Evaluate()
	Spell kLeftSpell = Player.GetEquippedSpell(0)
	Spell kRightSpell = Player.GetEquippedSpell(1)

	float fCastTime = Max(kLeftSpell.GetCastTime(), kRightSpell.GetCastTime())

	if (fCastTime == 0.0)
		Player.ModActorValue(CastSpeedAV, CastPenalty)
		CastPenalty = 0.0
		return
	endif

	bool bIsHasHeavy = Player.WornHasKeyword(ArmorHeavy)
	bool bIsHasLight = Player.WornHasKeyword(ArmorLight)

	if (!bIsHasHeavy && !bIsHasLight)
		Player.ModActorValue(CastSpeedAV, CastPenalty)
		CastPenalty = 0.0		
		return
	endif

	float fNeededCastTime = fCastTime
	if bIsHasHeavy
		fNeededCastTime = Max(fCastTime * HeavyArmorPenalty, fCastTime)
	elseif bIsHasLight
		fNeededCastTime = Max(fCastTime * LightArmorPenalty, fCastTime)
	endif

	float fCastPenalty = (1 - (fCastTime / fNeededCastTime)) * 100
	float fCastPenaltyDifference = fCastPenalty - CastPenalty

	Player.ModActorValue(CastSpeedAV, -fCastPenaltyDifference)
	CastPenalty = fCastPenalty

	;debug.messagebox(fCastTime + " / " + (fCastTime / (1 - (fCastPenalty/100))))	
EndFunction

float Function Max(float afValue1, float afValue2)
	if afValue1 > afValue2
		return afValue1
	endif
	return afValue2
EndFunction

Function UpdateRatios()
	HeavyArmorPenalty = CalculateRatio(HeavyPerks, HeavyFactors, HeavyArmorStartPenalty)
	LightArmorPenalty = CalculateRatio(LightPerks, LightFactors, LightArmorStartPenalty)

	;debug.messagebox(HeavyArmorPenalty + " / " + LightArmorPenalty)	
EndFunction

float Function CalculateRatio(Perk[] akPerks, float[] afFactors, float afPenalty)
	int i = 0
	while (i < akPerks.Length)
		if Player.HasPerk(akPerks[i])
			afPenalty *= (1.0 - afFactors[i])
		endif
		i += 1
	endwhile
	return afPenalty
EndFunction