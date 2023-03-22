class_name EntityManager extends Node

const g_info = preload("game_info.gd")
const option = preload("option.gd")

var game_info:GameInfo
var entities:Dictionary

func _ready():
	game_info = $"../GameInfo" as GameInfo

func get_entity(id:String) -> Option:
	# stage 1: attempt find in cache
	if entities.has(id):
		return Option.from(entities[id])
	# stage 2: attempt find in children
	var possible_child = get_node_or_null(id)
	if possible_child != null:
		entities[id] = possible_child # cache entity
		return Option.from(possible_child)
	# TODO: Check in database
	# Other than that, we've failed. Return None.
	return Option.from(get_node_or_null(id))

# add a new entity.
func add_entity():
	pass

# remove an entity from the game.
func remove_entity(refID:String):
	remove_child(get_node(refID))
	entities.erase(refID)
