@tool

class_name EditorQuestStep
extends GraphNode


const GOAL_PREFAB = preload("res://addons/journalgd/Editor/goal_prefab.tscn")
const STEP_COLORS = {
	"all" : 0xFF5400FF, # orange
	"any" : 0x9E0059FF, # magenta
	"branch" : 0xFFBD00FF, # yellow
	"start" : 0xABE188FF, # green
	"end" : 0xFF0054FF, # pinkish
}

var is_exit:bool:
	get:
		return $IsExitButton.button_pressed
	set(val):
		$IsExitButton.button_pressed = val
		_set_title_color()
var step_name:String:
	get: 
		return ($StepName as LineEdit).text
	set(val):
		($StepName as LineEdit).text = val
		title = val
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
		_set_is_branch(val == QuestStep.StepType.BRANCH)
		match val:
			QuestStep.StepType.ALL:
				$StepType.select(0)
			QuestStep.StepType.ANY:
				$StepType.select(1)
			QuestStep.StepType.BRANCH:
				$StepType.select(2)
			_:
				$StepType.select(0)
		_set_title_color()
var mapped_goals:Array:
	get:
		return get_goals().map(func(x:EditorQuestGoal): return x.name)
var is_entry_step:bool:
	get:
		return $IsEntryButton.button_pressed
	set(val):
		$IsEntryButton.button_pressed = val
		set_slot_enabled_left(4, not val)
		_set_title_color()


func setup(qs:SavedStep) -> void:
	is_exit = qs.is_final_step
	step_name = qs.step_name
	position_offset = qs.editor_coordinates
	print(position)
	is_entry_step = qs.is_entry_step
	for g in qs.goals:
		add_goal(g)
	step_type = qs.step_type # put this at end because we need to have the goals count
	_set_title_color()


func _update_is_exit(val:bool):
	print("update is exit")
	set_slot_enabled_right(0, not val)
	_set_title_color()


func _on_delete_node_button_up() -> void:
	print("Delete step")
	get_parent().delete_node(name)


func _set_title_color() -> void:
	if is_exit:
		theme.set_color(&"title_color", &"GraphNode", Color.hex(STEP_COLORS.end))
		return
	if is_entry_step:
		theme.set_color(&"title_color", &"GraphNode", Color.hex(STEP_COLORS.start))
		return
	match step_type:
		QuestStep.StepType.ALL:
			theme.set_color(&"title_color", &"GraphNode", Color.hex(STEP_COLORS.all))
		QuestStep.StepType.ANY:
			theme.set_color( &"title_color", &"GraphNode", Color.hex(STEP_COLORS.any))
		QuestStep.StepType.BRANCH:
			theme.set_color(&"title_color", &"GraphNode", Color.hex(STEP_COLORS.branch))


## Handles dealing with multiple output points with branches.
func _set_is_branch(state:bool) -> void:
	print("set is goal")
	var conn_count = get_connection_output_count()
	if state:
		if is_exit:
			return
		var goal_amount = get_goals().size()
		for i in conn_count:
			set_slot_enabled_right(i, false)
		for i in goal_amount:
			set_slot_enabled_right(i, true)
	else:
		for i in conn_count:
			set_slot_enabled_right(i, false)
		set_slot_enabled_right(0, not is_exit)


func get_goals() -> Array:
	return $Scroll/GoalsContainer.get_children()


func _on_add_goal() -> EditorQuestGoal:
	var n = GOAL_PREFAB.instantiate()
	$Scroll/GoalsContainer.add_child(n)
	n.owner = self
	_set_is_branch(step_type == QuestStep.StepType.BRANCH)
	return n


func _on_delete_goal_pressed() -> void:
	_set_is_branch(step_type == QuestStep.StepType.BRANCH)


func add_goal(g:SavedGoal) -> EditorQuestGoal:
	var n = GOAL_PREFAB.instantiate()
	n.setup(g)
	$Scroll/GoalsContainer.add_child(n)
	n.owner = self
	return n


func _ready() -> void:
	theme = theme.duplicate(true)
	$StepType.item_selected.connect(func(x:int): _set_is_branch(x == 2))
	$IsEntryButton.toggled.connect(func(state:bool): set_slot_enabled_left(4, not state))
	$StepName.text_changed.connect(func(x): title = x)
	resize_request.connect(func(new_minsize:Vector2):size = new_minsize)
	close_request.connect(_on_delete_node_button_up.bind())
