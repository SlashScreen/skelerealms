class_name SKEntityComponent 
extends Node
## A component that is within an [SKEntity].
## Extend these to add functionality to an entity.
## When inheriting, make sure to call super._ready() if overriding.


## Parent entity of this component.
@onready var parent_entity:SKEntity = get_parent() as SKEntity
## Whether this component should be saved.
var dirty:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return 
	
	parent_entity = get_parent() as SKEntity
	if not parent_entity.left_scene.is_connected(_on_exit_scene.bind()):
		parent_entity.left_scene.connect(_on_exit_scene.bind())
	if not parent_entity.entered_scene.is_connected(_on_enter_scene.bind()):
		parent_entity.entered_scene.connect(_on_enter_scene.bind())


func _entity_ready() -> void:
	pass


## Called when the parent entity enters a scene. See [signal SKEntity.entered_scene].
func _on_enter_scene():
	pass


## Called when the parent entity exits a scene. See [signal SKEntity.left_scene].
func _on_exit_scene():
	pass


## Process a dialogue command given to the entity.
func _try_dialogue_command(command:String, args:Array) -> void:
	pass


## Gather data to save.
func save() -> Dictionary:
	return {}


## Load a data blob from the savegame system.
func load_data(data:Dictionary):
	pass


## Gather and format any relevant info for a debug console or some other debugger.
func gather_debug_info() -> String:
	return ""


func _to_string() -> String:
	return gather_debug_info()


## Prints a rich text message to the console prepended with the entity name. Used for easier debugging. 
func printe(text:String) -> void:
	if parent_entity:
		parent_entity.printe(text)
	else:
		(get_parent() as SKEntity).printe(text)


## Get the dependencies for this node, for error warnings. Dependencies are the class name as a string.
func get_dependencies() -> Array[String]:
	return []


## Do any first-time setup needed for this component. For example, roll a loot table, randomize facial attributes, etc.
func on_generate() -> void:
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var output := PackedStringArray()
	
	if not (get_parent() is SKEntity or get_parent() is SKElementGroup):
		output.push_back("Component should be the child of an SKEntity or an SKElementGroup.")
	
	for dep:String in get_dependencies():
		if not get_parent().has_node(dep):
			output.push_back("This component needs %s" % dep)
	
	return output
