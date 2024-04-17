@tool
class_name Prototype
extends Resource


@export var data:RefData


func instantiate_prototype(path:String, base_id: String) -> void:
	if data == null:
		return
	var n:RefData = data.duplicate()
	n.id = base_id
	ResourceSaver.save(n, path)
