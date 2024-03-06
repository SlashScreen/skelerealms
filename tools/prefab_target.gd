@tool
extends TextureRect


var scene:String

signal prefab_set(path:String)
signal scene_set(s: String)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false
	if not data.has("files"):
		return false
	if not data.files.size() == 0:
		return false
	return data.files.all(func(x:String) -> bool: return x.ends_with(".tscn") or x.ends_with(".res"))


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	EditorInterface.get_resource_previewer().queue_resource_preview(data.files[0], self, &"get_thumb", null)


func set_thumb(path:String) -> void:
	EditorInterface.get_resource_previewer().queue_resource_preview(path, self, &"_silent_set_thumb", null)


func _silent_set_thumb(path:String, preview:Texture2D, _thumb:Texture2D, _ud:Variant) -> void:
	print(preview)
	scene = path
	texture = preview


func get_thumb(path:String, preview:Texture2D, _thumb:Texture2D, _ud:Variant) -> void:
	scene = path
	scene_set.emit(path)
	texture = preview
	prefab_set.emit(path)
