class_name GOAPAction
extends Node
## Base class for GOAP actions.


@export var prerequisites:Dictionary
@export var effects:Dictionary


func is_achievable():
	pass


func pre_perform():
	pass


func target_reached():
	pass


func post_perform():
	pass
