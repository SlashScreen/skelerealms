class_name DamageableComponent
extends SKEntityComponent
## Allows an entity to be damaged.


signal damaged(info:DamageInfo)


func damage(info:DamageInfo):
	damaged.emit(info)


func _init() -> void:
	name = "DamageableComponent"
