class_name QuestEngine
extends Node
## This keeps track of all of the quests.
## Quests will be instantiated as [QuestObject]s underneath this node.
## Registering a quest event will update the tree downwards. What does this mean? I don't know, I'm tired.
## When functions ask for a "Quest path", they are referring to a string in the format of [code]quest_name/step_name/goal_name[/code].


static var instance:QuestEngine

## Array of IDs of all the quests that are currently active.
var active_quests: Array[String]
## Array of IDs of all the quests the player has completed.
var complete_quests:Array[String]

## Emitted when a quest has started.
signal quest_started(q_id:String)
## Emitted when a quest is complete.
signal quest_complete(q_id:String)
## Emitted when a quest goal has been updated - the amount has been increased, or it is marked as complete.
signal goal_updated(quest_path:String, data:Dictionary)
## Emitted when a step is updated - when a step is marked as complete.
signal step_updated(quest_path:String, data:Dictionary)
## Emitted when a quest updates.
signal quest_updated(quest_path:String, data:Dictionary)


func _ready() -> void:
	instance = self


## Loads all quests from the [code]biznasty/quests_directory[/code] project setting, and then instantiates them as child [QuestObject]s.
func load_quest_objects():
	_load_dir(ProjectSettings.get_setting("journalgd/quests_path"))


func _load_dir(path:String):
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			_load_dir(file_name)
		else:
			add_quest_from_path("%s/%s" % [path, file_name])
		file_name = dir.get_next()


## Load a quest resource at a path, and load it into the system.
func add_quest_from_path(path:String):
	var q = load(path) as SavedQuest
	add_node_from_saved(q)


## Mark a quest as started.
func start_quest(q_id:String) -> bool:
	if get_node_or_null(q_id):
		active_quests.append(q_id)
		quest_started.emit(q_id)
		return true
	return false


## Add a quest from a [SavedQuest] resource.
func add_node_from_saved(q:SavedQuest) -> void:
	var q_node = QuestNode.new()
	q_node.qID = q.quest_id
	q_node.name = q.quest_id
	
	# Create steps
	for s in q.steps:
		var s_node = QuestStep.new(q.steps[s], step_updated, goal_updated)
		if q.steps[s].is_entry_step:
			q_node._active_step = s_node 
		q_node.add_child(s_node)
	
	add_child(q_node)
	if q.entry_point == &"":
		q_node._active_step = q_node.get_child(0)
		print(q_node._active_step)
	else:
		q_node = q.entry_point


## Is a member currently in progress?
func is_member_active(q_path) -> bool:
	var path_info = _parse_quest_path(q_path) if q_path is String else q_path
	
	match path_info:
		{"quest": var quest}:
			return active_quests.has(quest)
		{"quest": var quest, "step": var step}:
			var q:QuestNode = _get_member_node(quest)
			return q._active_step.name == step
		{"goal", ..}:
			var g:QuestGoal = _get_member_node(path_info)
			return g.already_satisfied
		_:
			return false


## Has a member reached their completion state- a quest has reached a step marked as the end, a step has all goals completed, or a goal has been satisfied.
func is_member_complete(q_path) -> bool:
	var path_info = _parse_quest_path(q_path) if q_path is String else q_path
	
	match path_info:
		{"quest": var quest}:
			return complete_quests.has(quest)
		{"quest": var quest, "step": var step}:
			var p = "%s/%s" % [quest, step]
			var s:QuestStep = _get_member_node(p)
			return s.is_already_complete
		{"goal", ..}:
			var g:QuestGoal = _get_member_node(path_info)
			return g.already_satisfied
		_:
			return false


## Is a member active, or has it been completed. Inverting this can tell if the player hasn't started a quest.
func has_member_been_started(q_path) -> bool:
	var path_info = _parse_quest_path(q_path) if q_path is String else q_path
	return is_member_active(path_info) or is_member_complete(path_info)


## Get a [QuestNode], [QuestStep], or [QuestGoal]'s data from the quest path. Returns a dictionary:
## [CodeBlock]
## Goal:
## {
##     "progress": int <- how many times this event has been triggered
##     "target": int <- the amount of times to be triggered to be considered completed
##     "filter": String
##     "optional": bool
##     "only_while_active": bool
## }
## Step:
## {
##     "type": StepType <- All, Any, Branch
##     "is_first_step": bool
##     "is_last_step": bool
##     "goal_keys": Array[String] <- Keys of all goals
## }
## Quest:
## {
##     "steps": Array[String] <- Names of all steps
## }
## [/CodeBlock]
func get_member(q_path) -> Dictionary:
	var path_info = q_path if q_path is String else _fuse_path(q_path)
	var n = get_node_or_null(path_info)
	if n:
		return n.data
	else:
		return {}


func _get_member_node(q_path) -> Variant:
	var path_info = q_path if q_path is String else _fuse_path(q_path)
	return get_node_or_null(path_info)


## Register a quest event. This function has unique behavior based on the path you give it: [br]
## [code]goal_key[/code] - Apply the event to all quests loaded in the system, active or not. [br]
## [code]quest_name/goal_key[/code] - Apply the event to all steps in a quest. [br]
## [code]quest_name/step_name/goal_key[/code] - Apply the event only to a specific step of a specific quest. [br]
## [code]args[/code] is an optional dictionary with the shape of
## [CodeBlock]
## {
##  	"filter" : String <- Optional, filter to check against for goal conditions.
## }
## [/CodeBlock]
## Use "undo" to instad un-register an event, if you need to do that.
func register_quest_event(path:String, args:Dictionary = {}, undo:bool = false):
	match _parse_quest_path(path):
		{"quest": var key}:
			propagate_call("register_step_event", [path, args, undo])
		{"quest": var quest, "step": var key}:
			var qnode = _get_member_node({"quest": quest})
			if not qnode:
				return
			qnode.register_step_event(key, args, undo)
		{"quest": var quest, "step": var step, "goal": var key}:
			var snode:QuestStep = _get_member_node({"quest": quest, "step": step})
			if not snode:
				return
			snode.register_event(key, args, undo)
		_:
			return
	_update_all_quests()


func _update_all_quests():
	for q in get_children():
		q.update()
		if q.complete and not complete_quests.has(q.name):
			complete_quests.append(q.name)
			quest_complete.emit(q.name)


func _parse_quest_path(path:String) -> Dictionary:
	var chunks = path.split("/")
	var output:Dictionary = {"quest":chunks[0]}
	if chunks.size() > 1:
		output["step"] = chunks[1]
	if chunks.size() > 2:
		output["goal"] = chunks[2]
	return output


func _fuse_path(path:Dictionary) -> String:
	var output = ""
	if path.has("quest"):
		output += path["quest"]
	if path.has("step"):
		output += "/" + path["step"]
	if path.has("goal"):
		output += "/" + path["goal"]
	return output


func save() -> Dictionary:
	var quest_data = {}
	for quest in get_children():
		quest_data[quest.name] = quest.save()
	return {
		"active_quests": active_quests,
		"complete_quests": complete_quests,
		"quest_data": quest_data
	}


func load_data(data:Dictionary) -> void:
	active_quests = data.active_quests
	complete_quests = data.complete_quests
	for quest in data.quest_data:
		get_node(quest).load_data(data.quest_data[quest])
