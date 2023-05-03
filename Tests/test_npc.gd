extends GutTest
## Tests the functions of NPCs and their various functions.


func setup_npc() -> Node:
	var em:EntityManager = autofree(EntityManager.new())
	em.name = "EntityManager"
	em.add_entity(load("res://Tests/test_dummy_instance.tres"))
	
	var test_cam = autofree(Camera3D.new())
	test_cam.position = Vector3()
	GameInfo.active_camera = test_cam
	
	var test_world_root = autofree(Node.new())
	
	test_world_root.add_child(em)
	test_world_root.add_child(test_cam)
	return test_world_root


func test_damage() -> void:
	var root = setup_npc()
	add_child(root)
	var em:EntityManager = root.get_child(0)
	var npc:Entity = em.get_entity("test_dummy").unwrap()
	var damage_module:DefaultDamageModule = (npc.get_component("NPCComponent").unwrap() as NPCComponent).data.modules.filter(func(x:AIModule): return x is DefaultDamageModule).front()
	#var npc_component:NPCComponent = (npc.get_component("NPCComponent").unwrap() as NPCComponent)
	var damage_component:DamageableComponent = (npc.get_component("DamageableComponent").unwrap() as DamageableComponent)
	var vitals_component:VitalsComponent = (npc.get_component("VitalsComponent").unwrap() as VitalsComponent)
	
	# Test blunt damage
	vitals_component.vitals["health"] = 100
	damage_component.damage(DamageInfo.new("", {&"blunt":10}))
	assert_eq(vitals_component.vitals["health"], 90, "Should pass - Took 10 blunt damage without modifiers.")
	
	# Test resistance
	vitals_component.vitals["health"] = 100
	damage_module.piercing_modifier = 0.5
	damage_component.damage(DamageInfo.new("", {&"piercing":10}))
	assert_eq(vitals_component.vitals["health"], 95, "Should pass - Took 10 piercing damage with a 0.5 modifier.")
	
	# Test stacked magic resistance
	vitals_component.vitals["health"] = 100
	damage_module.light_modifier = 0.5
	damage_module.magic_modifier = 0.5
	damage_component.damage(DamageInfo.new("", {&"light":10}))
	assert_eq(vitals_component.vitals["health"], 97.5, "Should pass - Took 10 light damage with a 0.5 light modifier and a 0.5 magic modifier.")
	
	# Test stamina damage
	vitals_component.vitals["moxie"] = 100
	damage_component.damage(DamageInfo.new("", {&"moxie":10}))
	assert_eq(vitals_component.vitals["moxie"], 90, "Should pass - Took 10 stamina damage without modifiers.")
	
	# Test will damage
	vitals_component.vitals["will"] = 100
	damage_component.damage(DamageInfo.new("", {&"will":10}))
	assert_eq(vitals_component.vitals["will"], 90, "Should pass - Took 10 will damage without modifiers.")
