@tool
extends Node
## Network baker for the coarse navigation system.
## Generates navigation networks from navigation meshes by:
## 1. Creating navigation points from mesh triangles
## 2. Connecting points that share vertices
## 3. Pruning small triangles
## 4. Building an octree for spatial queries
## 5. Adding portals and their connections


const MIN_TRI_SIZE := 1.0
const Octree = preload("res://addons/skelerealms/scripts/network/octree.gd")

## Navigation mesh to generate the network from
@export var nav_mesh: NavigationMesh

## Button to trigger network baking
@export_tool_button("Bake") var bake_fn = bake


## Bakes a coarse navigation network from the navigation mesh
## Returns: A new CoarseNetwork instance
func bake() -> CoarseNetwork:
	var barycenters: Array[Vector3]
	var areas: Dictionary[int, float] = {}
	var vert_map: Dictionary[int, PackedInt32Array] = {}
	
	# Stage 1: Create navigation points from mesh triangles
	var verts: PackedVector3Array = nav_mesh.get_vertices()
	for i: int in nav_mesh.get_polygon_count():
		var polygon: PackedInt32Array = nav_mesh.get_polygon(i)
		var point_a: Vector3 = verts[polygon[0]]
		var point_b: Vector3 = verts[polygon[1]]
		var point_c: Vector3 = verts[polygon[2]]
		
		var barycenter: Vector3 = get_barycenter(point_a, point_b, point_c)
		var area: float = area_of_triangle(point_a, point_b, point_c)
		
		var b_idx: int = barycenters.size()
		barycenters.append(barycenter)
		areas[b_idx] = area
		vert_map.get_or_add(point_a, PackedInt32Array()).append(b_idx)
		vert_map.get_or_add(point_b, PackedInt32Array()).append(b_idx)
		vert_map.get_or_add(point_c, PackedInt32Array()).append(b_idx)
	
	# Stage 2: Connect points that share vertices
	var connections: Array[Connection] = []
	var connections_map: Dictionary[int, Array] = {}
	for v_idx: int in vert_map:
		var vert_shares: PackedInt32Array = vert_map[v_idx]
		for a: int in vert_shares:
			for b: int in vert_shares:
				if a == b:
					continue
				var c := Connection.new(a, b)
				connections.append(c)
				connections_map.get_or_add(a, []).append(c)
				connections_map.get_or_add(b, []).append(c)
	
	# Stage 2.5: Prune small triangles
	var to_remove := PackedInt32Array()
	for idx: int in areas.size():
		if areas[idx] < MIN_TRI_SIZE:
			to_remove.append(idx)
	
	for idx: int in to_remove:
		var others := PackedInt32Array()
		# Get connected points
		for c: Connection in connections_map.get_or_add(idx, []):
			var other_idx: int
			if c.a == idx:
				other_idx = c.b
			else:
				other_idx = c.a
			others.push_back(other_idx)
			connections_map.get_or_add(idx, []).erase(c)
			connections.erase(c)
		# Connect remaining points
		for a: int in others:
			for b: int in others:
				if a == b: continue
				var c := Connection.new(a, b)
				connections.append(c)
				connections_map.get_or_add(a, []).append(c)
				connections_map.get_or_add(b, []).append(c)
	
	# Remove pruned points
	for idx: int in to_remove:
		areas.erase(idx)
		barycenters.remove_at(idx)
	
	# Stage 3: Generate octree for spatial queries
	var max_point: Vector3 = barycenters.max()
	var max_dist: float = Vector3.ZERO.distance_to(max_point)
	var min_point: Vector3 = barycenters.min()
	var min_dist: float = Vector3.ZERO.distance_to(min_point)
	
	var longest_distance: float = max_point[max_point.max_axis_index()] if max_dist > min_dist else min_point[min_point.max_axis_index()]
	var octree := Octree.new()
	octree.aabb = AABB(-Vector3(longest_distance, longest_distance, longest_distance), Vector3(longest_distance, longest_distance, longest_distance) * 2.0)
	
	for pos: int in barycenters.size():
		octree.insert(barycenters, pos)
	
	# Stage 4: Add portals and their connections
	var portals: Array[Node] = get_tree().get_nodes_in_group(&"network portal")
	var connection_info: Array = (
		portals
		.filter(func(x: Node) -> bool: return x.has_method(&"get_coarse_nav_info"))
		.map(func(x: Node) -> Dictionary: return x.get_coarse_nav_info())
	)
	var portal_info: Dictionary[int, Dictionary] = {}
	for info: Dictionary in connection_info:
		var closest_index: int = octree.find_nearest_point(barycenters, info.position).best_point
		barycenters.append(info.position)
		var portal_index: int = barycenters.size() - 1
		portal_info[portal_index] = {
			&"destination_world": info.destination_world,
			&"destination_position": info.destination_position,
		}
		connections.append(Connection.new(portal_index, closest_index))
	
	# Stage 5: Build final network
	var coarse_network := CoarseNetwork.new()
	var compressed_connections := PackedInt64Array()
	for c: Connection in connections:
		compressed_connections.append(c.a)
		compressed_connections.append(c.b)
	coarse_network.connections = compressed_connections
	coarse_network.octree = octree
	coarse_network.positions = barycenters
	coarse_network.portals = portals
	coarse_network.portal_destinations = portal_info
	coarse_network.portal_connections = analyze_portals(barycenters, portals, connections)
	
	return coarse_network


## Analyzes portal connectivity within a world
## Inspired by Factorio's portal optimization (https://factorio.com/blog/post/fff-317)
## Pre-computes which portals can reach each other to avoid runtime pathfinding
## [param points] Array of all navigation points
## [param portals] Array of portal indices
## [param node_connections] Array of connections between nodes
## Returns: Array of portal-to-portal connections
func analyze_portals(points: PackedVector3Array, portals: PackedInt64Array, node_connections: Array[Connection]) -> PackedInt64Array:
	var portal_connections := PackedInt64Array()
	# Set up A* for pathfinding
	var astar := AStar3D.new()
	astar.reserve_space(points.size())
	for p_idx: int in points.size():
		astar.add_point(p_idx, points[p_idx])
	for c: Connection in node_connections:
		astar.connect_points(c.a, c.b)
	# Check portal connectivity
	for a: int in portals:
		for b: int in portals:
			if a == b: continue
			var path: PackedInt64Array = astar.get_id_path(a, b)
			if not path.is_empty():
				portal_connections.push_back(a)
				portal_connections.push_back(b)
	
	return portal_connections


## Calculates the area of a triangle
## [param point_a] First vertex
## [param point_b] Second vertex
## [param point_c] Third vertex
## Returns: Area of the triangle
func area_of_triangle(point_a: Vector3, point_b: Vector3, point_c: Vector3) -> float:
	var side_a := point_a.distance_to(point_b)
	var side_b := point_b.distance_to(point_c)
	var side_c := point_c.distance_to(point_a)

	var semi_perimeter: float = (side_a + side_b + side_c) / 2.0
	return sqrt(semi_perimeter * (semi_perimeter - side_a) * (semi_perimeter - side_b) * (semi_perimeter - side_c))


## Calculates the barycenter (centroid) of a triangle
## [param point_a] First vertex
## [param point_b] Second vertex
## [param point_c] Third vertex
## Returns: Barycenter of the triangle
func get_barycenter(point_a: Vector3, point_b: Vector3, point_c: Vector3) -> Vector3:
	return (point_a + point_b + point_c) / 3.0


## Represents a connection between two navigation points
class Connection:
	## First point index
	var a: int
	
	## Second point index
	var b: int
	
	## Creates a new connection
	## [param p_a] First point index
	## [param p_b] Second point index
	func _init(p_a: int, p_b: int) -> void:
		a = p_a
		b = p_b
