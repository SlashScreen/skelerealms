class_name SKLTItemChance
extends SKLootTableItem


@export var item:ItemData
@export_range(0.0, 1.0) var chance:float = 1.0


func resolve() -> SKLootTable.LootTableResult:
	if randf() > chance:
		return SKLootTable.LootTableResult.new([item], {})
	else:
		return SKLootTable.LootTableResult.new()
