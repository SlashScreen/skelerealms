class_name Chest
extends InteractiveObject
## A chest's represenmtation in the world.


@export var instance:ChestInstance


signal opened_inventory


func _ready():
	SKEntityManager.instance.get_entity(instance.ref_id) # bring the chest instance into the world
	on_interact.connect(func(_id): try_open_inventory())


# TODO: Allow for lockpicking
func try_open_inventory():
	opened_inventory.emit()
	SkeleRealmsGlobal.inventory_opened.emit(instance.ref_id)
