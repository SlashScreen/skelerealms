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
	GameInfo.pause.connect(_refresh_inventory.bind())
	pinventory.inventory_changed.connect(func(): # we refresh the inventory if it's changed, but only if it's paused
		# TODO: make it only add or remove the item we care about
		if GameInfo.paused:
			_refresh_inventory()
	)


func _process(delta: float) -> void:
	if GameInfo.paused:
		# change button state
		$VBoxContainer/drop_button.disabled = not $ItemList.is_anything_selected()


## Clear the inventory list and re-fill it with items.
func _refresh_inventory() -> void:
	$ItemList.clear()
	for item in pinventory.inventory:
		$ItemList.add_item(item, load("res://icon.svg"))


func _drop_item(id:String) -> bool:
	pinventory.remove_from_inventory(id)
	return true
