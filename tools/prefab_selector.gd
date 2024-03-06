@tool
extends PanelContainer


var scene:String

signal prefab_set(path:String)


func _on_prefab_target_prefab_set(path: String) -> void:
	prefab_set.emit(path)


func _on_prefab_target_scene_set(s: String) -> void:
	scene = s


func set_path_label(s: String) -> void:
	$VBoxContainer/PathLabel.text = s


func clear() -> void:
	$VBoxContainer/PrefabTarget.texture = null
	$VBoxContainer/PrefabTarget.scene = ""


func set_to_scene(path:String) -> void: 
	$VBoxContainer/PrefabTarget.set_thumb(path)
	set_path_label(path)


func _on_clear_pressed() -> void:
	clear()
	scene = ""
	prefab_set.emit("")
