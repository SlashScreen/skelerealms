@tool
class_name SKWorldEntity
extends Marker3D


# TODO: How to sync position??

@export var sync_position:bool = false:
	set(val):
		if val:
			_sync()
@export var entity:PackedScene:
	set(val):
		entity = val 
		if Engine.is_editor_hint():
			if get_child_count() > 0:
				get_child(0)
			if val:
				add_child(val.instantiate())


func _ready() -> void:
	if Engine.is_editor_hint():
		add_child(entity.instantiate())
	else:
		SKEntityManager.instance.get_entity(entity._bundled.names[0])


func _sync() -> void:
	if not Engine.is_editor_hint():
		return
	
	if not entity:
		return
	
	var e:SKEntity = get_child(0) as SKEntity
	if not e:
		return
	
	var ce := e.duplicate()
	ce.position = global_position
	ce.rotation = quaternion
	ce.world = EditorInterface.get_edited_scene_root().name
	
	var ne := PackedScene.new()
	ne.pack(ce)
	ResourceSaver.save(ne, entity.resource_path)
	entity = ResourceLoader.load(entity.resource_path)
