class_name TeleportComponent
extends SKEntityComponent
## Allows an entity to warp.


## Emitted when teleporting. Used to let puppet holders know to move their puppets.
signal teleporting(world:String, position:Vector3)


## Teleport the entity to a world and position.
func teleport(world:String, position:Vector3):
	parent_entity.world = world
	parent_entity.position = position
	teleporting.emit(world, position)


func _init() -> void:
	name = "TeleportComponent"
