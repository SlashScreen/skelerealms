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


class TestMerchant:
	extends GutTest
	# Test transaction


class TestInventory:
	extends GutTest
	# Test add
	# Test remove
	# Test transfer
	# Test equip
	# Test drop


class TestCrime:
	extends GutTest
	# Test add crime
	# Test bounty
	# Test coven reaction


class TestSkills:
	extends GutTest
	
	var e:Entity
	var skills_component:SkillsComponent
	
	
	func before_each() -> void:
		e = autofree(Entity.new())
		e.add_child(SkillsComponent.new())
		skills_component = e.get_component("SkillsComponent").unwrap()
	
	
	func test_default_level() -> void:
		skills_component.skills = {
			&"short_blade" : 1,
			&"long_blade" : 2,
			&"blunt" : 3,
		}
		assert_eq(skills_component.level, 6, "Should pass. Default level totals skills, which is 6.")
	
	
	func test_manual_level() -> void:
		skills_component.level = 10
		assert_eq(skills_component.level, 10, "Should pass. Manual level set to 10.")
	
	
	func test_save_default() -> void:
		skills_component.skills = {
			&"short_blade" : 1,
			&"long_blade" : 2,
			&"blunt" : 3,
		}
		
		var save_data = skills_component.save()
		assert_eq(save_data, {
			"skills": {
				&"short_blade" : 1,
				&"long_blade" : 2,
				&"blunt" : 3,
			},
			"level": -1
		})
	
	
	func test_save_manual() -> void:
		skills_component.skills = {
			&"short_blade" : 1,
			&"long_blade" : 2,
			&"blunt" : 3,
		}
		skills_component.level = 10
		
		var save_data = skills_component.save()
		assert_eq(save_data, {
			"skills": {
				&"short_blade" : 1,
				&"long_blade" : 2,
				&"blunt" : 3,
			},
			"level": 10
		})
	
	
	func test_load_default() -> void:
		var save_data = {
			"skills": {
				&"short_blade" : 1,
				&"long_blade" : 2,
				&"blunt" : 3,
			},
			"level": -1
		}
		
		skills_component.load_data(save_data)
		assert_eq(skills_component.skills, {
				&"short_blade" : 1,
				&"long_blade" : 2,
				&"blunt" : 3,
			})
		assert_eq(skills_component.level, 6)
	
	
	func test_load_manual() -> void:
		var save_data = {
			"skills": {
				&"short_blade" : 1,
				&"long_blade" : 2,
				&"blunt" : 3,
			},
			"level": 10
		}
		
		skills_component.load_data(save_data)
		assert_eq(skills_component.skills, {
				&"short_blade" : 1,
				&"long_blade" : 2,
				&"blunt" : 3,
			})
		assert_eq(skills_component.level, 10)


class TestAttributes:
	extends GutTest
	
	var e:Entity
	var attributes_component:AttributesComponent
	
	
	func before_each() -> void:
		e = autofree(Entity.new())
		e.add_child(AttributesComponent.new())
		attributes_component = e.get_component("AttributesComponent").unwrap()
	
	
	func test_save() -> void:
		attributes_component.attributes[&"luck"] = 5
		var save_data = attributes_component.save()
		assert_eq(save_data[&"luck"], 5)
	
	
	func test_load() -> void:
		var save_data = {
			&"perception" : 0,
			&"luck" : 5,
			&"amity" : 0,
			&"maxnomity" : 0,
			&"litheness" : 0,
		}
		
		attributes_component.load_data(save_data)
		assert_eq(attributes_component.attributes[&"luck"], 5)
