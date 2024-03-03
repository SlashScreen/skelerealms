@tool
extends PanelContainer


const TRACK_WIDTH = 140
const TRACK_OFFSET = 64

var internal_pos:int
var internal_size:int
var editing:ScheduleEvent
var editor:Control

signal delete_requested


func _ready() -> void:
	internal_pos = position.x
	internal_size = size.x
	if editing == null:
		editing = ScheduleEvent.new()
		editing.from = Timestamp.new()
		editing.to = Timestamp.new()


func _on_beginning_point_dragged(offset: Variant) -> void:
	internal_pos += offset.x
	position.x = editor.snap_to_hour(editor.snap_to_minute(editor.scroll_value + internal_pos))


func _on_end_point_dragged(offset: Variant) -> void:
	internal_size += offset.x
	size.x = editor.snap_to_hour(editor.snap_to_minute(position.x + internal_size)) - position.x


func _process(_delta: float) -> void:
	if editor == null:
		return
	
	position.x = editor.snap_to_hour(editor.snap_to_minute(editor.scroll_value + internal_pos))
	
	var start:Dictionary = editor.get_time_from_position(position.x)
	var end:Dictionary = editor.get_time_from_position(position.x + size.x)
	editing.from.hour = start.hour
	editing.from.minute = start.minute
	editing.to.hour = end.hour
	editing.to.minute = end.minute


func switch_track(to:int) -> void:
	position.y = TRACK_OFFSET + TRACK_WIDTH * to


func edit(s:ScheduleEvent, e:Control) -> void:
	editing = s
	editor = e
	internal_pos = editor.position_from_time({
		&"hour": s.from.hour,
		&"minute": s.from.minute,
	})
	size.x = editor.position_from_time({
		&"hour": s.to.hour,
		&"minute": s.to.minute,
	}) - internal_pos
	$MarginContainer/Controls/LineEdit.text = editing.name


func _on_line_edit_text_submitted(new_text: String) -> void:
	editing.name = new_text


func _on_button_pressed() -> void:
	EditorInterface.edit_resource(editing)


func _on_remove_pressed() -> void:
	delete_requested.emit()
