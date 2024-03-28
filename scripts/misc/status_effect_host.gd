class_name StatusEffectHost
extends Node


## This class holds and processes [class StatusEffect]s - Updating them, resolivng tag comflicts, so on. It can work by itself, but it's intended to be the child
## of some kind of "vessel", which can handle [signal message_broadcast] to carry out the will of status effects. That sounds philosophical, but it isn't (unless you want it to be).


## The effects applied to this host. Shape is {StringName:[class StatusEffect]}.
var effects:Dictionary = {}
## The effects are also organized by tag, for optimization purposes. The shape is {StringName:Array\[[class StatusEffect]\]}.
var tag_map:Dictionary = {}
## This signal is listened to by a host's vessel (by default, [class EffectsComponent] and [class EffectsObject]), which will relay the message to other nodes.
## THis is called from the effects if they want to make changes to the object they are attached to.
signal message_broadcast(what:StringName, args:Array)


func _process(delta: float) -> void:
	for e:StatusEffect in effects.values():
		e.on_update(delta, self)


## Add an effect to this host. It will scan the registered effects (See [member SkeleRealmsGlobal.status_effects]) and add the registered effect.
## It will also resolve all tag conflicts as well. If it cannot add the effect due to a tag conflict, or if it already has that effect, it will silently fail. If no effect is found in the database,
## it will push an error.
func add_effect(what:StringName) -> void:
	# check if has already
	if effects.has(what):
		return
	
	if SkeleRealmsGlobal.status_effects.has(what):
		var ne:StatusEffect = (SkeleRealmsGlobal.status_effects[what] as StatusEffect).duplicate()
		# Check incompatibilities
		for x:StringName in ne.incompatible:
			if effects.has(x):
				return
		for x:StringName in ne.incompatible_tags:
			if tag_map.has(x) and not tag_map[x].is_empty():
				return
		# Check negates
		for x:StringName in ne.negates:
			if effects.has(x):
				remove_effect(x)
		for x:StringName in ne.negates_tags:
			var to_remove:Array = tag_map[x].map(func(e:StatusEffect) -> StringName: return e.name)
			for i:StringName in to_remove:
				remove_effect(i)
		# Add effect
		effects[what] = ne
		ne.on_start_effect(self)
	else:
		push_error("No status effect \"%s\" registered." % what)


## Remove an effect by its name. If there is no effect by this name, it will silently fail.
func remove_effect(e:StringName) -> void:
	if not effects.has(e):
		return
	var to_remove:StatusEffect = effects[e]
	to_remove.on_end_effect(self)
	for t:StringName in to_remove.tags:
		tag_map[t].erase(to_remove)
	effects.erase(e)


## Used by status effects to broadcast messages to a hosts' node tree.
## For example, broadcasting "damage" from a host attached to an entity could cause it to be damaged,
## if it has a [class DamageableComponent].
func send_message(what:StringName, args:Array) -> void:
	message_broadcast.emit(what, args)


func has_effect_with_tag(tag:StringName) -> bool: 
	if not effects.has(tag):
		return false 
	if effects[tag].is_empty():
		return false
	return true


func has_effect(effect:StringName) -> bool:
	return effects.has(effect)
