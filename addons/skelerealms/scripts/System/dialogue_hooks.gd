extends Node
## This singleton allows you to hook into dialogue controls and commands that are issued by Skelerealms.
## As it does not come with its own dialogue solution, you can hook into these signals and call these methods to allow it to interface with a system of your choosing.
## In that sense, it is like an API endpoint.

# TODO: Allow more node slots

## The most recent dialogue node played. You could use this to continue if dialogue was interrupted with [method pause_dialogue].
## Its structure is as follows (note the [StringName]s):
## [codeblock]
## last_dialogue_node = {
##		&"node" : String, # Node that is playing
##		&"participants" : Array[StringName], # RefIDs of participating NPCs
##		&"data" : Dictionary # Any extra data passed in
##	}
## [/codeblock]
var last_dialogue_node:Dictionary = {}:
	get:
		return last_dialogue_node
	set(val):
		last_dialogue_node = val
		last_node_updated.emit()


## Signal emitted when dialogue is started, with the name of the node to play, the RefIDs of any participating NPCs, and any extra data you want to pass through.
## This is also emitted when dialogue is continued after pausing. See [method pause_dialogue].
signal dialogue_started(dialogue_node:String, participants:Array[StringName], data:Dictionary)
## Signal emitted when dialogue has ended.
signal dialogue_stopped
## Signal emitted when dialogue is interrputed.
signal dialogue_paused
## Signal emitted when [member last_dialogue_node] is updated.
signal last_node_updated
signal participant_added(who:StringName)
signal participant_removed(who:StringName)


## Start a dialogue node. Optionally pass in RefIDs for participants, and a dictionary of arbitrary data.
func start_dialogue(dialogue_node:String, participants:Array[StringName] = [], data:Dictionary = {}) -> void:
	dialogue_started.emit(dialogue_node, participants, data)
	update_dialogue_cache(dialogue_node, participants, data)


## Stop dialogue.
func stop_dialogue() -> void:
	dialogue_stopped.emit()


## Pause dialogue.
func pause_dialogue() -> void:
	dialogue_paused.emit()


func add_participant(who:StringName) -> void:
	last_dialogue_node[&"participants"].append(who)
	last_node_updated.emit()
	participant_added.emit(who)


func remove_participant(who:StringName) -> bool:
	if last_dialogue_node[&"participants"].has(who):
		last_dialogue_node[&"participants"].erase(who)
		participant_removed.emit(who)
		last_node_updated.emit()
		return true
	return false


## Continues dialogue state stored in [member last_dialogue_node]. Does nothing if there is no last dialogue stored.
func continue_dialogue() -> void:
	if last_dialogue_node.is_empty():
		return
	
	start_dialogue(last_dialogue_node[&"node"], last_dialogue_node[&"participants"], last_dialogue_node[&"data"])


## Update [member last_dialogue_node]. Keep track of what dialogue is currently playing so you can interrupt it and keep it playing later.
func update_dialogue_cache(dialogue_node:String = "", participants:Array[StringName] = [], data:Dictionary = {}) -> void:
	last_dialogue_node = {
		&"node" : dialogue_node if not dialogue_node == "" else last_dialogue_node[&"node"],
		&"participants" : participants if not participants.is_empty() else last_dialogue_node[&"participants"],
		&"data" : data if not data.is_empty() else last_dialogue_node[&"data"]
	}


## Send a command to an entity without having to do monkey business trying to find it.
func send_command_to_entity(ref_id:StringName, command:String, args:Array) -> void:
	var e = SkeleRealmsGlobal.entity_manager.get_entity(ref_id)
	if e.some():
		(e.unwrap() as Entity).dialogue_command(command, args)
