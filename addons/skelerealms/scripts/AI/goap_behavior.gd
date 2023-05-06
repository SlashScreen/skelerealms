class_name GOAPBehavior
extends Resource


@export var id:StringName
@export var prerequisites:Dictionary
@export var effects:Dictionary
@export var cost:float
@export var duration:float
## Whether this objective is actively being worked on
var running:bool = false
var parent_goap:GOAPComponent
var entity:Entity


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
