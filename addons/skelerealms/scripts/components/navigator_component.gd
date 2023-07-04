class_name NavigatorComponent
extends EntityComponent
## Handles finding paths through the granular navigation system. See [NavigationMaster].


## Calculate a path from the entity's current position to a [NavPoint].
## Array is empty if no path is found.
func calculate_path_to(pt:NavPoint) -> Array[NavPoint]:
	# TODO: This
	return []


func _init() -> void:
	name = "NavigatorComponent"
