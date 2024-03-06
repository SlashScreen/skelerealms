@tool
extends PanelContainer


@onready var fd:FileDialog = $FileDialog
@onready var class_list:OptionButton = $HBoxContainer/VBoxContainer2/HBoxContainer/ComponentsList
@onready var tag_line:LineEdit = $HBoxContainer/VBoxContainer/VBoxContainer/LineEdit
var editing:ItemData


func _ready() -> void:
	fd.files_selected.connect(func(files:PackedStringArray) -> void: 
		for f:String in files:
			var n:ItemDataComponent = load(f)
			if not n:
				return
			_add_component_to_list(n)
			editing.components.append(n)
		)
	class_list.clear()
	var inherited:Array = SKToolPlugin.find_classes_that_inherit(&"ItemDataComponent")
	for d:Dictionary in inherited:
		class_list.add_item(d.class)
		class_list.set_item_metadata(class_list.item_count - 1, d.path)


func edit(e:ItemData) -> void:
	editing = e
	$HBoxContainer/VBoxContainer/HBoxContainer3/Stack.pressed = e.stackable
	$HBoxContainer/VBoxContainer/HBoxContainer2/Worth.value = e.worth as float
	$HBoxContainer/VBoxContainer/HBoxContainer/Weight.value = e.weight as float
	$HBoxContainer/VBoxContainer3/Prefab.set_to_scene(e.prefab.resource_path)
	$HBoxContainer/VBoxContainer3/HeldItem.set_to_scene(e.hand_item.resource_path)
	$HBoxContainer/VBoxContainer/BaseID.text = e.id
	for t:StringName in e.tags:
		_add_tag_to_list(t)
	for c:ItemDataComponent in e.components:
		_add_component_to_list(c)


func _on_held_item_prefab_set(path: String) -> void:
	if path.is_empty():
		editing.hand_item = null
	else:
		editing.hand_item = load(path)


func _on_prefab_prefab_set(path: String) -> void:
	if path.is_empty():
		editing.prefab = null
	else:
		editing.prefab = load(path)


func _on_open_component_pressed() -> void:
	fd.popup_centered()


func _on_add_component_pressed() -> void:
	var path:String = class_list.get_item_metadata(class_list.selected)
	var n:ItemDataComponent = load(path).new()
	_add_component_to_list(n)
	editing.components.append(n)


func _add_component_to_list(ic:ItemDataComponent) -> void:
	var container:HBoxContainer = HBoxContainer.new()
	var l:Label = Label.new()
	l.text = ic.get_type() # may nt work
	var rb:Button = Button.new()
	rb.text = "Remove"
	rb.pressed.connect(func() -> void:
		container.queue_free()
		editing.components.erase(ic)
		)
	var ib:Button = Button.new()
	ib.text = "Open in Inspector"
	ib.pressed.connect(func() -> void:
		EditorInterface.edit_resource(ic)
		)
	
	container.add_child(l)
	container.add_child(rb)
	container.add_child(ib)


func _on_add_tag_pressed() -> void:
	var tag:StringName = StringName(tag_line.text)
	tag_line.clear()
	if not editing.tags.has(tag):
		_add_tag_to_list(tag)
		editing.tags.append(tag)


func _add_tag_to_list(tag:StringName) -> void:
	var container:HBoxContainer = HBoxContainer.new() 
	var l:Label = Label.new() 
	l.text = String(tag)
	var rb:Button = Button.new()
	rb.text = "Remove"
	rb.pressed.connect(func() -> void:
		container.queue_free()
		editing.tags.erase(tag)
		)


func _on_base_id_text_submitted(new_text: String) -> void:
	editing.id = new_text


func _on_weight_value_changed(value: float) -> void:
	editing.weight = roundi(value)


func _on_worth_value_changed(value: float) -> void:
	editing.worth = roundi(value)


func _on_stack_toggled(toggled_on: bool) -> void:
	editing.stackable = toggled_on
