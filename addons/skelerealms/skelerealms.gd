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
	add_autoload_singleton("DialogueHooks", "res://addons/skelerealms/scripts/System/dialogue_hooks.gd")
	# settings
	ProjectSettings.set_setting("skelerealms/actor_fade_distance", 100.0)
	ProjectSettings.set_setting("skelerealms/entity_cleanup_timer", 300.0)
	ProjectSettings.set_setting("skelerealms/granular_navigation_sim_distance", 1000.0)
	ProjectSettings.set_setting("skelerealms/savegame_indents", true)
	
	ProjectSettings.set_setting("skelerealms/seconds_per_minute", 2.0)
	ProjectSettings.set_setting("skelerealms/minutes_per_hour", 31.0)
	ProjectSettings.set_setting("skelerealms/hours_per_day", 15.0)
	ProjectSettings.set_setting("skelerealms/days_per_week", 8)
	ProjectSettings.set_setting("skelerealms/weeks_in_month", 4)
	ProjectSettings.set_setting("skelerealms/months_in_year", 8)
	
	ProjectSettings.set_setting("skelerealms/worlds_path", "res://Worlds")
	ProjectSettings.set_setting("skelerealms/entities_path", "res://Entities")
	ProjectSettings.set_setting("skelerealms/covens_path", "res://Covens")
	ProjectSettings.set_setting("skelerealms/doors_path", "res://Doors")
	ProjectSettings.set_setting("skelerealms/networks_path", "res://Networks")


func _exit_tree():
	# gizmos
	remove_node_3d_gizmo_plugin(item_gizmo_plugin)
	remove_node_3d_gizmo_plugin(npc_gizmo_plugin)
	remove_inspector_plugin(door_jump_plugin)
	# autoload
	remove_autoload_singleton("SkeleRealmsGlobal")
	remove_autoload_singleton("CovenSystem")
	remove_autoload_singleton("GameInfo")
	remove_autoload_singleton("SaveSystem")
	remove_autoload_singleton("CrimeMaster")
	remove_autoload_singleton("DialogueHooks")
	# settings
	ProjectSettings.set_setting("skelerealms/actor_fade_distance", null)
	ProjectSettings.set_setting("skelerealms/entity_cleanup_timer", null)
	ProjectSettings.set_setting("skelerealms/granular_navigation_sim_distance", null)
	ProjectSettings.set_setting("skelerealms/savegame_indents", null)
	
	ProjectSettings.set_setting("skelerealms/seconds_per_minute", null)
	ProjectSettings.set_setting("skelerealms/minutes_per_hour", null)
	ProjectSettings.set_setting("skelerealms/hours_per_day", null)
	ProjectSettings.set_setting("skelerealms/days_per_week", null)
	ProjectSettings.set_setting("skelerealms/weeks_in_month", null)
	ProjectSettings.set_setting("skelerealms/months_in_year", null)
	
	ProjectSettings.set_setting("skelerealms/worlds_path", null)
	ProjectSettings.set_setting("skelerealms/entities_path", null)
	ProjectSettings.set_setting("skelerealms/covens_path", null)
	ProjectSettings.set_setting("skelerealms/doors_path", null)
	ProjectSettings.set_setting("skelerealms/networks_path", null)
