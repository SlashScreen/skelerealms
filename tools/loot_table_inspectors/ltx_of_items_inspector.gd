@tool
extends PanelContainer


var editing:SKLTXOfItem


func edit(e:SKLTXOfItem) -> void:
	editing = e
	$VBoxContainer/HBoxContainer/Min.value = e.x_min
	$VBoxContainer/HBoxContainer2/Max.value = e.x_max


func _on_min_value_changed(value: float) -> void:
	editing.x_min = roundi(value)


func _on_max_value_changed(value: float) -> void:
	editing.x_max = roundi(value)


func _on_inspect_table_pressed() -> void:
	pass # Replace with function body.
