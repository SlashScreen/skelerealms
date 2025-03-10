class_name NavNode
extends Node3D
## A node in the granular navigation system implementing a k-d tree structure.
## Each node represents a point in 3D space and maintains connections to other nodes.
## The k-d tree structure allows for efficient spatial partitioning and nearest neighbor searches.


## Connections to other navigation nodes with associated traversal costs
## Dictionary structure: { connected_node: NavNode -> cost: float }
var connections: Dictionary = {}

## Current splitting dimension (0=X, 1=Y, 2=Z) for k-d tree partitioning
var dimension: int

## The world identifier this node belongs to
var world: String

## Left child in the k-d tree (points with smaller coordinate in current dimension)
var left_child: NavNode

## Right child in the k-d tree (points with larger/equal coordinate in current dimension)
var right_child: NavNode

## The navigation point representing this node's position and world
var nav_point: NavPoint:
	get:
		return NavPoint.new(world, position)


## Adds a new navigation node to the k-d tree
## Uses recursive binary space partitioning based on alternating dimensions
## [param pos] The 3D position for the new node
## Returns: The newly created navigation node
func add_nav_node(pos: Vector3) -> NavNode:
	# Determine which child branch to follow based on position comparison
	var is_left: bool = pos[dimension] < position[dimension]
	
	if is_left:
		if left_child:
			return left_child.add_nav_node(pos)
		else:
			var new_n = NavNode.new()
			new_n.position = pos
			new_n.dimension = (dimension + 1) % 3  # Cycle through X,Y,Z dimensions
			new_n.world = world
			new_n.name = NavMaster.format_point_name(pos, world)
			add_child(new_n)
			left_child = new_n
			return new_n
	else:
		if right_child:
			return right_child.add_nav_node(pos)
		else:
			var new_n = NavNode.new()
			new_n.position = pos
			new_n.dimension = (dimension + 1) % 3
			new_n.world = world
			new_n.name = NavMaster.format_point_name(pos, world)
			add_child(new_n)
			right_child = new_n
			return new_n


## Finds the closest navigation node to a given position
## Uses k-d tree traversal for efficient nearest neighbor search
## [param pos] The position to find the closest node to
## Returns: The nearest navigation node
func get_closest_point(pos: Vector3) -> NavNode:
	var is_left: bool = pos[get_parent().dimension] < position[get_parent().dimension]
	
	if is_left:
		if left_child:
			return left_child.get_closest_point(pos)
		else:
			return self
	else:
		if right_child:
			return right_child.get_closest_point(pos)
		else:
			return self


## Creates a connection between this node and another
## [param other] The node to connect to
## [param cost] The traversal cost for this connection
func connect_nodes(other: NavNode, cost: float) -> void:
	connections[other] = cost
