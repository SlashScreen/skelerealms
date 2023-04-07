class_name InstanceData
extends Resource
## The base class for an instance of an NPC, item, Etc.

@export var ref_id:String
@export var world:String
@export var position:Vector3


## Get all of the entitiy components associated with this type of entity.
## Override this and create the components this needs.
## Example: An item instance should have, say, [ItemComponent], [InteractiveComponent], [PuppetComponent].
func get_archetype_components() -> Array[EntityComponent]:
	return []
