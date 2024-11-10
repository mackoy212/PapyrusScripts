Scriptname RFAB_Origin extends MiscObject  

Spell[] Property OriginSpells Auto
Perk[] Property OriginPerks Auto

string[] Property ActorValues Auto
int[] Property ActorValuesOffsets Auto

Outfit Property Equipment Auto

int Property OriginQuestStage = -1 Auto 

Actor Player

Function Choose()
	Player = Game.GetPlayer()

	GiveSpells()
	GivePerks()
	ModActorValues()

	if (OriginQuestStage != -1)
		Quest.GetQuest("RFAB_Origin_Main").SetStage(OriginQuestStage)
	endif

	Player = None
EndFunction	

Function GiveSpells()
	int i = 0
	while i < OriginSpells.Length
		Player.AddSpell(OriginSpells[i], false)
		i += 1
	endwhile
EndFunction

Function GivePerks()
	int i = 0
	while i < OriginPerks.Length
		Player.AddPerk(OriginPerks[i])
		i += 1
	endwhile
EndFunction

Function ModActorValues()
	int i = 0
	while i < ActorValues.Length
		Player.SetActorValue(ActorValues[i], Player.GetBaseActorValue(ActorValues[i]) + ActorValuesOffsets[i])
		i += 1
	endwhile
EndFunction