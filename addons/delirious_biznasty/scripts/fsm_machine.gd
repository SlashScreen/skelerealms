class_name FSMMachine
extends Node


var initial_state:String
var state:FSMState


signal transitioned(state_name:String)


func setup(states:Array[FSMState]) -> void:
	# add all children
	for s in states:
		s.state_machine = self
		add_child(s)
	owner = get_parent()
	# transition to initial states
	transition(initial_state)


func _process(delta: float) -> void:
	for c in get_children():
		c.update(delta)


func transition(state_name:String, msg:Dictionary = {}) -> void:
	if not has_node(state_name):
		return
	
	state.exit()
	
	state = get_node(state_name)
	state.enter(msg)
	
	transitioned.emit(state_name)
