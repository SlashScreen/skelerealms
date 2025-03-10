class_name NavWorld
extends Node
## A world container in the granular navigation system.
## Manages a k-d tree of navigation nodes for a specific world space.
## Acts as the root node for all navigation points in a given world.


## Initial splitting dimension for the k-d tree (X-axis)
const dimension = 0

## The identifier for this navigation world
@export var world: String


## Adds a navigation point to this world
## Creates the root node if none exists, otherwise delegates to the k-d tree
## [param pos] The 3D position to add
## Returns: The newly created navigation node
func add_point(pos: Vector3) -> NavNode:
	# Create root node if world is empty
	if get_child_count() == 0:
		var new_n = NavNode.new()
		new_n.position = pos
		new_n.dimension = 0  # Start with X dimension
		new_n.world = world
		new_n.name = NavMaster.format_point_name(pos, world)
		add_child(new_n)
		return new_n
	
	# Delegate to existing k-d tree
	return (get_child(0) as NavNode).add_nav_node(pos)


## Finds the closest navigation point to a given position
## [param pos] The position to find the nearest node to
## Returns: The nearest navigation node, or null if world is empty
func get_closest_point(pos: Vector3) -> NavNode:
	if get_child_count() == 0:
		return null
	else:
		return (get_child(0) as NavNode).get_closest_point(pos)
