class_name SkillsComponent
extends EntityComponent
## Component holding the skills of this entity. 
## Examples in Skyrim would be Destruction, Sneak, Alteration, Smithing.


## The skills of this Entity.
## It is in a dictionary so you can add, remove, and customize at will.
var skills:Dictionary = {
	&"short_blade" : 0,
	&"long_blade" : 0,
	&"blunt" : 0,
}:
	get:
		return skills
	set(val):
		skills = val
		dirty = true


func _init() -> void:
	name = "SkillsComponent"


func save() -> Dictionary:
	dirty = false
	return skills


func load_data(data:Dictionary):
	skills = data
	dirty = false
