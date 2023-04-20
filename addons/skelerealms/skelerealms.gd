@tool
extends EditorPlugin


var item_gizmo_plugin = WorldItemGizmo.new()
var npc_gizmo_plugin = WorldNPCGizmo.new()
var door_jump_plugin = DoorJumpPlugin.new(self)


func _enter_tree():
	# gizmos
	add_node_3d_gizmo_plugin(item_gizmo_plugin)
	add_node_3d_gizmo_plugin(npc_gizmo_plugin)
	add_inspector_plugin(door_jump_plugin)
	# autoload
	add_autoload_singleton("SkeleRealmsGlobal", "res://addons/skelerealms/scripts/sk_global.gd")
	add_autoload_singleton("CovenSystem", "res://addons/skelerealms/scripts/Covens/coven_system.gd")
	add_autoload_singleton("GameInfo", "res://addons/skelerealms/scripts/System/game_info.gd")
	add_autoload_singleton("SaveSystem", "res://addons/skelerealms/scripts/System/save_system.gd")
	add_autoload_singleton("CrimeMaster", "res://addons/skelerealms/scripts/Crime/crime_master.gd")


func _exit_tree():
	remove_node_3d_gizmo_plugin(item_gizmo_plugin)
	remove_node_3d_gizmo_plugin(npc_gizmo_plugin)
	remove_inspector_plugin(door_jump_plugin)
	remove_autoload_singleton("SkeleRealmsGlobal")
	remove_autoload_singleton("CovenSystem")
	remove_autoload_singleton("GameInfo")
	remove_autoload_singleton("SaveSystem")
	remove_autoload_singleton("CrimeMaster")
