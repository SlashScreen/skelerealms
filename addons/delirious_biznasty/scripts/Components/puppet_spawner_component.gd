class_name PuppetSpawnerComponent
extends EntityComponent
## Manages spawning and despawning of puppets.

## The puppet node.
var puppet:Node 

signal spawned_puppet(puppet:Node)
signal despawned_puppet

func _ready():
	super._ready()
	name = "PuppetSpawnerComponent"


## Spawn a new puppet.
func spawn(data:PackedScene):
	var n = data.instantiate()
	(n as Node3D).set_position(parent_entity.position)
	puppet = n
	add_child(n)
	spawned_puppet.emit(puppet)
	print("spawned %s at %s" % [parent_entity.name, parent_entity.position])


## Despawn a puppet.
func despawn():
	print("despawned %s" % parent_entity.name)
	for n in get_children():
		remove_child(n)
	puppet = null
	despawned_puppet.emit()


## Set the puppet's position.
func set_puppet_position(pos:Vector3):
	if not puppet == null:
		(puppet as Node3D).position = pos
