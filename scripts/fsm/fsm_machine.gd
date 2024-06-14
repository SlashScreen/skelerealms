class_name FSMMachine
extends Node
## Finite State Machine manager.


## The entry node's name.
var initial_state:String
## The current state of the machine.
var state:FSMState


## Emit when it has made a transition. String is the new state name.
signal transitioned(state_name:String)


## Set this FSM up with a list of state nodes.
func setup(states:Array[FSMState]) -> void:
	# add all children
	for s in states:
		s.state_machine = self
		add_child(s)
	owner = get_parent()
	# call on ready
	for c in get_children():
		c.owner = get_parent()
		(c as FSMState).on_ready()
	# transition to initial states
	transition(initial_state)


func _process(delta: float) -> void:
	state.update(delta)


## Transition to a new state by state name. DOes nothing if no state with name found.
func transition(state_name:String, msg:Dictionary = {}) -> void:
	#print("transitioning from %s state to %s" % [state.name if state else "None", state_name])
	if not has_node(state_name):
		return
	
	if state:
		state.exit()
	
	state = get_node(state_name)
	state.enter(msg)
	
	transitioned.emit(state_name)
