class_name TestNPC
extends GutTest
## Tests the functions of NPCs and their various functions.


func setup_npc() -> Node:
	var em:EntityManager = autofree(EntityManager.new())
	em.name = "EntityManager"
	em.add_entity(load("res://tests/TestAssets/test_dummy_instance.tres"))
	
	var test_cam = autofree(Camera3D.new())
	test_cam.position = Vector3()
	GameInfo.active_camera = test_cam
	
	var test_world_root = autofree(Node.new())
	
	test_world_root.add_child(em)
	test_world_root.add_child(test_cam)
	
	add_child(test_world_root)
	
	return test_world_root


class TestSpells:
	extends TestNPC
	
	var root
	var em:EntityManager
	var npc:Entity
	var spell_component:SpellTargetComponent
	var vitals_component:VitalsComponent
	var spell:Spell
	
	
	func before_all() -> void:
		spell = load("res://Tests/TestAssets/spell.tres")
	
	
	func before_each() -> void:
		root = setup_npc()
		em = root.get_child(0)
		npc = em.get_entity("test_dummy").unwrap()
		spell_component = (npc.get_component("SpellTargetComponent").unwrap() as SpellTargetComponent)
		vitals_component = (npc.get_component("VitalsComponent").unwrap() as VitalsComponent)
	
	
	func test_spell_apply() -> void:
		spell._apply_spell_effect_to(spell_component, spell.spell_effects.front())
		assert_eq(spell_component.active_effects.size(), 1, "Should pass: Effect has been applied to the NPC.")
	
	
	func test_spell_damage() -> void:
		spell._apply_spell_effect_to(spell_component, spell.spell_effects.front())
		gut.simulate(root, 10, 0.1)
		assert_almost_eq(vitals_component.vitals["health"], 99.0, 0.01, "Should pass - Took 1 poison damage over 1 second without modifiers.")
	
	
	func test_spell_autoremoval() -> void:
		spell._apply_spell_effect_to(spell_component, spell.spell_effects.front())
		gut.simulate(root, 20, 0.1)
		assert_eq(spell_component.active_effects.size(), 0, "Should pass: Effect has been removed from the NPC.")


class TestDamage:
	extends TestNPC
	
	var root
	var em:EntityManager
	var npc:Entity
	var damage_module:DefaultDamageModule
	var damage_component:DamageableComponent
	var vitals_component:VitalsComponent
	
	
	func before_each() -> void:
		root = setup_npc()
		em = root.get_child(0)
		npc = em.get_entity("test_dummy").unwrap()
		damage_module = (npc.get_component("NPCComponent").unwrap() as NPCComponent).data.modules.filter(func(x:AIModule): return x is DefaultDamageModule).front()
		damage_component = (npc.get_component("DamageableComponent").unwrap() as DamageableComponent)
		vitals_component = (npc.get_component("VitalsComponent").unwrap() as VitalsComponent)
	
	
	func test_blunt_damage() -> void:
		vitals_component.vitals["health"] = 100
		damage_component.damage(DamageInfo.new("", {&"blunt":10}))
		assert_eq(vitals_component.vitals["health"], 90.0, "Should pass - Took 10 blunt damage without modifiers.")
	
	
	func test_resistance() -> void:
		vitals_component.vitals["health"] = 100
		damage_module.piercing_modifier = 0.5
		damage_component.damage(DamageInfo.new("", {&"piercing":10}))
		assert_eq(vitals_component.vitals["health"], 95.0, "Should pass - Took 10 piercing damage with a 0.5 modifier.")
	
	
	func test_stacked_magic_resistance() -> void:
		vitals_component.vitals["health"] = 100
		damage_module.light_modifier = 0.5
		damage_module.magic_modifier = 0.5
		damage_component.damage(DamageInfo.new("", {&"light":10}))
		assert_eq(vitals_component.vitals["health"], 97.5, "Should pass - Took 10 light damage with a 0.5 light modifier and a 0.5 magic modifier.")
	
	
	func test_stamina_damage() -> void:
		vitals_component.vitals["moxie"] = 100
		damage_component.damage(DamageInfo.new("", {&"moxie":10}))
		assert_eq(vitals_component.vitals["moxie"], 90.0, "Should pass - Took 10 stamina damage without modifiers.")
	
	
	func test_will_damage() -> void:
		vitals_component.vitals["will"] = 100
		damage_component.damage(DamageInfo.new("", {&"will":10}))
		assert_eq(vitals_component.vitals["will"], 90.0, "Should pass - Took 10 will damage without modifiers.")


# TODO
class TestNavigation:
	extends TestNPC


class TestSchedule:
	extends TestNPC
	
	var root
	var em:EntityManager
	var npc:Entity
	var npc_component:NPCComponent
	
	
	func before_each() -> void:
		root = setup_npc()
		em = root.get_child(0)
		npc = em.get_entity("test_dummy").unwrap()
		npc_component = (npc.get_component("NPCComponent").unwrap() as NPCComponent)
		GameInfo.world_time[&"hour"] = 0
		GameInfo.continuity_flags["test"] = 0
	
	
	func test_different_hours() -> void:
		npc_component._calculate_new_schedule()
		assert_eq(npc_component._current_schedule_event.name, "sandbox 1", "Should pass - the current schedule should be the first one.")
		
		GameInfo.world_time[&"hour"] = 3
		npc_component._calculate_new_schedule()
		assert_eq(npc_component._current_schedule_event.name, "sandbox 2", "Should pass - the current schedule should be the second one.")
	
	
	func test_conditional() -> void:
		GameInfo.continuity_flags["test"] = 1
		GameInfo.world_time[&"hour"] = 3
		npc_component._calculate_new_schedule()
		assert_eq(npc_component._current_schedule_event.name, "schedule overridden", "Should pass - the current schedule should be overridden, since it passes the condition.")


class TestGOAP:
	extends TestNPC
	
	var root
	var em:EntityManager
	var npc:Entity
	var goap_component:GOAPComponent
	
	
	func before_each() -> void:
		root = setup_npc()
		em = root.get_child(0)
		npc = em.get_entity("test_dummy").unwrap()
		goap_component = (npc.get_component("GOAPComponent").unwrap() as GOAPComponent)
	
	
	func test_plan_creation() -> void:
		goap_component.add_objective({"goal":true}, true, 1)
		gut.simulate(root, 1, 0.01)
		assert_eq(goap_component.action_queue.map(func(x): return x.name), [&"action c", &"action b"], "Should pass. This is the least costly path to the goal, minus the first action.")
		assert_eq(goap_component._current_action.name, &"action a", "Should pass - Current action should be action a")
	
	
	func test_conditional_path() -> void:
		npc.world = &"goap"
		goap_component.add_objective({"goal":true}, true, 1)
		gut.simulate(root, 1, 0.01)
		assert_eq(goap_component.action_queue.map(func(x): return x.name), [&"action c", &"action e"], "Should pass. This is the least costly path to the goal with the condition, minus the first action.")
		assert_eq(goap_component._current_action.name, &"action a", "Should pass - Current action should be action a")
	
	
	func test_plan_execution() -> void:
		goap_component.add_objective({"goal":true}, true, 1)
		gut.simulate(root, 7, 0.01)
		assert_eq(goap_component.objectives, [], "Should pass - objectives finished")
		assert_eq(goap_component.action_queue, [], "Should pass - Done with the queue")
	
	
	func test_repeating_goals() -> void:
		goap_component.add_objective({"goal":true}, false, 1)
		gut.simulate(root, 5, 0.01)
		assert_eq(goap_component.objectives.size(), 1, "Should pass: Still has goal")
	
	
	func test_goal_priority() -> void:
		goap_component.add_objective({"goal":true}, true, 1)
		goap_component.add_objective({"priority":true}, true, 2)
		gut.simulate(root, 1, 0.01)
		assert_eq(goap_component.action_queue.map(func(x): return x.name), [&"action f", &"action b"], "Should pass. This is the least costly path to the higher priority goal, minus the first action.")
		assert_eq(goap_component._current_action.name, &"action a", "Should pass - Current action should be action a")
