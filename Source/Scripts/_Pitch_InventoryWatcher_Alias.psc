ScriptName _Pitch_InventoryWatcher_Alias extends ReferenceAlias

_Pitch_TentPitcher_Quest Property TentPitcher Auto
FormList Property MiscObjectList Auto

Event OnInit()
	AddInventoryEventFilter(MiscObjectList)
	RegisterForModEvent("_Pitch_ModToggled", "OnModToggled")
EndEvent

Event OnModToggled(bool _enabled)
	RemoveAllInventoryEventFilters()
	If _enabled
		AddInventoryEventFilter(MiscObjectList)
	EndIf
EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	TentPitcher.QueueUpdate()
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	TentPitcher.QueueUpdate()
EndEvent