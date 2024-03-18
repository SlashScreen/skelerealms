class_name EffectsObject
extends SKWorldObject


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
