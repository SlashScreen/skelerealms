extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is SKWorldEntity


func _parse_begin(object: Object) -> void:
	var b := Button.new()
	b.text = "Sync position with entity"
	b.pressed.connect(object._sync.bind())
	add_custom_control(b)
