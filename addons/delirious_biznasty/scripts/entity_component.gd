class_name EntityComponent extends Node

const entity_class = preload("entity.gd")
var parent_entity:Entity

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_entity = get_parent() as Entity
	parent_entity.left_scene.connect(_on_exit_scene.bind())
	parent_entity.entered_scene.connect(_on_enter_scene.bind())
	
func _on_enter_scene():
	pass
	
func _on_exit_scene():
	pass
