class_name FSMState
extends Node
## Abstract class for states for the [FSMMachine].


## Parent state machine.
var state_machine:FSMMachine = null


func _init() -> void:
	name = _get_state_name()


## get this state node's name. Override to work properly.
func _get_state_name() -> String:
	return "State"


## Called when the state machine finishes adding its nodes in [method FSMMachine.setup].
func on_ready() -> void:
	pass


## Same as _process(), but controlled by the machine.
func update(delta:float) -> void:
	pass


## Called when the node is entered. Message can pass some data to this state.
func enter(msg:Dictionary) -> void:
	pass


## Called when this node is exited.
func exit() -> void:
	pass
