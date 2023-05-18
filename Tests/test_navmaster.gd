extends GutTest


var nmaster:NavMaster
var ndata:Network


func get_children_recursive(n:Node) -> Array[Node]:
	var res:Array[Node] = []
	for c in n.get_children():
		res.append(c)
		res.append_array(get_children_recursive(c))
	return res


func find_closest_brute_force(goal:Vector3, nodes:Array) -> Vector3:
	nodes.sort_custom(func(a, b): return a.position.distance_squared_to(goal) < b.position.distance_squared_to(goal))
	return nodes.front().position


func before_all() -> void:
	ndata = load("res://Tests/TestAssets/test network2.tres")


func before_each() -> void:
	nmaster = autofree(NavMaster.new())
	add_child(nmaster)


func test_load() -> void:
	assert_ne(ndata.points, [], "Should pass: Data should be loaded.")


func test_build_network() -> void:
	nmaster._load_from_networks({&"net test":ndata})
	nmaster.print_tree_pretty()
	assert_gt(nmaster.get_child_count(), 0)
	var to_check = get_children_recursive(nmaster.get_child(0).get_child(0)) # should be root of tree
	for n in to_check:
		var p = n.get_parent() as NavNode
		# check less than if left
		if n == p.left_child:
			if not n.position[p.dimension] == p.position[p.dimension]:
				assert_lt(n.position[p.dimension], p.position[p.dimension], "This node should be to the 'left' of the parent.")
		else: # check greater than if right
			if not n.position[p.dimension] == p.position[p.dimension]:
				assert_gt(n.position[p.dimension], p.position[p.dimension], "This node should be to the 'right' of the parent.")


func test_find_closest_point() -> void:
	nmaster._load_from_networks({&"net test":ndata})
	nmaster.print_tree_pretty()
	var pt = Vector3(1, 0, 5)
	var correct = find_closest_brute_force(pt, get_children_recursive(nmaster.get_child(0)))
	var closest = nmaster.nearest_point(NavPoint.new(&"net test", pt))
	if not closest:
		fail_test("A node should be found.")
		return
	assert_eq(closest.position, correct, "Should pass. That is the closest node.")


func test_find_path() -> void:
	nmaster._load_from_networks({&"net test":ndata})
	var start = NavPoint.new(&"net test", Vector3(1, 0, 1))
	var end = NavPoint.new(&"net test", Vector3(-1, 0, -5))
	var path = nmaster.calculate_path(start, end)
	# TODO: Make sure that path is actually correct
	assert_gt(path.filter(func(x:NavPoint): return x.position), [Vector3(-2.809, 0, 1.494), Vector3(-6.11, 0, -2.782), Vector3(-2.54, 0, -6.143)])

# TODO: Test path between worlds
