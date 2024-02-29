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
