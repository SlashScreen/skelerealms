class_name SavedGoal
extends Resource


@export var goal_key:StringName
@export var amount:int = 1
@export var filter:String
@export var only_while_active:bool = true
@export var optional:bool


func _init(eqg:EditorQuestGoal = null) -> void:
	if not eqg:
		return
	goal_key = eqg.goal_key
	amount = eqg.amount
	filter = eqg.filter
	only_while_active = eqg.only_while_active
	optional = eqg.optional
