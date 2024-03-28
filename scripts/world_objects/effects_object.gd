class_name EffectsObject
extends SKWorldObject


## This is a vessel for [class StatusEffectHost], intended to give statuseffects to non-entity objects.
## For example, you could add this and a [class DamageableObject] to a wooden box, and if the box is set
## on fire, it will turn to ash.


var host:StatusEffectHost


func _ready() -> void:
	host = StatusEffectHost.new()
	add_child(host)
	host.message_broadcast.connect(broadcast_message.bind())


func add_effect(what:StringName) -> void:
	host.add_effect(what)


func remove_effect(e:StringName) -> void:
	host.remove_effect(e)


func receive_message(msg:StringName, args:Array = []) -> void:
	match msg:
		&"add_effect":
			add_effect(args[0])
		&"remove_effect":
			remove_effect(args[0])
