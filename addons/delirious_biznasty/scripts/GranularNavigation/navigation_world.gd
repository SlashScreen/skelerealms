class_name NavWorld
extends Node
## A world of the granular navigation system. [br]


@export var world:String


func add_point(pos:Vector3):
	# if we have no childrenm, add one
	if get_child_count() == 0:
		var new_n = NavNode.new()
		new_n.position = pos # set position
		new_n.dimension = 0
		add_child(new_n)
		return
	#else, tell that child to add one
	(get_child(0) as NavNode).add_nav_node(pos)


## Gets closest point in world to a position.
func get_closest_point(pos:Vector3) -> NavNode:
	if get_child_count() == 0:
		return null
	else:
		return (get_child(0) as NavNode).get_closest_point(pos)
