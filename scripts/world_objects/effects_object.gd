class_name EffectsObject
extends Node


var host:StatusEffectHost


func _ready() -> void:
	host = StatusEffectHost.new()
	add_child(host)
	#host.message_broadcast.connect(parent_entity.broadcast_message.bind())


func add_effect(what:StringName) -> void:
	host.add_effect(what)


func remove_effect(e:StringName) -> void:
	host.remove_effect(e)
