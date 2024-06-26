extends EditorProperty


var option_button: OptionButton = OptionButton.new()
var updating:bool
var current:Array[StringName] = []
var parent_vbox := VBoxContainer.new()
var items_vbox := VBoxContainer.new()


func _init() -> void:
	add_child(parent_vbox)
	parent_vbox.add_child(items_vbox)
	
	var hbox := HBoxContainer.new()
	var b := Button.new()
	b.text = "Add item"
	b.pressed.connect(func() -> void:
		_add_item(option_button.get_item_text(option_button.get_selected_id()))
		_sync()
		)
	hbox.add_child(option_button)
	hbox.add_child(b)
	parent_vbox.add_child(hbox)
	
	add_focusable(option_button)


func _ready() -> void:
	for i:StringName in SkeleRealmsGlobal.config.equipment_slots:
		option_button.add_item(i)
		var n_i:int = option_button.item_count - 1


func _sync() -> void:
	var values:Array[StringName] = _get_values()
	if not values == get_edited_object()[get_edited_property()]:
		current = values
		emit_changed(get_edited_property(), values)
		return


func _update_property() -> void:
	var new_value:Array[StringName] = get_edited_object()[get_edited_property()]
	
	if (new_value == current):
		return
	
	updating = true 
	current = new_value
	
	for n:Node in items_vbox.get_children():
		n.queue_free()
	for i:StringName in new_value:
		_add_item(i)
	updating = false


func _add_item(kind:StringName = &"") -> void:
	if (not kind.is_empty()) and _get_values().has(kind):
		return
	var hbox := HBoxContainer.new()
	
	var o:OptionButton = option_button.duplicate()
	if not kind.is_empty():
		for i:int in o.item_count:
			if o.get_item_text(i) == kind:
				o.select(i)
				break
	o.item_selected.connect(func(_i:int) -> void: _sync())
	hbox.add_child(o)
	
	var b := Button.new()
	b.text = "Delete"
	b.pressed.connect(func() -> void: 
		hbox.queue_free()
		_sync()
		)
	hbox.add_child(b)
	
	items_vbox.add_child(hbox)


func _get_values() -> Array[StringName]:
	var output:Array[StringName] = []
	
	for n:Node in items_vbox.get_children():
		var o:OptionButton = ((n as HBoxContainer).get_child(0) as OptionButton)
		output.append(o.get_item_text(o.get_selected_id()))
	
	return output
