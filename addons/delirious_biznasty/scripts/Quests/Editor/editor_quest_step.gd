class_name EditorQuestStep
extends GraphNode

var is_entry:bool
var is_exit:bool
var step_name:String
var node_position:Vector2
var next_connections:Array[String]
var step_type:QuestStep.StepType
var optional:bool


@export var step_name_field:LineEdit
@export var is_exit_button:CheckButton


func _ready():
	step_name_field.text_submitted.connect(_update_step_name.bind())
	is_exit_button.toggled.connect(_update_is_exit.bind())


func _update_step_name(val:String):
	step_name = val


func _update_is_exit(val:bool):
	is_exit = val
	set_slot_enabled_right(0, not val)


## Evaluate whether the quest is complete or not.
func evaluate() -> bool:
	return true


