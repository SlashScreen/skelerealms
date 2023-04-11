class_name SpellTargetComponent
extends EntityComponent


var active_effects:Array[SpellEffect] = []


signal hit_with_spell(spell:Spell)


func _init() -> void:
	name = "SpellTargetComponent"


func _process(delta: float) -> void:
	# update all effects
	for eff in active_effects:
		eff.on_update(delta)


func add_effect(effect:SpellEffect) -> void:
	var eff = effect.duplicate(true)
	eff.apply(self) # bind to this
	active_effects.append(eff)
	eff.on_start_effect() # callback


## Dispel an effect.
func remove_effect(eff:SpellEffect) -> void:
	eff.on_end_effect()
	active_effects.erase(eff)
