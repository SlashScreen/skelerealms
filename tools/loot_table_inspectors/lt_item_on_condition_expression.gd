@tool
extends PanelContainer


@onready var ce:CodeEdit = $VBoxContainer/CodeEdit
var editing:SKLTOnCondition


func edit(e:SKLTOnCondition) -> void:
	editing = e
	ce.text = e.condition


func _on_code_edit_text_changed() -> void:
	editing.condition = ce.text


func _on_inspect_pressed() -> void:
	pass # Replace with function body.
