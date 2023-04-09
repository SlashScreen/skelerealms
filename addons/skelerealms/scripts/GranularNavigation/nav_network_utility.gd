@tool
class_name NavigationNetworkUtility
extends Control


var mode:ToolMode = ToolMode.NONE
var target:NavigationNetwork3D


func set_target(t:NavigationNetwork3D) -> void:
	target = t


func _on_merge_pressed() -> void:
	pass # Replace with function body.


func _on_select_toggled(button_pressed:bool) -> void:
	if button_pressed:
		mode = ToolMode.SELECT


func _on_add_toggled(button_pressed:bool) -> void:
	if button_pressed:
		mode = ToolMode.ADD


enum ToolMode {
	NONE,
	ADD,
	SELECT,
}
