extends PanelContainer



var editing: ItemInstance


func edit(e:ItemInstance) -> void:
	editing = e
	$VBoxContainer/HBoxContainer.edit(e)
	$VBoxContainer/ItemDataInspector.edit(e.item_data)
