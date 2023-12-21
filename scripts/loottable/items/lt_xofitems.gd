class_name SKLTXOfItem
extends SKLootTableItem


@export_range(0, 100, 1, "or_greater") var x:int = 1
@export var items: Array[SKLootTableItem] = []


func resolve() -> Array[ItemData]:
	if items.size() == 0 or x == 0:
		return []
	
	var output:Array[ItemData] = []
	var i:int = 0
	while output.size() < x:
		output.append_array(items[i].resolve())
		i += 1
		if i >= items.size():
			i = 0
	return output.slice(0, x)
