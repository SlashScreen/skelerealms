@tool
extends Node
## A global singleton for the SkeleRealms addon that provides centralized access to game systems and utility functions.
## Handles status effects, world states, configuration, and various entity-related operations.

const PriorityQueue = preload("res://addons/skelerealms/scripts/priority_queue.gd")

## Dictionary of world states used by the GOAP AI system
var world_states:Dictionary
## Dictionary of registered status effects that can be applied to entities
var status_effects:Dictionary = {}
## The loaded SkeleRealms configuration resource
var config:SKConfig 
## The currently active character slot number
var current_character: int = 0
## Queue for scheduling AI think operations
var think_queue := PriorityQueue.new()
## Total elapsed game time in seconds
var game_time_elapsed : float

## Emitted when the entity manager has completed loading all entities
signal entity_manager_loaded
## Emitted when an inventory container (chest, corpse, etc.) is opened
signal inventory_opened(id:StringName)

func _ready() -> void:
	ProjectSettings.settings_changed.connect(_reload_config.bind())
	_reload_config()

func _process(delta : float) -> void:
	game_time_elapsed += delta
	try_think()

## Reloads the SkeleRealms configuration from project settings
func _reload_config() -> void:
	var path:Variant = ProjectSettings.get_setting("skelerealms/config_path")
	
	if path == null:
		return
	if not path is String:
		return
	
	if not ResourceLoader.exists(path):
		config = null
		return 
	
	config = ResourceLoader.load(path)
	
	if Engine.is_editor_hint():
		return
	
	config.compile()
	for se:StatusEffect in config.status_effects:
		SkeleRealmsGlobal.register_effect(se.name, se)

## Searches up the scene tree from a node to find its parent entity
## Returns null if no entity is found
func get_entity_in_tree(child:Node) -> SKEntity:
	var checking = child
	while not checking.get_parent() == null:
		if checking is SKEntity:
			return checking
		
		# Check if puppet and getting puppeteer
		if checking.has_method("get_puppeteer"):
			if checking.get_puppeteer():
				checking = checking.get_puppeteer()
				continue
		
		checking = checking.get_parent()
	
	return null

## Gets an array of RIDs for all CollisionObject3D nodes in the given node's children
func get_child_rids(child:Node) -> Array:
	var output = []
	
	for c in child.get_children():
		if c is CollisionObject3D:
			output.append(c.get_rid())
		output.append_array(get_child_rids(c))
	
	return output

## Finds the nearest damageable node (component or object) from the given node
func get_damageable_node(n:Node) -> Node:
	return _walk_for_component(n, "DamageableComponent", func(x:Node): return x is DamageableObject)

## Finds the nearest interactive node (component or object) from the given node
func get_interactive_node(n:Node) -> Node:
	return _walk_for_component(n, "InteractiveComponent", func(x:Node): return x is InteractiveObject)

## Finds the nearest spell target node (component or object) from the given node
func get_spell_target_component(n:Node) -> Node:
	return _walk_for_component(n, "SpellTargetComponent", func(x:Node): return x is SpellTargetObject)

## Internal helper that searches for components or world objects in the scene tree
func _walk_for_component(n:Node, component_type:String, wo_check:Callable) -> Node:
	# Check children
	for c in n.get_children():
		if wo_check.call(c):
			return c
	
	# Check for world object in parents
	var checking = n
	while not checking.get_parent() == null:
		if wo_check.call(checking):
			return checking
		
		# Check if puppet and getting puppeteer
		if checking.has_method("get_puppeteer"):
			if checking.get_puppeteer():
				checking = checking.get_puppeteer()
				continue
		
		checking = checking.get_parent()
	
	# Check for entity component
	var e = get_entity_in_tree(n)
	if e:
		var dc = e.get_component(component_type)
		return dc
	
	return null

## Registers a new status effect that can be applied to entities
func register_effect(what:String, eff:StatusEffect) -> void:
	status_effects[what] = eff

## Schedules an AI think operation to occur at a specific game time
func register_think(callback : Callable, time : float) -> void: 
	think_queue.push(time, callback)

## Processes any pending AI think operations that are due to run
func try_think() -> void:
	if think_queue.is_empty():
		return
	
	var node : PriorityQueue.PQNode = think_queue.peek() # O(1)
	while game_time_elapsed >= node.priority:
		node.value.call()
		think_queue.pop()
		node = think_queue.peek()
