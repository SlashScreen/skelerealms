class_name AttributesComponent
extends SKEntityComponent
## Holds the attributes of an SKEntity, such as the D&D abilities - Charisma, Dexterity, etc.


## The attributes of this SKEntity.
## It is in a dictionary so you can add, remove, and customize at will.
@export var attributes:Dictionary:
	get:
		return attributes
	set(val):
		attributes = val
		dirty = true
# I yearn for Ruby's symbols, but StingName is an adequate substitute.
# I yearn for ruby just in general.

func _init() -> void:
	name = "AttributesComponent"


func save() -> Dictionary:
	dirty = false
	return attributes


func load_data(data:Dictionary):
	attributes = data
	dirty = false


func gather_debug_info() -> String:
	return """
[b]AttributesComponent[/b]
	Attributes: 
%s
""" % [
	JSON.stringify(attributes, '\t').indent("\t\t")
]
