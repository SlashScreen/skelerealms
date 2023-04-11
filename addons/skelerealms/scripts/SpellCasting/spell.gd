class_name Spell
extends Resource
## This the base class for any spell that NPCs can cast.
## This essentially a blank slate, and as this is a GDScript file, a spell can do literally anything, sky is the limit.
## However, with great control comes great responsibility, my uncle once told me. This means you need to deal with basic stuff, like willpower drain, yourself.
## Despite that, it includes a number of helper methods to do the simple stuff. See [method _find_spell_targets_in_range].


## Spell's ID for translation.
@export var spell_name:String
## Custom assets for this spell; particles, floating hand models, whatever.
## You can pack it all in here so you don't have to use load(), but you can still do that if you want to.
@export var spell_assets:Dictionary
## An array of spell effects we can apply to something we hit.
@export var spell_effects:Array[SpellEffect]
## Whether being hit by this spell is to be considered an attack.
@export var aggressive:bool = false
## The spell caster.
var _caster:SpellHand


## When the spell is first cast.
func on_spell_cast():
	pass


## Called every frame as the spell is being held by the player; eg. as the button is being held to blast flames.
## You can use the delta to drain willpower, or whatever.
func on_spell_held(delta):
	pass


## When the spell is released; eg. when the button is released.
## This doesn't just have to cancel the spell, though; perhaps the player needs to hold a spell to choose a target or charge a kamehameha, and then release to cast.
func on_spell_released():
	pass


## Called when the spell needs to be reset to cast again, and also when it is loaded for the first time; so this is also like a _ready() function.
## Only reset your own variables; the variables defined in this parent class will not be re-initialized.
func reset():
	pass


## Find all nodes in a range of a point, with the results in a dictionary matching a physics query (like raycasting). 
## You can use this for an AOE attack.
## Using ignore_self assumes that the caster's origin defines the root of the actor casting it.
## Only returns 32 results max.
func _find_spell_targets_in_range(pos:Vector3, radius:float, ignore_self:bool = false) -> Dictionary:
	var space_state = _caster.get_world_3d().direct_space_state # get space state
	# create query
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = SphereShape3D.new()
	# create query position
	var t = Transform3D()
	t.origin = pos
	t.scaled(Vector3(radius, radius, radius)) # scale to match radius
	query.transform = t
	# make query
	await _caster.get_tree().physics_frame
	var res = space_state.intersect_shape(query)
	# if ignoring self, filter out all nodes part of this tree
	if ignore_self:
		res = res.filter(func(x:Dictionary):
			return not (x["collider"] as Node).is_ancestor_of(_caster) and not (x["collider"] as Node).find_child(_caster.name)
		)
	# return results, where all colliders are selected from it.
	return res


## Apply a spell effect to an object.
## Only works if target is of type [SpellTargetComponent] or [SpellTargetObject].
func _apply_spell_effect_to(target, effect:SpellEffect):
	# return early if invalid object
	if not target is SpellTargetComponent or not target is SpellTargetObject:
		return
	target.add_effect(effect)


## Casts a ray, and returns anything it hits, with the results in a dictionary matching a physics query (like raycasting). The dictionary is empty if it hits nothing.
## Using ignore_self assumes that the caster's origin defines the root of the actor casting it.
func _raycast(from:Vector3, direction:Vector3, distance:float, ignore_self:bool = false) -> Dictionary:
	var to = from + (direction * distance)
	var ray = PhysicsRayQueryParameters3D.create(from, to)
	var space_state = _caster.get_world_3d().direct_space_state # get space state
	await _caster.get_tree().physics_frame
	var res = space_state.intersect_ray(ray)
	if ignore_self:
		return res.filter(func(x:Dictionary):
			return not (x["collider"] as Node).is_ancestor_of(_caster) and not (x["collider"] as Node).find_child(_caster.name)
		)
	return res
