extends GutTest


var em:EntityManager
var barter_node:BarterSystem
var e_vendor:Entity
var e_customer:Entity
var ic_vendor:InventoryComponent
var ic_customer:InventoryComponent
var item:Entity

# TODO: Try to figure out how to dupe. maybe loading the game in the middle of a transaction?

func before_each() -> void:
	em = autofree(EntityManager.new())
	# set up an item
	item = em.add_entity(load("res://Tests/TestAssets/test_item_instance_1.tres"))
	# set up 2 test inventories
	e_vendor = Entity.new()
	e_vendor.name = &"vendor"
	ic_vendor = InventoryComponent.new()
	e_vendor.add_component(ic_vendor)
	ic_vendor.snails = 100
	em._add_entity_raw(e_vendor)
	
	e_customer = Entity.new()
	e_customer.name = &"customer"
	ic_customer = InventoryComponent.new()
	e_customer.add_component(ic_customer)
	ic_customer.snails = 100
	em._add_entity_raw(e_customer)
	
	add_child(em)
	
	barter_node = autofree(BarterSystem.new())
	add_child(barter_node)


func test_sell() -> void:
	item.get_component("ItemComponent").unwrap().move_to_inventory(&"customer")
	barter_node.start_barter(ic_vendor, ic_customer)
	barter_node.sell_item(&"test_item_1")
	barter_node.accept_barter(1, 1)
	assert_true(ic_vendor.has_item(&"test_item_1"))
	assert_eq(ic_vendor.snails, 80)


func test_buy() -> void:
	item.get_component("ItemComponent").unwrap().move_to_inventory(&"vendor")
	barter_node.start_barter(ic_vendor, ic_customer)
	barter_node.buy_item(&"test_item_1")
	barter_node.accept_barter(1, 1)
	assert_true(ic_customer.has_item(&"test_item_1"))
	assert_eq(ic_customer.snails, 80)


func test_sell_modifier() -> void:
	item.get_component("ItemComponent").unwrap().move_to_inventory(&"customer")
	barter_node.start_barter(ic_vendor, ic_customer)
	barter_node.sell_item(&"test_item_1")
	barter_node.accept_barter(0.5, 1)
	assert_true(ic_vendor.has_item(&"test_item_1"))
	assert_eq(ic_vendor.snails, 90) # well. maybe not 90


func test_buy_modifier() -> void:
	item.get_component("ItemComponent").unwrap().move_to_inventory(&"vendor")
	barter_node.start_barter(ic_vendor, ic_customer)
	barter_node.buy_item(&"test_item_1")
	barter_node.accept_barter(1, 0.5)
	assert_true(ic_customer.has_item(&"test_item_1"))
	assert_eq(ic_customer.snails, 90)
