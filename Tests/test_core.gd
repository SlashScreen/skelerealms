extends GutTest
## Tests for core systems.


class TestInScene:
	extends GutTest
	
	
	var test_cam:Camera3D
	var entity:Entity
	
	
	func before_each() -> void:
		entity = autofree(Entity.new())
		entity.world = &"test_world"
		entity.position = Vector3()
		
		test_cam = autofree(Camera3D.new())
		test_cam.position = Vector3()
		GameInfo.active_camera = test_cam
		
		var test_world_root = autofree(Node.new())
		
		test_world_root.add_child(entity)
		test_world_root.add_child(test_cam)
		
		add_child(test_world_root)
	
	
	func test_in_world() -> void:
		GameInfo.world = &"test_world"
		test_cam.position = Vector3(0, 0, 0)
		gut.simulate(entity, 1, 0.1) # advance a frame
		assert_true(entity.in_scene, "Should pass- entity should be in scene here - in world, in range.")
	
	
	func test_out_of_world() -> void:
		GameInfo.world = &"another_test_world"
		test_cam.position = Vector3(0, 0, 0)
		gut.simulate(entity, 1, 0.1) # advance a frame
		assert_false(entity.in_scene, "Should fail- entity should not be in scene here - not in world, in range.")
	
	
	func test_in_world_out_range() -> void:
		GameInfo.world = &"test_world"
		test_cam.position = Vector3(1000, 0, 0)
		gut.simulate(entity, 1, 0.1) # advance a frame
		assert_false(entity.in_scene, "Should fail- entity should not be in scene here - in world, not in range.")
	
	
	func test_out_world_out_range() -> void:
		GameInfo.world = &"another_test_world"
		test_cam.position = Vector3(0, 0, 0)
		gut.simulate(entity, 1, 0.1) # advance a frame
		assert_false(entity.in_scene, "Should fail- entity should not be in scene here - not in world, not in range.")


class TestActivityTimers:
	extends GutTest
	
	
	var test_cam:Camera3D
	var entity:Entity
	var em:EntityManager
	
	
	func before_each() -> void:
		em = autofree(EntityManager.new())
		em.name = "EntityManager"
		entity = autofree(Entity.new())
		entity.world = &"test_world"
		entity.position = Vector3()
		entity.name = &"test_entity" 
		em.entities[entity.name] = entity
		em.add_child(entity)
		
		test_cam = autofree(Camera3D.new())
		test_cam.position = Vector3()
		GameInfo.active_camera = test_cam
		
		var test_world_root = autofree(Node.new())
		
		test_world_root.add_child(em)
		test_world_root.add_child(test_cam)
		
		add_child(test_world_root)
	
	
	func test_stale_timer() -> void:
		var stale_timer_max = ProjectSettings.get_setting("skelerealms/entity_cleanup_timer")
		var step = 0.1
		gut.simulate(entity, (stale_timer_max + 1)/step, step)
		assert_gt(entity.stale_timer, stale_timer_max)
		# test cleanup
		em._cleanup_stale_entities()
		assert_eq(em.get_child_count(), 0)
	
	
	func test_poke() -> void:
		var stale_timer_max = ProjectSettings.get_setting("skelerealms/entity_cleanup_timer")
		var step = 0.1
		gut.simulate(entity, (stale_timer_max + 1)/step/2, step)
		em.get_entity(&"test_entity") # poke entity
		gut.simulate(entity, (stale_timer_max + 1)/step/2, step)
		assert_lt(entity.stale_timer, stale_timer_max)
