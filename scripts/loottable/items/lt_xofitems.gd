class_name SKLTXOfItem
extends SKLootTableItem


@export_range(0, 100, 1, "or_greater") var x_min:int = 1
@export_range(0, 100, 1, "or_greater") var x_max:int = 0
var items: SKLootTable


func _ready() -> void:
	items = get_child(0)


func resolve() -> SKLootTable.LootTableResult:
	var x = randi_range(x_min, x_min if x_max <= x_min else x_max)
	if items.size() == 0 or x == 0:
		return SKLootTable.LootTableResult.new()
	
	var output:SKLootTable.LootTableResult = SKLootTable.LootTableResult.new()
	var i:int = 0
	while output.size() < x:
		output.concat(items.items[i].resolve())
		i += 1
		if i >= items.size():
			i = 0
	output.items = output.items.slice(0, x)
	return output
