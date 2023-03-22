extends Node3D

const entity_class = preload("entity.gd")

signal change_position(Vector3)

# Called when the node enters the scene tree for the first time.
func _ready():
	change_position.connect((get_parent().get_parent() as Entity)._on_set_position.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	change_position.emit(position)
