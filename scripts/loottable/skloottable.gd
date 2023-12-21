class_name SKLootTable
extends Resource


@export var items:Array[SKLootTableItem] = []
@export var currencies:Array[SKLootTableCurrency] = []


## Get generated items from the loot table.
func resolve_items() -> Array[ItemData]:
	var output: Array[ItemData] = []
	for i:SKLootTableItem in items:
		output.append_array(i.resolve())
	return output


## Get currencies from loot table currency entires
func resolve_currencies() -> Dictionary:
	var output = {}
	for d:SKLootTableCurrency in currencies:
		var r: Dictionary = d.resolve()
		for c:StringName in r:
			if output.has(c):
				output[c] += r[c]
			else:
				output[c] = r[c]
	return output
