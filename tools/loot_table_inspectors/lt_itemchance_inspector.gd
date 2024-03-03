@tool
extends PanelContainer


var editing:SKLTItemChance


func edit(e:SKLTItem) -> void:
	$VBoxContainer/Path.text = e.resource_path


func _on_open_pressed() -> void:
	pass # Replace with function body.


func _on_create_pressed() -> void:
	pass # Replace with function body.


func _on_inspect_pressed() -> void:
	pass # Replace with function body.


func _on_h_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
