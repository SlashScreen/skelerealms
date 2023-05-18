class_name SavedGoal
extends Resource


@export var goal_key:StringName
@export var amount:int = 1
@export var ref_id:String
@export var base_id:String
@export var only_while_active:bool = true
@export var optional:bool


func _init(eqg:EditorQuestGoal = null) -> void:
	if not eqg:
		return
	goal_key = eqg.goal_key
	amount = eqg.amount
	ref_id = eqg.ref_id
	base_id = eqg.base_id
	only_while_active = eqg.only_while_active
	optional = eqg.optional
