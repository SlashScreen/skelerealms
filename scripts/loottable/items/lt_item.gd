class_name SKLTItem
extends SKLootTableItem


@export var data:ItemData


func resolve() -> SKLootTable.LootTableResult:
	return SKLootTable.LootTableResult.new([data], {})
