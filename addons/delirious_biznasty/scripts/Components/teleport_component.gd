class_name TeleportComponent
extends EntityComponent
## Allows an entity to warp.

## Teleport the entity to a world and position.
func teleport(world:String, position:Vector3):
	parent_entity.world = world
	parent_entity.position = position
