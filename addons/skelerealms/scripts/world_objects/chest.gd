class_name Chest
extends InteractiveObject
## A chest's represenmtation in the world.


@export var data:ChestInstance


signal opened_inventory


func _ready():
	SkeleRealmsGlobal.entity_manager.get_entity(data.ref_id) # bring the chest instance into the world
	on_interact.connect(try_open_inventory.bind())


# TODO: Allow for lockpicking
func try_open_inventory():
	opened_inventory.emit()
