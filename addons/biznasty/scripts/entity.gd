class_name Entity extends Node3D

const g_info = preload("game_info.gd")
const e_mngr = preload("entity_manager.gd")

@export var world: String
var in_scene: bool: set = _set_in_scene, get = _get_in_scene
var game_info:Callable
@export_enum("item") var type

signal left_scene
signal entered_scene

# TODO: Handle destruction

func _ready():
	game_info = func(): return (get_parent() as EntityManager).game_info

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	should_be_in_scene()
	
func _set_in_scene(val: bool):
	if in_scene && !val: # if was in scene and now not
		left_scene.emit()
	if !in_scene && val: # if was not in scene and now is
		entered_scene.emit()
	in_scene = val
	
func _get_in_scene() -> bool:
	return in_scene

func should_be_in_scene():
	# if not in correct world
	if game_info.call().world != world:
		in_scene = false
		return
	# if we are outside of actor fade distance
	if position.distance_squared_to(get_viewport().get_camera_3d().position) > game_info.call().actor_fade_distance ** 2: # does this work??
		in_scene = false
		return
	in_scene = true
