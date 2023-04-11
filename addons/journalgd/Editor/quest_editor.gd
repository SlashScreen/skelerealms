@tool

class_name QuestEditor
extends GraphEdit

@export var node_prefab:PackedScene
var q_name_input:LineEdit


func _ready():
	q_name_input = $"../HBoxContainer/QName"
	connection_request.connect(make_connection.bind())
	disconnection_request.connect(make_disconnection.bind())


func _on_add_new_button_down():
	add_child(node_prefab.instantiate())


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
	
	for s in get_children():
		var q_step = QuestStep.new()
		q_step.name = (s as EditorQuestStep).step_name
		print("Packing step %s" % q_step.name)
		q_step.is_final_step = (s as EditorQuestStep).is_exit
		q_step.next_steps = get_connection_list() \
			.filter(func(c): c.from == q_step.name) \
			.map(func(c): get_node(c.to)) #TODO: Map keys if branch
		
		for g in (s as EditorQuestStep).get_goals(): # Load goals
			var q_goal:QuestGoal = QuestGoal.new()
			q_goal.name = (g as EditorQuestGoal).goal_key
			print("Packing goal %s" % q_goal.name)
			# TODO: Load info
			q_step.add_child(q_goal)
			q_goal.owner = q_step
		# TODO: Load info
		q_root.add_child(q_step)
		q_step.owner = q_root
	
	print("Packed quest %s with %s children" % [q_root.name, q_root.get_child_count()])
	# Pack and save
	var result = Quest.new()
	result.pack(q_root)
	# TODO: File dialogue
	ResourceSaver.save(result, (ProjectSettings.get_setting("skelerealms/quests_directory") + "/%s.tscn" % q_root.name))
