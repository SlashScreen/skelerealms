class_name NavMaster
extends Node
## Master controller for the Granular Navigation System.
## 
## This singleton manages pathfinding across multiple game worlds using a low-resolution
## navigation system. It allows NPCs to navigate when outside the active scene, ensuring
## they reach expected locations without the overhead of full navmesh pathfinding.
##
## The system divides navigation into worlds (similar to cells in Bethesda games):
## - Each [NavWorld] contains [NavNode]s arranged in a k-d tree
## - Nodes represent key navigation points in the physical space
## - NPCs use these points for pathfinding when off-screen
## - Performance is balanced by [code]skelerealms/granular_navigation_sim_distance[/code]
##
## The k-d tree structure enables efficient spatial queries and pathfinding across worlds.
## @deprecated: use [class CoarseNavSolver] instead.

## Singleton instance of the navigation master
static var instance: NavMaster

## Dictionary mapping world names to their navigation world nodes
## Key: World identifier
## Value: [NavWorld] root node of the k-d tree
var worlds: Dictionary = {}


## Initialize singleton and connect to game start event
func _ready() -> void:
	GameInfo.game_started.connect(load_all_networks.bind())
	instance = self


## Calculates a path between two navigation points using A* pathfinding
## Handles cross-world pathfinding by adjusting heuristics
## [param start] Starting navigation point
## [param end] Target navigation point
## Returns: Array of navigation points forming the path
func calculate_path(start: NavPoint, end: NavPoint) -> Array[NavPoint]:
	var start_node: NavNode = nearest_point(start)
	var end_node: NavNode = nearest_point(end)
	
	var open_list: Array[NavNode] = [start_node]
	var closed_list: Array[NavNode] = []
	
	var g_score: Dictionary = {start_node: 0}
	var f_score: Dictionary = {start_node: _heuristic(start_node, end_node)}
	var came_from: Dictionary = {}
	
	while not open_list.is_empty():
		# Sort descending for efficient array operations
		open_list.sort_custom(func(a: NavNode, b: NavNode): 
			# Lazy evaluation of heuristics
			if not f_score.has(a):
				f_score[a] = _heuristic(a, end_node) + g_score[a]
			if not f_score.has(b):
				f_score[b] = _heuristic(b, end_node) + g_score[b]
				
			if f_score[a] == f_score[b]:
				return g_score[a] > g_score[b]
			else:
				return f_score[a] > f_score[b]
		)
		var current: NavNode = open_list.pop_back()
		
		for c in current.connections:
			if closed_list.has(c):
				continue
			
			came_from[c] = current
			
			if c == end_node:
				return _reconstruct_path(came_from, c)
			
			open_list.append(c)
			g_score[c] = g_score[current] + current.connections[c]
		
		closed_list.append(current)
	
	return []


## Reconstructs the path from the A* search results
## [param came_from] Dictionary tracking the path
## [param current] End node to trace back from
## Returns: Array of navigation points forming the path
func _reconstruct_path(came_from: Dictionary, current: NavNode) -> Array[NavPoint]:
	var path: Array[NavPoint] = [current.nav_point]
	while current in came_from:
		path.push_front(came_from[current].nav_point)
		current = came_from[current]
	return path


## Calculates the heuristic distance between two nodes
## Uses a high penalty for cross-world paths to prefer same-world routes
## [param a] Starting node
## [param end] Target node
## Returns: Heuristic distance value
func _heuristic(a: NavNode, end: NavNode) -> float:
	# High cost for cross-world paths since euclidean distance isn't meaningful
	if not a.world == end.world:
		return 1000
	else:
		return a.position.distance_squared_to(end.position)


## Recursively searches down the k-d tree for the nearest point
## [param n] Current node in traversal
## [param goal] Target point to find nearest to
## [param current_closest] Current best match
## Returns: Nearest node found in this branch
func _walk_down(n: NavNode, goal: NavPoint, current_closest: NavNode) -> NavNode:
	if n.position.distance_squared_to(goal.position) < current_closest.position.distance_squared_to(goal.position):
		current_closest = n
	
	if not n.left_child and not n.right_child:
		return current_closest
	
	var is_left: bool = goal.position[n.dimension] < n.position[n.dimension]
	if is_left and n.left_child:
		return _walk_down(n.left_child, goal, current_closest)
	elif not is_left and n.right_child:
		return _walk_down(n.right_child, goal, current_closest)
	else:
		return current_closest


## Finds the navigation node closest to a given point
## Uses k-d tree traversal with backtracking to ensure optimal results
## [param pt] The point to find the nearest node to
## Returns: Nearest navigation node, or null if world not found
func nearest_point(pt: NavPoint) -> NavNode:
	if not worlds.has(pt.world):
		return null
	
	var root = worlds[pt.world].get_child(0)
	var current_closest: NavNode = root
	
	# Initial descent
	current_closest = _walk_down(root, pt, current_closest)
	
	# Backtrack and check other branches
	var walking_node: NavNode = current_closest
	while walking_node.get_parent() is NavNode:
		var p = walking_node.get_parent() as NavNode
		# Check other branch if it might contain a closer point
		if abs(p.position[p.dimension] - pt.position[p.dimension]) < walking_node.position.distance_to(current_closest.position):
			if p.left_child == walking_node and p.right_child:
				current_closest = _walk_down(p.right_child, pt, current_closest)
			elif p.right_child == walking_node and p.left_child:
				current_closest = _walk_down(p.left_child, pt, current_closest)
		walking_node = p
	
	return current_closest


## Constructs k-d trees from a set of navigation points
## Optimizes tree balance by selecting strategic median points
## [param points] Array of navigation points to build trees from
func construct_tree(points: Array[NavPoint]):
	# Sort points by world
	var sorted_points: Dictionary = {}
	for n in points:
		if not sorted_points.has(n.world):
			sorted_points[n.world] = []
		sorted_points[n.world].append(n)
	
	# Initial tree construction with strategic medians
	for w in sorted_points:
		var median: NavPoint
		if sorted_points[w].size() >= 5:
			# Select median from random sample for large sets
			var selected: Array[NavPoint] = (func():
				var arr: Array[NavPoint] = []
				for i in range(5):
					arr.append(sorted_points[w].pick_random())
				return arr
			).call()
			
			var middle_coords: Vector3 = selected.reduce(func(accum: Array, pt: NavPoint):
				accum[0] += pt.position.x
				accum[1] += pt.position.y
				accum[2] += pt.position.z
				return accum
			, [0,0,0]).reduce(func(accum: Vector3, num: float):
				return Vector3(num/5, num/5, num/5)
			)
			
			selected.sort_custom(func(a: NavPoint, b: NavPoint):
				return middle_coords.distance_squared_to(a.position) > middle_coords.distance_squared_to(b.position)
			)
			median = selected.pop_back()
		else:
			# Use true median for small sets
			var arr_size = sorted_points[w].size()
			var middle_coords: Vector3 = sorted_points[w].reduce(func(accum: Array, pt: NavPoint):
				accum[0] += pt.position.x
				accum[1] += pt.position.y
				accum[2] += pt.position.z
				return accum
			, [0,0,0]).reduce(func(accum: Vector3, num: float):
				return Vector3(num/arr_size, num/arr_size, num/arr_size)
			)
			
			sorted_points[w].sort_custom(func(a: NavPoint, b: NavPoint):
				return middle_coords.distance_squared_to(a.position) > middle_coords.distance_squared_to(b.position)
			)
			median = sorted_points[w].pop_back()
		
		add_point(median.world, median.position)
	
	# Add remaining points using dynamic median selection
	for w in sorted_points:
		while not sorted_points[w].is_empty():
			var arr_size = sorted_points[w].size()
			var middle_coords: Vector3 = sorted_points[w].reduce(func(accum: Array, pt: NavPoint):
				accum[0] += pt.position.x
				accum[1] += pt.position.y
				accum[2] += pt.position.z
				return accum
			, [0,0,0]).reduce(func(accum: Vector3, num: float):
				return Vector3(num/arr_size, num/arr_size, num/arr_size)
			)
			
			sorted_points[w].sort_custom(func(a: NavPoint, b: NavPoint):
				return middle_coords.distance_squared_to(a.position) > middle_coords.distance_squared_to(b.position)
			)
			var median = sorted_points[w].pop_back()
			add_point(median.world, median.position)
	
	# Cache world references
	for c in get_children():
		worlds[c.name] = c as NavWorld


## Adds a navigation point to the appropriate world tree
## Creates new world nodes as needed
## [param world] World identifier
## [param pos] Position to add
## Returns: The created navigation node
func add_point(world: String, pos: Vector3) -> NavNode:
	print("Adding a point at %s in world %s" % [pos, world])
	var world_node: NavWorld = get_node_or_null(world)
	
	if not world_node:
		world_node = NavWorld.new()
		world_node.world = world
		world_node.name = world
		worlds[world] = world_node
		add_child(world_node)
	
	return world_node.add_point(pos)


## Creates a bidirectional connection between two navigation nodes
## [param a] First node to connect
## [param b] Second node to connect
## [param cost] Cost of traversing this connection
func connect_nodes(a: NavNode, b: NavNode, cost: float) -> void:
	a.connect_nodes(b, cost)
	b.connect_nodes(a, cost)


## Build a series of KD Trees from [Netowrk]s. Dictionary assumes the key is the world name, and the value is the network.
func _load_from_networks(data:Dictionary):
	# thank god we use RC instead of GC but this is still memory heavy
	# TODO: COnvert to a system using packed arrays and indices. Will be *far* more memory efficient, but a bit difficult to reason about, which is why I did it this way first.
	# use dictionary to hold the point and the new node it contains, to avoid duplicates and to have lookups later
	var added_nodes = {}
	var edges = []
	var portals = []
	var portal_edges = []
	# add each point from each network
	for world in data:
		print("loading world network %s" % world)
		edges.append_array(data[world].edges)
		portals.append_array(data[world].portals)
		portal_edges.append(data[world].portal_edges)
		
		for point in data[world].points + data[world].portals:
			added_nodes[point] = add_point(world, point.position)
	# then go back and connect edges and portals, using the dictionary as a lookup
	for edge in edges:
		connect_nodes(added_nodes[edge.point_a], added_nodes[edge.point_b], edge.cost)
	for edge in portal_edges:
		if added_nodes.has(edge.portal_from) and added_nodes.has(edge.portal_to):
			connect_nodes(added_nodes[edge.portal_from], added_nodes[edge.portal_to], 0)
		else:
			print("Unable to make portal connection. Ensure that connecting world is loaded.")


func _load_from_disk(path:String, networks:Dictionary, regex:RegEx) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if '.tres.remap' in file_name:
				file_name = file_name.trim_suffix('.remap')
			if dir.current_is_dir(): # if is directory, cache subdirectory
				_load_from_disk(file_name, networks, regex)
			else: # if filename, cache filename
				var result = regex.search(file_name)
				if result:
					print("%s/%s" % [path, file_name])
					networks[result.get_string(1) as StringName] = load("%s/%s" % [path, file_name])
			file_name = dir.get_next()
		dir.list_dir_end()


func load_all_networks() -> void:
	print("Loading all networks...")
	var networks = {}
	var path = ProjectSettings.get_setting("skelerealms/networks_path")
	var regex = RegEx.new()
	regex.compile("([^\\/\n\\r]+).tres")
	
	print("Loading from disk...")
	_load_from_disk(path, networks, regex)
	print("Compiling networks...")
	_load_from_networks(networks)
	
	print_tree_pretty()


static func format_point_name(pt:Vector3, world:StringName) -> String:
	return ("%s-%s" % [world, pt]).replace(".", "_")
