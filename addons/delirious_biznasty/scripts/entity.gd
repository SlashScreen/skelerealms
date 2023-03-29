class_name Entity 
extends Node
## An entity for the pseudo-ecs. Contains [EntityComponent]s.
## These allow constructs such as NPCs and Items to persist even when not in the scene.


## The world this entity is in.
@export var world: String
## Position within the world it's in.
@export var position:Vector3
## An internal timer of how long this entity has gone without being modified or referenced. 
## One it's beyond a certain point, the [EntityManager] will mark it for cleanup after a save.
var stale_timer:float


## Whether this entity is in the scene or not.
var in_scene: bool: 
	get:
		return in_scene
	set(val):
		if not val:
			print("%s is not in scene, it's in world %s" % [name, world])
		if in_scene && !val: # if was in scene and now not
			print("%s left scene" % name)
			left_scene.emit()
		if !in_scene && val: # if was not in scene and now is
			print("%s entered scene" % name)
			entered_scene.emit()
		in_scene = val


## Emitted when an entity enters a scene.
signal left_scene
## Emitted when an entity leaves a scene.
signal entered_scene


func _ready():
	add_to_group("savegame")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_should_be_in_scene()
	# If we aren't in the scene, start counting up. Otherwise, we are still in the scene with the player and shouldn't depsawn.
	if not in_scene:
		stale_timer += delta
	else:
		stale_timer = 0


func _should_be_in_scene():
	# if not in correct world
	if BizGlobal.game_info.world != world:
		in_scene = false
		return
	# if we are outside of actor fade distance
	if position.distance_squared_to(get_viewport().get_camera_3d().position) > ProjectSettings.get_setting("biznasty/actor_fade_distance") ** 2: # does this work??
		in_scene = false
		return
	in_scene = true


func _on_set_position(p:Vector3):
	position = p


## Gets a component by the string name. 
## Example: [codeblock]
## (e.get_component("NPCComponent").unwrap() as NPCComponent).kill()
## [/codeblock]
func get_component(type:String) -> Option:
	var n = get_node_or_null(type)
	return Option.from(n)


## Whether it has a component type or not. Useful for checking the capabilities of an entity.
func has_component(type:String) -> bool:
	var x = get_component(type)
	return x.some()


# TODO: Determine whether it should be saved (add "dirty" variable)
# TODO: Don't participate if there's nothing to save
func save() -> Dictionary: 
	var data:Dictionary = {}
	for c in get_children():
		data[c.name] = ((c as EntityComponent).save())
	return data


func load_data(data:Dictionary):
	# loop through all saved components and call load
	for d in data:
		get_node(d).load(data[d])
	pass


func reset_stale_timer():
	stale_timer = 0
