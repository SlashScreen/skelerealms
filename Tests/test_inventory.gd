extends GutTest


#const test_item_1:ItemInstance = preload("res://tests/TestAssets/test_item_instance_1.tres")
#const test_item_2:ItemInstance = preload("res://tests/TestAssets/test_item_instance_2.tres")

var em:EntityManager
var e1:Entity
var e2:Entity
var inventory1:InventoryComponent
var inventory2:InventoryComponent
var equips:EquipmentComponent
var item1:Entity
var item2:Entity


func before_each() -> void:
	em = autofree(EntityManager.new())
	# set up an item
	item1 = em.add_entity(ResourceLoader.load("res://tests/TestAssets/test_item_instance_1.tres"))
	item2 = em.add_entity(ResourceLoader.load("res://tests/TestAssets/test_item_instance_2.tres"))
	# set up 2 test inventories and equips
	e1 = Entity.new()
	e1.name = &"inventory1"
	inventory1 = InventoryComponent.new()
	e1.add_component(inventory1)
	em._add_entity_raw(e1)
	
	e2 = Entity.new()
	e2.name = &"inventory2"
	inventory2 = InventoryComponent.new()
	e2.add_component(inventory2)
	equips = EquipmentComponent.new()
	e2.add_component(equips)
	em._add_entity_raw(e2)
	
	add_child(em)


func test_add() -> void:
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).move_to_inventory("inventory1")
	assert_true(inventory1.has_item("test_item_1"))


func test_remove() -> void:
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).move_to_inventory("inventory1")
	assert_true(inventory1.has_item("test_item_1"))
	inventory1.remove_from_inventory("test_item_1")
	assert_false(inventory1.has_item("test_item_1"))


func test_transfer() -> void:
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).move_to_inventory("inventory1")
	assert_true(inventory1.has_item("test_item_1"))
	assert_false(inventory2.has_item("test_item_1"))
	# move item
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).move_to_inventory("inventory2")
	assert_true(inventory2.has_item("test_item_1"))
	assert_false(inventory1.has_item("test_item_1"))


func test_equip() -> void:
	var attempt:bool = false
	attempt = equips.equip(&"test_item_2", EquipmentSlots.Slots.NECK)
	assert_false(attempt)
	attempt = equips.equip(&"test_item_2", EquipmentSlots.Slots.HEAD)
	assert_true(attempt)


func test_drop() -> void:
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).move_to_inventory("inventory1")
	assert_true(inventory1.has_item("test_item_1"))
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).drop()
	assert_false(inventory1.has_item("test_item_1"))
