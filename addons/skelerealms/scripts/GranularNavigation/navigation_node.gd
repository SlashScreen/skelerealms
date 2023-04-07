class_name NavNode
extends Node3D
## A single navigation node in the granular navigation system.


## The connections/edges this node has to other nodes. [br]
## The structure of this dictionary is: [br]
## [Codeblock]
## connected_node_id:NavNode, cost:float
## [/Codeblock]
var connections: Dictionary = {}
var dimension:int
var world:String
var left_child:NavNode
var right_child:NavNode
var nav_point:NavPoint:
	get:
		return NavPoint.build(world, position)


# TODO: Figure out connections
func add_nav_node(pos:Vector3):
	# figure out if the dimension is less or greater than ourselves.
	# equal is treated as greater.
	var is_left:bool = pos[dimension] < position[dimension]
	if is_left:
		# if our left child exists, tell it to add the node.
		if left_child:
			left_child.add_nav_node(pos)
		else:
			var new_n = NavNode.new()
			new_n.position = pos # set position
			new_n.dimension = (dimension + 1) % 3 # set dimension and wrap to 3 dimensions
			add_child(new_n)
			left_child = new_n
	else:
		if right_child:
			right_child.add_nav_node(pos)
		else:
			var new_n = NavNode.new()
			new_n.position = pos
			new_n.dimension = (dimension + 1) % 3
			add_child(new_n)
			right_child = new_n


func get_closest_point(pos:Vector3) -> NavNode:
	var is_left:bool = pos[dimension] < position[dimension]
	
	if is_left:
		if left_child: # if we have a left child, call it instead, 
			return left_child.get_closest_point(pos)
		else: # else it's this
			return self
	else:
		if right_child:
			return right_child.get_closest_point(pos)
		else:
			return self
