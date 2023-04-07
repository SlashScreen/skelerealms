@tool
extends EditorPlugin

var dock:Control
var item_gizmo_plugin = WorldItemGizmo.new()
var npc_gizmo_plugin = WorldNPCGizmo.new()
var door_jump_plugin = DoorJumpPlugin.new(self)


func _enter_tree():
	# Initialization of the plugin goes here.
	dock = preload("res://addons/skelerealms/scripts/Quests/Editor/quest_editor_screen.tscn").instantiate()
	add_control_to_bottom_panel(dock, "Quest Editor")
	# gizmos
	add_node_3d_gizmo_plugin(item_gizmo_plugin)
	add_node_3d_gizmo_plugin(npc_gizmo_plugin)
	add_inspector_plugin(door_jump_plugin)


func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.free()
	
	remove_node_3d_gizmo_plugin(item_gizmo_plugin)
	remove_node_3d_gizmo_plugin(npc_gizmo_plugin)
	remove_inspector_plugin(door_jump_plugin)
