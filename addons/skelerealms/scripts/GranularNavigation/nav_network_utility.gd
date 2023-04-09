@tool
class_name NavigationNetworkUtility
extends Control


var mode:ToolMode = ToolMode.NONE
var target:NavigationNetwork3D
var plugin:EditorPlugin


func set_target(t:NavigationNetwork3D) -> void:
	target = t


func reset() -> void:
	target = null

	for b in get_child(0).get_children(): # dirty and duct tape as fuck but dont @ me 
		if b is Button:
			(b as Button).button_pressed = false
	
	mode = ToolMode.NONE
	

func _on_merge_pressed() -> void:
	pass # Replace with function body.


func _on_select_toggled(button_pressed:bool) -> void:
	if button_pressed:
		mode = ToolMode.SELECT


func _on_add_toggled(button_pressed:bool) -> void:
	if button_pressed:
		mode = ToolMode.ADD


func get_input(viewport_camera: Camera3D, event: InputEvent) -> void:
	print("Got input!")
	#TODO: Add new nodes. im too tired to do this today
	# Get raycast point
	# Create new netpoint 
	# connect to old one
	# add to network


enum ToolMode {
	NONE,
	ADD,
	SELECT,
}
