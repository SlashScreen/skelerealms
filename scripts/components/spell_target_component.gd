class_name SpellTargetComponent
extends EntityComponent
## Allows entities to be hit with spells, and keeps track of any applied spell effects.


var status_effect:EffectsComponent


signal hit_with_spell(spell:Spell)


## Hit this entity with a spell. Doesn't actually do anything apart from emit [signal hit_with_spell]. To apply effects, you can do that on the [Spell] side.
func hit(spell:Spell) -> void:
	hit_with_spell.emit(spell)


func _init() -> void:
	name = "SpellTargetComponent"


func _entity_ready() -> void:
	status_effect = parent_entity.get_component(&"EffectsComponent")


func add_effect(effect:StringName) -> void:
	status_effect.add_effect(effect)


func remove_effect(eff:StringName) -> void:
	status_effect.remove_effect(eff)
