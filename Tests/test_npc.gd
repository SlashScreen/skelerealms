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
	var em:EntityManager = root.get_child(0)
	var npc:Entity = em.get_entity("test_dummy").unwrap()
	var damage_module:DefaultDamageModule = (npc.get_component("NPCComponent").unwrap() as NPCComponent).data.modules.filter(func(x:AIModule): return x is DefaultDamageModule).front()
	var npc_component:NPCComponent = (npc.get_component("NPCComponent").unwrap() as NPCComponent)
	var damage_component:DamageableComponent = (npc.get_component("DamageableComponent").unwrap() as DamageableComponent)
	var vitals_component:VitalsComponent = (npc.get_component("VitalsComponent").unwrap() as VitalsComponent)
	
	vitals_component.vitals["health"] = 100
	# Test blunt damage
	damage_component.damage(DamageInfo.new("", {&"blunt":10}))
	assert_eq(vitals_component.vitals["health"], 90, "Should pass - Took 10 blunt damage without modifiers.")
