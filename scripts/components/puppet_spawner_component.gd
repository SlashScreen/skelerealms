@tool
class_name PuppetSpawnerComponent
extends SKEntityComponent
## Component that manages the spawning and despawning of physical puppet representations for entities in the world.
## Handles the transition between granular and full simulation by creating and removing 3D models.

var prefab: PackedScene  ## The scene to instantiate when spawning a new puppet
var puppet: Node  ## The currently active puppet instance in the world

signal spawned_puppet(puppet: Node)  ## Emitted when a new puppet is spawned into the world
signal despawned_puppet  ## Emitted when the current puppet is removed from the world


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


## Creates and adds a new puppet instance to the world
## If no prefab is set but a child exists, packs that child as the prefab
func spawn():
	var n: Node3D
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
	n.rotation = parent_entity.rotation.get_euler()
	puppet = n
	spawned_puppet.emit(puppet)
	printe("spawned at %s : %s" % [parent_entity.world, parent_entity.position])


## Removes the current puppet from the world
## If no prefab is set, packs the current puppet as the prefab before removing
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


## Updates the puppet's position in the world
## [param pos] The new world position for the puppet
func set_puppet_position(pos: Vector3):
	if not puppet == null:
		(puppet as Node3D).position = pos
