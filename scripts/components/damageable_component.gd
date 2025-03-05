class_name DamageableComponent
extends SKEntityComponent
## Component that allows an entity to receive and process damage events.

signal damaged(info : DamageInfo)  ## Emitted when the entity receives damage, containing damage type and amount


## Processes incoming damage and emits the damaged signal
## [param info] The DamageInfo object containing damage type, amount, and other relevant data
func damage(info : DamageInfo):
	damaged.emit(info)


func _init() -> void:
	name = &"DamageableComponent"
