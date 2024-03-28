class_name EffectsComponent
extends EntityComponent


## This component governs active effects on this entity. 


var host:StatusEffectHost


func _init() -> void:
	name = "EffectsComponent"


func _ready() -> void:
	host = StatusEffectHost.new()
	add_child(host)
	host.message_broadcast.connect(parent_entity.broadcast_message.bind())


## Pass-through for [method StatusEffectHost.add_effect].
func add_effect(what:StringName) -> void:
	host.add_effect(what)


func remove_effect(e:StringName) -> void:
	host.remove_effect(e)
