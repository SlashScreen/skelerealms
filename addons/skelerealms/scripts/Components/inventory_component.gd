class_name InventoryComponent 
extends EntityComponent
## Keeps track of an inventory.

## The RefIDs of the items in the inventory.
var inventory: PackedStringArray
## The amount of cash moneys.
var snails: int

signal added_to_inventory(id:String)
signal removed_from_inventory(id:String)
signal inventory_changed
signal added_snails(amount:int)
signal removed_snails(amount:int)


func _init() -> void:
	name = "InventoryComponent"


func _ready() -> void:
	added_to_inventory.connect(func(x): inventory_changed.emit())
	removed_from_inventory.connect(func(x): inventory_changed.emit())


## Add an item to the inventory.
func add_to_inventory(id:String):
	var e = SkeleRealmsGlobal.entity_manager.get_entity(id)
	if e.some():
		var ic = (e.unwrap() as Entity).get_component("ItemComponent")
		if ic.some():
			inventory.append(id)
			added_to_inventory.emit(id)


## Remove an item from the inventory.
func remove_from_inventory(id:String):
	print(inventory)
	var index = inventory.find(id)
	if index == -1: # catch if it doesnt have the item
		return
	inventory.remove_at(index)
	removed_from_inventory.emit(id)


## Add an amount of snails to the inventory.
func add_snails(amount:int):
	added_snails.emit(amount)
	snails += amount
	_clamp_snails()


## Remove some snails from the inventory.
func remove_snails(amount:int):
	removed_snails.emit(amount)
	snails -= amount
	_clamp_snails()

## Keeps the number of snails from going below 0.
func _clamp_snails():
	if snails < 0:
		snails = 0


func has_item(ref_id:String) -> bool:
	return inventory.has(ref_id)
