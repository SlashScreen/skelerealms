@tool

class_name QuestEditor
extends GraphEdit

@export var node_prefab:PackedScene
var q_name_input:LineEdit


func _ready():
	q_name_input = $"../HBoxContainer/QName"
	connection_request.connect(make_connection.bind())
	disconnection_request.connect(make_disconnection.bind())


func _on_add_new_button_down() -> EditorQuestStep:
	var n = node_prefab.instantiate()
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


func save():
	if q_name_input.text == "":
		print("Write a quest name to save.")
		return
	
	print("Start save")
	var q_root:QuestNode = QuestNode.new()
	q_root.name = q_name_input.text
	
	# Get steps
	for s in get_children():
		var q_step = QuestStep.new()
		q_root.add_child(q_step)
		q_step.owner = q_root
		print("Packing step %s" % q_step.name)
		# Get connections
		var connections:Array
		connections = get_connection_list() \
			.filter(func(c): return c.from == q_step.name) \
			.map(func(c): return get_node(c.to))
		q_step.next_steps = connections
			#TODO: Map keys if branch
		
		# Get goals
		for g in (s as EditorQuestStep).get_goals(): 
			var q_goal:QuestGoal = QuestGoal.new()
			var e_goal = g as EditorQuestGoal
			
			q_goal.name = e_goal.goal_key
			# skip if goal name empty
			if q_goal.name.is_empty() or q_goal.name == "":
				print("empty name on goal")
				continue
			
			print("Packing goal %s" % q_goal.name)
			q_step.add_child(q_goal)
			print("setting owner")
			q_goal.owner = q_root
			# Load info into node
			print("setting values")
			q_goal.amount = e_goal.amount
			q_goal.only_while_active = e_goal.only_while_active
			q_goal.optional = e_goal.optional
			q_goal.baseID = e_goal.base_id
			q_goal.refID = e_goal.ref_id
			
		# Load info
		q_step.type = (s as EditorQuestStep).step_type
		q_step.is_final_step = (s as EditorQuestStep).is_exit
		q_step.name = (s as EditorQuestStep).step_name
		q_step.editor_coordinates = (s as EditorQuestStep).position
	
	
	print("Packed quest %s with %s children" % [q_root.name, q_root.get_child_count()])
	# Pack and save
	var result = Quest.new()
	var scene = PackedScene.new()
	q_root.print_tree_pretty()
	scene.pack(q_root)
	result.quest_id = q_root.name
	result.quest_scene = scene
	ResourceSaver.save(result, (ProjectSettings.get_setting("journalgd/quests_directory") + "/%s.tres" % q_root.name))


func open(q:Quest) -> void:
	# Get rid of all children
	for s in get_children():
		delete_node(s.name)
	# Create steps
	q_name_input.text = q.quest_id # set quest ID
	var quest_scene = q.quest_scene.instantiate() # unpack scene to analyze
	var to_connect:Array[Dictionary] = []
	quest_scene.print_tree_pretty()
	# Iterate through steps, create new
	for step in quest_scene.get_children():
		# create new step
		print("unpacking step %s" % step.name)
		var new_step = _on_add_new_button_down()
		# load goals
		for goal in step.get_children():
			var s_goal = goal as QuestGoal
			var e_goal = new_step._on_add_goal()
			print("unpacking goal %s" % s_goal.name)
			# Load values
			e_goal.goal_key = s_goal.name
			e_goal.optional = s_goal.optional
			e_goal.amount = s_goal.amount
			e_goal.base_id = s_goal.baseID
			e_goal.ref_id = s_goal.refID
			e_goal.only_while_active = s_goal.only_while_active
		# Load info
		new_step.step_name = step.name
		new_step.step_type = step.type
		new_step.is_exit = step.is_final_step
		new_step.position = step.editor_coordinates
		# Add connection
		for c in step.next_steps:
			to_connect.append({
				"from" : step.name,
				"to" : c.to
			})
	# Connect all
	# TODO: Branches
	for conn in to_connect:
		print("Connecting %s to %s" % [conn["from"], conn["to"]] )
		make_connection(find_child(conn["from"]), 0, find_child(conn["to"]), 0)


func _on_clear_pressed() -> void:
	q_name_input.text = ""
	for s in get_children():
		delete_node(s.name)
