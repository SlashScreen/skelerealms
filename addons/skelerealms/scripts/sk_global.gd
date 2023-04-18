extends Node
## A singleton that allows any script to access various important nodes without having to deal with scene scope.


## Reference to the [EntityManager] singleton.
var entity_manager:EntityManager
## Reference to the [QuestEngine].
var quest_engine:QuestEngine
## World states for the GOAP system.
var world_states:Dictionary


## Attempts to find an entity in the tree above a node. Returns null if none found. Automatically takes account of reparented puppets.
## By default, for efficiency, it walks up the tree by jumping from owner to owner, because objects connected to entities are intended to be set up to have the entity be an owner at some point,
## As well as have the puppet root node be an owner as well. If you're having issues with it finding the entity because of this, that is a code smell, but if for watever reason you cannot structure your
## tree the intended way, you can turn owner mode off and it will go parent by parent.
static func get_entity_in_tree(child:Node, owner_mode:bool = true) -> Entity:
	var checking = child
	while (not owner_mode and not checking.parent() == null) or (owner_mode and not checking.owner == null):
		if checking is Entity:
			return checking
		
		# Check if puppet and getting puppeteer
		if checking.has_method("get_puppeteer"):
			if checking.get_puppeteer():
				checking = checking.get_puppeteer()
				continue
		
		if owner_mode:
			checking = checking.owner
		else:
			checking = checking.get_parent()
	return null
