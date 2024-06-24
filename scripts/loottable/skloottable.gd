class_name SKLootTable
extends Node


## This is a loot table. It can resolve into a collection of items and currencies.


var items:Array[SKLootTableItem] = []


func _ready() -> void:
	items.resize(get_child_count())
	for c:Node in get_children():
		items.append(c)


## Generate all members of the loot table. Returns a dictionary shaped like {&"items":Array[ItemData], &"currencies":{name:amount,...}}
func resolve() -> Dictionary:
	var output:LootTableResult = LootTableResult.new()
	for i:SKLootTableItem in items:
		output.concat(i.resolve())
	return output.to_dict()


class LootTableResult:
	extends RefCounted
	
	
	var items: Array[PackedScene] = []
	var currencies: Dictionary = {}
	var entities: Array[StringName] = []
	
	
	func _init(i:Array[PackedScene] = [], c:Dictionary = {}, e:Array[StringName] = []) -> void:
		items = i
		currencies = c
		entities = e
	
	
	func concat(other:LootTableResult) -> void:
		items.append_array(other.items)
		for c:StringName in other.currencies:
			if currencies.has(c):
				currencies[c] += other.currencies[c]
			else:
				currencies[c] = other.currencies[c]
		for id:StringName in other.entities:
			if not entities.has(id):
				entities.append(id)
	
	
	func to_dict() -> Dictionary:
		return {
			&"items": items,
			&"currencies": currencies,
			&"entities": entities,
		}
