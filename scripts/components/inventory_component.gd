class_name InventoryComponent
extends SKEntityComponent
## Component that manages an entity's inventory and currency system.
## Supports automatic loot generation through SKLootTable child nodes.

@export var inventory: PackedStringArray  ## Array of RefIDs for items in the inventory
var currencies: Dictionary[StringName, int] = {}  ## Dictionary mapping currency types to their amounts

signal added_to_inventory(id:String)  ## Emitted when an item is added to inventory
signal removed_from_inventory(id:String)  ## Emitted when an item is removed from inventory
signal inventory_changed  ## Emitted whenever the inventory contents change
signal added_money(amount:int)  ## Emitted when currency is added
signal removed_money(amount:int)  ## Emitted when currency is removed


func _ready() -> void:
	added_to_inventory.connect(func(x): inventory_changed.emit())
	removed_from_inventory.connect(func(x): inventory_changed.emit())


## Adds an item to the inventory if it has a valid ItemComponent
## [param id] The RefID of the item to add
func add_to_inventory(id:String):
	var e = SKEntityManager.instance.get_entity(id)
	if e:
		var ic = e.get_component(&"ItemComponent")
		if ic:
			inventory.append(id)
			added_to_inventory.emit(id)


## Removes an item from the inventory if it exists
## [param id] The RefID of the item to remove
func remove_from_inventory(id:String):
	var index = inventory.find(id)
	if index == -1: # catch if it doesnt have the item
		return
	inventory.remove_at(index)
	removed_from_inventory.emit(id)


## Adds currency to the inventory
## [param amount] Amount of currency to add
## [param currency] Type of currency to add
func add_money(amount:int, currency:StringName):
	added_money.emit(amount)
	if currencies.has(currency):
		currencies[currency] += amount
	else:
		currencies[currency] = amount
	_clamp_money(currency)


## Removes currency from the inventory
## [param amount] Amount of currency to remove
## [param currency] Type of currency to remove
func remove_money(amount:int, currency:StringName):
	removed_money.emit(amount)
	if not currencies.has(currency):
		currencies[currency] = 0
		return
	currencies[currency] -= amount
	_clamp_money(currency)


## Ensures currency amount never goes below zero
## [param currency] Type of currency to clamp
func _clamp_money(currency:StringName):
	if currencies[currency] < 0:
		currencies[currency] = 0


## Counts how many items of a specific data type are in the inventory
## [param data_id] The data ID to count
## [returns] Number of matching items found
func count_item_by_data(data_id:String) -> int:
	var amount: int = 0
	for i in inventory:
		var ic:ItemComponent = SKEntityManager.instance.get_entity(i).get_component(&"ItemComponent")
		if ic.data.id == data_id:
			amount += 1
	return amount


## Checks if a specific item exists in the inventory
## [param ref_id] The RefID to check for
## [returns] Whether the item exists in inventory
func has_item(ref_id:String) -> bool:
	return inventory.has(ref_id)


## Returns items that satisfy a given condition
## [param fn] Callable that takes a RefID and returns bool
## [returns] Array of matching item RefIDs
func get_items_that(fn: Callable) -> Array[StringName]:
	var pt: Array[StringName] = []
	for i in inventory:
		if fn.call(i):
			pt.append(i)
	return pt


## Returns all items of a specific form ID
## [param id] The form ID to match
## [returns] Array of matching item RefIDs
func get_items_of_form(id:String) -> Array[StringName]:
	return get_items_that(func(x:StringName): return ItemComponent.get_item_component(x).parent_entity.form_id == id)


## Generates initial inventory contents from attached SKLootTable
func on_generate() -> void:
	if get_child_count() == 0:
		return
	var lt:SKLootTable = get_child(0) as SKLootTable
	if not lt:
		return
	
	var res: Dictionary = lt.resolve()
	
	for id:PackedScene in res.items:
		var e:SKEntity = SKEntityManager.instance.add_entity(id)
		add_to_inventory(e.name)
	for id:StringName in res.entities:
		add_to_inventory(id)
	currencies = res.currencies


## Generates a debug string showing inventory contents and currencies
## [returns] Formatted string with inventory debug information
func gather_debug_info() -> String:
	return """
[b]InventoryComponent[/b]
	Currency: %s
	Inventory: %s
	""" % [
		JSON.stringify(currencies, "\t"),
		JSON.stringify(inventory, "\t"),
	]
