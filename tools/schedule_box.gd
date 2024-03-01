@tool
extends PanelContainer


func _on_beginning_point_dragged(offset: Variant) -> void:
	position.x += offset.x


func _on_end_point_dragged(offset: Variant) -> void:
	size.x += offset.x
