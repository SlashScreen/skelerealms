class_name SkillsComponent
extends SKEntityComponent
## Component that manages an entity's skills and leveling system.
## Handles skill progression, XP tracking, and level-ups similar to RPG systems like Skyrim.

@export var skills:Dictionary[StringName, int]:  ## Dictionary of skill names to their current levels
	get: return skills
	set(val):
		skills = val
		dirty = true

var level:int = 0  ## Current character level
var _manually_set_level = false  ## Whether level was manually set or calculated from skills
var skill_xp:Dictionary = {}  ## Maps skill names to their current XP progress
var character_xp:int = 0  ## Total XP towards next character level

signal skill_levelled_up(skill:StringName, new_level:int)  ## Emitted when a skill increases in level
signal character_levelled_up(new_level:int)  ## Emitted when the character gains a level


func _init() -> void:
	name = &"SkillsComponent"


## Saves the current skills and level state. Returns serialized component data.
func save() -> Dictionary:
	dirty = false
	return {
		"skills": skills,
		"level": level if _manually_set_level else -1
	}


## Loads skills and level data from saved state
## [param data] Dictionary containing saved skills and level data
func load_data(data:Dictionary):
	skills = data["skills"]
	level = data["level"]
	dirty = false


## Adds experience points to a specific skill, potentially triggering level-up
## [param skill] Name of the skill to add XP to
## [param amount] Amount of XP to add
func add_skill_xp(skill:StringName, amount:int) -> void:
	if not skills.has(skill):
		push_warning("SKEntity %s has no skill %s." % [parent_entity.name, skill])
		return 
	skill_xp[skill] += amount
	var target:int = SkeleRealmsGlobal.config.compute_skill(skills[skill])
	if target == -1:
		return
	if skill_xp[skill] >= target:
		skills[skill] += 1
		skill_levelled_up.emit(skill, skills[skill])


## Adds experience points toward character level, potentially triggering level-up
## [param amount] Amount of XP to add
func add_character_xp(amount:int) -> void:
	character_xp += amount
	var target:int = SkeleRealmsGlobal.config.compute_character(level)
	if target == -1:
		return
	if character_xp >= amount:
		level += 1
		character_levelled_up.emit(level)


## Generates a debug string showing current skills and levels. Returns formatted debug info.
func gather_debug_info() -> String:
	return """
[b]SkillsComponent[/b]
	Skills:
%s
""" % [
	JSON.stringify(skills, '\t').indent("\t\t")
]
