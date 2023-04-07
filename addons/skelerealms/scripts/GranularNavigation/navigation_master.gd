class_name NavMaster
extends Node
## This is the manager for the [b]Granular Navigation System[/b].
## This is a singleton-like object that will find a path through the game's worlds. [br]
## [b]Granular navigation System[/b][br]
## This system is essentially a low-resolution navmesh that allows actors outside of the scene to continue walking around the worlds, so they will be where the player expects them to be.[br]
## The granular navigation system is split up into "worlds", corresponding to the "worlds" of the game. These are roughly analagous to "cells" in Bethesda games.
## Each [NavWorld] contains [NavNode]s as children that are laid out to match the physical space of a world.
## When NPCs are offscreen, instead of using a navmesh, they will attempt to go to their destination by following these nodes.
## This is done to improve performance. However, be sure not to have [i]too[/i] many entities using this at once, otherwise performance may suffer. 
## See project setting [code]biznasty/granular_navigation_sim_distance[/code] to adjust how far away the actors have to be before they stop using this system and just stay idle.


## Dictionary of references to the roots of KD trees.
var worlds:Dictionary = {}


func calculate_path(start:NavPoint, end:NavPoint) -> Array[NavPoint]:
	var start_node:NavNode = nearest_point(start)
	var end_node:NavNode = nearest_point(end)
	
	var open_list:Array[NavNode] = [start_node]
	var closed_list:Array[NavNode] = []
	
	var g_score:Dictionary = {start_node:0}
	var f_score:Dictionary = {start_node:_heuristic(start_node, end_node)}
	var came_from:Dictionary = {}
	
	while not open_list.is_empty():
		# sort to find lowest f score descending, pushing the lowest score to the end of the list.
		# sorting descending is an optimization: popping from the front of a large array is slower, since it has to reindex everything.
		open_list.sort_custom(func(a:NavNode, b:NavNode): 
			# Lazy add heuristics to f_score
			if not f_score.has(a):
				f_score[a] = _heuristic(a, end_node) + g_score[a]
			if not f_score.has(b):
				f_score[b] = _heuristic(b, end_node) + g_score[b]
				
			if f_score[a] == f_score[b]:
				return g_score[a] > g_score[b]
			else:
				return f_score[a] > f_score[b]
		)
		var current:NavNode = open_list.pop_back() # pop from end of list to get lowest f value
		
		for c in current.connections:
			# if connection already closed, skip
			if closed_list.has(c):
				continue
			
			# If connection is the end node, we found a path.
			if c == end_node:
				return _reconstruct_path(came_from, c)
			
			open_list.append(c) # add to current
			came_from[c] = current # set path parent
			# update G score from previosu to 
			g_score[c] = g_score[current] + current.connections[c]
		
		closed_list.append(current)
	
	return []


func _reconstruct_path(came_from:Dictionary, current:NavNode) -> Array[NavPoint]:
	# potential optimization: Push back and then reverse?
	var path:Array[NavPoint] = [current.nav_point]
	while current in came_from:
		path.push_front(came_from[current].nav_point)
		current = came_from[current]
	return path


func _heuristic(a: NavNode, end:NavNode) -> float:
	# doing the heuristic in this way turns the AStar into Dijkstra unless the nodes are in the same world.
	# this is because, since the worlds are not really euclidean in relation to eachother, it's impossible to find accurate heuristic distances. So we just don't.
	# if we find this too inaccurate, we could keep track of connections between worlds and calculate out heuristics by measuring from door to door. But that's hard.
	if not a.world == end.world:
		return 1000
	else:
		# use squared as a small optimization
		return a.position.distance_squared_to(end.position)


# TODO: load and apply connections
func _load():
	pass


## Find the nav node closest to a given point.
func nearest_point(pt:NavPoint) -> NavNode:
	if not worlds.has(pt.world):
		return null
	
	# recursive descent to find closest leaf
	var current_closest:NavNode = worlds[pt.world].get_closest_point(pt.position)
	
	var walking_node:NavNode = current_closest.get_parent() as NavNode
	while walking_node.get_parent() is NavNode:
		# step 1: compare distance with current closes t:
		if current_closest.position.distance_squared_to(pt.position) > walking_node.position.distance_squared_to(pt.position): # if is further than closest
			current_closest = walking_node # set
			
		# step 2: explore other branches 
		# if the distance betweeen the walking node's splitting plane and the current closest's splitting plane,
		# we want to check the opposite branch, too.
		if abs(walking_node.position[walking_node.dimension] - pt.position[walking_node.dimension]) < \
		abs(current_closest.position[current_closest.dimension] - pt.position[current_closest.dimension]):
			if pt.position[walking_node.dimension] < walking_node.position[walking_node.dimension]: # "is left" check
				walking_node = walking_node.right_child.get_closest_point(pt.position)
			else:
				walking_node = walking_node.left_child.get_closest_point(pt.position)
		
		# ascend up the tree.
		walking_node = walking_node.get_parent() as NavNode
	
	return current_closest


func construct_tree(points:Array[NavPoint]):
	# this constructs a KD tree.
	
	# 1) sort into worlds
	var sorted_points:Dictionary = {}
	for n in points:
		# if point world not already created:
		if not sorted_points.has(n.world):
			# create sort array
			sorted_points[n.world] = Array[NavPoint].new()
		sorted_points[n.world].append(n) # then append
		
	# 2) for each world, select median point from random selection of nodes and add to tree.
	# the median is semi-important to try to make sure the tree isn't lopsided for faster and more accurate lookups.
	for w in sorted_points:
		var median:NavPoint
		# if >= 5 nodes in world, select random and find median
		if sorted_points[w].size() >= 5:
			# select 5 random points
			var selected:Array[NavPoint] = (func():
				var arr: Array[NavPoint] = []
				for i in range(5):
					arr.append(sorted_points[w].pick_random())
				return arr
			).call()
			# Find median point
			var middle_coords:Vector3 = selected.reduce(func(accum:Array, pt:NavPoint): # first we sum up the point coordinates
				accum[0] += pt.position.x
				accum[1] += pt.position.y
				accum[2] += pt.position.z
			).reduce(func(accum:Vector3, num:float): # then we divide each component
				accum[0] = num / 5
				accum[1] = num / 5
				accum[2] = num / 5
			)
			# then we sort by distance to center point. using quared to avoid a sqrt. Sort descending.
			selected.sort_custom(func(a:NavPoint, b:NavPoint): return middle_coords.distance_squared_to(a.position) > middle_coords.distance_squared_to(b.position))
			median = selected.pop_back()
		else: # else, accumulate all of them
			var arr_size = sorted_points[w].size()
			var middle_coords:Vector3 = sorted_points[w].reduce(func(accum:Array, pt:NavPoint): # first we sum up the point coordinates
				accum[0] += pt.position.x
				accum[1] += pt.position.y
				accum[2] += pt.position.z
			).reduce(func(accum:Vector3, num:float): # then we divide each component
				accum[0] = num / arr_size
				accum[1] = num / arr_size
				accum[2] = num / arr_size
			)
			# then we sort by distance to center point. using quared to avoid a sqrt. Sort descending.
			sorted_points[w].sort_custom(func(a:NavPoint, b:NavPoint): return middle_coords.distance_squared_to(a.position) > middle_coords.distance_squared_to(b.position))
			median = sorted_points[w].pop_back()
		# add median
		add_point(median.world, median.position)
	
	# 3) for each world, add all the rest of the points, going by the median.
	# A bit wasteful, maybe, As before, we want to keep the tree balanced.
	for w in sorted_points:
		var median:NavPoint
		while not sorted_points[w].size() == 0: # while loop here, because 1) gdscript doesnt like you editing an array while looping through it, and we want to empty the array anyway
			var arr_size = sorted_points[w].size()
			var middle_coords:Vector3 = sorted_points[w].reduce(func(accum:Array, pt:NavPoint): # first we sum up the point coordinates
				accum[0] += pt.position.x
				accum[1] += pt.position.y
				accum[2] += pt.position.z
			).reduce(func(accum:Vector3, num:float): # then we divide each component
				accum[0] = num / arr_size
				accum[1] = num / arr_size
				accum[2] = num / arr_size
			)
			# then we sort by distance to center point. using quared to avoid a sqrt. Sort descending.
			sorted_points[w].sort_custom(func(a:NavPoint, b:NavPoint): return middle_coords.distance_squared_to(a.position) > middle_coords.distance_squared_to(b.position))
			median = sorted_points[w].pop_back()
			# add median
			add_point(median.world, median.position)
	
	# Cache references to trees
	for c in get_children():
		worlds[c.name] = c as NavWorld


## Add a point to the tree
func add_point(world:String, pos:Vector3):
	var world_node: NavWorld = find_child(world)
	# Add world if it doesnt already exist
	if not world_node:
		world_node = NavWorld.new()
		world_node.name = world
		add_child(world_node)
	
	world_node.add_point(pos)