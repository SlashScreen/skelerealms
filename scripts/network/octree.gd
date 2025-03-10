@tool
extends Resource
## An octree implementation for efficient spatial partitioning.
## Used by the coarse navigation system to quickly find nearest nodes.
## Supports dynamic subdivision and nearest neighbor queries.


const Octree = preload("res://addons/skelerealms/scripts/network/octree.gd")
const MAX_POINT_COUNT: int = 4  ## Maximum points per leaf node before subdivision


## Axis-aligned bounding box defining this octree node's volume
var aabb: AABB

## Array of point indices stored in this node
## Only used in leaf nodes
var data: PackedInt32Array

## Child octree nodes
## Empty for leaf nodes, contains 8 nodes for branch nodes
var children: Array[Octree] = []


## Inserts a point into the octree
## Subdivides the node if it exceeds MAX_POINT_COUNT
## [param points] Array of all point positions
## [param pos] Index of the point to insert
func insert(points: PackedVector3Array, pos: int) -> void:
	if encloses(points[pos]):
		data.append(pos)
		if data.size() >= MAX_POINT_COUNT:
			_subdivide(points)


## Checks if a point is within this node's bounds
## [param point] The point to check
## Returns: true if the point is within the AABB
func encloses(point: Vector3) -> bool:
	return aabb.has_point(point)


## Finds the nearest point to a given position
## Uses recursive traversal with early exit optimization
## [param points] Array of all point positions
## [param point] The point to find nearest to
## [param best_dist] Current best distance (for optimization)
## [param best_point] Current best point index (for optimization)
## Returns: Dictionary containing best_point and best_dist
func find_nearest_point(points: PackedVector3Array, point: Vector3, best_dist := INF, best_point: int = INF) -> Dictionary:
	if not data.is_empty():  # Leaf node
		for p: int in data:
			var dist: float = points[p].distance_squared_to(point)
			if dist < best_dist:
				best_dist = dist
				best_point = p
	elif not children.is_empty():  # Branch node
		var octant: int = _get_octant_containing_point(point)
		match children[octant].find_nearest_point(points, point, best_dist, best_point):
			{&"best_point": var b_p, &"best_dist": var b_d}:
				best_point = b_p
				best_dist = b_d
		
		# Check other octants if they might contain closer points
		var dx: float = abs(point.x - aabb.get_center().x)
		var dy: float = abs(point.y - aabb.get_center().y)
		var dz: float = abs(point.z - aabb.get_center().z)
		
		if min(dx, dy, dz) < best_dist:
			for o: Octree in children:
				match o.find_nearest_point(points, point, best_dist, best_point):
					{&"best_point": var b_p, &"best_dist": var b_d}:
						best_point = b_p
						best_dist = b_d
	
	return {
		&"best_point": best_point,
		&"best_dist": best_dist
	}


## Determines which octant contains a given point
## [param point] The point to check
## Returns: Index of the containing octant (0-7)
func _get_octant_containing_point(point: Vector3) -> int:
	var octant: int = 0
	if point.x >= aabb.get_center().x: octant |= 4
	if point.y >= aabb.get_center().y: octant |= 2
	if point.z >= aabb.get_center().z: octant |= 1
	return octant


## Subdivides this node into 8 child nodes
## Redistributes existing points to children
## [param points] Array of all point positions
func _subdivide(points: PackedVector3Array) -> void:
	var new_octrees: Array = [
		aabb.position,
		aabb.position + Vector3(aabb.size.x, 0.0, 0.0),
		aabb.position + Vector3(0.0, aabb.size.y, 0.0),
		aabb.position + Vector3(0.0, 0.0, aabb.size.z),
		aabb.position + Vector3(aabb.size.x, aabb.size.y, 0.0),
		aabb.position + Vector3(0.0, aabb.size.y, aabb.size.z),
		aabb.position + Vector3(aabb.size.x, 0.0, aabb.size.z),
		aabb.end,
	].map(func(pos: Vector3) -> Octree: 
		var o: Octree = Octree.new()
		o.aabb = AABB(pos, aabb.size / 2.0)
		return o
		)
	
	children = new_octrees
	
	for point: int in data:
		var o: Octree = new_octrees[_get_octant_containing_point(points[point])]
		o.insert(points, point)
	
	data.clear()
