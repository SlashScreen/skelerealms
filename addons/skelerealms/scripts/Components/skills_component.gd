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
## The level of this entity/character. If not set manually, it will return a sum of all skills. If set manually, it will return the level set.
## It may seem like an odd choice to do it this way. In my own application of Skelerelams, I'm planning for levels to be calculated the sum way.
## However, not everyone will want to do it this way, so I allowed a more traditional approach as well. [br]
## Set it to -1 to restore summing behavior, if you so choose.
var level:int = -1:
	get:
		if level == -1:
			return skills.values().reduce(func(sum, next): return sum + next)
		else:
			return level
	set(val):
		level = val
		if not val == -1:
			_manually_set_level = true
		dirty = true
## Used to determine how to save levels.
var _manually_set_level = false


func _init() -> void:
	name = "SkillsComponent"


func save() -> Dictionary:
	dirty = false
	return {
		"skills": skills,
		"level": level if _manually_set_level else -1
	}


func load_data(data:Dictionary):
	skills = data["skills"]
	level = data["level"]
	dirty = false
