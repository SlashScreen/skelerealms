extends GutTest
## Tests for core systems.

var entity:Entity
var test_cam:Camera3D
var test_world_root:Node


func before_all() -> void:
	entity = Entity.new()
	entity.world = &"test_world"
	entity.position = Vector3()
	
	test_cam = Camera3D.new()
	test_cam.position = Vector3()
	GameInfo.active_camera = test_cam
	
	test_world_root = Node.new()
	
	test_world_root.add_child(entity)
	test_world_root.add_child(test_cam)
	
	add_child(test_world_root)


## Test in world
func test_in_world() -> void:
	GameInfo.world = &"test_world"
	test_cam.position = Vector3(0, 0, 0)
	gut.simulate(entity, 1, 0.1) # advance a frame
	assert_eq(entity.in_scene, true, "Should pass- entity should be in scene here - in world, in range.")


## Test out of world
func test_out_world() -> void:
	GameInfo.world = &"another_test_world"
	test_cam.position = Vector3(0, 0, 0)
	gut.simulate(entity, 1, 0.1) # advance a frame
	assert_eq(entity.in_scene, false, "Should fail- entity should not be in scene here - not in world, in range.")


## Test in world, out of range
func test_out_of_range() -> void:
	GameInfo.world = &"test_world"
	test_cam.position = Vector3(1000, 0, 0)
	gut.simulate(entity, 1, 0.1) # advance a frame
	assert_eq(entity.in_scene, false, "Should fail- entity should not be in scene here - same world, not in range.")


## Test out of world, out of range
func test_out_of_world_and_range() -> void:
	GameInfo.world = &"another_test_world"
	test_cam.position = Vector3(0, 0, 0)
	gut.simulate(entity, 1, 0.1) # advance a frame
	assert_eq(entity.in_scene, false, "Should fail- entity should not be in scene here - not in world, not in range.")


func after_all() -> void:
	test_world_root.queue_free()
