extends Node
## Solver for the coarse navigation system.
## Handles pathfinding across multiple worlds using a hierarchical approach:
## 1. High-level portal network for cross-world navigation
## 2. Per-world A* pathfinding for local movement
## 3. Efficient spatial queries using octrees


const Octree = preload("res://addons/skelerealms/scripts/network/octree.gd")

## Dictionary mapping world names to their navigation data
var worlds: Dictionary[StringName, World] = {}

## Network of portals connecting different worlds
var portal_map: PortalNetwork


## Builds the navigation system from a set of coarse networks
## [param networks] Dictionary mapping world names to their navigation networks
func build(networks: Dictionary[StringName, CoarseNetwork]) -> void:
	portal_map = PortalNetwork.new()
	
	for world_name: StringName in networks:
		var cs: CoarseNetwork = networks[world_name]
		var new_world := World.new()
		new_world.load_network(cs)
		worlds[world_name] = new_world
		
		_compile_portals(new_world, world_name, cs.portals, cs.portal_destinations, cs.portal_connections)
	
	# Add inter-world connections after all worlds are loaded
	for world_name: StringName in worlds:
		var world: World = worlds[world_name]
		for p: int in world.portal_info:
			var p_i: Dictionary = world.portal_info[p]
			
			var dest_world: StringName = p_i.destination_world
			var dest_pos: Vector3 = p_i.destination_position
			var dest_idx: int = worlds[dest_world].get_closest_point(dest_pos)
			portal_map.add_inter_world_connection(world_name, p, dest_world, dest_idx)


## Finds a path between two points in different worlds
## Returns a dictionary containing:
## - positions: Array of path points
## - world_palette: Array of world names
## - worlds: Array of world indices (into palette)
## [param from_world] Starting world
## [param from_position] Starting position
## [param to_world] Target world
## [param to_position] Target position
func find_coarse_path(from_world: StringName, from_position: Vector3, to_world: StringName, to_position: Vector3) -> Dictionary:
	return _render_path_steps(_find_path_steps(from_world, from_position, to_world, to_position))


## Compiles portal connections for a world
## [param world] The world to process
## [param for_world] World identifier
## [param portals] Array of portal indices
## [param portal_info] Portal destination information
## [param portal_connections] Intra-world portal connections
func _compile_portals(world: World, for_world: StringName, portals: PackedInt64Array, portal_info: Dictionary[int, Dictionary], portal_connections: PackedInt64Array) -> void:
	portal_map = PortalNetwork.new()
	
	# Add world portals
	for p: int in portals:
		portal_map.add_world_point(world.get_point_position(p), for_world, p)
	
	# Add precomputed intra-world connections
	for conn_idx in range(0, world.portal_connections.size(), 2):
		portal_map.add_intra_world_connection(for_world, portal_connections[conn_idx], portal_connections[conn_idx + 1])


## Converts path steps into a concrete path
## Returns a dictionary containing:
## - positions: Array of path points
## - world_palette: Array of world names
## - worlds: Array of world indices
## [param steps] Array of navigation steps
func _render_path_steps(steps: Array[CoarseNavStep]) -> Dictionary:
	var res := {
		&"positions": PackedVector3Array(),
		&"world_palette": [],
		&"worlds": PackedInt32Array(),
	}
	
	for step: CoarseNavStep in steps:
		match step:
			var through_step when step is CoarseNavStep.MoveThroughWorldStep:
				var pal_idx: int = res.world_palette.find(through_step.world)
				if pal_idx == -1:
					pal_idx = res.world_palette.size()
					res.world_palette.append(through_step.world)
				
				for p: Vector3 in through_step.path:
					res.positions.append(p)
					res.worlds.append(pal_idx)
			var between_step when step is CoarseNavStep.MoveBetweenWorldsStep:
				var pal_idx: int = res.world_palette.find(between_step.world)
				if pal_idx == -1:
					pal_idx = res.world_palette.size()
					res.world_palette.append(between_step.to_world)
					
				res.positions.append(between_step.to_pos)
				res.worlds.append(pal_idx)
	
	return res


## Finds the sequence of steps needed to reach a destination
## [param from_world] Starting world
## [param from_position] Starting position
## [param to_world] Target world
## [param to_position] Target position
## Returns: Array of navigation steps
func _find_path_steps(from_world: StringName, from_position: Vector3, to_world: StringName, to_position: Vector3) -> Array[CoarseNavStep]:
	var steps: Array[CoarseNavStep] = []
	
	if from_world == to_world:  # Same world pathfinding
		var step := _find_path_within_world(from_world, from_position, to_position)
		if step:
			steps.append(step)
	else:  # Cross-world pathfinding
		var first_portal: int = portal_map.world_info_to_portal_id[{
			&"world": from_world,
			&"source_index": worlds[from_world].closest_portal(from_position),
		}]
		var last_portal: int = portal_map.world_info_to_portal_id[{
			&"world": to_world,
			&"source_index": worlds[to_world].closest_portal(to_position),
		}]
		
		var portal_path: PackedInt64Array = portal_map.get_id_path(first_portal, last_portal)
		for i: int in portal_path.size() - 1:
			var a: Dictionary = portal_map.portal_id_to_world_info[i]
			var b: Dictionary = portal_map.portal_id_to_world_info[i + 1]
			var w_a: World = worlds[a.world]
			var w_b: World = worlds[b.world]
			
			if a.world == b.world:
				# Intra-world pathfinding between portals
				var step := _find_path_within_world(a.world, w_a.get_point_position(a.source_index), w_a.get_point_position(b.source_index))
				if step:
					steps.append(step)
			else:
				# World transition step
				var step := CoarseNavStep.MoveBetweenWorldsStep.new()
				step.to_world = b.world
				step.to_pos = w_b.get_point_position(b.source_index)
				steps.append(step)
	
	return steps


## Finds a path within a single world
## [param world_name] World to pathfind in
## [param from] Starting position
## [param to] Target position
## Returns: Navigation step containing the path
func _find_path_within_world(world_name: StringName, from: Vector3, to: Vector3) -> CoarseNavStep.MoveThroughWorldStep:
	var world: World = worlds[world_name]
	var from_idx: int = world.get_closest_point(from)
	var to_idx: int = world.get_closest_point(to)
	var path: PackedVector3Array = world.get_point_path(from_idx, to_idx)
	if path.is_empty():
		return null
	
	var step := CoarseNavStep.MoveThroughWorldStep.new()
	step.path = path
	step.world = world_name
	return step


## World-specific navigation data and pathfinding
class World:
	extends AStar3D
	
	## Portal destination information
	var portal_info: Dictionary[int, Dictionary]
	
	## Octree for efficient portal lookups
	var portal_tree: Octree
	
	## Array of node positions
	var points: PackedVector3Array

	## Loads navigation data from a coarse network
	## [param cn] The coarse network to load
	func load_network(cn: CoarseNetwork) -> void:
		reserve_space(cn.positions.size())
		var idx: int = 0

		for p: Vector3 in cn.positions:
			add_point(idx, p)
			idx += 1

		for conn_idx in range(0, cn.connections.size(), 2):
			connect_points(cn.connections[conn_idx], cn.connections[conn_idx + 1])
		
		portal_info = cn.portal_destinations
		
		# Build portal octree
		var new_tree := Octree.new()
		var oct_aabb := AABB()
		for p: int in cn.portals:
			oct_aabb = oct_aabb.expand(cn.positions[p])
		new_tree.aabb = oct_aabb
		for p: int in cn.portals:
			new_tree.insert(cn.positions, p)
		portal_tree = new_tree
		
		points = cn.positions
	
	## Finds the closest portal to a position
	## [param point] Position to find nearest portal to
	## Returns: Index of the nearest portal
	func closest_portal(point: Vector3) -> int:
		return portal_tree.find_nearest_point(points, point).best_point


## Network of portals connecting different worlds
class PortalNetwork:
	extends AStar3D

	const SAME_WORLD_COST := 1.0
	const DIFFERENT_WORLD_COST := 1000.0

	## Maps portal IDs to world information
	var portal_id_to_world_info: Dictionary[int, Dictionary] = {}
	
	## Maps world information to portal IDs
	var world_info_to_portal_id: Dictionary[Dictionary, int] = {}
	
	
	## Adds a portal point to the network
	## [param point] Portal position
	## [param world_name] World containing the portal
	## [param source_index] Index in the world's portal array
	func add_world_point(point: Vector3, world_name: StringName, source_index: int) -> void:
		var p_idx: int = get_point_capacity()
		add_point(p_idx, point)
		portal_id_to_world_info[p_idx] = {
			&"world": world_name,
			&"source_index": source_index,
		}
		world_info_to_portal_id[{
			&"world": world_name,
			&"source_index": source_index,
		}] = p_idx
	

	## Adds a connection between portals in the same world
	## [param world_name] World containing the portals
	## [param from_src] Source portal index
	## [param to_src] Target portal index
	func add_intra_world_connection(world_name: StringName, from_src: int, to_src: int) -> void:
		var from: int = world_info_to_portal_id[{
			&"world": world_name,
			&"source_index": from_src,
		}]
		var to: int = world_info_to_portal_id[{
			&"world": world_name,
			&"source_index": to_src,
		}]
		connect_points(from, to)
	

	## Adds a connection between portals in different worlds
	## [param from_world] Source world
	## [param from_src_idx] Source portal index
	## [param to_world] Target world
	## [param to_src_idx] Target portal index
	func add_inter_world_connection(from_world: StringName, from_src_idx: int, to_world: StringName, to_src_idx: int) -> void:
		var from: int = world_info_to_portal_id[{
			&"world": from_world,
			&"source_index": from_src_idx,
		}]
		var to: int = world_info_to_portal_id[{
			&"world": to_world,
			&"source_index": to_src_idx,
		}]
		connect_points(from, to)
	

	## Computes the cost of traversing between portals
	## [param from_id] Source portal ID
	## [param to_id] Target portal ID
	## Returns: Cost of traversal
	func _compute_cost(from_id: int, to_id: int) -> float:
		if portal_id_to_world_info[from_id].world == portal_id_to_world_info[to_id].world:
			return SAME_WORLD_COST
		else:
			return DIFFERENT_WORLD_COST


	## Estimates the cost to reach the goal
	## [param from_id] Current portal ID
	## [param end_id] Goal portal ID
	## Returns: Estimated cost
	func _estimate_cost(from_id: int, end_id: int) -> float:
		return _compute_cost(from_id, end_id)


## Base class for navigation steps
class CoarseNavStep:
	## Step representing movement within a world
	class MoveThroughWorldStep:
		extends CoarseNavStep
		
		## World being traversed
		var world: StringName
		
		## Path through the world
		var path: PackedVector3Array
	
	## Step representing transition between worlds
	class MoveBetweenWorldsStep:
		extends CoarseNavStep
		
		## Target world
		var to_world: StringName
		
		## Position in target world
		var to_pos: Vector3
