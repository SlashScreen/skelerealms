@tool
extends EditorPlugin


const NetworkPanel:PackedScene = preload("res://addons/skelerealms/scripts/GranularNavigation/network_plugin.tscn")

var dock:Control
var item_gizmo_plugin = WorldItemGizmo.new()
var npc_gizmo_plugin = WorldNPCGizmo.new()
var door_jump_plugin = DoorJumpPlugin.new(self)
var network_gizmo = NavNetworkGizmo.new(self)
var network_menu_instance:NavigationNetworkUtility


func _enter_tree():
	# Initialization of the plugin goes here.
	dock = preload("res://addons/skelerealms/scripts/Quests/Editor/quest_editor_screen.tscn").instantiate()
	add_control_to_bottom_panel(dock, "Quest Editor")
	# nav network
	network_menu_instance = NetworkPanel.instantiate()
	network_menu_instance.plugin = self
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, network_menu_instance)
	get_editor_interface().get_selection().selection_changed.connect(_selection_changed.bind())

	# gizmos
	add_node_3d_gizmo_plugin(item_gizmo_plugin)
	add_node_3d_gizmo_plugin(npc_gizmo_plugin)
	add_node_3d_gizmo_plugin(network_gizmo)
	add_inspector_plugin(door_jump_plugin)


func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.free()

	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, network_menu_instance)
	network_menu_instance.queue_free()

	remove_node_3d_gizmo_plugin(item_gizmo_plugin)
	remove_node_3d_gizmo_plugin(npc_gizmo_plugin)
	remove_node_3d_gizmo_plugin(network_gizmo)
	remove_inspector_plugin(door_jump_plugin)


func _set_network_plugin_visible(state:bool):
	if network_menu_instance:
		if state:
			network_menu_instance.show()
		else:
			network_menu_instance.hide()
			network_menu_instance.reset()


func _selection_changed() -> void:
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	if selection.is_empty():
		_set_network_plugin_visible(false)
		return 
	
	if selection[0] is NavigationNetwork3D:
		_set_network_plugin_visible(true)
		network_menu_instance.set_target(selection[0])
	else:
		_set_network_plugin_visible(false)


func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if not network_menu_instance:
		return EditorPlugin.AFTER_GUI_INPUT_PASS
	if not event is InputEventMouseButton:
		return EditorPlugin.AFTER_GUI_INPUT_PASS
	if network_menu_instance.mode == NavigationNetworkUtility.ToolMode.ADD:
		network_menu_instance.get_input(viewport_camera, event)
		return EditorPlugin.AFTER_GUI_INPUT_STOP
	return EditorPlugin.AFTER_GUI_INPUT_PASS


func _handles(object: Object) -> bool:
	return object is NavigationNetwork3D
