class_name EntityManager 
extends Node
## Manages entities in the game.

var entities:Dictionary

## Gets an entity in the game.
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

## add a new entity.
func add_entity(archetype:PackedScene):
	pass

## remove an entity from the game.
func remove_entity(refID:String):
	remove_child(get_node(refID))
	entities.erase(refID)
