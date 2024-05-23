@tool
class_name SKWorldEntity
extends Marker3D


@export var entity:PackedScene:
	set(val):
		entity = val 
		if Engine.is_editor_hint():
			if get_child_count() > 0:
				get_child(0)
			add_child(val.instantiate())


func _ready() -> void:
	if Engine.is_editor_hint():
		add_child(entity.instantiate())
	else:
		SKEntityManager.instance.get_entity(entity._bundled.node_paths[0])
