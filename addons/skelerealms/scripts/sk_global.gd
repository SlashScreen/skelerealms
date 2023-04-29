extends Node
## A singleton that allows any script to access various important nodes without having to deal with scene scope.


## Reference to the [EntityManager] singleton.
var entity_manager:EntityManager
## Reference to the [QuestEngine].
var quest_engine:QuestEngine
## World states for the GOAP system.
var world_states:Dictionary


## Attempts to find an entity in the tree above a node. Returns null if none found. Automatically takes account of reparented puppets.
func get_entity_in_tree(child:Node) -> Entity:
	var checking = child
	while not checking.get_parent() == null:
		if checking is Entity:
			return checking
		
		# Check if puppet and getting puppeteer
		if checking.has_method("get_puppeteer"):
			if checking.get_puppeteer():
				checking = checking.get_puppeteer()
				continue
		
		checking = checking.owner

	return null
