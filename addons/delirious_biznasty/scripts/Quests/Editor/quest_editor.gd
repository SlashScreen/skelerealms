@tool

extends GraphEdit

@export var node_prefab:PackedScene

func _ready():
	connection_drag_started.connect(func(from_node, from_port, is_output): print("Connection drag started: from %s slot %s output: %s " % [from_node, from_port, is_output]))
	connection_drag_ended.connect(func(): print("Connection drag ended."))
	connection_request.connect(make_connection.bind())
	disconnection_request.connect(make_disconnection.bind())
	connection_to_empty.connect(func(x, y, z): print("Dropped connection."))

func _on_add_new_button_down():
	add_child(node_prefab.instantiate())


func _on_save_button_up():
	pass # Replace with function body.

func make_connection(from_node, from_port, to_node, to_port):
	print("Made connection request: from %s port %s to %s port %s" % [from_node, from_port, to_node, to_port])
	connect_node(from_node, from_port, to_node, to_port)

func make_disconnection(from_node, from_port, to_node, to_port):
	print("Made disconnection request: from %s port %s to %s port %s" % [from_node, from_port, to_node, to_port])
	disconnect_node(from_node, from_port, to_node, to_port)
