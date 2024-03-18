class_name StatusEffectHost
extends Node


var effects:Dictionary = {}
var tag_map:Dictionary = {}

signal message_broadcast(what:StringName, args:Array)


func _process(delta: float) -> void:
	for e:StatusEffect in effects.values():
		e.on_update(delta, self)


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


func remove_effect(e:StringName) -> void:
	var to_remove:StatusEffect = effects[e]
	to_remove.on_end_effect(self)
	for t:StringName in to_remove.tags:
		tag_map[t].erase(to_remove)
	effects.erase(e)


func send_message(what:StringName, args:Array) -> void:
	message_broadcast.emit(what, args)
