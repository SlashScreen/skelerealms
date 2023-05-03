class_name VitalsComponent
extends EntityComponent
## Component keeping check of the main 3 attributes of an entity - health, stamina, and magica.


## Called when this entity's health reaches 0. See [member health].
signal dies
## Called when the stamina value reaches 0. See [member moxie].
signal exhausted
## Called when the magica value reaches 0. See [member will].
signal drained

signal hurt


## Health, stamina, magica, and max of values.
var vitals = {
	"health" = 100,
	"moxie" = 100,
	"will" = 100,
	"max_health" = 100,
	"max_moxie" = 100,
	"max_will" = 100,
}:
	get:
		return vitals
	set(val):
		vitals = val
		dirty = true


## Whether this agent is dead.
var is_dead:bool: 
	get:
		return vitals["health"] <= 0
## Whether this agent is exhausted.
var is_exhausted:bool: 
	get:
		return vitals["moxie"] <= 0
## Whether this agent is drained.
var is_drained:bool: 
	get:
		return vitals["will"] <= 0


func _init() -> void:
	name = "VitalsComponent"


func save() -> Dictionary:
	dirty = false
	return vitals


func load_data(data:Dictionary):
	vitals = data
	dirty = false
