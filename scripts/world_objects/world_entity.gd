@tool
class_name SKWorldEntity
extends Marker3D


@export var entity:PackedScene:
	set(val):
		entity = val 
		if Engine.is_editor_hint():
			if get_child_count() > 0:
				get_child(0)
			if val:
				_show_preview()


func _ready() -> void:
	if Engine.is_editor_hint():
		_show_preview()
	else:
		SKEntityManager.instance.get_entity(entity._bundled.names[0])


func _show_preview() -> void:
	if not entity:
		return
	var e:SKEntity = entity.instantiate()
	var n:Node = e.get_world_entity_preview().duplicate()
	e.queue_free()
	if not n:
		return
	add_child(n)


func _sync() -> void:
	if not Engine.is_editor_hint():
		return
	
	if not entity:
		return
	
	var e:SKEntity = entity.instantiate()
	if not e:
		return
	
	e.position = global_position
	e.world = EditorInterface.get_edited_scene_root().name
	
	entity.pack(e)
