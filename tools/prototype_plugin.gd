@tool
class_name PrototypePlugin
extends EditorInspectorPlugin


signal inspect(object:Prototype)


func _can_handle(object):
	return object is Prototype


func _parse_begin(object):
	var sync_position:Button = Button.new()
	sync_position.text = "Instantiate"
	sync_position.pressed.connect(func(): inspect.emit(object))
	add_custom_control(sync_position)
