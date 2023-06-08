class_name SpellTargetObject
extends Node3D

# I wish I had mixins or interfaces. maybe I need to restructure something?
var active_effects:Array[SpellEffect] = []


signal hit_with_spell


func hit():
	pass


func apply_effect(eff:SpellEffect):
	# TODO: Emit effect
	active_effects.append(eff)
