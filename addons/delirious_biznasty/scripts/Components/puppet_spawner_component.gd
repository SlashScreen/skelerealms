class_name PuppetSpawnerComponent
extends EntityComponent
## Manages spawning and despawning of puppets.

## The puppet node.
var puppet:Node 


func _ready():
	super._ready()
	name = "PuppetSpawnerComponent"


## Spawn a new puppet.
func spawn(data:PackedScene):
	var n = data.instantiate()
	(n as Node3D).set_position(parent_entity.position)
	puppet = n
	add_child(n)


## Despawn a puppet.
func despawn():
	for n in get_children():
		remove_child(n)
	puppet = null


## Set the puppet's position.
func set_puppet_position(pos:Vector3):
	if not puppet == null:
		(puppet as Node3D).position = pos
