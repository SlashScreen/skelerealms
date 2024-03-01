extends Label


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


func get_thumb(path:String, _preview:Texture2D, thumb:Texture2D, _ud:Variant) -> void:
	text = path
