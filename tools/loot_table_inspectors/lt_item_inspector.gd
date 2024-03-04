@tool
extends PanelContainer


@onready var fd:FileDialog = $FileDialog
var editing:SKLTItem
var inspector:Control


func edit(e:SKLTItem, i:Control) -> void:
	editing = e
	inspector = i
	$VBoxContainer/Path.text = e.resource_path
	fd.file_selected.connect(func(p:String) -> void:
		var n:ItemData = load(p)
		if n:
			editing.data = n
		)


func _on_open_pressed() -> void:
	fd.popup_centered()


func _on_create_pressed() -> void:
	editing.data = ItemData.new()


func _on_button_pressed() -> void:
	pass # Replace with function body.
