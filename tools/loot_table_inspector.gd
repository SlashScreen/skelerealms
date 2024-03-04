@tool
extends PanelContainer


@onready var back_button:Button = $HBoxContainer/VBoxContainer/Controls/Back
@onready var class_list:OptionButton = $HBoxContainer/VBoxContainer/Controls/ClassSelector
@onready var item_list:ItemList = $HBoxContainer/VBoxContainer/ScrollContainer/ItemList
@onready var inspector_root:Control = %InspectionRoot
@onready var fd:FileDialog = $FileDialog
var source_stack:Array = []
var table_stack:Array = []
var working_table:Array[SKLootTableItem]:
	get:
		return table_stack.back()
var path_to_class:Dictionary = {}
@export var class_to_editor:Dictionary = {}

signal table_updated(src:Object, tbl:Array[SKLootTableItem])


func _ready() -> void:
	fd.files_selected.connect(func(fs:PackedStringArray) -> void:
		for s:String in fs:
			var r:SKLootTableItem = load(s)
			if r:
				_add_item(r)
			_update_source()
		)
	_update_class_list()


func edit(lt:SKLootTableItem) -> void:
	var n:Control = class_to_editor[path_to_class[lt.get_script().resource_path]].instantiate()
	inspector_root.add_child(n)
	n.edit(lt, self)


func inspect(source:Object, table:Array[SKLootTableItem]) -> void:
	if not source == null:
		source_stack.push_back(source)
	_update_back_button()
	table_stack.push_back(table)
	render(working_table)


func render(table:Array[SKLootTableItem]) -> void:
	item_list.clear()
	for i:SKLootTableItem in table:
		_add_item(i)


func _add_item(sk:SKLootTableItem) -> void:
	var i:int = item_list.add_item("Item")
	item_list.set_item_metadata(i, sk)


func _update_back_button() -> void:
	back_button.disabled = source_stack.is_empty()


func _update_class_list() -> void:
	class_list.clear()
	var inherited:Array = SKToolPlugin.find_classes_that_inherit(&"SKLootTableItem")
	for d:Dictionary in inherited:
		class_list.add_item(d.class)
		class_list.set_item_metadata(class_list.item_count - 1, d.path)
		path_to_class[d.path] = d.class


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
	print(class_list.selected)
	print(class_list.get_item_metadata(class_list.selected))
	_add_item(load(class_list.get_item_metadata(class_list.selected)).new())


func _on_load_pressed() -> void:
	fd.popup_centered()


func _on_item_list_item_selected(index: int) -> void:
	var data:SKLootTableItem = item_list.get_item_metadata(index)
	_clear_inpector()
	edit(data)


func _on_remove_pressed() -> void:
	if not item_list.is_anything_selected():
		return
	var i:int = item_list.get_selected_items()[0]
	var x:SKLootTableItem = item_list.get_item_metadata(i)
	item_list.remove_item(i)
	working_table.erase(x)
	_clear_inpector()
	_update_source()
