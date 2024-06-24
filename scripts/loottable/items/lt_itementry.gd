class_name SKLTItemEntry
extends SKLootTableItem


@export var item:PackedScene


func resolve() -> SKLootTable.LootTableResult:
	return SKLootTable.LootTableResult.new([item], {})
