extends GutTest


var em:EntityManager
var inventory1:Entity
var inventory2:Entity
var item1:Entity
var item2:Entity


func before_each() -> void:
	em = autofree(EntityManager.new())
	# set up an item
	item1 = em.add_entity(load("res://Tests/TestAssets/test_item_instance_1.tres"))
	item2 = em.add_entity(load("res://Tests/TestAssets/test_item_instance_2.tres"))
	# set up 2 test inventories and equips
	inventory1 = Entity.new()
	inventory1.name = &"inventory1"
	inventory1.add_component(InventoryComponent.new())
	em._add_entity_raw(inventory1)
	
	inventory2 = Entity.new()
	inventory2.name = &"inventory2"
	inventory2.add_component(InventoryComponent.new())
	inventory2.add_component(EquipmentComponent.new())
	em._add_entity_raw(inventory2)
	
	add_child(em)


func test_add() -> void:
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).move_to_inventory("inventory1")
	assert_true((inventory1.get_component("InventoryComponent").unwrap() as InventoryComponent).has_item("test_item_1"))


func test_remove() -> void:
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).move_to_inventory("inventory1")
	assert_true((inventory1.get_component("InventoryComponent").unwrap() as InventoryComponent).has_item("test_item_1"))
	(inventory1.get_component("InventoryComponent").unwrap() as InventoryComponent).remove_from_inventory("test_item_1")
	assert_false((inventory1.get_component("InventoryComponent").unwrap() as InventoryComponent).has_item("test_item_1"))


func test_transfer() -> void:
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).move_to_inventory("inventory1")
	assert_true((inventory1.get_component("InventoryComponent").unwrap() as InventoryComponent).has_item("test_item_1"))
	assert_false((inventory2.get_component("InventoryComponent").unwrap() as InventoryComponent).has_item("test_item_1"))
	# move item
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).move_to_inventory("inventory2")
	assert_true((inventory2.get_component("InventoryComponent").unwrap() as InventoryComponent).has_item("test_item_1"))
	assert_false((inventory1.get_component("InventoryComponent").unwrap() as InventoryComponent).has_item("test_item_1"))


func test_equip() -> void:
	var attempt:bool = false
	attempt = (inventory2.get_component("EquipmentComponent").unwrap() as EquipmentComponent).equip(&"test_item_2", EquipmentSlots.Slots.NECK)
	assert_false(attempt)
	attempt = (inventory2.get_component("EquipmentComponent").unwrap() as EquipmentComponent).equip(&"test_item_2", EquipmentSlots.Slots.HEAD)
	assert_true(attempt)


func test_drop() -> void:
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).move_to_inventory("inventory1")
	assert_true((inventory1.get_component("InventoryComponent").unwrap() as InventoryComponent).has_item("test_item_1"))
	(item1.get_component("ItemComponent").unwrap() as ItemComponent).drop()
	assert_false((inventory1.get_component("InventoryComponent").unwrap() as InventoryComponent).has_item("test_item_1"))
