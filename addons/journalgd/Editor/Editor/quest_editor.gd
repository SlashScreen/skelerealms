@tool

class_name QuestEditor
extends GraphEdit


var STEP_PREFAB = preload("res://addons/journalgd/Editor/step_prefab.tscn")

var q_name_input:LineEdit


func _ready():
	q_name_input = $"../HBoxContainer/QName"
	connection_request.connect(make_connection.bind())
	disconnection_request.connect(make_disconnection.bind())


func _on_add_new_button_down() -> EditorQuestStep:
	var n = STEP_PREFAB.instantiate()
	n.position_offset = scroll_offset
	add_child(n)
	return n


func _on_save_button_up():
	save()


func make_connection(from_node, from_port, to_node, to_port):
	print("Made connection request: from %s port %s to %s port %s" % [from_node, from_port, to_node, to_port])
	connect_node(from_node, from_port, to_node, to_port)


func make_disconnection(from_node, from_port, to_node, to_port):
	print("Made disconnection request: from %s port %s to %s port %s" % [from_node, from_port, to_node, to_port])
	disconnect_node(from_node, from_port, to_node, to_port)


func delete_node(n:String):
	# { from_port: 0, from: "GraphNode name 0", to_port: 1, to: "GraphNode name 1" }.
	var connections_for_n:Array[Dictionary] = get_connection_list().filter(func(x): return x.from == n || x.to == n) # get all connections with this involved
	for node in connections_for_n: # for each in connections
		disconnect_node(node.from, node.from_port, node.to, node.to_port) # disconnect
	print("Deleting node $s", n)
	get_node(n).queue_free()


func find_step(sname:StringName) -> EditorQuestStep:
	for c in get_children():
		if c.name == sname:
			return c
	return null


func save() -> void:
	if q_name_input.text == "":
		print("Write a quest name to save.")
		return
	
	var quest = SavedQuest.new()
	quest.quest_id = q_name_input.text
	# Get steps
	for s in get_children():
		quest.add_step(SavedStep.new(s))
	
	print(quest.steps)
	for conn in get_connection_list():
		print(conn)
		quest.steps[_get_step_name_for_node(conn["from"])].add_named_connection(conn["from_port"], _get_step_name_for_node(conn["to"]))
	
	# Pack and save
	ResourceSaver.save(quest, (ProjectSettings.get_setting("journalgd/quests_directory") + "/%s.tres" % quest.quest_id))


func open(q:SavedQuest) -> void:
	# Get rid of all children
	clear()
	
	if not q:
		return
	
	# Create steps
	q_name_input.text = q.quest_id # set quest ID
	var to_connect:Array[Dictionary] = []
	
	for step in q.steps:
		var e_step = _on_add_new_button_down()
		e_step.setup(q.steps[step])
		for c in q.steps[step].connections:
			to_connect.append({
				"from" : step,
				"to" : q.steps[step].connections[c],
				"from_port" : q.steps[step].port_for_goal_key(c)
			})
	# Connect all
	for conn in to_connect:
		print("Connecting %s to %s from port %s" % [conn["from"], conn["to"], conn["from_port"]] )
		make_connection(_get_node_for_step_name(conn["from"]), conn["from_port"], _get_node_for_step_name(conn["to"]), 0)


func _get_step_name_for_node(n:String) -> StringName:
	return get_node(n).step_name


func _get_node_for_step_name(n:StringName) -> StringName:
	return get_children().filter(func(x:EditorQuestStep): return x.step_name == n).front().name


func _on_clear_pressed() -> void:
	clear()


func clear():
	q_name_input.text = ""
	clear_connections()
	for s in get_children():
		delete_node(s.name)
	queue_redraw()
