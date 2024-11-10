Scriptname RFAB_MCM extends SKI_ConfigBase
{Настройки RFAB MCM, в основном меняет значения, если кто-то будет тут делать длинную логику какой-то механики я ему руки переломаю}

import PO3_SKSEFunctions
import PapyrusIniManipulator

Actor Property Player Auto

RFAB_MCM_Alias Property Data Auto
{Хранилище обновляемых переменных}

; Менюшки
RFAB_DoomStoneMenu Property DoomStoneMenu Auto
{Меню Камней Хранителей}
RFAB_DifficultyMenu Property DifficultyMenu Auto
{Меню сложности}
RFAB_Menu Property Menu Auto
{Главное меню RFaB}

; Интерфейс
RFAB_ResistWidget Property ResistWidget Auto
{Виджет сопротивлений и скорости}
RFAB_PlayerInfoWidget Property PlayerInfoWidget Auto
{Виджет боя, веса, времени, кол-ва золота и т.д.}
RFAB_WeaponMagicEquip Property WeaponMagicEquip Auto
{Виджет экипированного оружия, магии, криков}

; Прочие приколы
RFAB_DualWielding Property DualWielding Auto
{Блокирование и парирование на хот кеи}
RFAB_GlowingBooks Property GlowingBooks Auto
{Подсветка книг}
RFAB_Mounts Property Mounts Auto
{Ездовые животные}
RFAB_ExtendedHotkeys Property ExtendedHotkeys Auto
{Горячие клавиши}
RFAB_AutoLoot Property AutoLoot Auto
{Автолут}

GlobalVariable Property FollowerTeleportKey Auto
GlobalVariable Property JumpNPC Auto

bool IsBizarreActived = false
bool IsGodModeActive = false

Perk Property BlockSteal Auto
Perk Property BlockSitting Auto

int Key_FollowerTeleport = 48 ; B
int PlayerDoomStoneID

Event OnConfigInit()	
	ModName = " RFAB"
	Pages = new string[8]
	Pages[0] = "Настройки"
	Pages[1] = "Ездовые животные"
	Pages[2] = "Светящиеся книги"
	Pages[3] = "Опыт"
	Pages[4] = "Интерфейс"
	Pages[5] = "Горячие клавиши"
	Pages[6] = "Автолут"
	Pages[7] = "Дебаг"
	if IsPluginFound("RFAB_BizarreAdventure.esp")
		IsBizarreActived = True
	endif
EndEvent

Event OnPageReset(string page)
	if (page == "")
		LoadCustomContent("RFAB\\logo.dds")
		return
	else
		UnloadCustomContent()
	endIf
	SetCursorFillMode(TOP_TO_BOTTOM)
	if page == "Настройки"
		ShowSettings()
	elseif page == "Светящиеся книги"
		ShowGlowingBooks()
	elseif page == "Ездовые животные"
		ShowMounts()
	elseif page == "Интерфейс"
		ShowInterface()
	elseif page == "Опыт"
		ShowExperience()
	elseif page == "Горячие клавиши"
		ShowHotkeys()
	elseif page == "Автолут"
		ShowAutoLoot()
	elseif page == "Дебаг"
		ShowDebug()
	endif
Endevent

Event OnConfigOpen()
	IsGodModeActive = GetGodMode()
EndEvent

; Автолут ================================================================================================================================
Function ShowAutoLoot()
	SetCursorFillMode(LEFT_TO_RIGHT)
	AddHeaderOption("Автоматический сбор")
	AddHeaderOption("Cбор горячей клавишей")
	AddToggleOptionST("AutoLoot_LootByCloak", "Автоматический сбор", AutoLoot.LootByCloak)
	AddToggleOptionST("AutoLoot_LootByHotKey", "Cбор горячей клавишей", AutoLoot.LootByHotKey)
	AddToggleOptionST("AutoLoot_InCombat", "Cбор в бою", AutoLoot.InCombat, EnableIf(AutoLoot.LootByCloak))
	AddKeyMapOptionST("AutoLoot_HotKey", "Горячая клавиша", AutoLoot.HotKey, EnableIf(AutoLoot.LootByHotKey))
	AddHeaderOption("Общие настройки")
	AddHeaderOption("")
	AddToggleOptionST("AutoLoot_LootMisc", "Всегда поднимать шкуры и ингредиенты", AutoLoot.LootMisc)
	AddEmptyOption()
	AddToggleOptionST("AutoLoot_SaveBlessing", "Не брать неправедные предметы", AutoLoot.SaveBlessing)
	AddEmptyOption()
	AddToggleOptionST("AutoLoot_OverWeight", "Предотвращать перегруз", AutoLoot.DisallowOverWeight)
	AddEmptyOption()

	AddMenuOptionST("AutoLoot_Method", "Алгоритм сбора", AutoLoot.Methods[AutoLoot.MethodID])
	if (AutoLoot.MethodID == 3) ; Вес
		AddInputOptionST("AutoLoot_Value", "Собирать ниже веса:", AutoLoot.Value)
	elseif (AutoLoot.MethodID == 2) ; Цена
		AddInputOptionST("AutoLoot_Value", "Собирать выше цены:", AutoLoot.Value)
	elseif (AutoLoot.MethodID == 1) ; Цена/Вес
		AddInputOptionST("AutoLoot_Value", "Собирать если цена/вес выше:", AutoLoot.Value)
	else
		AddEmptyOption()
	endif
EndFunction

State AutoLoot_Method
    Event OnMenuOpenST()
    	SetMenuDialogStartIndex(AutoLoot.MethodID)
		SetMenuDialogOptions(AutoLoot.Methods)
    EndEvent
    Event OnMenuAcceptST(int aiIndex)
    	AutoLoot.MethodID = aiIndex
		SetMenuOptionValueST(AutoLoot.Methods[aiIndex])
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		AutoLoot.MethodID = 0
		SetMenuOptionValueST(AutoLoot.Methods[0])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
        SetInfoText("По каким параметрам будет сбор предметов.")
    EndEvent	
EndState

State AutoLoot_Value
	Event OnInputAcceptST(string asInput)
		AutoLoot.Value = asInput as int
		SetInputOptionValueST(AutoLoot.Value)
	EndEvent
	Event OnDefaultST()
		AutoLoot.Value = 0
		SetInputOptionValueST(AutoLoot.Value)
	EndEvent
EndState

State AutoLoot_SaveBlessing
    Event OnSelectST()
    	AutoLoot.SaveBlessing = !AutoLoot.SaveBlessing
    	SetToggleOptionValueST(AutoLoot.SaveBlessing)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Игнорирование предметов, которые могут привести к потери праведности.")
    EndEvent
EndState

State AutoLoot_OverWeight
    Event OnSelectST()
    	AutoLoot.DisallowOverWeight = !AutoLoot.DisallowOverWeight
    	SetToggleOptionValueST(AutoLoot.DisallowOverWeight)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Остановка сбора предметов, если они приведут к перегрузу персонажа.")
    EndEvent
EndState

State AutoLoot_LootMisc
    Event OnSelectST()
    	AutoLoot.LootMisc = !AutoLoot.LootMisc
    	SetToggleOptionValueST(AutoLoot.LootMisc)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Всегда подбирать шкуры животных и ингредиенты, даже если они не совпадают параметрам подбора.")
    EndEvent
EndState

State AutoLoot_LootByCloak
    Event OnSelectST()
    	AutoLoot.LootByCloak = !AutoLoot.LootByCloak
    	SetToggleOptionValueST(AutoLoot.LootByCloak)
    	SetOptionFlagsST(DisableIf(!AutoLoot.LootByCloak), false, "AutoLoot_InCombat")
    EndEvent
    Event OnHighlightST()
        SetInfoText("Включение и выключение автоматического подбора предметов.")
    EndEvent
EndState

State AutoLoot_InCombat
    Event OnSelectST()
    	AutoLoot.InCombat = !AutoLoot.InCombat
    	SetToggleOptionValueST(AutoLoot.InCombat)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Включение и выключение подбора предметов во время боя.")
    EndEvent
EndState

State AutoLoot_LootByHotKey
    Event OnSelectST()
    	AutoLoot.LootByHotKey = !AutoLoot.LootByHotKey
    	SetToggleOptionValueST(AutoLoot.LootByHotKey)
    	SetOptionFlagsST(DisableIf(!AutoLoot.LootByHotKey), false, "AutoLoot_HotKey")
    EndEvent
    Event OnHighlightST()
        SetInfoText("Включение и выключение подбора предметов при нажатии горячей клавиши.")
    EndEvent
EndState

State AutoLoot_HotKey
    Event OnKeyMapChangeST(int keyCode, string conflictControl, string conflictName)
		AutoLoot.Hotkey = keyCode
		SetKeyMapOptionValueST(AutoLoot.Hotkey)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Клавиша подбора предметов с ближайших трупов.")
    EndEvent
EndState

; Опыт ==================================================================================================================================
Function ShowExperience()
	SetCursorFillMode(LEFT_TO_RIGHT)
	AddHeaderOption("Настройки меню RFAB")
	AddHeaderOption("")
	AddInputOptionST("Menu_PositionX", "Сдвиг по X", Menu.Offset_X)
	AddInputOptionST("Menu_PositionY", "Сдвиг по Y", Menu.Offset_Y)
	AddInputOptionST("Menu_Scale", "Размер", Menu.Scale)
	AddColorOptionST("Menu_NoficationColor", "Цвет сообщений опыта", Menu.NotificationColor)
	AddKeymapOptionST("Menu_Hotkey", "Клавиша вызова меню", Menu.Hotkey)
EndFunction

State Menu_Hotkey
    Event OnKeyMapChangeST(int keyCode, string conflictControl, string conflictName)
		Menu.Hotkey = keyCode
		SetKeyMapOptionValueST(Menu.Hotkey)
	EndEvent
	Event OnDefaultST()
		Menu.Hotkey = 35 ; H
		SetKeyMapOptionValueST(Menu.Hotkey)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Клавиша вызова меню RFAB.")
    EndEvent
EndState

State Menu_NoficationColor
	Event OnColorAcceptST(int color)
		Menu.NotificationColor = color
		SetColorOptionValueST(Menu.NotificationColor)
	EndEvent
	Event OnDefaultST()
		Menu.NotificationColor = 16777215
		SetColorOptionValueST(Menu.NotificationColor)
	EndEvent
EndState

State Menu_PositionX
	Event OnInputAcceptST(string asInput)
		Menu.Offset_X = asInput as int
		SetInputOptionValueST(Menu.Offset_X)
	EndEvent
	Event OnDefaultST()
		Menu.Offset_X = 0
		SetInputOptionValueST(Menu.Offset_X)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Сдвиг меню RFAB по оси X.")
    EndEvent	
EndState

State Menu_PositionY
	Event OnInputAcceptST(string asInput)
		Menu.Offset_Y = asInput as int
		SetInputOptionValueST(Menu.Offset_Y)
	EndEvent
	Event OnDefaultST()
		Menu.Offset_Y = 0
		SetInputOptionValueST(Menu.Offset_Y)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Сдвиг меню RFAB по оси Y.")
    EndEvent	
EndState

State Menu_Scale
	Event OnInputAcceptST(string asInput)
		Menu.Scale = asInput as int
		SetInputOptionValueST(Menu.Scale)
	EndEvent
	Event OnDefaultST()
		Menu.Scale = 100
		SetInputOptionValueST(Menu.Scale)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Размер меню RFAB.")
    EndEvent	
EndState

; Интерфейс =============================================================================================================================
Function ShowInterface()
	SetCursorFillMode(LEFT_TO_RIGHT)
	AddHeaderOption("Виджет сопротивлений")
	AddHeaderOption("")
	AddInputOptionST("RW_PositionX", "Положение по X", ResistWidget.X)
	AddInputOptionST("RW_PositionY", "Положение по Y", ResistWidget.Y)
	AddInputOptionST("RW_Scale", "Размер в процентах", ResistWidget.Scale)
	AddSliderOptionST("RW_Alpha", "Непрозрачность", ResistWidget.Alpha, "{0}%")
	AddMenuOptionST("RW_Rotation", "Ориентация виджета", ResistWidget.RotationOptions[ResistWidget.RotationOptionID])
	AddMenuOptionST("RW_Color", "Цветность виджета", ResistWidget.ColorOptions[ResistWidget.ColorOptionID])

	AddHeaderOption("Виджет информации игрока")
	AddHeaderOption("")
	AddMenuOptionST("PIW_State", "Элемент виджета", PlayerInfoWidget.Sections[PlayerInfoWidget.SectionID])
	AddEmptyOption()
	AddInputOptionST("PIW_PositionX", "Положение по X", PlayerInfoWidget.X)
	AddInputOptionST("PIW_PositionY", "Положение по Y", PlayerInfoWidget.Y)
	AddInputOptionST("PIW_Scale", "Размер в процентах", PlayerInfoWidget.Scale)
	AddSliderOptionST("PIW_Alpha", "Непрозрачность", PlayerInfoWidget.Alpha, "{0}%")

	AddHeaderOption("Виджет экипированного")
	AddHeaderOption("")
	AddInputOptionST("WME_PositionX", "Положение по X", WeaponMagicEquip.X)
	AddInputOptionST("WME_PositionY", "Положение по Y", WeaponMagicEquip.Y)
	AddInputOptionST("WME_Scale", "Размер в процентах", WeaponMagicEquip.Scale)
	AddSliderOptionST("WME_Alpha", "Непрозрачность", WeaponMagicEquip.Alpha, "{0}%")
EndFunction

State WME_Scale
	Event OnInputAcceptST(string asInput)
		WeaponMagicEquip.Scale = asInput as int
		SetInputOptionValueST(WeaponMagicEquip.Scale)
	EndEvent
	Event OnDefaultST()
		WeaponMagicEquip.Scale = WeaponMagicEquip.Scale_Default
		SetInputOptionValueST(WeaponMagicEquip.Scale)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Размер в процентах.")
    EndEvent	
EndState

State WME_Alpha
    Event OnSliderAcceptST(float value)
        WeaponMagicEquip.Alpha = value as int
        SetSliderOptionValueST(value, "{0}%")
    EndEvent
	Event OnDefaultST()
		WeaponMagicEquip.Alpha = WeaponMagicEquip.Alpha_Default
		SetSliderOptionValueST(WeaponMagicEquip.Alpha, "{0}%")
	EndEvent
    Event OnSliderOpenST()
        SetSliderDialogStartValue(WeaponMagicEquip.Alpha)
        SetSliderDialogRange(0.0, 100.0)
        SetSliderDialogInterval(1.0)
    EndEvent
   	Event OnHighlightST()
        SetInfoText("Непрозрачность виджета экипированного оружия, магии и криков.")
    EndEvent	
EndState

State WME_PositionY
	Event OnInputAcceptST(string asInput)
		WeaponMagicEquip.Y = asInput as int
		SetInputOptionValueST(WeaponMagicEquip.Y)
	EndEvent
	Event OnDefaultST()
		WeaponMagicEquip.Y = WeaponMagicEquip.Y_Default
		SetInputOptionValueST(WeaponMagicEquip.Y)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Положение по Y.")
    EndEvent	
EndState

State WME_PositionX
	Event OnInputAcceptST(string asInput)
		WeaponMagicEquip.X = asInput as int
		SetInputOptionValueST(WeaponMagicEquip.X)
	EndEvent
	Event OnDefaultST()
		WeaponMagicEquip.X = WeaponMagicEquip.X_Default
		SetInputOptionValueST(WeaponMagicEquip.X)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Положение по X.")
    EndEvent	
EndState

State PIW_State
    Event OnMenuOpenST()
    	SetMenuDialogStartIndex(PlayerInfoWidget.SectionID)
		SetMenuDialogOptions(PlayerInfoWidget.Sections)
    EndEvent
    Event OnMenuAcceptST(int aiIndex)
    	PlayerInfoWidget.SectionID = aiIndex
		SetMenuOptionValueST(PlayerInfoWidget.Sections[aiIndex])
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		PlayerInfoWidget.SectionID = 0
		SetMenuOptionValueST(PlayerInfoWidget.Sections[0])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
        SetInfoText("Элемент виджета информации игрока.")
    EndEvent	
EndState

State PIW_Scale
	Event OnInputAcceptST(string asInput)
		PlayerInfoWidget.Scale = asInput as int
		SetInputOptionValueST(PlayerInfoWidget.Scale)
	EndEvent
	Event OnDefaultST()
		PlayerInfoWidget.Scale = PlayerInfoWidget.Scale_Default
		SetInputOptionValueST(PlayerInfoWidget.Scale)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Размер в процентах.")
    EndEvent	
EndState

State PIW_Alpha
    Event OnSliderAcceptST(float value)
        PlayerInfoWidget.Alpha = value as int
        SetSliderOptionValueST(value, "{0}%")
    EndEvent
	Event OnDefaultST()
		PlayerInfoWidget.Alpha = PlayerInfoWidget.Alpha_Default
		SetSliderOptionValueST(PlayerInfoWidget.Alpha, "{0}%")
	EndEvent
    Event OnSliderOpenST()
        SetSliderDialogStartValue(PlayerInfoWidget.Alpha)
        SetSliderDialogRange(0.0, 100.0)
        SetSliderDialogInterval(1.0)
    EndEvent
   	Event OnHighlightST()
        SetInfoText("Непрозрачность виджета информации игрока.")
    EndEvent	
EndState

State PIW_PositionY
	Event OnInputAcceptST(string asInput)
		PlayerInfoWidget.Y = asInput as int
		SetInputOptionValueST(PlayerInfoWidget.Y)
	EndEvent
	Event OnDefaultST()
		PlayerInfoWidget.Y = PlayerInfoWidget.Y_Default
		SetInputOptionValueST(PlayerInfoWidget.Y)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Положение по Y.")
    EndEvent	
EndState

State PIW_PositionX
	Event OnInputAcceptST(string asInput)
		PlayerInfoWidget.X = asInput as int
		SetInputOptionValueST(PlayerInfoWidget.X)
	EndEvent
	Event OnDefaultST()
		PlayerInfoWidget.X = PlayerInfoWidget.X_Default
		SetInputOptionValueST(PlayerInfoWidget.X)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Положение по X.")
    EndEvent	
EndState

State RW_Color
    Event OnMenuOpenST()
    	SetMenuDialogStartIndex(ResistWidget.ColorOptionID)
		SetMenuDialogOptions(ResistWidget.ColorOptions)
    EndEvent
    Event OnMenuAcceptST(int aiIndex)
    	ResistWidget.ColorOptionID = aiIndex
		SetMenuOptionValueST(ResistWidget.ColorOptions[aiIndex])
	EndEvent
	Event OnDefaultST()
		ResistWidget.ColorOptionID = 1
		SetMenuOptionValueST(ResistWidget.ColorOptions[ResistWidget.ColorOptionID])
	EndEvent
	Event OnHighlightST()
        SetInfoText("Цветовая палитра виджета сопротивлений.")
    EndEvent	
EndState

State RW_Rotation
    Event OnMenuOpenST()
    	SetMenuDialogStartIndex(ResistWidget.RotationOptionID)
		SetMenuDialogOptions(ResistWidget.RotationOptions)
    EndEvent
    Event OnMenuAcceptST(int aiIndex)
    	ResistWidget.RotationOptionID = aiIndex
		SetMenuOptionValueST(ResistWidget.RotationOptions[aiIndex])
	EndEvent
	Event OnDefaultST()
		ResistWidget.RotationOptionID = 0
		SetMenuOptionValueST(ResistWidget.RotationOptions[ResistWidget.RotationOptionID])
	EndEvent
	Event OnHighlightST()
        SetInfoText("Ориентация виджета сопротивлений.")
    EndEvent	
EndState

State RW_Alpha
    Event OnSliderAcceptST(float value)
        ResistWidget.Alpha = value as int
        SetSliderOptionValueST(value, "{0}%")
    EndEvent
    Event OnSliderOpenST()
        SetSliderDialogStartValue(ResistWidget.Alpha)
        SetSliderDialogRange(0.0, 100.0)
        SetSliderDialogInterval(1.0)
    EndEvent
   	Event OnDefaultST()
		ResistWidget.Alpha = ResistWidget.Alpha_Default
		SetSliderOptionValueST(ResistWidget.Alpha, "{0}%")
	EndEvent
   	Event OnHighlightST()
        SetInfoText("Непрозрачность виджета сопротивлений.")
    EndEvent	
EndState

State RW_Scale
	Event OnInputAcceptST(string asInput)
		ResistWidget.Scale = asInput as int 
		SetInputOptionValueST(ResistWidget.Scale)
	EndEvent
	Event OnDefaultST()
		ResistWidget.Scale = ResistWidget.Scale_Default
		SetInputOptionValueST(ResistWidget.Scale)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Размер в процентах.")
    EndEvent	
EndState

State RW_PositionY
	Event OnInputAcceptST(string asInput)
		ResistWidget.Y = asInput as int
		SetInputOptionValueST(ResistWidget.Y)
	EndEvent
	Event OnDefaultST()
		ResistWidget.Y = ResistWidget.Y_Default
		SetInputOptionValueST(ResistWidget.Y)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Положение по Y.")
    EndEvent	
EndState

State RW_PositionX
	Event OnInputAcceptST(string asInput)
		ResistWidget.X = asInput as int
		SetInputOptionValueST(ResistWidget.X)
	EndEvent
	Event OnDefaultST()
		ResistWidget.X = ResistWidget.X_Default
		SetInputOptionValueST(ResistWidget.X)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Положение по X.")
    EndEvent	
EndState

; Extended Hotkeys =============================================================================================================================
Function ShowHotkeys()
	SetCursorFillMode(LEFT_TO_RIGHT)
	AddHeaderOption("Extended Hotkeys")
	AddHeaderOption("")
	AddMenuOptionST("EHK_SpellPriorities", "Приоритет экипировки заклинаний", ExtendedHotkeys.SpellPriorities[ExtendedHotkeys.SpellPriorityID])
	AddMenuOptionST("EHK_ScrollPriorities", "Приоритет экипировки свитков", ExtendedHotkeys.ScrollPriorities[ExtendedHotkeys.ScrollPriorityID])

	AddMenuOptionST("EHK_AllowDualWield", "Экипировка парного оружия горячими клавишами", ExtendedHotkeys.AllowDualWield[ExtendedHotkeys.AllowDualWieldID])
	AddMenuOptionST("EHK_DisallowUnequipShield", "Запретить снимать щит кнопкой экипировки", ExtendedHotkeys.DisallowUnequipShield[ExtendedHotkeys.DisallowUnequipShieldID])
	AddKeymapOptionST("EHK_EmptyHandsHotkey", "Убрать все из рук", ExtendedHotkeys.EmptyHandsHotkey)
EndFunction

State EHK_EmptyHandsHotkey
    Event OnKeyMapChangeST(int keyCode, string conflictControl, string conflictName)
		ExtendedHotkeys.EmptyHandsHotkey = keyCode
		SetKeyMapOptionValueST(ExtendedHotkeys.EmptyHandsHotkey)
	EndEvent
	Event OnDefaultST()
		ExtendedHotkeys.EmptyHandsHotkey = 12
		SetKeyMapOptionValueST(ExtendedHotkeys.EmptyHandsHotkey)
		ForcePageReset()
	EndEvent
    Event OnHighlightST()
        SetInfoText("Убрать все из рук.")
    EndEvent
EndState

State EHK_DisallowUnequipShield
    Event OnMenuOpenST()
    	SetMenuDialogStartIndex(ExtendedHotkeys.DisallowUnequipShieldID)
		SetMenuDialogOptions(ExtendedHotkeys.DisallowUnequipShield)
    EndEvent
    Event OnMenuAcceptST(int aiIndex)
    	ExtendedHotkeys.DisallowUnequipShieldID = aiIndex
		SetMenuOptionValueST(ExtendedHotkeys.DisallowUnequipShield[aiIndex])
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		ExtendedHotkeys.DisallowUnequipShieldID = 1
		SetMenuOptionValueST(ExtendedHotkeys.DisallowUnequipShield[1])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
        SetInfoText("Запретить снимать щит кнопкой экипировки.")
    EndEvent	
EndState

State EHK_AllowDualWield
    Event OnMenuOpenST()
    	SetMenuDialogStartIndex(ExtendedHotkeys.AllowDualWieldID)
		SetMenuDialogOptions(ExtendedHotkeys.AllowDualWield)
    EndEvent
    Event OnMenuAcceptST(int aiIndex)
    	ExtendedHotkeys.AllowDualWieldID = aiIndex
		SetMenuOptionValueST(ExtendedHotkeys.AllowDualWield[aiIndex])
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		ExtendedHotkeys.AllowDualWieldID = 1
		SetMenuOptionValueST(ExtendedHotkeys.AllowDualWield[1])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
        SetInfoText("Экипировка парного оружия горячими клавишами.")
    EndEvent	
EndState

State EHK_ScrollPriorities
    Event OnMenuOpenST()
    	SetMenuDialogStartIndex(ExtendedHotkeys.ScrollPriorityID)
		SetMenuDialogOptions(ExtendedHotkeys.ScrollPriorities)
    EndEvent
    Event OnMenuAcceptST(int aiIndex)
    	ExtendedHotkeys.ScrollPriorityID = aiIndex
		SetMenuOptionValueST(ExtendedHotkeys.ScrollPriorities[aiIndex])
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		ExtendedHotkeys.ScrollPriorityID = 1
		SetMenuOptionValueST(ExtendedHotkeys.ScrollPriorities[1])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
        SetInfoText("Приоритет экипировки свитков.")
    EndEvent	
EndState

State EHK_SpellPriorities
    Event OnMenuOpenST()
    	SetMenuDialogStartIndex(ExtendedHotkeys.SpellPriorityID)
		SetMenuDialogOptions(ExtendedHotkeys.SpellPriorities)
    EndEvent
    Event OnMenuAcceptST(int aiIndex)
    	ExtendedHotkeys.SpellPriorityID = aiIndex
		SetMenuOptionValueST(ExtendedHotkeys.SpellPriorities[aiIndex])
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		ExtendedHotkeys.SpellPriorityID = 1
		SetMenuOptionValueST(ExtendedHotkeys.SpellPriorities[1])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
        SetInfoText("Приоритет экипировки свитков.")
    EndEvent	
EndState

; Ездовые Животные ====================================================================================================================
Function ShowMounts()
	SetCursorFillMode(LEFT_TO_RIGHT)
	AddHeaderOption("Настройки")
	AddHeaderOption("")
	AddKeyMapOptionST("MountsHotKey", "Вызов лошади/открыть инвентарь", Mounts.HotKey)
	AddToggleOptionST("MountsCarryWeightInName", "Отображать вес в имени", Mounts.IsShowWeightInName)
	AddSliderOptionST("MountsLoudness", "Громкость свиста", Mounts.Loudness * 100, "{0}%")
	AddToggleOptionST("MountsCarryWeightInMenu", "Отображать вес в инвентаре", Mounts.IsShowWeightInMenu)
	AddHeaderOption("Характеристики")
	AddHeaderOption("")
	AddTextOption("Переносимый вес", Mounts.MountCarryWeight)
	AddTextOption("Скорость", Mounts.MountSpeed - 50 + " %")
	AddInputOptionST("MountName", "Имя", Mounts.MountName)
EndFunction

State MountName
	Event OnInputAcceptST(string asInput)
		Mounts.MountName = asInput
		SetInputOptionValueST(Mounts.MountName)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Имя ездового животного, распространяется на всех.")
    EndEvent
EndState

State MountsLoudness
    Event OnSliderAcceptST(float value)
        Mounts.Loudness = value / 100
        SetSliderOptionValueST(value, "{0}%")
    EndEvent
    Event OnSliderOpenST()
        SetSliderDialogStartValue(Mounts.Loudness * 100)
        SetSliderDialogRange(0.0, 100.0)
        SetSliderDialogInterval(1.0)
    EndEvent
EndState

State MountsCarryWeightInMenu
    Event OnSelectST()
    	Mounts.IsShowWeightInMenu = !Mounts.IsShowWeightInMenu
    	SetToggleOptionValueST(Mounts.IsShowWeightInMenu)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Отображение переносимого веса ездового животного в его инвентаре.")
    EndEvent
EndState

State MountsCarryWeightInName
    Event OnSelectST()
    	Mounts.IsShowWeightInName = !Mounts.IsShowWeightInName
    	SetToggleOptionValueST(Mounts.IsShowWeightInName)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Отображение переносимого веса ездового животного в его имени.")
    EndEvent
EndState

State MountsHotKey
    Event OnKeyMapChangeST(int keyCode, string conflictControl, string conflictName)
		Mounts.HotKey = keyCode
		SetKeyMapOptionValueST(Mounts.HotKey)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Клавиша, на которую Вы сможете открыть инвентарь ездового животного, отозвать и призвать его к себе.")
    EndEvent
EndState

; Настройки =============================================================================================================================
Function ShowSettings()
	SetCursorFillMode(LEFT_TO_RIGHT)
	AddHeaderOption("Опциональные настройки")
	AddHeaderOption("")
	AddToggleOptionST("FastTravel", "Быстрое перемещение", Data.IsFastTravelAllowed)
	AddToggleOptionST("BlockSitting", "Подтверждение при использовании фурнитуры", Player.HasPerk(BlockSitting))
	;AddToggleOptionST("JumpNPC", "Прыжки НПС", JumpNPC.GetValueInt() as bool)
	AddToggleOptionST("BlessingMessage", "Уведомление о праведности", Data.IsBlessingMessageOn)
	AddToggleOptionST("BlockSteal", "Предотвращение случайной кражи", Player.HasPerk(BlockSteal))

	AddHeaderOption("Горячие клавиши")
	AddHeaderOption("")
	AddKeyMapOptionST("BlockKey", "Клавиша блокирования", DualWielding.KeyBlock)
	AddKeyMapOptionST("FollowerTeleport", "Клавиша телепорта союзников", Key_FollowerTeleport)
	AddKeyMapOptionST("ParryingKey", "Клавиша парирования", DualWielding.KeyBash)
	AddEmptyOption()

	AddHeaderOption("Сложность игры")
	AddHeaderOption("")
	AddMenuOptionST("Difficulty", "Уровень сложности", DifficultyMenu.DifficultyNames[DifficultyMenu.DifficultyIndex], 0)
	AddToggleOptionST("Curse", "Проклятие", DifficultyMenu.Cursed)
EndFunction

State Difficulty
    Event OnMenuOpenST()
    	SetMenuDialogStartIndex(DifficultyMenu.DifficultyIndex)
		SetMenuDialogOptions(DifficultyMenu.DifficultyNames)
    EndEvent
    Event OnMenuAcceptST(int aiIndex)
    	DifficultyMenu.SetDifficulty(aiIndex)
		SetMenuOptionValueST(DifficultyMenu.DifficultyNames[aiIndex])
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		DifficultyMenu.SetDifficulty(0)
		SetMenuOptionValueST(DifficultyMenu.DifficultyNames[0])
		ForcePageReset()
	EndEvent
    Event OnHighlightST()
        SetInfoText(DifficultyMenu.DifficultyInfo[DifficultyMenu.DifficultyIndex])
    EndEvent
EndState

State Curse
	Event OnSelectST()
		DifficultyMenu.SetCurse(!DifficultyMenu.Cursed)
		SetToggleOptionValueST(DifficultyMenu.Cursed)
    EndEvent
    Event OnHighlightST()
        SetInfoText("С самого вашего рождения вас прокляли таинственными чарами.\nВы наносите половину базового урона.")
    EndEvent
EndState

State FollowerTeleport
    Event OnKeyMapChangeST(int keyCode, string conflictControl, string conflictName)
    	Key_FollowerTeleport = keyCode
		SetKeyMapOptionValueST(Key_FollowerTeleport)
		FollowerTeleportKey.SetValueInt(Key_FollowerTeleport)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Клавиша, на которую Вы сможете быстро вернуть к себе союзников.")
    EndEvent
EndState

State BlockKey
    Event OnKeyMapChangeST(int keyCode, string conflictControl, string conflictName)
		DualWielding.SetBlockKey(keyCode)
		SetKeyMapOptionValueST(keyCode)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Клавиша, на которую игровой персонаж сможет быстро блокировать, в том числе парным оружием и руками.")
    EndEvent
EndState

State ParryingKey
    Event OnKeyMapChangeST(int keyCode, string conflictControl, string conflictName)
		DualWielding.SetBashKey(keyCode)
		SetKeyMapOptionValueST(keyCode)
	EndEvent
    Event OnHighlightST()
        SetInfoText("Клавиша, на которую игровой персонаж сможет быстро парировать, в том числе парным оружием и руками.")
    EndEvent
EndState

State BlessingMessage
    Event OnSelectST()
    	Data.IsBlessingMessageOn = !Data.IsBlessingMessageOn
    	SetToggleOptionValueST(Data.IsBlessingMessageOn)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Уведомление о потери и восстановлении праведности.")
    EndEvent
EndState

State BlockSitting
    Event OnSelectST()
		bool bBlockSitting = Player.HasPerk(BlockSitting)
    	if bBlockSitting
    		Player.RemovePerk(BlockSitting)
    	else
    		Player.AddPerk(BlockSitting)
    	endif
    	SetToggleOptionValueST(!bBlockSitting)
    EndEvent
    Event OnHighlightST()
        SetInfoText("При использовании стульев/столов/скамеек выводится окно с подтверждением выбора.")
    EndEvent
EndState

State BlockSteal
    Event OnSelectST()
    	bool bBlockSteal = Player.HasPerk(BlockSteal)
    	if bBlockSteal
    		Player.RemovePerk(BlockSteal)
    	else
    		Player.AddPerk(BlockSteal)
    	endif
    	SetToggleOptionValueST(!bBlockSteal)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Предотвращает случайную кражу в мире. Особенно полезно для праведных персонажей.")
    EndEvent
EndState

State JumpNPC
    Event OnSelectST()
    	bool bJumpOn = JumpNPC.GetValueInt() as Bool
    	if bJumpOn
    		JumpNPC.SetValueInt(0)
    	else
    		JumpNPC.SetValueInt(1)
    	endif
    	SetToggleOptionValueST(!bJumpOn)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Включение и отключение механики прыжков у НПС")
    EndEvent
EndState

State FastTravel
    Event OnSelectST()
		if (!IsBizarreActived || IsGodModeActive)
			Data.IsFastTravelAllowed = !Data.IsFastTravelAllowed
		    SetToggleOptionValueST(Data.IsFastTravelAllowed)
		else
			debug.messagebox("Быстрое перемещение недоступно в честном режиме Bizarre Adventure")		    
		endif
    EndEvent
    Event OnHighlightST()
        SetInfoText("Включение возможности быстрого перемещения по карте. Недоступно в честном режиме Bizarre Adventure.")
    EndEvent
EndState

; Светящиеся книги =============================================================================================================================
Function ShowGlowingBooks()
	SetCursorFillMode(LEFT_TO_RIGHT)
	AddHeaderOption("Подсветка книг")
	AddHeaderOption("")

	AddToggleOptionST("BooksGlowingXP", "Подсвечивать книги опыта", GlowingBooks.Glowing_BookXP)
	AddColorOptionST("BooksColorXP", "Цвет свечения", GlowingBooks.Color_BookXP)

	AddToggleOptionST("BooksGlowingSpell", "Подсвечивать тома заклинаний", GlowingBooks.Glowing_BookSpell)
	AddColorOptionST("BooksColorSpell", "Цвет свечения", GlowingBooks.Color_BookSpell)

	AddToggleOptionST("BooksGlowingQuest", "Подсвечивать книги заданий", GlowingBooks.Glowing_BookQuest)
	AddColorOptionST("BooksColorQuest", "Цвет свечения", GlowingBooks.Color_BookQuest)

	AddToggleOptionST("BooksGlowingDefault", "Подсвечивать обычные книги", GlowingBooks.Glowing_BookDefault)
	AddColorOptionST("BooksColorDefault", "Цвет свечения", GlowingBooks.Color_BookDefault)

	AddMenuOptionST("BookGlowTexture", "Текстура свечения", GlowingBooks.TextureNames[GlowingBooks.GlowTextureID])
	AddSliderOptionST("BooksAlpha", "Непрозрачность свечения", GlowingBooks.GlowingAlpha, "{0}%")
EndFunction

State BooksAlpha
    Event OnSliderAcceptST(float value)
        GlowingBooks.GlowingAlpha = value
        SetSliderOptionValueST(value, "{0}%")
    EndEvent
    Event OnSliderOpenST()
        SetSliderDialogStartValue(GlowingBooks.GlowingAlpha)
        SetSliderDialogDefaultValue(GlowingBooks.GlowingAlpha)
        SetSliderDialogRange(0.0, 100.0)
        SetSliderDialogInterval(1.0)
    EndEvent
EndState

State BookGlowTexture
    Event OnMenuOpenST()
    	SetMenuDialogStartIndex(GlowingBooks.GlowTextureID)
		SetMenuDialogOptions(GlowingBooks.TextureNames)
    EndEvent
    Event OnMenuAcceptST(int aiIndex)
    	GlowingBooks.GlowTextureID = aiIndex
		SetMenuOptionValueST(GlowingBooks.TextureNames[aiIndex])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
        SetInfoText("Стиль свечения книг.")
    EndEvent
EndState

State BooksColorXP
	Event OnColorAcceptST(int color)
		SetColorOptionValueST(color)
		GlowingBooks.Color_BookXP = color
	EndEvent
EndState

State BooksColorSpell
	Event OnColorAcceptST(int color)
		SetColorOptionValueST(color)
		GlowingBooks.Color_BookSpell = color
	EndEvent
EndState

State BooksColorQuest
	Event OnColorAcceptST(int color)
		SetColorOptionValueST(color)
		GlowingBooks.Color_BookQuest = color
	EndEvent
EndState

State BooksColorDefault
	Event OnColorAcceptST(int color)
		SetColorOptionValueST(color)
		GlowingBooks.Color_BookDefault = color
	EndEvent
EndState

State BooksGlowingXP
	Event OnSelectST()
		bool BooksGlowing = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books glowing xp")
		GlowingBooks.Glowing_BookXP = !BooksGlowing
    	SetToggleOptionValueST(!BooksGlowing)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Подсветка книг, за чтение которых персонаж получает опыт.")
    EndEvent
EndState

State BooksGlowingSpell
	Event OnSelectST()
		bool BooksGlowing = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books glowing spell")
		GlowingBooks.Glowing_BookSpell = !BooksGlowing
    	SetToggleOptionValueST(!BooksGlowing)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Подсветка томов заклинаний.")
    EndEvent
EndState

State BooksGlowingQuest
	Event OnSelectST()
		bool BooksGlowing = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books glowing quest")
		GlowingBooks.Glowing_BookQuest = !BooksGlowing
    	SetToggleOptionValueST(!BooksGlowing)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Подсветка книг, связанных с заданием.")
    EndEvent
EndState

State BooksGlowingDefault
	Event OnSelectST()
		bool BooksGlowing = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books glowing default")
		GlowingBooks.Glowing_BookDefault = !BooksGlowing
    	SetToggleOptionValueST(!BooksGlowing)
    EndEvent
    Event OnHighlightST()
        SetInfoText("Подсветка обычных книг.")
    EndEvent
EndState

;Дебаг======================================================================================
Function ShowDebug()
	AddHeaderOption("Камни Хранители")
	PlayerDoomStoneID = DoomStoneMenu.GetDoomStoneID()
	AddMenuOptionST("DoomStones", "Камень Хранитель", DoomStoneMenu.DoomStoneNames[PlayerDoomStoneID], 0)
	if IsBizarreActived
		AddHeaderOption("Bizarre Adventure")
		Spell BizarreDebugSpell = Game.GetFormFromFile(0x161EDD28, "RFAB_BizarreAdventure.esp") as Spell
		AddToggleOptionST("BizarreDebug", "Debug spell", Player.HasSpell(BizarreDebugSpell))
	endif
EndFunction

State DoomStones
    Event OnMenuOpenST()
    	SetMenuDialogStartIndex(PlayerDoomStoneID)
		SetMenuDialogOptions(DoomStoneMenu.DoomStoneNames)
    EndEvent
    Event OnMenuAcceptST(int aiIndex)
		DoomStoneMenu.SetDoomStoneByID(aiIndex)
		SetMenuOptionValueST(DoomStoneMenu.DoomStoneNames[aiIndex])
		ForcePageReset()
	EndEvent
    Event OnHighlightST()
        SetInfoText("Смена Камня Хранителя игрового персонажа. Использование не для честной игры.")
    EndEvent
EndState

State BizarreDebug
    Event OnSelectST()
    	Spell BizarreDebugSpell = Game.GetFormFromFile(0x161EDD28, "RFAB_BizarreAdventure.esp") as Spell
    	if Player.HasSpell(BizarreDebugSpell)
    		Player.RemoveSpell(BizarreDebugSpell)
    		SetToggleOptionValueST(false)
    	else
			Player.AddSpell(BizarreDebugSpell)
    		SetToggleOptionValueST(true)
    	endif
    EndEvent
    Event OnHighlightST()
        SetInfoText("Спелл с настройками стадий Bizarre Adventure")
    EndEvent
EndState

; =========================================================================

; Отключает редактирование опции, если условие ложно
int Function DisableIf(bool abValue)
	if (abValue)
		return OPTION_FLAG_DISABLED
	endif 
	return 0
EndFunction

; Включает редактирование опции, если условие правдиво
int Function EnableIf(bool abValue)
	if (abValue)
		return 0
	endif 
	return OPTION_FLAG_DISABLED
EndFunction