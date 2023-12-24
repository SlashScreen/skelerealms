class_name SKLTAlwaysHave
extends SKLootTableItem


@export var items:Array[SKLootTableItem] = []


func resolve() -> SKLootTable.LootTableResult:
	var o:SKLootTable.LootTableResult = SKLootTable.LootTableResult.new()
	for i:SKLootTableItem in items:
		o.concat(i.resolve())
	return o
