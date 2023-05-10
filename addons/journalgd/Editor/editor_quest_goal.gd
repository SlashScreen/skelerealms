@tool
class_name EditorQuestGoal
extends Control


var goal_key:String:
	get:
		return ($VBoxContainer/GoalName as LineEdit).text
	set(val):
		($VBoxContainer/GoalName as LineEdit).text = val
var optional:bool:
	get:
		return ($VBoxContainer/OptionalButton as CheckButton).button_pressed
	set(val):
		($VBoxContainer/OptionalButton as CheckButton).button_pressed = val
var base_id:String:
	get:
		return ($VBoxContainer/BaseID as LineEdit).text
	set(val):
		($VBoxContainer/BaseID as LineEdit).text = val
var ref_id:String:
	get:
		return ($VBoxContainer/RefID as LineEdit).text
	set(val):
		($VBoxContainer/RefID as LineEdit).text = val
var amount:int:
	get:
		return ($VBoxContainer/HBoxContainer/AmountBox as SpinBox).value
	set(val):
		($VBoxContainer/HBoxContainer/AmountBox as SpinBox).value = val
var only_while_active:bool:
	get:
		return ($VBoxContainer/OnlyWhileActive as CheckBox).button_pressed
	set(val):
		($VBoxContainer/OnlyWhileActive as CheckBox).button_pressed = val


func _on_delete_pressed() -> void:
	queue_free()
