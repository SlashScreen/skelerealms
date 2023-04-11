@tool

class_name EditorQuestStep
extends GraphNode


var is_entry:bool
var is_exit:bool
var step_name:String:
	get: 
		return ($StepName as LineEdit).text
var node_position:Vector2
var next_connections:Array[String]
var step_type:QuestStep.StepType:
	get:
		match $StepType.get_item_text($StepType.get_selected_id()):
			"All":
				return QuestStep.StepType.ALL
			"Any":
				return QuestStep.StepType.ANY
			"Branch":
				return QuestStep.StepType.BRANCH
			_:
				return QuestStep.StepType.ALL
var optional:bool


var step_name_field:LineEdit
var is_exit_button:CheckButton


func _update_is_exit(val:bool):
	print("update is exit")
	is_exit = val
	set_slot_enabled_right(0, not val)


## Evaluate whether the quest is complete or not.
func evaluate() -> bool:
	return true


func _on_delete_node_button_up():
	print("Delete step")
	get_parent().delete_node(name)


func get_goals() -> Array:
	return $Scroll/GoalsContainer.get_children().map(func(x): return x as EditorQuestGoal)
