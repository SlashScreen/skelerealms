class_name SpellEffect
extends Resource
## Base class for spell effects.


## The target of this spell effect.
var target:SpellTargetComponent


func apply(stc:SpellTargetComponent) -> void:
	target = stc


## Called every frame as the spell is active.
func on_update(delta:float) -> void:
	pass


## Called when the spell first begins.
func on_start_effect() -> void:
	pass


## Called when the spell ends.
func on_end_effect() -> void:
	pass
