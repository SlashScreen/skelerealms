class_name LootTableEntry
extends Resource


@export var item:ItemData
## Whether we want a custom ref ID for this item.
## useful for say, a quest item as loot, but the rest of the chest is randomized.
## Do not use this if the chest regeneration is active; it will cause confusion in the system.
@export var ref_id_override:String
@export var quest_item:bool
@export_range(0,1) var chance:float


func determine_success() -> bool:
	# if chance is boolean, return true or false
	if chance == 1.0:
		return true
	if chance == 0.0:
		return false
	# else dice roll
	return randf() <= chance
