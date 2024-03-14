@tool
extends PanelContainer


var editing:SKLTXOfItem
var inspector:Control


func edit(e:SKLTXOfItem, i:Control) -> void:
	editing = e
	inspector = i
	$VBoxContainer/HBoxContainer/Min.value = e.x_min
	$VBoxContainer/HBoxContainer2/Max.value = e.x_max
	inspector.table_updated.connect(func(o:Object, tbl:Array[SKLootTableItem]) -> void: 
		if o == self:
			editing.items.items = tbl
		)


func _on_min_value_changed(value: float) -> void:
	editing.x_min = roundi(value)


func _on_max_value_changed(value: float) -> void:
	editing.x_max = roundi(value)


func _on_inspect_table_pressed() -> void:
	inspector.inspect(self, editing.items)
