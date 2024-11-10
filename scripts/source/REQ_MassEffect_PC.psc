Scriptname REQ_MassEffect_PC extends REQ_PlayerAlias
{This script is the master script for the mass effect. It controls the mass effect for the PC and also serves as a data storage for all NPC-clients.}

Bool updating = True

Spell Property MassEffect Auto
Perk Property MassPerk Auto
Formlist Property worn Auto
{an empty formlist, used to sort out multiple occurences of multi-slot equipment}

Perk[] Property ArcheryPerks Auto
float[] Property ArcheryFactors Auto

Perk[] Property BlockPerks Auto
float[] Property BlockFactors Auto

Perk[] Property HeavyPerks Auto
float[] Property HeavyFactors Auto

Perk[] Property LightPerks Auto
float[] Property LightFactors Auto

Perk[] Property OneHandedPerks Auto
float[] Property OneHandedFactors Auto

Perk[] Property TwoHandedPerks Auto
float[] Property TwoHandedFactors Auto

float[] Property RatiosArmor Auto Hidden
{
	0 = Light
	1 = Heavy
	2 = Cloth or None
	3 = Shield Light
	4 = Shield Heavy
	5 = Shield Cloth
}

float[] Property RatiosWeapon Auto Hidden
{
	0 = Fists
	1 = Swords
	2 = Daggers
	3 = War Axes
	4 = Maces
	5 = Greatswords
	6 = Battleaxes AND Warhammers
	7 = Bows
	8 = Staff
	9 = Crossbows
}

float Property Mass = 0.0 Auto Hidden
float Property Penalty = 0.0 Auto Hidden

bool IsNeedUpdate = false

Event ScriptInit(string eventName, string strArg, float numArg, Form sender)
	RatiosArmor = new float[6]
	RatiosWeapon = new float[10]
	RegisterForMenu("StatsMenu")
	REQ_AutoUpdater UpdateControl = GetOwningQuest().GetAlias(0) as REQ_AutoUpdater
	int index = UpdateControl.Scripts.find(self)
	updating = False
	UpdateControl.ShutdownReady[index] = False
	Update_Ratios()
	FullEvaluate()
	GoToState("")
EndEvent

Event ScriptShutDown(string eventName, string strArg, float numArg, Form sender)
	ResetValues()
	updating = True
	UnregisterForAllMenus()
	REQ_AutoUpdater UpdateControl = GetOwningQuest().GetAlias(0) as REQ_AutoUpdater
	int index = UpdateControl.Scripts.find(self)
	UpdateControl.ShutdownReady[index] = True
EndEvent

Event OnMenuClose(String MenuName)
	Update_Ratios()
	FullEvaluate()
EndEvent

Event OnPlayerLoadGame()
	RegisterForMenu("StatsMenu")
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
		FullEvaluate()
		GoToState("")
    endif
EndEvent

Event OnObjectEquipped(Form akObject, ObjectReference akReference)
	if (akObject as Armor || akObject as Weapon)
		GoToState("Busy")
		FullEvaluate()
		GoToState("")
	endif
EndEvent

Event OnObjectUnEquipped(Form akObject, ObjectReference akReference)
	if (akObject as Armor || akObject as Weapon)
		GoToState("Busy")
		FullEvaluate()
		GoToState("")
	endif
EndEvent

Function FullEvaluate()
	float fMass = 0.0
	float fPenalty = 0.0
	Form[] kEquipment = PO3_SKSEFunctions.AddAllEquippedItemsToArray(Player)
	int i = 0
	while (i < kEquipment.Length)
		Form kItem = kEquipment[i]
		Armor kArmor = kItem as Armor
		Weapon kWeapon = kItem as Weapon
		float fItemMass = kItem.GetWeight() / 100.0
		if kArmor
			int iType = kArmor.GetWeightClass()
			if kArmor.IsShield()
				iType += 3
			endif
			fPenalty += RatiosArmor[iType] * fItemMass
		elseif kWeapon
			int iType = kWeapon.GetWeaponType()
			fPenalty += RatiosWeapon[iType] * fItemMass
		endif
		fMass += fItemMass
		i += 1
	endwhile
	FullEvaluateValues(fMass, fPenalty)
EndFunction

Function FullEvaluateValues(float afMass, float afPenalty)
	float fPenaltyDifference = afPenalty - Penalty

	Player.ModActorValue("Mass", afMass - Mass)
	;Player.ModActorValue("Infamy", fPenaltyDifference)
	Player.ModActorValue("MovementNoiseMult", fPenaltyDifference)
	Player.ModActorValue("SpeedMult", 50.0 * -fPenaltyDifference)

	Mass = afMass
	Penalty = afPenalty
EndFunction

Function ResetValues()
	Player.ModActorValue("Mass", -Mass)
	;Player.ModActorValue("Infamy", -Penalty)
	Player.ModActorValue("MovementNoiseMult", -Penalty)
	Player.ModActorValue("SpeedMult", 50.0 * Penalty)
	Mass = 0.0
	Penalty = 0.0
EndFunction

Function Update_Ratios()
	float fLightRatio = CalculateRatio(LightPerks, LightFactors)
	RatiosArmor[0] = fLightRatio
	RatiosArmor[2] = fLightRatio

	float fHeavyRatio = CalculateRatio(HeavyPerks, HeavyFactors)
	RatiosArmor[1] = fHeavyRatio

	float fBlockRatio = CalculateRatio(BlockPerks, BlockFactors)
	RatiosArmor[3] = fBlockRatio
	RatiosArmor[4] = fBlockRatio
	RatiosArmor[5] = fBlockRatio		

	float fOneHandedRatio = CalculateRatio(OneHandedPerks, OneHandedFactors)
	RatiosWeapon[1] = fOneHandedRatio
	RatiosWeapon[2] = fOneHandedRatio
	RatiosWeapon[3] = fOneHandedRatio
	RatiosWeapon[4] = fOneHandedRatio
	RatiosWeapon[8] = fOneHandedRatio

	float fTwoHandedRatio = CalculateRatio(TwoHandedPerks, TwoHandedFactors)
	RatiosWeapon[5] = fTwoHandedRatio
	RatiosWeapon[6] = fTwoHandedRatio

	float fArcheryRatio = CalculateRatio(ArcheryPerks, ArcheryFactors)
	RatiosWeapon[7] = fArcheryRatio
	RatiosWeapon[9] = fArcheryRatio
	RatiosWeapon[0] = 0.0
EndFunction

float Function CalculateRatio(Perk[] akPerks, float[] afFactors)
	int i = 0
	float fRatio = 1.0
	while (i < akPerks.Length)
		fRatio -= (Player.HasPerk(akPerks[i]) as float) * afFactors[i]
		i += 1
	endwhile
	return Max(fRatio, 0.0)
EndFunction

float Function Max(float afValue1, float afValue2)
	if (afValue1 > afValue2)
		return afValue1
	endif
	return afValue2
EndFunction