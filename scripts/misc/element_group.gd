class_name SKElementGroup
extends Node


func _enter_tree() -> void:
	while get_child_count() > 0:
		get_child(0).reparent(get_parent())
	queue_free()
