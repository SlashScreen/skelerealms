class_name SKLTItem
extends SKLootTableItem


@export var data:PackedScene


func resolve() -> SKLootTable.LootTableResult:
	return SKLootTable.LootTableResult.new([data], {})
