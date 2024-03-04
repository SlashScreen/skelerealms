@tool
extends PanelContainer


@onready var fd:FileDialog = $FileDialog
var editing:SKLTItemChance
var inspector:Control


func edit(e:SKLTItemChance, i:Control) -> void:
	editing = e
	inspector = i
	$VBoxContainer/Path.text = e.resource_path
	fd.file_selected.connect(func(p:String) -> void:
		var n:ItemData = load(p)
		if n:
			editing.item = n
		)


func _on_open_pressed() -> void:
	fd.show()


func _on_create_pressed() -> void:
	editing.item = ItemData.new()


func _on_inspect_pressed() -> void:
	return


func _on_h_slider_value_changed(value: float) -> void:
	editing.chance = value
