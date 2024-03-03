@tool
extends PanelContainer


var editing:SKLTItem


func edit(e:SKLTItem) -> void:
	$VBoxContainer/Path.text = e.resource_path


func _on_open_pressed() -> void:
	pass # Replace with function body.


func _on_create_pressed() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	pass # Replace with function body.
