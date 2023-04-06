class_name FSMState
extends Node


var state_machine:FSMMachine = null


func _init() -> void:
	name = _get_state_name()


func _get_state_name() -> String:
	return "State"


func ready() -> void:
	pass


func update(delta:float) -> void:
	pass


func enter(msg:Dictionary) -> void:
	pass


func exit()-> void:
	pass
