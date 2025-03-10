class_name VitalsComponent
extends SKEntityComponent
## Component that manages an entity's vital statistics (health, stamina, and magic).

# TODO: This is for player only, make a generalized one 
signal dies  ## Emitted when health reaches 0
signal exhausted  ## Emitted when stamina (moxie) reaches 0
signal drained  ## Emitted when magic (will) reaches 0
signal hurt  ## Emitted when the entity takes damage
signal vitals_updated(data:Dictionary)  ## Emitted when any vital stat changes

const DISHONORED_MODE:bool = false  ## Enables Dishonored-style magic regeneration system, where magic is drained when cast and regenerates over time to the previous value.

var vitals = {  ## Dictionary containing current and maximum values for all vital stats
	&"health" : 100.0,
	&"moxie" : 100.0,
	&"will" : 100.0,
	&"max_health" : 100.0,
	&"max_moxie" : 100.0,
	&"max_will" : 100.0,
	&"return_to_will" : 0.0,
}:
	get:
		return vitals
	set(val):
		vitals = val
		dirty = true
		vitals_updated.emit(vitals)
var moxie_recharge_rate:float = 2  ## Rate at which stamina regenerates per second
var moxie_just_changed:bool  ## Tracks if stamina changed this frame to control regeneration
var will_recharge_rate:float = 1  ## Rate at which magic regenerates per second
var will_just_changed:bool  ## Tracks if magic changed this frame to control regeneration


## Whether the entity's health is below 1
var is_dead:bool: 
	get:
		return vitals[&"health"] <= 0
## Whether this agent is exhausted.
var is_exhausted:bool: 
	get:
		return vitals[&"moxie"] <= 0
## Whether the entity's magic is drained
var is_drained:bool: 
	get:
		return vitals[&"will"] <= 0
var will_timer:Timer  ## Timer for Dishonored-style magic regeneration
var tween:Tween  ## Tween for smooth magic regeneration


func _init() -> void:
	name = &"VitalsComponent"


func _ready() -> void:
	will_timer = Timer.new()
	add_child(will_timer)
	will_timer.timeout.connect(do_return_to_will.bind())
	will_timer.one_shot = true


## Sets health to a specific value, clamped between 0 and max_health
## [param val] The new health value
func set_health(val:float) -> void:
	vitals[&"health"] = clampf(val, 0.0, vitals[&"max_health"])
	vitals_updated.emit(vitals)
	if is_dead:
		dies.emit()


## Changes health by a relative amount
## [param val] Amount to change health by (positive or negative)
func change_health(val:float) -> void:
	set_health(vitals[&"health"] + val)


## Sets stamina to a specific value, clamped between 0 and max_moxie
## [param val] The new stamina value
func set_moxie(val:float) -> void:
	vitals[&"moxie"] = clampf(val, 0.0, vitals[&"max_moxie"])
	vitals_updated.emit(vitals)
	moxie_just_changed = true
	if is_exhausted:
		exhausted.emit()


## Changes stamina by a relative amount
## [param val] Amount to change stamina by (positive or negative)
func change_moxie(val:float) -> void:
	set_moxie(vitals[&"moxie"] + val)


## Sets magic to a specific value, clamped between 0 and max_will
## [param val] The new magic value
func set_will(val:float) -> void:
	vitals[&"will"] = clampf(val, 0.0, vitals[&"max_will"])
	vitals_updated.emit(vitals)
	will_just_changed = true
	if is_drained:
		drained.emit()


## Handles magic consumption and regeneration setup for spell casting
## [param cost] Amount of magic the spell costs
func cast_spell(cost:float) -> void:
	if DISHONORED_MODE:
		if tween:
			tween.kill()
		vitals[&"return_to_will"] = vitals[&"will"]
		will_just_changed = true
		will_timer.start(1.0)
	change_will(-cost)


## Initiates the Dishonored-style magic regeneration tween
func do_return_to_will() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_method(set_will.bind(), vitals.will, vitals.return_to_will, 1.0)
	tween.tween_callback(func(): 
		will_just_changed = false)


## Changes magic by a relative amount
## [param val] Amount to change magic by (positive or negative)
func change_will(val:float) -> void:
	set_will(vitals[&"will"] + val)


## Saves current vital statistics. Returns serialized vitals data.
func save() -> Dictionary:
	dirty = false
	return vitals


## Loads vital statistics from saved data
## [param data] Dictionary containing saved vitals data
func load_data(data:Dictionary):
	vitals = data
	dirty = false


func _physics_process(delta: float) -> void:
	if not moxie_just_changed and not vitals.moxie == vitals.max_moxie:
		change_moxie(moxie_recharge_rate * delta)
	moxie_just_changed = false
	
	if not will_just_changed and not vitals.will == vitals.max_will:
		change_will(will_recharge_rate * delta)
	if not DISHONORED_MODE:
		will_just_changed = false


func gather_debug_info() -> String:
	return """
[b]VitalsComponent[/b]
	Vitals: 
%s
""" % [
	JSON.stringify(vitals, '\t').indent("\t\t")
]
