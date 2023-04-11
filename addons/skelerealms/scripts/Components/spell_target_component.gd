class_name SpellTargetComponent
extends EntityComponent
## Allows entities to be hit with spells, and keeps track of any applied spell effects.


var active_effects:Array[SpellEffect] = []


signal hit_with_spell(spell:Spell)
signal added_effect(effect:SpellEffect)


## Hit this entity with a spell. Doesn't actually do anything apart from emit [signal hit_with_spell]. To apply effects, you can do that on the [Spell] side.
func hit(spell:Spell) -> void:
	hit_with_spell.emit(spell)


func _init() -> void:
	name = "SpellTargetComponent"


func _process(delta: float) -> void:
	# update all effects
	for eff in active_effects:
		eff.on_update(delta)


## Duplicates an initializes a new spell effect. Returns the new effect.
func add_effect(effect:SpellEffect) -> SpellEffect:
	var eff = effect.duplicate(true)
	eff.apply(self) # bind to this
	active_effects.append(eff)
	eff.on_start_effect() # callback
	return eff


## Dispel an effect.
func remove_effect(eff:SpellEffect) -> void:
	eff.on_end_effect()
	active_effects.erase(eff)
