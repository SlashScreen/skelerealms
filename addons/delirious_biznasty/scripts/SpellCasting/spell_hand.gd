class_name SpellHand
extends Node3D
## Spell casting origin. This is a Node3D, and in general, it should be placed underneath a hand bone, or the top of a staff, or something like that.
## You gotta connect these to inputs yourself.


## What spell is active right now.
var _active_spell:Spell


func cast_spell():
	_active_spell.reset()
	_active_spell.on_spell_cast()


func hold_spell(delta):
	_active_spell.on_spell_held(delta)


func release_spell():
	_active_spell.on_spell_released()


func load_spell(sp:Spell):
	_active_spell = sp
	sp._caster = self
	sp.reset()