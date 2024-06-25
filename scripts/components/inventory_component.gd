class_name InventoryComponent
extends SKEntityComponent


## Keeps track of an inventory and currencies.
## If you add an [SKLootTable] node underneath, the loot table will be rolled upon generating. See [method SKEntityComponent.on_generate].


## The RefIDs of the items in the inventory. Put any unique items in here.
@export var inventory: PackedStringArray
## The amount of cash moneys.
var currencies = {}

signal added_to_inventory(id:String)
signal removed_from_inventory(id:String)
signal inventory_changed
signal added_money(amount:int)
signal removed_money(amount:int)


func _ready() -> void:
	added_to_inventory.connect(func(x): inventory_changed.emit())
	removed_from_inventory.connect(func(x): inventory_changed.emit())


## Add an item to the inventory.
func add_to_inventory(id:String):
	var e = SKEntityManager.instance.get_entity(id)
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
		var ic:ItemComponent = SKEntityManager.instance.get_entity(i).get_component("ItemComponent")
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


func get_items_of_form(id:String) -> Array[StringName]:
	return get_items_that(func(x:StringName): return ItemComponent.get_item_component(x).parent_entity.form_id == id)


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


func gather_debug_info() -> String:
	return """
[b]InventoryComponent[/b]
	Currency: %s
	Inventory: %s
	""" % [
		JSON.stringify(currencies, "\t"),
		JSON.stringify(inventory, "\t"),
	]
