Scriptname _Pitch_EasyWheelMenu_Quest extends EWM_HandleModBase  

_Pitch_TentPitcher_Quest Property TentPitcher Auto
Spell[] Property Powers Auto

; Easy Wheel indices
; 0 _Pitch_PitchTent
; 1 _Pitch_PitchMisc
; 2 _Pitch_PitchAny

Event OnHandlerInit()
	ConsoleUtil.PrintMessage("TentPitcher: EasyWheelMenu handler init")
EndEvent

Event On_Pitch_PitchTent()
	TentPitcher.DoPitchTent()
EndEvent

Event On_Pitch_Misc()
	TentPitcher.DoPitchMisc()
EndEvent

Event On_Pitch_Any()
	TentPitcher.DoPitchAny()
EndEvent

Spell Function GetFunctionSpell(int ixFunc)
	If ixFunc >= 0 && ixFunc < Powers.length && Powers[ixFunc]
		return Powers[ixFunc]
	EndIf
	
	return None
EndFunction