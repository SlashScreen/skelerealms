@tool

class_name QuestGoal
extends Node

var optional:bool = false
var update_signal:Signal
var internal_amount:int = 0:
	get:
		return internal_amount
	set(val):
		_emit_updated()
		internal_amount = val
var already_satisfied:bool = false:
	get:
		return already_satisfied
	set(val):
		_emit_updated()
		already_satisfied = val
var data:Dictionary:
	get:
		return {
			"progress": internal_amount,
			"target": amount,
			"filter": filter,
			"optional": optional,
			"only_while_active": only_while_active
		}
@export var amount:int = 1
@export var filter:String
@export var only_while_active:bool = true
# TODO: Multiple events to satisfy, match against refID
# TODO: Allow undoing events


func _init(eqg:SavedGoal = null, goal_update_signal:Signal = Signal()) -> void:
	if not eqg:
		return
	optional = eqg.optional
	amount = eqg.amount
	filter = eqg.filter
	only_while_active = eqg.only_while_active
	update_signal = goal_update_signal
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
func attempt_register(r_key:String, args:Dictionary, undo:bool): # TODO: only_while_active
	# check event name
	if not r_key == name:
		return
	# check for invalid filter
	if not filter == "":
		if args.has("filter") and not args["filter"] == filter:
			return
	# all checks passed, increase amount
	internal_amount += -1 if undo else 1
	if undo and already_satisfied:
		already_satisfied = false


func save() -> Dictionary:
	return {
		"already_satisfied" : already_satisfied,
		"internal_amount" : internal_amount
	}


func load_data(data:Dictionary) -> void:
	already_satisfied = data.already_satisfied
	internal_amount = data.internal_amount


func _emit_updated() -> void:
	update_signal.emit("%s/%s/%s" % [get_parent().get_parent().name, get_parent().name, name], data)
