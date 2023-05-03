extends Node
## A singleton that allows any script to access various important nodes without having to deal with scene scope.
## It also has some important utility functions for working with entities.


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


## Recursively get [RID]s of all children below this node if it is a [CollisionObject3D].
func get_child_rids(child:Node) -> Array:
	var output = []
	
	for c in child.get_children():
		if c is CollisionObject3D:
			output.append(c.get_rid())
		output.append_array(get_child_rids(c))
	
	return output


## Get any damageable node in parent chain or children 1 layer deep; either [DamageableObject] or [DamageableComponent]. Null if none found.
func get_damageable_node(n:Node) -> Node:
	# Check children
	for c in n.get_children():
		if c is DamageableObject:
			return c
	
	# Check for world object in parents
	var checking = n
	while not checking.get_parent() == null:
		if checking is DamageableObject:
			return checking
		
		# Check if puppet and getting puppeteer
		if checking.has_method("get_puppeteer"):
			if checking.get_puppeteer():
				checking = checking.get_puppeteer()
				continue
		
		checking = checking.owner
	
	# Check for entity component
	var e = get_entity_in_tree(n)
	if e:
		var dc = e.get_component("DamageableComponent")
		if dc.some():
			return dc.unwrap()
	
	return null


## Get any interactible node in parent chain or children 1 layer deep; either [InteractiveObject] or [InteractiveComponent]. Null if none found.
func get_interactive_node(n:Node) -> Node:
	# Check children
	for c in n.get_children():
		if c is InteractiveObject:
			return c
	
	# Check for world object in parents
	var checking = n
	while not checking.get_parent() == null:
		if checking is InteractiveObject:
			return checking
		
		# Check if puppet and getting puppeteer
		if checking.has_method("get_puppeteer"):
			if checking.get_puppeteer():
				checking = checking.get_puppeteer()
				continue
		
		checking = checking.owner
	
	# Check for entity component
	var e = get_entity_in_tree(n)
	if e:
		var dc = e.get_component("InteractiveComponent")
		if dc.some():
			return dc.unwrap()
	
	return null


## Get any spell target node in parent chain or children 1 layer deep; either [SpellTargetObject] or [SpellTargetComponent]. Null if none found.
func get_spell_target_component(n:Node) -> Node:
	# Check children
	for c in n.get_children():
		if c is SpellTargetObject:
			return c
	
	# Check for world object in parents
	var checking = n
	while not checking.get_parent() == null:
		if checking is SpellTargetObject:
			return checking
		
		# Check if puppet and getting puppeteer
		if checking.has_method("get_puppeteer"):
			if checking.get_puppeteer():
				checking = checking.get_puppeteer()
				continue
		
		checking = checking.owner
	
	# Check for entity component
	var e = get_entity_in_tree(n)
	if e:
		var dc = e.get_component("SpellTargetComponent")
		if dc.some():
			return dc.unwrap()
	
	return null
