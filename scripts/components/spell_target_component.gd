class_name SpellTargetComponent
extends SKEntityComponent
## Component that enables entities to be affected by spells and manage spell effects.
## Works in conjunction with EffectsComponent to handle status effects from spells.

var status_effect:EffectsComponent  ## Reference to the entity's EffectsComponent for managing status effects

signal hit_with_spell(spell:Spell)  ## Emitted when the entity is hit by a spell


## Processes a spell hit on this entity
## [param spell] The spell that hit this entity
func hit(spell:Spell) -> void:
	hit_with_spell.emit(spell)


func _init() -> void:
	name = &"SpellTargetComponent"


## Sets up the reference to the entity's EffectsComponent
func _entity_ready() -> void:
	status_effect = parent_entity.get_component(&"EffectsComponent")


## Adds a status effect to the entity
## [param effect] The name of the effect to add
func add_effect(effect:StringName) -> void:
	status_effect.add_effect(effect)


## Removes a status effect from the entity
## [param eff] The name of the effect to remove
func remove_effect(eff:StringName) -> void:
	status_effect.remove_effect(eff)
