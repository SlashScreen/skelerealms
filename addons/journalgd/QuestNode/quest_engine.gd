class_name QuestEngine
extends Node
## This keeps track of all of the quests.
## Quests will be instantiated as [QuestObject]s underneath this node.
## Registering a quest event will update the trree downwards. What does this mean? I don't know, I'm tired.


## Array of IDs of all the quests that are currently active.
var active_quests: Array[String]
## Array of IDs of all the quests the player has completed.
var complete_quests:Array[String]


## Loads all quests from the [code]biznasty/quests_directory[/code] project setting, and then instantiates them as child [QuestObject]s.
func load_quest_objects():
	_load_dir(ProjectSettings.get_setting("skelerealms/quests_directory"))


func _load_dir(path:String):
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			_load_dir(file_name)
		else:
			add_quest_node("%s/%s" % [path, file_name])
		file_name = dir.get_next()


func add_quest_node(path:String):
	var q = load(path) as Quest
	add_child(q.instantiate())


## Checks whether a quest is currently active.
func is_quest_active(qID:String) -> bool:
	return active_quests.has(qID)


## Checks whether a quest has been complete.
func is_quest_complete(qID:String) -> bool:
	return complete_quests.has(qID)


## Checks whether a quest has been started, meaning it is either currently in progress, or already complete.
## Inverting this can check if the quest hasn't been started by the player.
func is_quest_started(qID:String) -> bool:
	return is_quest_active(qID) or is_quest_complete(qID)


# TODO: Use propogate_call instead.
## Register a quest event. 
## You can either pass in a path formatted like [Code]MyQuest/MyEvent[/code] to send an event to a specific quest,
## or simply pass in the event key to send an event to all quests.
func register_quest_event(path:String):
	if path.contains("/"): # if the key is a path
		var chunks = path.split("/")
		var qnode = get_node_or_null(chunks[0]) as QuestNode
		if qnode == null:
			return
		qnode.register_step_event(chunks[1])
	else: # if jsut the key
		for q in get_children().map(func(x): return x as QuestNode):
			q.register_step_event(path)


func is_step_complete(path:String) -> bool:
	var chunks = path.split("/")
	var qnode = get_node_or_null(chunks[0]) as QuestNode
	if qnode == null:
		return false
	return qnode.is_step_complete(chunks[1])


func is_step_in_progress(path:String) -> bool:
	var chunks = path.split("/")
	var qnode = get_node_or_null(chunks[0]) as QuestNode
	if qnode == null:
		return false
	return qnode._active_step.name == chunks[1]


func _update_all_quests():
	for q in get_children().map(func(x): return x as QuestNode):
		q.update()
