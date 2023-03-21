class_name GoapPlanner extends Node

const goap_action = preload("goap_action.gd")

static func plan(beliefs:Dictionary, world_state:Dictionary, goals:Dictionary, pool: Array[GOAPAction]) -> Array[GOAPAction]:
	var initial_beliefs : Dictionary = beliefs.duplicate(true)
	initial_beliefs.merge(world_state)
		
	return pool
