class_name StatusEffect
extends Resource


## Base class for all status effects.


## The name of this effect.
@export var name:StringName
## The tags this status effect has.
@export var tags:Array[StringName] = []
## Status effects that this status effect will remove when applied to an entity.
## For example, the "wet" effect will negate the "burning" effect.
@export var negates:Array[StringName] = []
## Status effects with these tags will be removed when this status effect is applied.
## For example, the "muddy" and "slimy" effects may have a "dirty" tag. The "wet" effect
## would remove the "dirty" tag.
@export var negates_tags:Array[StringName] = []
## If an entity has an effect on this list, this effect will not be applied.
@export var incompatible:Array[StringName] = []
## If there are any effects with this tag on the entity, this status effect will not be applied.
@export var imcompatible_tags:Array[StringName] = []


## Called every frame as the effect is active.
func on_update(delta:float, target: EffectsComponent) -> void:
	pass


## Called when the effect first begins.
func on_start_effect(target: EffectsComponent) -> void:
	pass


## Called when the effect ends.
func on_end_effect(target: EffectsComponent) -> void:
	pass
