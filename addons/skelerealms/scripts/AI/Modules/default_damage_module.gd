class_name DefaultDamageModule
extends AIModule
## Example implementation of a damage processing AI Module.


@export_category("Physical")
@export var sharp_modifier:float = 1.0
@export var piercing_modifier:float = 1.0
@export var blunt_modifier:float = 1.0
@export var poison_modifier:float = 1.0
@export_category("Magic")
@export var magic_modifier:float = 1.0
@export var light_modifier:float = 1.0
@export var frost_modifier:float = 1.0
@export var flame_modifier:float = 1.0
@export var plant_modifier:float = 1.0
@export_category("Attribute")
@export var stamina_modifier:float = 1.0
@export var will_modifier:float = 1.0

var spell_component:SpellTargetComponent
var vitals_component:VitalsComponent

signal damage_received


func _initialize() -> void:
	print("damage module initialized.")
	await _npc.parent_entity.instantiated
	(_npc.parent_entity.get_component("DamageableComponent").unwrap() as DamageableComponent).damaged.connect(func(info):
		print("received info.")
		process_damage(info)
	)
	spell_component = _npc.parent_entity.get_component("SpellTargetComponent").unwrap()
	vitals_component = _npc.parent_entity.get_component("VitalsComponent").unwrap()


func process_damage(info:DamageInfo) -> void:
	# Damage effects
	print("processing damage")
	var accumulated_damage = 0
	for effect in info.damage_effects:
		print("Effect is %s" % effect)
		var effect_amount = info.damage_effects[effect]
		# if you have many more than these, some sort of dictionary may be in order.
		match effect:
			# Physical
			&"sharp":
				accumulated_damage = effect_amount * sharp_modifier
			&"piercing":
				accumulated_damage = effect_amount * piercing_modifier
			&"blunt":
				accumulated_damage = effect_amount * blunt_modifier
			&"poison":
				accumulated_damage = effect_amount * poison_modifier
			# Magic
			&"light":
				accumulated_damage = effect_amount * light_modifier * magic_modifier
			&"frost":
				accumulated_damage = effect_amount * frost_modifier * magic_modifier
			&"flame":
				accumulated_damage = effect_amount * flame_modifier * magic_modifier
			&"plant":
				accumulated_damage = effect_amount * plant_modifier * magic_modifier
			# Attribute
			&"moxie":
				vitals_component["moxie"] -= effect_amount * stamina_modifier
			&"will":
				vitals_component["will"] -= effect_amount * will_modifier
		
		_npc.damaged_with_effect.emit(effect)
	
	# Apply damage
	print("Accumulated damage: %s" % accumulated_damage)
	vitals_component["health"] -= accumulated_damage
	
	# Add magic effects
	for eff in info.spell_effects:
		spell_component.add_effect(eff)
	
	# Send damaging signal if we are hit by an entity
	# Could also add behavior somewhere to avoid areas that cause damage. Looking at you, Lydia Skyrim.
	if not info.offender == "":
		_npc.hit_by.emit(info.offender)
	
	damage_received.emit()
