class_name TeleportComponent
extends SKEntityComponent
## Component that enables entities to teleport between different worlds and positions.
## Handles both the logical position update and notifying puppet handlers.


## Emitted when teleporting to update puppet positions
signal teleporting(world:String, position:Vector3)


## Moves the entity to a new world and position
## [param world] The target world identifier
## [param position] The target position in the world
func teleport(world:String, position:Vector3):
	parent_entity.world = world
	parent_entity.position = position
	teleporting.emit(world, position)


func _init() -> void:
	name = &"TeleportComponent"
