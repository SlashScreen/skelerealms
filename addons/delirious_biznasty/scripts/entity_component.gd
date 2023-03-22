class_name EntityComponent 
extends Node
## A component that is within an [Entity].
## Extend these to add functionality to an entity.

## Parent entity of this component.
@onready var parent_entity:Entity = get_parent() as Entity

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_entity.left_scene.connect(_on_exit_scene.bind())
	parent_entity.entered_scene.connect(_on_enter_scene.bind())

## Called when the parent entity enters a scene. See [signal Entity.entered_scene].
func _on_enter_scene():
	pass

## Called when the parent entity exits a scene. See [signal Entity.left_scene].
func _on_exit_scene():
	pass
