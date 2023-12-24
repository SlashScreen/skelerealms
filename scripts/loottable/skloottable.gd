class_name SKLootTable
extends Resource


@export var items:Array[SKLootTableItem] = []


## Generate all members of the loot table. Returns a dictionary shaped like {&"items":Array[ItemData], &"currencies":{name:amount,...}}
func resolve() -> Dictionary:
	var output:LootTableResult = LootTableResult.new()
	for i:SKLootTableItem in items:
		output.concat(i.resolve())
	return output.to_dict()


class LootTableResult:
	extends Object
	
	
	var items: Array[ItemData] = []
	var currencies: Dictionary = {}
	
	
	func _init(i:Array[ItemData] = [], c:Dictionary = {}) -> void:
		items = i
		currencies = c
	
	
	func concat(other:LootTableResult) -> void:
		items.append_array(other.items)
		for c:StringName in other.currencies:
			if currencies.has(c):
				currencies[c] += other.currencies[c]
			else:
				currencies[c] = other.currencies[c]
	
	
	func to_dict() -> Dictionary:
		return {
			&"items": items,
			&"currencies": currencies
		}
