class_name SKLTItemEntity
extends SKLootTableItem


## The unique entity to put in the inventory.
@export var item:PackedScene


func resolve() -> SKLootTable.LootTableResult:
	var id:StringName = item._bundled.names[0]
	return SKLootTable.LootTableResult.new([], {}, [id])
