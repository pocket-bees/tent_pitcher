ScriptName _Pitch_MCM_Quest extends MCM_ConfigBase

_Pitch_TentPitcher_Quest Property TentPitcher Auto

string Property ModStatus Auto
string Property VersionString Auto
bool Property bEnablePitchTentPower Auto
bool Property bEnablePitchMiscPower Auto

;;; Version 0.1.0
int version = 000100

int Function GetVersion()
	return version
EndFunction

Event OnVersionUpdate(int _version)
	If version != _version
		version = version
		TentPitcher.Reset()
	EndIf
EndEvent

Event OnConfigInit()
	RegisterForModEvent("_Pitch_ModToggled", "OnModToggled")
	VersionString = "" + version / 10000 + "." + (version / 100) % 10000 + "." + version % 100
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