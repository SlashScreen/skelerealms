@tool
extends EditorInspectorPlugin


const ScheduleEditor := preload("res://addons/skelerealms/tools/schedule_editor.tscn")

signal request_open(events: Array[ScheduleEvent])


func _can_handle(object: Object) -> bool:
	return object is Schedule


func _parse_begin(object: Object) -> void:
	var b := Button.new()
	b.text = "Open schedule editor"
	b.pressed.connect(func() -> void: request_open.emit((object as Schedule).events))
	add_custom_control(b)
