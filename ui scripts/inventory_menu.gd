class_name InventoryMenu
extends Control
## The inventory menu.


var pinventory:InventoryComponent


func _ready() -> void:
	pinventory = SkeleRealmsGlobal.entity_manager\
		.get_entity("Player")\
		.unwrap()\
		.get_component("InventoryComponent")\
		.unwrap()
	$"..".tab_changed.connect(_on_tab_changed.bind())
	GameInfo.pause.connect(_refresh_inventory.bind())


func _on_tab_changed(what:int) -> void:
	if what == 2: # TODO: Not hardcoded
		_refresh_inventory()


## Clear the inventory list and re-fill it with items.
func _refresh_inventory() -> void:
	$ItemList.clear()
	for item in pinventory.inventory:
		$ItemList.add_item(item, load("res://icon.svg"))
