Scriptname RFAB_GoldSpent_IconNotification extends ReferenceAlias  

Race Property KhajiitRace Auto

int GoldValue
string IconPath = "skyui/icons_item_psychosteve2.swf"
int MiscGold = 96

Event OnInit()
     RegisterForMenu("BarterMenu")
     RegisterForMenu("Training Menu")
EndEvent

Event OnPlayerLoadGame()
     RegisterForMenu("BarterMenu")
     RegisterForMenu("Training Menu")
EndEvent

Event OnMenuOpen(String asMenuName)
	GoldValue = Game.GetPlayer().GetGoldAmount()
EndEvent

Event OnMenuClose(String sMenuName)
	int ActualGoldValue = Game.GetPlayer().GetGoldAmount()
	int GoldDifference = ActualGoldValue - GoldValue
	string GoldSpentMessage

	if sMenuName == "BarterMenu"

		if ActualGoldValue > GoldValue
			GoldSpentMessage = GetPrefixByRace() + GetWordBySex("заработал") + GetSeptimText(GoldDifference)
		elseif ActualGoldValue < GoldValue
			GoldDifference = GoldDifference * -1 
			GoldSpentMessage = GetPrefixByRace() + GetWordBySex("потратил") + GetSeptimText(GoldDifference)
		else
			return
		endif
	elseif sMenuName == "Training Menu"
		GoldDifference = GoldDifference * -1
		if GoldDifference != 0
			GoldSpentMessage = GetPrefixByRace() + GetWordBySex("потратил") + "на уроки " + GetSeptimText(GoldDifference)
		else
			return 
		endif
	endif
	((GetOwningQuest() as Form) as UILIB_1).ShowNotificationIcon(GoldSpentMessage, IconPath, MiscGold)
EndEvent

string Function GetPrefixByRace()
	Actor Player = Game.GetPlayer()
	if Player.GetRace() == KhajiitRace
		return " " + Player.GetDisplayName()
	else
		return " Я"
	endif

EndFunction

string Function GetWordBySex(string asPrefix)
	if Game.GetPlayer().GetActorBase().GetSex() == 1 ; Female
		return  " " + asPrefix + "a "
	else 
		return " " + asPrefix + " "
	endif
EndFunction

string Function GetSeptimText(int aiGoldValue)
    if aiGoldValue % 100 >= 11 && aiGoldValue % 100 <= 19
        return aiGoldValue + " септимов."
    elseif aiGoldValue % 10 == 1
        return aiGoldValue + " септим."
    elseif aiGoldValue % 10 >= 2 && aiGoldValue % 10 <= 4
        return aiGoldValue + " септима."
    else 
        return aiGoldValue + " септимов."
    endif
EndFunction

