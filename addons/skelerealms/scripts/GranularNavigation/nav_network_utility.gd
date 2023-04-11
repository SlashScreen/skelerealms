@tool
class_name NavigationNetworkUtility
extends Control


const RAY_LENGTH = 500

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
	

func _on_link_pressed() -> void:
	if plugin.network_gizmo.penultimate_modified_node:
		if plugin.network_gizmo.last_modified_node.has_method("connect_point"):
			plugin.network_gizmo.last_modified_node.connect_point(plugin.network_gizmo.penultimate_modified_node, 1.0)
		else:
			print("oops")


func _on_select_toggled(button_pressed:bool) -> void:
	if button_pressed:
		mode = ToolMode.SELECT


func _on_add_toggled(button_pressed:bool) -> void:
	if button_pressed:
		mode = ToolMode.ADD


func get_input(camera: Camera3D, event: InputEvent) -> void:
	if not ((event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT && (event as InputEventMouseButton).pressed):
		return
		
	var screen_pos:Vector2 = (event as InputEventMouseButton).position
	# Get raycast point
	var from = camera.project_ray_origin(screen_pos)
	var to = from + (camera.project_ray_normal(screen_pos) * RAY_LENGTH)
	var ray = PhysicsRayQueryParameters3D.create(from, to)
	await target.get_tree().physics_frame
	var hits = target.get_world_3d().direct_space_state.intersect_ray(ray)
	# Create new netpoint 
	if hits:
		var new_point:NetPoint = NetPoint.new(hits["position"])
		if plugin.network_gizmo.last_modified_node:
			# connect to old one
			new_point.connect_point(plugin.network_gizmo.last_modified_node, 1) # TODO: Allow adjustable costs
		# add to network
		target.network._points.append(new_point)
		plugin.network_gizmo.last_modified_node = new_point
		plugin.network_gizmo._redraw(target.get_gizmos().filter(func(x:Node3DGizmo): return x.get_plugin() is NavNetworkGizmo)[0]) # IDK if this will work lol
	

enum ToolMode {
	NONE,
	ADD,
	SELECT,
}
