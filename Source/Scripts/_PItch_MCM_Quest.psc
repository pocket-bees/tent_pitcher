ScriptName _Pitch_MCM_Quest extends MCM_ConfigBase

_Pitch_TentPitcher_Quest Property TentPitcher Auto

string Property ModStatus Auto
string Property VersionString Auto
bool Property bEnablePitchTentPower Auto
bool Property bEnablePitchMiscPower Auto

;;; Version 1.0.0
int version = 010000

int Function GetVersion()
	return 010000
EndFunction

Event OnVersionUpdate(int _version)
	If version < 10000
		Debug.Notification("!!! WARNING !!! You have installed a breaking update to Tent Pitcher.")
		Debug.Notification("Breaking change: The FormIDs have changed, nothing will work.")
	EndIf
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