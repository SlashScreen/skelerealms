class_name InventoryComponent
extends EntityComponent
## Keeps track of an inventory.

## The RefIDs of the items in the inventory.
var inventory: PackedStringArray
## The amount of cash moneys.
var currencies = {}

signal added_to_inventory(id:String)
signal removed_from_inventory(id:String)
signal inventory_changed
signal added_money(amount:int)
signal removed_money(amount:int)


func _init(pre_inventory:Array[ItemInstance] = []) -> void:
	name = "InventoryComponent"
	# fill out inventory 
	for i in pre_inventory:
		add_to_inventory.bind(i.ref_id).call_deferred() # TODO: Make item inventory contained?


func _ready() -> void:
	added_to_inventory.connect(func(x): inventory_changed.emit())
	removed_from_inventory.connect(func(x): inventory_changed.emit())


## Add an item to the inventory.
func add_to_inventory(id:String):
	var e = EntityManager.instance.get_entity(id)
	if e:
		var ic = e.get_component("ItemComponent")
		if ic:
			inventory.append(id)
			added_to_inventory.emit(id)


## Remove an item from the inventory.
func remove_from_inventory(id:String):
	var index = inventory.find(id)
	if index == -1: # catch if it doesnt have the item
		return
	inventory.remove_at(index)
	removed_from_inventory.emit(id)


## Add an amount of snails to the inventory.
func add_money(amount:int, currency:StringName):
	added_money.emit(amount)
	if currencies.has(currency):
		currencies[currency] += amount
	else:
		currencies[currency] = amount
	_clamp_money(currency)


## Remove some snails from the inventory.
func remove_money(amount:int, currency:StringName):
	removed_money.emit(amount)
	if not currencies.has(currency):
		currencies[currency] = 0
		return
	currencies[currency] -= amount
	_clamp_money(currency)


## Keeps the number of snails from going below 0.
func _clamp_money(currency:StringName):
	if currencies[currency] < 0:
		currencies[currency] = 0


func count_item_by_data(data_id:String) -> int:
	var amount: int = 0
	for i in inventory:
		var ic:ItemComponent = EntityManager.instance.get_entity(i).get_component("ItemComponent")
		if ic.data.id == data_id:
			amount += 1
	return amount


func has_item(ref_id:String) -> bool:
	return inventory.has(ref_id)


func get_items_that(fn: Callable) -> Array[StringName]:
	var pt: Array[StringName] = []
	for i in inventory:
		if fn.call(i):
			pt.append(i)
	return pt


func get_items_of_base(id:String) -> Array[StringName]:
	return get_items_that(func(x:StringName): return ItemComponent.get_item_component(x).data.id == id)


func gather_debug_info() -> String:
	return """
[b]InventoryComponent[/b]
	Currency: %s
	Inventory: %s
	""" % [
		JSON.stringify(currencies, "\t"),
		JSON.stringify(inventory, "\t"),
	]
