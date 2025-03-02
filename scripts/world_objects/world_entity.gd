@tool
class_name SKWorldEntity
extends Marker3D


@export var entity:PackedScene:
	set(val):
		entity = val 
		if Engine.is_editor_hint():
			if get_child_count() > 0:
				get_child(0).queue_free()
			if val:
				_show_preview()
@export var spawn_new_instance : bool = false ## Whether a new instance of the entity should be generated. If not, spawn this specific entity.


func _ready() -> void:
	if Engine.is_editor_hint():
		_show_preview()
	else:
		if spawn_new_instance:
			SKEntityManager.instance.add_entity_from_scene_at_position(entity, global_position, quaternion, GameInfo.world)
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
		push_warning("Unable to sync entity position: Can only sync while in editor.")
		return
	
	if not entity:
		push_warning("Unable to sync entity position: No entity to sync..")
		return
	
	var e:SKEntity = entity.instantiate()
	if not e:
		push_warning("Unable to sync entity position: Entity could not instantiate.")
		return
	
	e.position = global_position
	e.world = EditorInterface.get_edited_scene_root().name
	
	entity.pack(e)
	ResourceSaver.save(entity, entity.resource_path)
