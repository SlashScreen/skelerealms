@tool
class_name PuppetSpawnerComponent
extends SKEntityComponent
## Manages spawning and despawning of puppets.


var prefab: PackedScene
## The puppet node.
var puppet:Node 

signal spawned_puppet(puppet:Node)
signal despawned_puppet


func _init() -> void:
	name = "PuppetSpawnerComponent"


func _ready():
	if Engine.is_editor_hint():
		return
	super._ready()
	# brute force getting the puppet for the player if it already exists.
	if get_child_count() > 0:
		puppet = get_child(0)


func get_world_entity_preview() -> Node:
	return get_child(0)


func _on_enter_scene() -> void:
	spawn()


func _on_exit_scene() -> void:
	despawn()


## Spawn a new puppet.
func spawn():
	var n:Node3D
	if not prefab and get_child_count() > 0:
		var ps: PackedScene = PackedScene.new()
		ps.pack(get_child(0))
		prefab = ps
		n = get_child(0)
	else:
		if not prefab:
			printe("Failed spawning: no prefab.")
			return
		n = prefab.instantiate()
		add_child(n)
	n.set_position(parent_entity.position)
	puppet = n
	spawned_puppet.emit(puppet)
	printe("spawned at %s : %s" % [parent_entity.world, parent_entity.position])


## Despawn a puppet.
func despawn():
	printe("despawned.")
	if not prefab:
		var ps: PackedScene = PackedScene.new()
		ps.pack(get_child(0))
		prefab = ps
	
	for n in get_children():
		n.queue_free()
	puppet = null
	despawned_puppet.emit()


## Set the puppet's position.
func set_puppet_position(pos:Vector3):
	if not puppet == null:
		(puppet as Node3D).position = pos
