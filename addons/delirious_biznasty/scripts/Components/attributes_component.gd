class_name AttributesComponent
extends EntityComponent
## Holds the attributes of an Entity, such as the D&D abilities - Charisma, Dexterity, etc.


## The attributes of this Entity.
## It is in a dictionary so you can add, remove, and customize at will.
var attributes:Dictionary = {
	&"perception" : 0,
	&"luck" : 0,
	&"amity" : 0,
	&"maxnomity" : 0,
	&"litheness" : 0,
}
# I yearn for Ruby's symbols, but StingName is an adequate substitute.
# I yearn for ruby just in general.

func _init() -> void:
	name = "AttributesComponent"
