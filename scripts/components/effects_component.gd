class_name EffectsComponent
extends SKEntityComponent
## Component that manages status effects applied to an entity.
## Uses StatusEffectHost to handle effect application and message broadcasting.

var host:StatusEffectHost  ## Host object that manages active status effects


func _init() -> void:
	name = &"EffectsComponent"


## Sets up the StatusEffectHost and connects message broadcasting
func _ready() -> void:
	host = StatusEffectHost.new()
	add_child(host)
	host.message_broadcast.connect(parent_entity.broadcast_message.bind())


## Applies a new status effect to the entity
## [param what] The identifier of the effect to apply
func add_effect(what:StringName) -> void:
	host.add_effect(what)


## Removes a status effect from the entity
## [param e] The identifier of the effect to remove
func remove_effect(e:StringName) -> void:
	host.remove_effect(e)
