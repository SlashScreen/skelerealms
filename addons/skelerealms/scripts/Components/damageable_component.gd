class_name DamageableComponent
extends EntityComponent
## Allows an entity to be damaged.


signal damaged(info:DamageInfo)


func damage(info:DamageInfo):
	print("Damage component connected to:")
	for c in damaged.get_connections():
		print(c)
	damaged.emit(info)
	print("taking damage")


func _init() -> void:
	name = "DamageableComponent"


func _ready() -> void:
	await parent_entity.instantiated
	damage(DamageInfo.new("", {&"blunt":10}))
