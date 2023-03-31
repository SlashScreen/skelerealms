class_name Spell
extends Resource
## This the base class for any spell that the player can cast.
## This essentially a blank slate, and as this is a GDScript file, a spell can do literally anything, sky is the limit.
## However, with great control comes great responsibility, my uncle once told me. This means you need to deal with basic stuff, like willpower drain, yourself.


## Spell's ID for translation.
@export var spell_name:String
## Custom assets for this spell; particles, floating hand models, spell effects, whatever.
## You can pack it all in here so you don't have to use load(), but you can still do that if you want to.
@export var spell_assets:Dictionary
## Whether being hit by this spell is to be considered an attack.
@export var aggressive:bool = false
## The spell caster.
var _caster:SpellHand


## When the spell is first cast.
func on_spell_cast():
	pass


## As the spell is being held by the player; eg. as the button is being held to blast flames.
## You can use the delta to drain willpower, or whatever.
func on_spell_held(delta):
	pass


## When the spell is released; eg. when the button is released.
## This doesn't just have to cancel the spell, though; perhaps the player needs to hold a spell to choose a target or charge a kamehameha, and then release to cast.
func on_spell_released():
	pass


## Find all spell targets ([SpellTargetComponent] and [SpellTargetProject]) in a range of a point.
## You can use this for an AOE attack.
func _find_spell_targets_in_range(pos:Vector3, range:float) -> Array:
	# TODO: This
	return []


# TODO:
# 	raycast
# 	spawn particle, node
# 	apply spell effect
