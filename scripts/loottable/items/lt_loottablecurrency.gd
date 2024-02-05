class_name SKLTCurrency
extends SKLootTableItem


@export var currency:StringName = &""
@export_range(0, 100, 1, "or_greater") var amount_min:int = 0
@export_range(0, 100, 1, "or_greater") var amount_max:int = 10


func resolve() -> SKLootTable.LootTableResult:
	return SKLootTable.LootTableResult.new([], {currency: amount_min if amount_max <= amount_min else randi_range(amount_min, amount_max)})
