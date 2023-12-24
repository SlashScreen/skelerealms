class_name SKLTItemEntry
extends SKLootTableItem


@export var item:ItemData


func resolve() -> SKLootTable.LootTableResult:
	return SKLootTable.LootTableResult.new([item], {})
