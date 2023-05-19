extends GutTest


var barter_node:BarterSystem
var e_vendor:Entity
var e_customer:Entity
var ic_vendor:InventoryComponent
var ic_customer:InventoryComponent
var item:Entity


func before_each() -> void:
	# TODO:
	# Set up items
	# Set up vendor
	# Set up customer
	return


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
	pending()
