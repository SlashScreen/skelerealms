class_name VitalsComponent
extends EntityComponent
## Component keeping check of the main 3 attributes of an entity - health, stamina, and magica.

# TODO: This is for player only, make a generalized one 
## Called when this entity's health reaches 0. See [member health].
signal dies
## Called when the stamina value reaches 0. See [member moxie].
signal exhausted
## Called when the magica value reaches 0. See [member will].
signal drained
signal hurt
signal vitals_updated(data:Dictionary)


const DISHONORED_MODE:bool = false
## Health, stamina, magica, and max of values.
var vitals = {
	"health" = 100.0,
	"moxie" = 100.0,
	"will" = 100.0,
	"max_health" = 100.0,
	"max_moxie" = 100.0,
	"max_will" = 100.0,
	"return_to_will" = 0.0,
}:
	get:
		return vitals
	set(val):
		vitals = val
		dirty = true
		vitals_updated.emit(vitals)
var moxie_recharge_rate:float = 2
var moxie_just_changed:bool
var will_recharge_rate:float = 1
var will_just_changed:bool


## Whether this agent is dead.
var is_dead:bool: 
	get:
		return vitals["health"] < 1
## Whether this agent is exhausted.
var is_exhausted:bool: 
	get:
		return vitals["moxie"] < 1
## Whether this agent is drained.
var is_drained:bool: 
	get:
		return vitals["will"] < 1
var will_timer:Timer
var tween:Tween


func _init() -> void:
	name = "VitalsComponent"


func _ready() -> void:
	will_timer = Timer.new()
	add_child(will_timer)
	will_timer.timeout.connect(do_return_to_will.bind())
	will_timer.one_shot = true


func set_health(val:float) -> void:
	vitals["health"] = clampf(val, 0.0, vitals["max_health"])
	vitals_updated.emit(vitals)
	if is_dead:
		dies.emit()


func change_health(val:float) -> void:
	set_health(vitals["health"] + val)


func set_moxie(val:float) -> void:
	vitals["moxie"] = clampf(val, 0.0, vitals["max_moxie"])
	vitals_updated.emit(vitals)
	moxie_just_changed = true
	if is_exhausted:
		exhausted.emit()


func change_moxie(val:float) -> void:
	set_moxie(vitals["moxie"] + val)


func set_will(val:float) -> void:
	vitals["will"] = clampf(val, 0.0, vitals["max_will"])
	vitals_updated.emit(vitals)
	will_just_changed = true
	if is_drained:
		drained.emit()


func cast_spell(cost:float) -> void:
	if DISHONORED_MODE:
		if tween:
			tween.kill()
		vitals.return_to_will = vitals["will"]
		will_just_changed = true
		will_timer.start(1.0)
	change_will(-cost)


func do_return_to_will() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_method(set_will.bind(), vitals.will, vitals.return_to_will, 1.0)
	tween.tween_callback(func(): 
		will_just_changed = false)


func change_will(val:float) -> void:
	set_will(vitals["will"] + val)


func save() -> Dictionary:
	dirty = false
	return vitals


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
