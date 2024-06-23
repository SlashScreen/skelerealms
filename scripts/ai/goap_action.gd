class_name GOAPAction
extends Node


## The cost of this action when making a plan.
var cost:float = 1.0
## Whether this objective is actively being worked on
var running:bool = false
var parent_goap:GOAPComponent
var entity:SKEntity
## The duration of this action.
var duration: float


func is_achievable_given(state:Dictionary) -> bool:
	return state.has_all(get_prerequisites().keys())


func is_achievable() -> bool:
	return true


func pre_perform() -> bool:
	return true


func target_reached() -> bool:
	return true


func post_perform() -> bool:
	return true


func is_target_reached(agent:NavigationAgent3D) -> bool:
	return agent.is_navigation_finished()


func interrupt() -> void:
	return


func get_prerequisites() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {}


func get_id() -> StringName:
	return &""
