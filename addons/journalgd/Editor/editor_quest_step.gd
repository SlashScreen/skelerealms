@tool

class_name EditorQuestStep
extends GraphNode


const GOAL_PREFAB = preload("res://addons/journalgd/Editor/goal_prefab.tscn")

var is_exit:bool:
	get:
		return $IsExitButton.button_pressed
	set(val):
		$IsExitButton.button_pressed = val
var step_name:String:
	get: 
		return ($StepName as LineEdit).text
	set(val):
		($StepName as LineEdit).text = val
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
	set(val):
		match val:
			QuestStep.StepType.ALL:
				$StepType.select(0)
			QuestStep.StepType.ANY:
				$StepType.select(1)
			QuestStep.StepType.BRANCH:
				$StepType.select(2)
			_:
				$StepType.select(0)


func _update_is_exit(val:bool):
	print("update is exit")
	set_slot_enabled_right(0, not val)


func _on_delete_node_button_up():
	print("Delete step")
	get_parent().delete_node(name)


func get_goals() -> Array:
	return $Scroll/GoalsContainer.get_children()


func _on_add_goal() -> EditorQuestGoal:
	var n = GOAL_PREFAB.instantiate()
	$Scroll/GoalsContainer.add_child(n)
	n.owner = self
	return n
