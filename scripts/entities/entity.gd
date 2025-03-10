@tool
class_name SKEntity
extends Node
## Base class for all entities in the SkeleRealms system.
## Entities are persistent objects that can exist in the game world, such as NPCs, items, or containers.
## Each entity is composed of [SKEntityComponent]s that define its behavior and capabilities.
## Entities persist even when not in the active scene and can be dynamically loaded/unloaded based on distance.


## The form ID defines what kind of entity this is (e.g., "iron_sword" for an iron sword item)
@export var form_id: StringName

## The world identifier where this entity exists
@export var world: String

## The entity's position within its world
@export var position:Vector3

## The entity's rotation in quaternion format
@export var rotation: Quaternion = Quaternion.IDENTITY

## Whether this is a unique entity (e.g., a named NPC) rather than a generic instance
@export var unique:bool = true

## Time elapsed since this entity was last modified or referenced
## Used by [SKEntityManager] to determine when to clean up inactive entities after saving
var stale_timer:float

## Controls whether the entity should spawn in the scene
## Used to prevent spawning of items that are contained within other entities (e.g., inventory items)
var supress_spawning:bool

## Whether the entity is currently in the active scene
var in_scene: bool:
	get:
		return in_scene
	set(val):
		if in_scene && !val: # Leaving scene
			left_scene.emit()
			printe("left scene", false)
		if !in_scene && val: # Entering scene
			entered_scene.emit()
			printe("entered scene", false)
		in_scene = val


## Emitted when the entity leaves the active scene
signal left_scene

## Emitted when the entity enters the active scene
signal entered_scene

## Emitted when all components have been added and the entity is fully initialized
## Wait for this signal before connecting to other nodes or accessing components
signal instantiated


func _init() -> void:
	instantiated.emit()
	for c in get_children():
		c._entity_ready()


func _ready():
	if Engine.is_editor_hint():
		return
	add_to_group("savegame_entity")


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		print(scene_file_path)
		return
	if not get_parent() is SKEntityManager:
		queue_free()


func _process(delta):
	if Engine.is_editor_hint():
		return
	_should_be_in_scene()
	# Update stale timer when not in scene
	if not in_scene:
		stale_timer += delta
	else:
		stale_timer = 0


## Determines if this entity should be loaded in the active scene based on:
## - Whether spawning is suppressed
## - If it's in the current world
## - Distance from the world origin (actor fade distance)
func _should_be_in_scene():
	if supress_spawning:
		in_scene = false
		return
	# if not in correct world
	if GameInfo.world != world:
		in_scene = false
		return
	# if we are outside of actor fade distance
	if position.distance_squared_to(GameInfo.world_origin.global_position) > ProjectSettings.get_setting("skelerealms/actor_fade_distance") ** 2:
		in_scene = false
		return
	in_scene = true


## Updates the entity's position
## [param p] The new position vector
func _on_set_position(p:Vector3):
	position = p


## Updates the entity's rotation
## [param q] The new rotation quaternion
func _on_set_rotation(q:Quaternion) -> void:
	rotation = q


## Gets a component by its type name
## [param type] The component type to retrieve (e.g., "NPCComponent")
## Returns: The requested component or null if not found
## Example: [codeblock]
## (e.get_component("NPCComponent") as NPCComponent).kill()
## [/codeblock]
func get_component(type:String) -> SKEntityComponent:
	return get_node_or_null(type)


## Checks if the entity has a specific component type
## [param type] The component type to check for
## Returns: [code]true[/code] if the component exists
func has_component(type:String) -> bool:
	return get_component(type) != null


## Adds a new component to this entity
## [param c] The component to add
func add_component(c:SKEntityComponent) -> void:
	add_child(c)


## Serializes the entity's state for saving
## Returns: Dictionary containing entity data and dirty component states
func save() -> Dictionary:
	var data:Dictionary = {
		"entity_data": {
			"world" = world,
			"position" = position,
			"unique" = unique
		}
	}
	for c in get_children().filter(func(x:SKEntityComponent): return x.dirty): # filter to get dirty acomponents
		data["components"][c.name] = ((c as SKEntityComponent).save())
	return data


## Loads entity state from saved data
## [param data] Dictionary containing the saved entity state
func load_data(data:Dictionary) -> void:
	world = data["entity_data"]["world"]
	position = JSON.parse_string(data["entity_data"]["position"])
	unique = JSON.parse_string(data["entity_data"]["unique"])

	for d in data["components"]:
		(get_node(d) as SKEntityComponent).load_data(data[d])


## Resets the entity to its initial state
## TODO: Handle runtime-generated entities
func reset_data() -> void:
	var i = SKEntityManager.instance.get_disk_data_for_entity(name)
	if i:
		_init()


## Resets the stale timer, preventing cleanup
func reset_stale_timer() -> void:
	stale_timer = 0


## Broadcasts a message to all components
## [param msg] The message/method name to call
## [param args] Arguments to pass to the method
func broadcast_message(msg:String, args:Array = []) -> void:
	for c in get_children():
		if c.has_method(msg):
			c.call(msg, args)


## Sends a dialogue command to all components
## [param command] The command to process
## [param args] Arguments for the command
func dialogue_command(command:String, args:Array) -> void:
	for c in get_children():
		c._try_dialogue_command(command, args)


## Gets a preview scene for [SKWorldEntity] visualization
## Returns: Preview node or null if none available
func get_world_entity_preview() -> Node:
	for c:Node in get_children():
		if c.has_method(&"get_world_entity_preview"):
			return c.get_world_entity_preview()
	return null


## Initializes a newly generated entity instance
## Called when spawning non-unique entities (e.g., random enemies)
func generate() -> void:
	for c:Node in get_children():
		c.on_generate()


## Gathers debug information about the entity and its components
## Returns: Array of strings containing formatted debug info
func gather_debug_info() -> PackedStringArray:
	var info := PackedStringArray()
	info.push_back("""
[b]SKEntity[/b]
	RefID: %s
	FormID: %s
	World: %s
	Position: x%s y%s z%s
	Rotation: x%s y%s z%s
	In scene: %s
""" % [
	name,
	form_id,
	world,
	position.x,
	position.y,
	position.z,
	rotation.x,
	rotation.y,
	rotation.z,
	in_scene
])
	
	for c in get_children():
		var i:String = (c as SKEntityComponent).gather_debug_info()
		if not i.is_empty():
			info.push_back(i)
	
	return info


## String representation of the entity, includes all debug info
func _to_string() -> String:
	return "\n".join(gather_debug_info())


## Prints a rich text debug message with entity context
## [param text] The message to print
## [param show_stack] Whether to include the stack trace
func printe(text:String, show_stack:bool = true) -> void:
	print_rich("[b]%s[/b]: %s\n%s" % [name, text, _format_stack_trace() if show_stack else ""])


## Formats the current stack trace for debug output
## Returns: Formatted string containing the stack trace
func _format_stack_trace() -> String:
	var trace:Array = get_stack()
	var output := "[indent]"
	for d:Dictionary in trace:
		output += "%s: [url]%s:%d[/url]\n" % [d.function, d.source, d.line]
	return output
