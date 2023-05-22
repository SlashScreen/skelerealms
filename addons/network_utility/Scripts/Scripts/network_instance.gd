@tool
class_name NetworkInstance
extends Node3D


@export var network:Network = Network.new()


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
