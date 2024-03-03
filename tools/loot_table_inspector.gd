@tool
extends PanelContainer


@onready var back_button:Button = $HBoxContainer/VBoxContainer/Controls/Back
@onready var class_list:OptionButton = $HBoxContainer/VBoxContainer/Controls/ClassSelector
@onready var item_list:ItemList = $HBoxContainer/VBoxContainer/ScrollContainer/ItemList
@onready var inspector_root:Control = %InspectionRoot
var source_stack:Array = []
var table_stack:Array = []
var working_table:Array[SKLootTableItem]:
	get:
		return table_stack.back()
var path_to_class:Dictionary = {}
@export var class_to_editor:Dictionary = {}

signal table_updated(src:Object, tbl:Array[SKLootTableItem])


func edit(lt:SKLootTableItem) -> void:
	var n:Control = class_to_editor[path_to_class[lt.get_script().resource_path]].instantiate()
	inspector_root.add_child(n)
	n.edit(lt)


func inspect(source:Object, table:Array[SKLootTableItem]) -> void:
	if not source == null:
		source_stack.push_back(source)
	_update_back_button()
	table_stack.push_back(table)
	render(working_table)


func render(table:Array[SKLootTableItem]) -> void:
	return


func _update_back_button() -> void:
	back_button.disabled = source_stack.is_empty()


func _update_class_list() -> void:
	return


func _update_source() -> void:
	table_updated.emit(source_stack.back(), table_stack.back())


func _on_back_pressed() -> void:
	source_stack.pop_back()
	table_stack.pop_back()
	render(working_table)
	_clear_inpector()


func _clear_inpector() -> void:
	while inspector_root.get_child_count() > 0:
		inspector_root.get_child(0).queue_free()


func _on_add_pressed() -> void:
	pass # Replace with function body.


func _on_load_pressed() -> void:
	pass # Replace with function body.


func _on_item_list_item_selected(index: int) -> void:
	var data:SKLootTableItem = item_list.get_item_metadata(index)
	_clear_inpector()
	edit(data)
