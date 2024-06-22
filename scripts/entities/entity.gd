@tool
class_name SKEntity
extends Node
## An entity for the pseudo-ecs. Contains [SKEntityComponent]s.
## These allow constructs such as NPCs and Items to persist even when not in the scene.


@export var form_id: StringName ## This is what [i]kind[/i] of entity it is. For example, Item "awesome_sword" has a form ID of "iron_sword".
@export var world: String: ## The world this entity is in.
	set(val):
		world = val
		printe("Setting world to %s" % val)
@export var position:Vector3 ## The entity's position in the world it lives within.
@export var rotation: Quaternion = Quaternion.IDENTITY ## The entity's rotation.
@export var unique:bool = true ## Whether this is the only entity of this setup. Usually used for named NPCs and the like.
## An internal timer of how long this entity has gone without being modified or referenced.
## One it's beyond a certain point, the [SKEntityManager] will mark it for cleanup after a save.
var stale_timer:float
## This is used to prevent items from spawning, even if they are supposed to be in scene.
## For example, items in invcentories should not spawn despite technically being "in the scene".
var supress_spawning:bool
## Whether this entity is in the scene or not.
var in_scene: bool:
	get:
		return in_scene
	set(val):
		if in_scene && !val: # if was in scene and now not
			left_scene.emit()
		if !in_scene && val: # if was not in scene and now is
			entered_scene.emit()
		in_scene = val


## Emitted when an entity enters a scene.
signal left_scene
## Emitted when an entity leaves a scene.
signal entered_scene
## This signal is emitted when all components have been added once [SKEntityManager.add_entity] is called.
## Await this when you want to connect with other nodes.
signal instantiated


func _init() -> void:
	# call entity ready
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		return
	_should_be_in_scene()
	# If we aren't in the scene, start counting up. Otherwise, we are still in the scene with the player and shouldn't depsawn.
	if not in_scene:
		stale_timer += delta
	else:
		stale_timer = 0


## Determine that this entity should be in scene
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


func _on_set_position(p:Vector3):
	position = p


func _on_set_rotation(q:Quaternion) -> void:
	rotation = q


## Gets a component by the string name.
## Example: [codeblock]
## (e.get_component("NPCComponent") as NPCComponent).kill()
## [/codeblock]
func get_component(type:String) -> SKEntityComponent:
	var n = get_node_or_null(type)
	return n


## Whether it has a component type or not. Useful for checking the capabilities of an entity.
func has_component(type:String) -> bool:
	var x = get_component(type)
	return not x == null


func add_component(c:SKEntityComponent) -> void:
	add_child(c)


func save() -> Dictionary: # TODO: Determine if instance is saved to disk. If not, save that as well. This will Theoretically allow for dynamic instances.
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


func load_data(data:Dictionary) -> void:
	world = data["entity_data"]["world"]
	position = JSON.parse_string(data["entity_data"]["position"])
	unique = JSON.parse_string(data["entity_data"]["unique"])

	# loop through all saved components and call load
	for d in data["components"]:
		(get_node(d) as SKEntityComponent).load_data(data[d])
	pass


func reset_data() -> void:
	# TODO: Figure out how to reset entities that are generated at runtime. oh boy that's gonna be fun.
	var i = SKEntityManager.instance.get_disk_data_for_entity(name)
	if i:
		_init()


func reset_stale_timer() -> void:
	stale_timer = 0


func broadcast_message(msg:String, args:Array = []) -> void:
	for c in get_children():
		if c.has_method(msg):
			c.call(msg, args)


func dialogue_command(command:String, args:Array) -> void:
	for c in get_children():
		c._try_dialogue_command(command, args)


## Get a preview scene tree from this entity, if applicable. This is used for getting previews for [class SKWorldEntity].
func get_world_entity_preview() -> Node:
	for c:Node in get_children():
		if c.has_method(&"get_world_entity_preview"):
			return c.get_world_entity_preview()
	return null


## Call this when an entity is generated for the first time; eg. a non-unique Spider enemy is spawned.
func generate() -> void:
	for c:Node in get_children():
		c.on_generate()


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


func _to_string() -> String:
	return "\n".join(gather_debug_info())


## Prints a rich text message to the console prepended with the entity name. Used for easier debugging. 
func printe(text:String) -> void:
	print_rich("[b]%s[/b]: %s\n%s" % [name, text, _format_stack_trace()])


func _format_stack_trace() -> String:
	var trace:Array = get_stack()
	var output := "[indent]"
	for d:Dictionary in trace:
		output += "%s: %s line %d\n" % [d.function, d.source, d.line]
	return output
