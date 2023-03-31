class_name SpellTargetComponent
extends EntityComponent


var active_effects:Array[SpellEffect] = []


# TODO: This
signal hit_with_spell(spell:Spell)


func hit():
	pass


func apply_effect(eff:SpellEffect):
	# TODO: Emit effect
	active_effects.append(eff)
