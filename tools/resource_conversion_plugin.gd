@tool
extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is InstanceData


func _parse_begin(object: Object) -> void:
	var id := object as InstanceData
	var b := Button.new()
	b.text = "Convert to Entity"
	b.pressed.connect(_convert.bind(id))
	add_custom_control(b)


func _convert(id:InstanceData) -> void:
	var ps:PackedScene = id.convert_to_scene()
	if not ps:
		return
	var path := ""
	if id.resource_path.ends_with(".tres"):
		path = id.resource_path.trim_suffix(".tres") + ".tscn"
		ResourceSaver.save(ps, path)
	else:
		path = id.resource_path.trim_suffix(".res") + ".scn"
		ResourceSaver.save(ps, path, ResourceSaver.FLAG_COMPRESS)
