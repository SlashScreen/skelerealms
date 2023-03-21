class_name EntityManager extends Node3D

const g_info = preload("game_info.gd")
const option = preload("option.gd")

var game_info:GameInfo

func _ready():
	game_info = $"../GameInfo" as GameInfo

func get_entity(id:String) -> Option:
	return Option.from(get_node_or_null(id))
