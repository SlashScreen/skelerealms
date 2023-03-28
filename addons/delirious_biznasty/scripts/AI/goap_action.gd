class_name GOAPAction
extends Node
## Base class for GOAP actions.


@export var prerequisites:Dictionary
@export var effects:Dictionary
@export var cost:float
@export var duration:float


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
