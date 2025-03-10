class_name SKEntityComponent 
extends Node
## Base class for all entity components in the SkeleRealms system.
## Components add functionality to entities through composition. Each component should
## handle a specific aspect of entity behavior (e.g., inventory, vitals, equipment).

@onready var parent_entity:SKEntity = get_parent() as SKEntity  ## Reference to the entity this component belongs to
var dirty:bool = false  ## Whether this component has unsaved changes


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return 
	
	if not parent_entity.left_scene.is_connected(_on_exit_scene.bind()):
		parent_entity.left_scene.connect(_on_exit_scene.bind())
	if not parent_entity.entered_scene.is_connected(_on_enter_scene.bind()):
		parent_entity.entered_scene.connect(_on_enter_scene.bind())


## Called after the entity is fully initialized. Override to add component-specific setup.
func _entity_ready() -> void:
	pass


## Called when the parent entity enters a scene. Override to handle scene entry logic.
func _on_enter_scene():
	pass


## Called when the parent entity exits a scene. Override to handle scene exit logic.
func _on_exit_scene():
	pass


## Processes a dialogue command sent to the entity. Override to handle component-specific commands.
## [param command] The command string to process
## [param args] Array of arguments for the command
func _try_dialogue_command(command:String, args:Array) -> void:
	pass


## Serializes component state for saving. Override to add component-specific data.
## Returns dictionary of data to save.
func save() -> Dictionary:
	return {}


## Loads component state from saved data. Override to handle component-specific data.
## [param data] Dictionary containing the saved component state
func load_data(data:Dictionary):
	pass


## Gather and format any relevant info for a debug console or some other debugger.
func gather_debug_info() -> String:
	return ""


func _to_string() -> String:
	return gather_debug_info()


## Prints a rich text message to the console with entity context
## [param text] The message to print
## [param show_stack] Whether to include the stack trace
func printe(text:String, show_stack:bool = true) -> void:
	if parent_entity:
		parent_entity.printe(text, show_stack)
	else:
		(get_parent() as SKEntity).printe(text, show_stack)


## Lists other components required by this component. Override to specify dependencies.
## Returns array of required component class names.
func get_dependencies() -> Array[String]:
	return []


## Performs one-time initialization when the entity is first generated.
## Override to add component-specific generation logic (e.g., randomization).
func on_generate() -> void:
	pass


## Validates component setup and dependencies
func _get_configuration_warnings() -> PackedStringArray:
	var output := PackedStringArray()
	
	if not (get_parent() is SKEntity or get_parent() is SKElementGroup):
		output.push_back("Component should be the child of an SKEntity or an SKElementGroup.")
	
	for dep:String in get_dependencies():
		if not get_parent().has_node(dep):
			output.push_back("This component needs %s" % dep)
	
	return output
