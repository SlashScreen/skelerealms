class_name NavigatorComponent
extends SKEntityComponent
## Handles finding paths through the granular navigation system. See [NavigationMaster].


## Calculate a path from the entity's current position to a [NavPoint].
## Array is empty if no path is found.
func calculate_path_to(pt:NavPoint) -> Array[NavPoint]:
	var start := NavPoint.new(parent_entity.world, parent_entity.position)
	return NavMaster.instance.calculate_path(start, pt)


func _init() -> void:
	name = "NavigatorComponent"
