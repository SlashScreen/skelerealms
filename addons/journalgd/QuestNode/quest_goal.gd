class_name QuestGoal
extends Node

var optional:bool = false
var key_registered:bool = false
var internal_amount:int = 0
var already_satisfied:bool = false

@export var amount:int = 1
@export var refID:String
@export var baseID:String
@export var only_while_active:bool = true

# TODO: Multiple events to satisfy, match against refID
# TODO: Allow undoing events

## Evaluate whether this has been satisfied or not.
func evaluate(is_active_step:bool) -> bool:
	if already_satisfied: # if we've satisfied it before
		return true
	if only_while_active and not is_active_step: # if not the active step and we need it to be, go false
		return false
	already_satisfied = amount >= internal_amount # every time it's satisfied, internal_amount goes up by 1, so we only need to check that.
	return already_satisfied


## Attempt to register an event with this goal.
func attempt_register(r_key:String, args):
	if not r_key == name:
		return
	amount += 1
