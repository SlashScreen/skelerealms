class_name SkillsComponent
extends EntityComponent
## Component holding the skills of this entity. 
## Examples in Skyrim would be Destruction, Sneak, Alteration, Smithing.


## The skills of this Entity.
## It is in a dictionary so you can add, remove, and customize at will.
@onready var skills:Dictionary = EntityManager.instance.config.skills.duplicate():
	get:
		return skills
	set(val):
		skills = val
		dirty = true
## Character level of this character
var level:int = 0
## Used to determine how to save levels.
var _manually_set_level = false
var skill_xp:Dictionary = {}
var character_xp:int = 0

signal skill_levelled_up(skill:StringName, new_level:int)
signal character_levelled_up(new_level:int)


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


func gather_debug_info() -> String:
	return """
[b]SkillsComponent[/b]
	Skills:
%s
""" % [
	JSON.stringify(skills, '\t').indent("\t\t")
]


func add_skill_xp(skill:StringName, amount:int) -> void:
	if not skills.has(skill):
		push_warning("Entity %s has no skill %s." % [parent_entity.name, skill])
		return 
	skill_xp[skill] += amount
	var target:int = EntityManager.instance.config.compute_skill(skills[skill])
	if target == -1:
		return
	if skill_xp[skill] >= target:
		skills[skill] += 1
		skill_levelled_up.emit(skill, skills[skill])


func add_character_xp(amount:int) -> void:
	character_xp += amount
	var target:int = EntityManager.instance.config.compute_character(level)
	if target == -1:
		return
	if character_xp >= amount:
		level += 1
		character_levelled_up.emit(level)
