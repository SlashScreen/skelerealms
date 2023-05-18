@tool

class_name QuestGoal
extends Node

var optional:bool = false
var key_registered:bool = false
var internal_amount:int = 0
var already_satisfied:bool = false:
	get:
		return already_satisfied
	set(val):
		already_satisfied = val

@export var amount:int = 1
@export var refID:String
@export var baseID:String
@export var only_while_active:bool = true
# TODO: Multiple events to satisfy, match against refID
# TODO: Allow undoing events


func _init(eqg:SavedGoal = null) -> void:
	if not eqg:
		return
	optional = eqg.optional
	amount = eqg.amount
	refID = eqg.ref_id
	baseID = eqg.base_id
	only_while_active = eqg.only_while_active
	name = eqg.goal_key


## Evaluate whether this has been satisfied or not.
func evaluate(is_active_step:bool) -> bool:
	if already_satisfied: # if we've satisfied it before
		return true
	if only_while_active and not is_active_step: # if not the active step and we need it to be, go false
		return false
	already_satisfied = amount <= internal_amount # every time it's satisfied, internal_amount goes up by 1, so we only need to check that.
	return already_satisfied


## Attempt to register an event with this goal.
func attempt_register(r_key:String, args:Dictionary): # TODO: only_while_active
	# check event name
	if not r_key == name:
		return
	# check for invalid refID
	if not refID == "":
		if args.has("refid") and not args["refid"] == refID:
			return
	# check for invalid baseID
	if not baseID == "":
		if args.has("baseid") and not args["baseid"] == baseID:
			return
	# all checks passed, increase amount
	internal_amount += 1
