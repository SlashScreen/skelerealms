class_name DamageInfo
extends RefCounted
## The effects of a damage event.
## Read the tutorial for how to use these.
## @tutorial(Damage Effects): https://github.com/SlashScreen/skelerealms/wiki/Damage-Effects


## Who caused the damage?
var offender:String
## The different kinds of damage.
var damage_effects:Dictionary
## Optional spell effects.
var spell_effects:Array[SpellEffect] = []
## Optional extra info.
var info:Dictionary = {}


func _init(who:String, what:Dictionary, spells:Array[SpellEffect] = [], data:Dictionary = {}) -> void:
	offender = who
	damage_effects = what
	spell_effects = spells
	info = data
