class_name SKLTAlwaysHave
extends SKLootTableItem


@export var items:Array[SKLootTableItem] = []


func resolve() -> Array[ItemData]:
	var o:Array[ItemData] = []
	for i:SKLootTableItem in items:
		o.append_array(i.resolve())
	return o
