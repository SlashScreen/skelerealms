class_name NavigatorComponent
extends SKEntityComponent
## Component that handles pathfinding through the granular navigation system.
## Interfaces with NavigationMaster to find paths between navigation points.


## Calculates a path from the entity's current position to a target point
## [param pt] The target navigation point to path to
## [returns] Array of NavPoints representing the path, empty if no path found
func calculate_path_to(pt:NavPoint) -> Array[NavPoint]:
	var start := NavPoint.new(parent_entity.world, parent_entity.position)
	return NavMaster.instance.calculate_path(start, pt)


func _init() -> void:
	name = &"NavigatorComponent"
