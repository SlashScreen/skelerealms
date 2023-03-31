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
var left_child:NavNode
var right_child:NavNode


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
	# forming an array so we can sort it
	var check:Array[NavNode] = [self]
	if left_child:
		check.append(left_child)
	if right_child:
		check.append(right_child)
	
	# sort by distance to target
	check.sort_custom(func(a:NavPoint, b:NavPoint): return pos.distance_squared_to(a.position) > pos.distance_squared_to(b.position))
	
	var result:NavNode = check.pop_back() # sorts descending so we pop top to find closest
	if result == self:
		return self
	else:
		return result.get_closest_point(pos) # else call child
