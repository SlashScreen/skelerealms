@tool
extends PanelContainer


var editing:CovenRankData

signal delete_requested


func edit(c:CovenRankData) -> void:
	editing = c
	_load()


func _load() -> void:
	$HBoxContainer/VBoxContainer/HBoxContainer/SpinBox.value = editing.rank
	if not editing.coven == null:
		$HBoxContainer/VBoxContainer/Coven/VBoxContainer/Label.text = editing.coven.resource_path


func open_coven_editor() -> void:
	SKToolPlugin.instance._open_window(editing.coven)


func _on_button_pressed() -> void:
	open_coven_editor()


func _on_spin_box_value_changed(value: float) -> void:
	editing.rank = floori(value)


func _on_delete_pressed() -> void:
	delete_requested.emit()
