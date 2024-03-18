class_name DamageableObject
extends SKWorldObject
## For objects in the world that can be damaged but don't have to be tracked, like training dummies


signal damaged(info:DamageInfo)


func receive_message(msg:StringName, args:Array = []) -> void:
	if msg == &"damage":
		damage(args[0])


func damage(info:DamageInfo):
	damaged.emit(info)


func _init() -> void:
	name = "DamageableObject"
