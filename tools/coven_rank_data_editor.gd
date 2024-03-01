extends Control


const COVEN_EDITOR = preload("coven_editor.tscn")

var editing:CovenRankData

signal delete_requested


func edit(c:CovenRankData) -> void:
	editing = c
	_load()


func _load() -> void:
	$Panel/HBoxContainer/VBoxContainer/HBoxContainer/SpinBox.value = editing.rank
	if not editing.coven == null:
		$Panel/HBoxContainer/VBoxContainer/Coven/VBoxContainer/Label.text = editing.coven.resource_path


func open_coven_editor() -> void:
	var w:Window = Window.new()
	w.close_requested.connect(w.queue_free.bind())
	w.position = EditorInterface.get_base_control().size / 2 - (EditorInterface.get_base_control().size / 4)
	w.min_size = EditorInterface.get_base_control().size / 2
	
	var c:Node = COVEN_EDITOR.instantiate()
	c.edit(editing.coven)
	w.add_child(c)
	
	EditorInterface.get_base_control().add_child(w)
	w.show()


func _on_button_pressed() -> void:
	open_coven_editor()


func _on_spin_box_value_changed(value: float) -> void:
	editing.rank = floori(value)


func _on_delete_pressed() -> void:
	delete_requested.emit()
