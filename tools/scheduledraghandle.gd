@tool
extends Control


var dragging:bool
var editing:ScheduleEvent
signal dragged(offset)


func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if (event as InputEventMouseButton).pressed:
				if _contains(event.global_position):
					dragging = true
			else:
				dragging = false
	elif event is InputEventMouseMotion:
		if dragging:
			dragged.emit(event.relative)


func _contains(pos: Vector2) -> bool:
	return get_global_rect().has_point(pos)
