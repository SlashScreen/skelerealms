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


class TestNavmaster:
	extends GutTest
	
	var nmaster:NavMaster
	var ndata:Network
	
	
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
	
	
	func test_find_closest_point() -> void:
		nmaster._load_from_networks({&"net test":ndata})
		nmaster.print_tree_pretty()
		var pt = Vector3(1, 0, 1)
		var correct = Vector3(-2.80927, 0, 1.4936)
		var closest = nmaster.nearest_point(NavPoint.new(&"net test", pt))
		if not closest:
			fail_test("A node should be found.")
			return
		assert_eq(closest.position, correct, "Should pass. That is the closest node.")


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
	
	var victim:Entity
	var perpetrator:Entity
	var v_covens_component:CovensComponent
	var p_covens_component:CovensComponent
	
	
	func before_all() -> void:
		CovenSystem.add_coven(load("res://Tests/TestAssets/test_coven_1.tres"))
		CovenSystem.add_coven(load("res://Tests/TestAssets/test_coven_2.tres"))
	
	
	func before_each() -> void:
		victim = autofree(Entity.new())
		victim.name = &"victim"
		victim.add_child(CovensComponent.new([load("res://Tests/TestAssets/test_coven_rank_data_1.tres") as CovenRankData]))
		v_covens_component = victim.get_component("CovensComponent").unwrap()
		
		perpetrator = autofree(Entity.new())
		perpetrator.name = &"perpetrator"
		perpetrator.add_child(CovensComponent.new([load("res://Tests/TestAssets/test_coven_rank_data_2.tres") as CovenRankData]))
		p_covens_component = victim.get_component("CovensComponent").unwrap()
		
		var em:EntityManager = autofree(EntityManager.new())
		em.add_child(victim)
		em.add_child(perpetrator)
		em.entities[&"victim"] = victim
		em.entities[&"perpetrator"] = perpetrator
		
		add_child(em)
		
		CrimeMaster.crimes.clear()
	
	
	func test_add_crime() -> void:
		var crime = Crime.new(&"tomfoolery", &"perpetrator", &"victim")
		CrimeMaster.add_crime(crime)
		assert_eq(CrimeMaster.crimes[&"gut_test_coven_1"]["unpunished"].size(), 1)
	
	
	func test_bounty() -> void:
		CrimeMaster.add_crime(Crime.new(&"tomfoolery", &"perpetrator", &"victim"))
		CrimeMaster.add_crime(Crime.new(&"assault", &"perpetrator", &"victim"))
		assert_eq(CrimeMaster.bounty_for_coven(&"perpetrator", &"gut_test_coven_1"), 10500)
	
	
	func test_coven_opinion_change() -> void:
		CrimeMaster.add_crime(Crime.new(&"assault", &"perpetrator", &"victim"))
		assert_eq(CovenSystem.get_coven(&"gut_test_coven_1").get_crime_modifier(&"perpetrator"), -20)


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
