class_name SKLTItemChance
extends SKLootTableItem


@export var item:ItemData
@export_range(0.0, 1.0) var chance:float = 1.0


func resolve() -> Array[ItemData]:
	if randf() > chance:
		return [item]
	else:
		return []
