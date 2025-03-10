class_name NavPoint
extends RefCounted
## A point in the navigation system representing a location in a specific world.
## Used for pathfinding and position tracking in the granular navigation system.
## Reference counted to allow efficient memory management when used in navigation paths.


## The 3D position of this navigation point
var position: Vector3

## The identifier of the world this point belongs to
var world: String


## Creates a new navigation point
## [param w] The world identifier
## [param pos] The 3D position in the world
func _init(w: String, pos: Vector3) -> void:
	world = w
	position = pos
