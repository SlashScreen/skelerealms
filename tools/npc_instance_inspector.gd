@tool
extends PanelContainer


var editing: NPCInstance


func edit(e:NPCInstance) -> void:
	editing = e
	$VBoxContainer/HBoxContainer.edit(e)
	$VBoxContainer/NPCDataInspector.edit(e.npc_data)
