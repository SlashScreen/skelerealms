class_name InventoryMenu
extends Control
## The inventory menu.


## Reference to the player's inventory.
var pinventory:InventoryComponent
## Maps the index of items in the item map to their ref IDs.
var inv_map = {}


func _ready() -> void:
	pinventory = SkeleRealmsGlobal.entity_manager\
		.get_entity("Player")\
		.unwrap()\
		.get_component("InventoryComponent")\
		.unwrap()
	GameInfo.pause.connect(_refresh_inventory.bind())
	pinventory.inventory_changed.connect(func(): # we refresh the inventory if it's changed, but only if it's paused
		# TODO: make it only add or remove the item we care about
		if GameInfo.paused:
			_refresh_inventory()
	)
	$VBoxContainer/drop_button.pressed.connect(func():
		_drop_item(inv_map[$ItemList.get_selected_items()[0]])
	)
	$ItemList.item_selected.connect(func(x):
		var ic = SkeleRealmsGlobal.entity_manager.get_entity(inv_map[$ItemList.get_selected_items()[0]]).unwrap().get_component("ItemComponent").unwrap() as ItemComponent # unsafe but we are assuming that if it is in the inventory it is an item because it can't be added otherwise
		$VBoxContainer/drop_button.disabled = ic.quest_item # check to not drop quest items
	)


## Clear the inventory list and re-fill it with items.
func _refresh_inventory() -> void:
	$VBoxContainer/drop_button.disabled = true
	$ItemList.clear()
	inv_map.clear()
	var i:int = 0
	for item in pinventory.inventory:
		$ItemList.add_item(item, load("res://icon.svg"))
		inv_map[i] = item
		i += 1


func _drop_item(id:String) -> bool:
	(SkeleRealmsGlobal.entity_manager.get_entity(id).unwrap().get_component("ItemComponent").unwrap() as ItemComponent).move_to_inventory("")
	return true
