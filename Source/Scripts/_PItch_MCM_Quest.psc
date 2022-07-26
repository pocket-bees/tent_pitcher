ScriptName _Pitch_MCM_Quest extends MCM_ConfigBase

_Pitch_TentPitcher_Quest Property TentPitcher Auto
_Pitch_EasyWheelMenu_Quest Property EWM Auto

string Property ModStatus Auto
string Property VersionString Auto
bool Property bEnablePitchTentPower Auto
bool Property bEnablePitchMiscPower Auto
bool Property bEnablePitchAnyPower Auto

;;; Version 1.1.1
int version = 010101

int Function GetVersion()
	return 010101
EndFunction

Event OnVersionUpdate(int _version)
	If version / 10000 < _version / 10000
		Debug.Notification("!!! WARNING !!! You have installed a breaking update to Tent Pitcher.")
		return
	EndIf
	ConsoleUtil.PrintMessage("Tent Pitcher: Updating from " + version + " to " + _version)
	
	If _version == 010101
		Debug.Notification("Tent Pitcher: Updated to 1.1.1")
	EndIf
	
	version = _version
	ConsoleUtil.PrintMessage("Tent Pitcher: Update complete.")
EndEvent

Event OnConfigInit()
	RegisterForModEvent("_Pitch_ModToggled", "OnModToggled")
	VersionString = "" + version / 10000 + "." + (version / 100) % 100 + "." + version % 100
EndEvent

Event OnModToggled(bool _bEnabled)
	ConsoleUtil.PrintMessage("TentPitcher: enabled = " + _bEnabled)
	If _bEnabled
		ModStatus = "Running"
	Else
		ModStatus = "Stopped"
	EndIf
EndEvent

Event OnSettingChange(string a_ID)
	If a_ID == "_Pitch_PitchTent_Power_Toggle"
		TentPitcher._SetPowerEnabled(0, bEnablePitchTentPower)
	ElseIf a_ID == "_Pitch_PitchMisc_Power_Toggle"
		TentPitcher._SetPowerEnabled(1, bEnablePitchMiscPower)
	ElseIf a_ID == "_Pitch_PitchAny_Power_Toggle"
		TentPitcher._SetPowerEnabled(2, bEnablePitchAnyPower)
	EndIf
EndEvent

Function ToggleEnabled()
	TentPitcher.ToggleEnabled()
	If ModStatus == "Running"
		ModStatus = "Stopping..."
	Else
		ModStatus = "Starting..."
	EndIf
	ForcePageReset()
EndFunction