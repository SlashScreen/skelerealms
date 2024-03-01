@tool
extends PanelContainer


const TRACK_WIDTH = 140

@export var internal_pos:int = position.x


func _ready() -> void:
	internal_pos = position.x


func _on_beginning_point_dragged(offset: Variant) -> void:
	internal_pos += offset.x


func _on_end_point_dragged(offset: Variant) -> void:
	size.x += offset.x


func _process(_delta: float) -> void:
	position.x = owner.scroll_value + internal_pos


func switch_track(to:int) -> void:
	position.y = TRACK_WIDTH * to
