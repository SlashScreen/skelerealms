class_name AttributesComponent
extends SKEntityComponent
## Component that manages entity attributes in a flexible, dictionary-based system.
## Allows for custom attributes similar to RPG stats (Strength, Dexterity, etc.).

@export var attributes:Dictionary:  ## Dictionary storing attribute name-value pairs
	get:
		return attributes
	set(val):
		attributes = val
		dirty = true
# I yearn for Ruby's symbols, but StingName is an adequate substitute.
# I yearn for ruby just in general.

func _init() -> void:
	name = &"AttributesComponent"


## Saves the current attributes state
## [returns] Dictionary of current attributes
func save() -> Dictionary:
	dirty = false
	return attributes


## Loads attributes from saved data
## [param data] Dictionary containing attribute data to load
func load_data(data:Dictionary):
	attributes = data
	dirty = false


## Generates a debug string showing all attributes and their values
## [returns] Formatted string with attribute debug information
func gather_debug_info() -> String:
	return """
[b]AttributesComponent[/b]
	Attributes: 
%s
""" % [
	JSON.stringify(attributes, '\t').indent("\t\t")
]
