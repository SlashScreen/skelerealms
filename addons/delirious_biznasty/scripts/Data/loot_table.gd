class_name LootTable
extends Resource
## Loot table for anything that requires a random inventory.
# TODO: Level scaling
# TODO: More granular control, minecraft-style

const uuid = preload("res://addons/delirious_biznasty/scripts/vendor/uuid.gd")


# TODO: Widget
@export var snails_min:int
@export var snails_max:int
@export var entries:Array[LootTableEntry]


## Create new [ItemInstance]s from the table.
func resolve_table_to_instances() -> Array[ItemInstance]:
	# Get all entries that pass the random generation
	var successes = entries.filter(func(e:LootTableEntry): return e.determine_success())
	return successes.map(func(x:LootTableEntry):
		var i_instance:ItemInstance = ItemInstance.new()
		i_instance.ref_id = uuid.v4()
		i_instance.item_data = x.item
		return i_instance
	)


## Generate the amount of snails.
func resolve_snails() -> int:
	return clamp(randi_range(snails_min, snails_max), 0, INF)
