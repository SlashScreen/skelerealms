@tool

extends GraphEdit

@export var node_prefab:PackedScene

func _on_add_new_button_down():
	add_child(node_prefab.instantiate())


func _on_save_button_up():
	pass # Replace with function body.
