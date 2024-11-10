Scriptname RFAB_GlowingBooks extends ReferenceAlias  
{Подсвечивает непрочитанные книги находящиеся по миру}

import PO3_Events_Alias
import PO3_SKSEFunctions

FormList Property Books_XP Auto
FormList Property Books_XPReaded Auto
FormList Property Books_Quest Auto

EffectShader Property Shader_BookXP Auto
EffectShader Property Shader_BookSpell Auto
EffectShader Property Shader_BookQuest Auto
EffectShader Property Shader_BookDefault Auto

Keyword Property BookXPKeyword Auto

string[] Property TextureNames Auto
string[] Property _TextureNames Auto

Cell LastCell

; Цвета свечения ===============================================================
int _ColorBookXP
int Property Color_BookXP
	int Function Get()
		return _ColorBookXP
	EndFunction
	Function Set(int color)
		_ColorBookXP = color
		ChangeColor(Shader_BookXP, "Books Color XP", color)
	EndFunction
EndProperty

int _ColorBookSpell
int Property Color_BookSpell
	int Function Get()
		return _ColorBookSpell
	EndFunction
	Function Set(int color)
		_ColorBookSpell = color
		ChangeColor(Shader_BookSpell, "Books Color Spell", color)
	EndFunction
EndProperty

int _ColorBookQuest
int Property Color_BookQuest
	int Function Get()
		return _ColorBookQuest
	EndFunction
	Function Set(int color)
		_ColorBookQuest = color
		ChangeColor(Shader_BookQuest, "Books Color Quest", color)
	EndFunction
EndProperty

int _ColorBookDefault
int Property Color_BookDefault
	int Function Get()
		return _ColorBookDefault
	EndFunction
	Function Set(int color)
		_ColorBookDefault = color
		ChangeColor(Shader_BookDefault, "books color default", color)
	EndFunction
EndProperty

Function ChangeColor(EffectShader akShader, string asKeyName, int aiColor)
	if JsonUtil.GetIntValue("RFAB_MCM_Settings.json", asKeyName) != aiColor
		SetShaderColor(akShader, DbColorFunctions.IntToRGB(aiColor), GlowingAlpha / 100)
		JsonUtil.SetIntValue("RFAB_MCM_Settings.json", asKeyName, aiColor)
		JsonUtil.Save("RFAB_MCM_Settings.json")
	endif
EndFunction
; ==============================================================================

; Включение и отключение свечения ==============================================
bool _GlowBookXP
bool Property Glowing_BookXP
	bool Function Get()
		return _GlowBookXP
	EndFunction
	Function Set(bool abGlowing)
		_GlowBookXP = abGlowing
		GlowSwitch(Shader_BookXP, "books glowing xp", abGlowing)
	EndFunction
EndProperty

bool _GlowBookSpell
bool Property Glowing_BookSpell
	bool Function Get()
		return _GlowBookSpell
	EndFunction
	Function Set(bool abGlowing)
		_GlowBookSpell = abGlowing
		GlowSwitch(Shader_BookSpell, "books glowing spell", abGlowing)
	EndFunction
EndProperty

bool _GlowBookQuest
bool Property Glowing_BookQuest
	bool Function Get()
		return _GlowBookQuest
	EndFunction
	Function Set(bool abGlowing)
		_GlowBookQuest = abGlowing
		GlowSwitch(Shader_BookQuest, "books glowing quest", abGlowing)
	EndFunction
EndProperty

bool _GlowBookDefault
bool Property Glowing_BookDefault
	bool Function Get()
		return _GlowBookDefault
	EndFunction
	Function Set(bool abGlowing)
		_GlowBookDefault = abGlowing
		GlowSwitch(Shader_BookDefault, "books glowing default", abGlowing)
	EndFunction
EndProperty

bool IsModWorking = true
Function GlowSwitch(EffectShader akShader, string asKeyName, bool abGlowing)
	if JsonUtil.GetIntValue("RFAB_MCM_Settings.json", asKeyName) != abGlowing
		JsonUtil.SetIntValue("RFAB_MCM_Settings.json", asKeyName, abGlowing as int)
		JsonUtil.Save("RFAB_MCM_Settings.json")
		
		if !Glowing_BookXP && !Glowing_BookQuest && !Glowing_BookSpell && !Glowing_BookDefault
			IsModWorking = false
			UnregisterForCellFullyLoaded(self)
			UnregisterForBookRead(self)
		else
			IsModWorking = true
			RegisterForCellFullyLoaded(self)
			RegisterForBookRead(self)
		endif
		FullUpdateGlowing()
	endif
EndFunction
; ==============================================================================
int _GlowTextureID
int Property GlowTextureID
	int Function Get()
		return _GlowTextureID
	EndFunction
	Function Set(int aiTextureID)
		if _GlowTextureID != aiTextureID
			_GlowTextureID = aiTextureID
			JsonUtil.SetIntValue("RFAB_MCM_Settings.json", "glow texture id", _GlowTextureID)
			JsonUtil.Save("RFAB_MCM_Settings.json")
			UpdateTextures()
			FullUpdateGlowing()
		endif
	EndFunction
EndProperty

float _GlowingAlpha
float Property GlowingAlpha
    float Function Get()
        return _GlowingAlpha
    EndFunction
    Function Set(float afAlpha)
    	if JsonUtil.GetFloatValue("RFAB_MCM_Settings.json", "books alpha") != _GlowingAlpha
			_GlowingAlpha = afAlpha
	        JsonUtil.SetFloatValue("RFAB_MCM_Settings.json", "books alpha", _GlowingAlpha)
			JsonUtil.Save("RFAB_MCM_Settings.json")
			UpdateColors()
		endif
    EndFunction
EndProperty
; ==============================================================================

int[] FormTypeBook

Event OnInit()
	TextureNames = new string[3]
	TextureNames[0] = "Волны Моря Призраков"
	TextureNames[1] = "Мантия"
	TextureNames[2] = "Загадочное зачарование"
	_TextureNames = new string[3]
	_TextureNames[0] = "Effects/darkswirls_blurry.dds"
	_TextureNames[1] = "Effects/dimFog.dds"
	_TextureNames[2] = "Effects/EnchFlameProject01.dds"

	FormTypeBook = new int[1]
	FormTypeBook[0] = 27

	int i = Books_XP.GetSize()
	while i
		i -= 1
		PO3_SKSEFunctions.AddKeywordToForm(Books_XP.GetAt(i), BookXPKeyword)
	endwhile

	SetUp()
EndEvent

Event OnPlayerLoadGame()
    SetUp()
    UpdateGlowing()
EndEvent

Function SetValues()
	GlowingAlpha = JsonUtil.GetFloatValue("RFAB_MCM_Settings.json", "books alpha")
	GlowTextureID = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "glow texture id")
	Glowing_BookXP = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books glowing xp")
	Glowing_BookSpell = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books glowing spell")
	Glowing_BookQuest = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books glowing quest")
	Glowing_BookDefault = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books glowing default")
	Color_BookXP = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books color xp")
	Color_BookSpell = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books color spell")
	Color_BookQuest = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books color quest")
	Color_BookDefault = JsonUtil.GetIntValue("RFAB_MCM_Settings.json", "books color default")
EndFunction

Function SetUp()
	if IsModWorking
		RegisterForCellFullyLoaded(self)
		RegisterForBookRead(self)
		SetValues()
	endif
	UpdateColors()
	UpdateTextures()
EndFunction

Event OnBookRead(Book akBook)
	PO3_SKSEFunctions.StopAllShaders(Game.GetCurrentCrosshairRef())
EndEvent

Event OnCellFullyLoaded(Cell akCell)
	GoToState("Busy")
	LastCell = akCell
	UpdateGlowing()
	GoToState("")
EndEvent

State Busy
Event OnCellFullyLoaded(Cell akCell)
	Cell CurrentCell = GetRef().GetParentCell()
	if CurrentCell != LastCell
		LastCell = akCell
		UpdateGlowing()
	endif
EndEvent
EndState

; Обновляет, но не перенакладывает эффект, если он уже есть
Function UpdateGlowing()
	ObjectReference[] BooksRefs = PO3_SKSEFunctions.FindAllReferencesOfFormType(GetReference(), 27, 0)
	Form[] BooksForms = SkyPal_Bases.From_References(BooksRefs, "...")

	int i = 0
	while i < BooksRefs.Length
		Book CurrentBook = BooksForms[i] as Book
		if !CurrentBook.IsRead() && PO3_SKSEFunctions.GetAllEffectShaders(BooksRefs[i]).Length == 0
			if CurrentBook.HasKeyword(BookXPKeyword) && !Books_XPReaded.HasForm(CurrentBook)
				if Glowing_BookXP
					Shader_BookXP.Play(BooksRefs[i])
				endif
			elseif CurrentBook.GetSpell()
				if Glowing_BookSpell
					Shader_BookSpell.Play(BooksRefs[i])
				endif
			elseif Books_Quest.HasForm(CurrentBook)
				if Glowing_BookQuest
					Shader_BookQuest.Play(BooksRefs[i])
				endif
			elseif Glowing_BookDefault
				Shader_BookDefault.Play(BooksRefs[i])
			endIf
		endif
		i += 1
	endWhile
EndFunction

; Обновляет все эффекты
Function FullUpdateGlowing()
	ObjectReference[] BooksRefs = PO3_SKSEFunctions.FindAllReferencesOfFormType(GetReference(), 27, 0)
	Form[] BooksForms = SkyPal_Bases.From_References(BooksRefs, "...")

	int i = 0
	while i < BooksRefs.Length
		Book CurrentBook = BooksForms[i] as Book
		
		if !CurrentBook.IsRead()
			PO3_SKSEFunctions.StopAllShaders(BooksRefs[i])
			if CurrentBook.HasKeyword(BookXPKeyword) && !Books_XPReaded.HasForm(CurrentBook)
				if Glowing_BookXP
					Shader_BookXP.Play(BooksRefs[i])
				endif
			elseif CurrentBook.GetSpell()
				if Glowing_BookSpell
					Shader_BookSpell.Play(BooksRefs[i])
				endif
			elseif Books_Quest.HasForm(CurrentBook)
				if Glowing_BookQuest
					Shader_BookQuest.Play(BooksRefs[i])
				endif
			elseif Glowing_BookDefault
				Shader_BookDefault.Play(BooksRefs[i])
			endif
		endIf
		i += 1
	endWhile
EndFunction

Function SetShaderColor(EffectShader akShader, int[] RGB, float afAlpha = 1.0)
	SetMembraneColorKeyData(akShader, 1, RGB, afAlpha, -1.0)
	SetMembraneColorKeyData(akShader, 2, RGB, afAlpha, -1.0)
	SetMembraneColorKeyData(akShader, 3, RGB, afAlpha, -1.0)
EndFunction

Function UpdateColors()
	float Alpha = _GlowingAlpha / 100
	SetShaderColor(Shader_BookDefault, DbColorFunctions.IntToRGB(Color_BookDefault), Alpha)
	SetShaderColor(Shader_BookQuest, DbColorFunctions.IntToRGB(Color_BookQuest), Alpha)
	SetShaderColor(Shader_BookSpell, DbColorFunctions.IntToRGB(Color_BookSpell), Alpha)
	SetShaderColor(Shader_BookXP, DbColorFunctions.IntToRGB(Color_BookXP), Alpha)
EndFunction
	
Function UpdateTextures()
	SetMembraneFillTexture(Shader_BookXP, _TextureNames[_GlowTextureID])
	SetMembraneFillTexture(Shader_BookSpell, _TextureNames[_GlowTextureID])
	SetMembraneFillTexture(Shader_BookQuest, _TextureNames[_GlowTextureID])
	SetMembraneFillTexture(Shader_BookDefault, _TextureNames[_GlowTextureID])
EndFunction