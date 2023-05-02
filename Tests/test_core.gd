extends GutTest
## Tests for core systems.


## Test in-scene determination behavior
func test_in_scene() -> void:
	# set up environment
	var entity = autofree(Entity.new())
	entity.world = &"test_world"
	entity.position = Vector3()
	
	var test_cam = autofree(Camera3D.new())
	test_cam.position = Vector3()
	GameInfo.active_camera = test_cam
	
	var test_world_root = autofree(Node.new())
	
	test_world_root.add_child(entity)
	test_world_root.add_child(test_cam)
	
	# Test in world
	GameInfo.world = &"test_world"
	test_cam.position = Vector3(0, 0, 0)
	gut.simulate(entity, 1, 0.1) # advance a frame
	assert_true(entity.in_scene, "Should pass- entity should be in scene here - in world, in range.")
	
	# Test out of world
	GameInfo.world = &"another_test_world"
	test_cam.position = Vector3(0, 0, 0)
	gut.simulate(entity, 1, 0.1) # advance a frame
	assert_false(entity.in_scene, "Should fail- entity should not be in scene here - not in world, in range.")
	
	# Test in world, out of range
	GameInfo.world = &"test_world"
	test_cam.position = Vector3(1000, 0, 0)
	gut.simulate(entity, 1, 0.1) # advance a frame
	assert_false(entity.in_scene, "Should fail- entity should not be in scene here - in world, not in range.")
	
	# Test out of world, out of range
	GameInfo.world = &"another_test_world"
	test_cam.position = Vector3(0, 0, 0)
	gut.simulate(entity, 1, 0.1) # advance a frame
	assert_false(entity.in_scene, "Should fail- entity should not be in scene here - not in world, not in range.")
