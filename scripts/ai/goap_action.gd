class_name GOAPAction
extends Node


@export var id:StringName
@export var prerequisites:Dictionary
@export var effects:Dictionary
@export var cost:float = 1
@export var duration:float
## Whether this objective is actively being worked on
var running:bool = false
var parent_goap:GOAPComponent
var entity:SKEntity


func is_achievable_given(state:Dictionary) -> bool:
	return state.has_all(prerequisites.keys())


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
