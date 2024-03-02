@tool
extends PanelContainer


const TRACK_WIDTH = 140
const TRACK_OFFSET = 64

@export var internal_pos:int = position.x
var editing:ScheduleEvent
var editor:Control:
	get:
		return owner.owner


func _ready() -> void:
	internal_pos = position.x
	if editing == null:
		editing = ScheduleEvent.new()
		editing.from = Timestamp.new()
		editing.to = Timestamp.new()


func _on_beginning_point_dragged(offset: Variant) -> void:
	internal_pos += offset.x


func _on_end_point_dragged(offset: Variant) -> void:
	size.x += offset.x


func _process(_delta: float) -> void:
	position.x = editor.snap_to_minute(editor.scroll_value + internal_pos)
	var start:Dictionary = editor.get_time_from_position(internal_pos)
	var end:Dictionary = editor.get_time_from_position(internal_pos + size.x)
	editing.from.hour = start.hour
	editing.from.minute = start.minute
	editing.to.hour = end.hour
	editing.to.minute = end.minute


func switch_track(to:int) -> void:
	position.y = TRACK_OFFSET + TRACK_WIDTH * to


func edit(s:ScheduleEvent) -> void:
	editing = s
	internal_pos = editor.position_from_time({
		&"hour": s.from.hour,
		&"minute": s.from.minute,
	})
	size.x = editor.position_from_time({
		&"hour": s.to.hour,
		&"minute": s.to.minute,
	}) - internal_pos
