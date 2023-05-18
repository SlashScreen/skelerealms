@tool
class_name SavedStep
extends Resource


@export var step_name:StringName
@export var step_type:QuestStep.StepType = QuestStep.StepType.ALL
## {goal_key:to_node}
@export var connections:Dictionary = {}
@export var goals:Array[SavedGoal] = []
@export var is_final_step:bool
@export var editor_coordinates:Vector2
@export var is_entry_step:bool


func _init(eqs:EditorQuestStep = null) -> void:
	if not eqs:
		return
	step_name = eqs.step_name
	step_type = eqs.step_type
	is_final_step = eqs.is_exit
	editor_coordinates = eqs.position
	is_entry_step = eqs.is_entry_step
	for g in eqs.get_goals():
		add_goal(SavedGoal.new(g))


func add_goal(goal:SavedGoal) -> SavedGoal:
	goals.append(goal)
	return goal


func add_named_connection(port:int, to:StringName) -> void:
	if not step_type == QuestStep.StepType.BRANCH:
		set_default_connection(to)
		return
	connections[goals[port].goal_key] = to


func set_default_connection(to:StringName) -> void:
	connections[goals[0].goal_key] = to


func port_for_goal_key(key:StringName) -> int:
	if not step_type == QuestStep.StepType.BRANCH:
		return 0
	return goals.find(goals.filter(func(x:SavedGoal): return x.goal_key == key)[0]) # this Sucks but it's fine.
