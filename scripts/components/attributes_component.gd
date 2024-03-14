class_name AttributesComponent
extends EntityComponent
## Holds the attributes of an Entity, such as the D&D abilities - Charisma, Dexterity, etc.


## The attributes of this Entity.
## It is in a dictionary so you can add, remove, and customize at will.
@onready var attributes:Dictionary = EntityManager.instance.config.attributes.duplicate():
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
