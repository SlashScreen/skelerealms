class_name DamageableObject
extends Node3D
## For objects in the world that can be damaged but don't have to be tracked, like training dummies



signal damaged(info:DamageInfo)


func damage(info:DamageInfo):
	damaged.emit(info)


func _init() -> void:
	name = "DamageableObject"
