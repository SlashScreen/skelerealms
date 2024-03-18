class_name SpellTargetObject
extends Node3D

# I wish I had mixins or interfaces. maybe I need to restructure something?
@onready var status_effects:EffectsObject = $EffectsObject


signal hit_with_spell(sp:Spell)


func hit(sp:Spell):
	hit_with_spell.emit(sp)


func apply_effect(eff:StringName):
	status_effects.add_effect(eff)
