Scriptname _Pitch_TentPitcher_Quest extends Quest  

Actor Property PlayerRef Auto
Spell[] Property Powers Auto
; Powers[0] = Pitch Tent
; Powers[1] = Pitch Misc
; Powers[2] = Set Up Camp

; Parallel form lists.
;  MiscObjectList should contain the MiscObjects a player clicks on to start placement
FormList Property MiscObjectList Auto
;  ActivatorList should contain the corresponding activator referenced in that object's attached CampPlaceableMiscObject script
FormList Property ActivatorList Auto
; Campfire.esm: isCampfireTentItem (??03AB3C)
Keyword Property TentKeyword Auto

; true = update lists if objects added/removed since last compute
Bool Property UpdateQueued Auto

; bitmask to keep track of which powers are enabled in the MCM
int Property mskEnabledPowers = 0x3 Auto

; TODO localization
; TODO keybinds
; TODO see if I can figure out UISelectionMenu and see if it's faster
; TODO move power management into a generic spell manager script - it's a lot

; States: default    - mod is disabled
;         processing - mod is placing or updating lists
;         idling     - mod is running but idle

;;; INTERFACE

; Place a tent item from the list
Function DoPitchTent()
	Debug.Notification("ERROR: Cannot pitch tent: mod disabled")
	_RemovePowers()
EndFunction

; Place a misc item from the list
Function DoPitchMisc()
	Debug.Notification("ERROR: Cannot pitch misc: mod disabled")
	_RemovePowers()
EndFunction

; Place any item from the list
Function DoPitchAny()
	Debug.Notification("ERROR: Cannot pitch any: mod disabled")
	_RemovePowers()
EndFunction

; Signal that we should update the arrays next time placement is triggered
Function QueueUpdate()
EndFunction

; Change mod state from enabled to disabled
Function ToggleEnabled()
	_GivePowers()
	
	int handle = ModEvent.Create("_Pitch_ModToggled")
	If handle
		ModEvent.PushBool(handle, true)
		ModEvent.Send(handle)
	EndIf
	
	GoToState("Idling")
EndFunction

;;; INTERNAL FUNCTIONS

; Default to enabled on first load
Event OnInit()
	ConsoleUtil.PrintMessage("Tent Pitcher: Initializing")
	_GivePowers()
	GoToState("Idling")
EndEvent

Function _SetPowerEnabled(int _ixPower, bool _bEnabled)
	If _ixPower < 0 || _ixPower >= Powers.length
		return
	EndIf

	int msk = Math.LeftShift(0x1, _ixPower)
	
	If _bEnabled
		mskEnabledPowers = Math.LogicalOr(mskEnabledPowers, msk)
		_GivePowers()
	Else
		mskEnabledPowers = Math.LogicalAnd(mskEnabledPowers, Math.LogicalNot(msk))
		PlayerRef.RemoveSpell(Powers[_ixPower])
	EndIf
EndFunction

Function _GivePowers()
	int ix = 0
	int msk = mskEnabledPowers
	While ix < Powers.length
		If Math.LogicalAnd(msk, 0x1)
			PlayerRef.AddSpell(Powers[ix], false)
		Else
			PlayerRef.RemoveSpell(Powers[ix])
		EndIf
		msk = Math.RightShift(msk, 1)
		ix += 1
	EndWhile
EndFunction

Function _RemovePowers()
	int ix = Powers.length
	While ix
		ix -= 1
		PlayerRef.RemoveSpell(Powers[ix])
	EndWhile
EndFunction

; Getters for our arrays. Compute them lazily.
int Function _GetTentArray()
	If !UpdateQueued && JDB.solveObj(".tentPitcher.inventoryTents")
		return JDB.solveObj(".tentPitcher.inventoryTents")
	EndIf
	
	; Missing array or update needed -- do now
	_BuildInventoryArrays(true)
	return JDB.solveObj(".tentPitcher.inventoryTents")
EndFunction

int Function _GetMiscArray()
	If !UpdateQueued && JDB.solveObj(".tentPitcher.inventoryMisc")
		return JDB.solveObj(".tentPitcher.inventoryMisc")
	EndIf
	
	; Missing array or update needed -- do now
	_BuildInventoryArrays(true)
	return JDB.solveObj(".tentPitcher.inventoryMisc")
EndFunction

int Function _GetAnyArray()
	If !UpdateQueued && JDB.solveObj(".tentPitcher.inventoryAny")
		return JDB.solveObj(".tentPitcher.inventoryAny")
	EndIf
	
	; Missing array or update needed -- do now
	_BuildInventoryArrays(true)
	return JDB.solveObj(".tentPitcher.inventoryAny")
EndFunction

; Create an array of objects in the player's inventory, as indices into the FormList properties	
Function _BuildInventoryArrays(bool _bForce = false)
	If !UpdateQueued && !_bForce
		ConsoleUtil.PrintMessage("Tent Pitcher: _BuildInventoryArrays cancelled - no update needed")
		return
	EndIf

	; Create empty arrays
	If !JDB.solveObjSetter(".tentPitcher.inventoryTents", JArray.object(), true) || \
	   !JDB.solveObjSetter(".tentPitcher.inventoryMisc", JArray.object(), true) || \
	   !JDB.solveObjSetter(".tentPitcher.inventoryAny", JArray.object(), true)
		ConsoleUtil.PrintMessage("Tent Pitcher: ERROR - unable to initialize JArrays")
		return
	EndIf
	
	int inventoryTents = JDB.solveObj(".tentPitcher.inventoryTents")
	int inventoryMisc = JDB.solveObj(".tentPitcher.inventoryMisc")
	int inventoryAny = JDB.solveObj(".tentPitcher.inventoryAny")

	If MiscObjectList.GetSize() != ActivatorList.GetSize()
		ConsoleUtil.PrintMessage("Tent Pitcher: ERROR - size mismatch between MiscObject and Activator formlists!")
		return
	EndIf

	; Iterate the MiscObject list and create our array of valid items to choose
	int ixItems = 0
	int numItems = MiscObjectList.GetSize()
	While ixItems < numItems
		Form item = MiscObjectList.GetAt(ixItems)
		If item && PlayerRef.GetItemCount(item)
			; At least one item in the invetory. Push this ix onto the appropriate array.		
			If item.HasKeyword(TentKeyword)
				JArray.AddInt(inventoryTents, ixItems)
			Else
				JArray.AddInt(inventoryMisc, ixItems)
			EndIf
			; Always add to PitchAny
			JArray.AddInt(inventoryAny, ixItems)
		EndIf
		ixItems += 1
	EndWhile
	
	UpdateQueued = False
EndFunction

Function _DoPitch(int _array)
	int numOptions = JArray.count(_array)
	int ixChoice = -1
	
	If numOptions <= 0
		ConsoleUtil.PrintMessage("Tent Pitcher: Pitch cancelled - no pitchable items in inventory")
		return
	ElseIf numOptions == 1
		; Skip menu - only one option
		ixChoice = JArray.GetInt(_array, 0)
	Else
		; Populate and show menu
		UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
		menu.ResetMenu()
		
		int ix = 0
		While ix < numOptions
			menu.AddEntryItem(MiscObjectList.GetAt(JArray.GetInt(_array, ix)).GetName())
			ix += 1
		EndWhile
		
		menu.OpenMenu()
		ixChoice = JArray.GetInt(_array, menu.GetResultInt())
	EndIf

	MiscObject miscObj = MiscObjectList.GetAt(ixChoice) As MiscObject
	Activator acti = ActivatorList.GetAt(ixChoice) As Activator
	
	If miscObj && acti
		; Taken from the implementation of private function _Camp_ObjectPlacementThreadManager::PlaceableObjectUsed
		CampPlacementIndicator indicator = PlayerRef.PlaceAtMe(acti) As CampPlacementIndicator
		indicator.required_inventory_item = miscObj
		indicator.Ready()
		
		UpdateQueued = true
	EndIf
EndFunction

;;; Running a long-ish function, so ignore any new requests
State Processing
	; Drop any new requests, but notify the user since this is a UI event
	Function DoPitchTent()
		Debug.Notification("Unable to pitch tent: mod is busy")
	EndFunction
	
	Function DoPitchMisc()
		Debug.Notification("Unable to pitch misc: mod is busy")
	EndFunction
	
	Function DoPitchAny()
		Debug.Notification("Unable to pitch any: mod is busy")
	EndFunction
	
	Function QueueUpdate()
		; Ignore the request
	EndFunction
	
	Function ToggleEnabled()
		; Switching to default state will defer cleanup
		GoToState("")
	EndFunction
EndState

;;; Default mod state, process all requests
State Idling
	Function DoPitchTent()
		GoToState("Processing")
		
		_DoPitch(_GetTentArray())
		
		If GetState() == ""
			; Disable triggered during processing
			GoToState("Idling")
			ToggleEnabled()
		EndIf
		
		GoToState("Idling")
	EndFunction
	
	Function DoPitchMisc()
		GoToState("Processing")
		
		_DoPitch(_GetMiscArray())
		
		If GetState() == ""
			; Disable triggered during processing
			ToggleEnabled()
		EndIf
		
		GoToState("Idling")
	EndFunction
	
	Function DoPitchAny()
	GoToState("Processing")
	
	_DoPitch(_GetAnyArray())
	
	If GetState() == ""
		; Disable triggered during processing
		ToggleEnabled()
	EndIf
	
		GoToState("Idling")
	EndFunction
	
	Function QueueUpdate()
		UpdateQueued = true
	EndFunction

	Function ToggleEnabled()
		_RemovePowers()
		JDB.setObj(".tentPitcher", 0)
		
		int handle = ModEvent.Create("_Pitch_ModToggled")
		If handle
			ModEvent.PushBool(handle, false)
			ModEvent.Send(handle)
		EndIf
		
		GoToState("")
	EndFunction
EndState