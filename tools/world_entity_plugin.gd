extends EditorInspectorPlugin


const TemplateSelector = preload("res://addons/skelerealms/tools/template_selector.tscn")


func _can_handle(object: Object) -> bool:
	return object is SKWorldEntity


func _parse_begin(object: Object) -> void:
	var b := Button.new()
	b.text = "Sync position with entity"
	b.pressed.connect(object._sync.bind())
	
	var t := TemplateSelector.instantiate()
	t.edit(object)
	
	var vbox := VBoxContainer.new()
	vbox.add_child(b)
	vbox.add_child(t)
	
	add_custom_control(vbox)
