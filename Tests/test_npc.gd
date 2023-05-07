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


func test_spells() -> void:
	var root = setup_npc()
	add_child(root)
	var em:EntityManager = root.get_child(0)
	var npc:Entity = em.get_entity("test_dummy").unwrap()
	var spell_component:SpellTargetComponent = (npc.get_component("SpellTargetComponent").unwrap() as SpellTargetComponent)
	var vitals_component:VitalsComponent = (npc.get_component("VitalsComponent").unwrap() as VitalsComponent)
	
	var spell:Spell = load("res://Tests/spell.tres")
	# Spell apply
	spell._apply_spell_effect_to(spell_component, spell.spell_effects.front())
	assert_eq(spell_component.active_effects.size(), 1, "Should pass: Effect has been applied to the NPC.")
	# Spell Effect over time
	gut.simulate(root, 10, 0.1)
	assert_almost_eq(vitals_component.vitals["health"], 99, 0.01, "Should pass - Took 1 poison damage over 1 second without modifiers.")
	# Spell removal
	gut.simulate(root, 10, 0.1)
	assert_eq(spell_component.active_effects.size(), 0, "Should pass: Effect has been removed from the NPC.")
	# TODO: Spell released and held?


func test_schedule() -> void:
	var root = setup_npc()
	add_child(root)
	var em:EntityManager = root.get_child(0)
	var npc:Entity = em.get_entity("test_dummy").unwrap()
	var npc_component:NPCComponent = (npc.get_component("NPCComponent").unwrap() as NPCComponent)
	
	# Test at different hours
	npc_component._calculate_new_schedule()
	assert_eq(npc_component._current_schedule_event.name, "sandbox 1", "Should pass - the current schedule should be the first one.")
	
	GameInfo.world_time[&"hour"] = 3
	npc_component._calculate_new_schedule()
	assert_eq(npc_component._current_schedule_event.name, "sandbox 2", "Should pass - the current schedule should be the second one.")
	
	# Test conditions
	GameInfo.continuity_flags["test"] = 1
	npc_component._calculate_new_schedule()
	assert_eq(npc_component._current_schedule_event.name, "schedule overridden", "Should pass - the current schedule should be overridden, since it passes the codition.")


func test_navigation() -> void:
	pass_test("Test not yet implemented")
	# Test in same world
	# Test different worlds


func test_goap() -> void:
	var root = setup_npc()
	add_child(root)
	var em:EntityManager = root.get_child(0)
	var npc:Entity = em.get_entity("test_dummy").unwrap()
	# var npc_component:NPCComponent = (npc.get_component("NPCComponent").unwrap() as NPCComponent)
	var goap_component:GOAPComponent = (npc.get_component("GOAPComponent").unwrap() as GOAPComponent)
	# Part 1: Plan creation
	# Test plan and cost
	goap_component.add_objective({"goal":true}, true, 1)
	gut.simulate(root, 1, 0.01)
	assert_eq(goap_component.action_queue.map(func(x): return x.name), [&"action c", &"action b"], "Should pass. This is the least costly path to the goal, minus the first action.")
	assert_eq(goap_component._current_action.name, &"action a", "Should pass - Current action should be action a")
	# Test conditional path
	npc.world = &"goap"
	goap_component.regenerate_plan()
	gut.simulate(root, 1, 0.01)
	assert_eq(goap_component.action_queue.map(func(x): return x.name), [&"action c", &"action e"], "Should pass. This is the least costly path to the goal with the condition, minus the first action.")
	assert_eq(goap_component._current_action.name, &"action a", "Should pass - Current action should be action a")
	# Part 2: Plan Execution
	gut.simulate(root, 4, 0.01)
	assert_eq(goap_component.objectives, [], "Should pass - objectives finished")
	# Test priority
	# Test repeating
