@tool
extends EditorPlugin


const DoorJumpPlugin = preload("res://addons/skelerealms/tools/door_connect.gd")
const ConversionPlugin = preload("res://addons/skelerealms/tools/resource_conversion_plugin.gd")
const WorldEntityPlugin = preload("res://addons/skelerealms/tools/world_entity_plugin.gd")
const PointGizmo = preload("res://addons/skelerealms/tools/point_gizmo.gd")
const ScheduleEditorPlugin = preload("res://addons/skelerealms/tools/schedule_editor_plugin.gd")

var door_jump_plugin := DoorJumpPlugin.new(self)
var conversion := ConversionPlugin.new()
var we_plugin := WorldEntityPlugin.new()
var point_gizmo := PointGizmo.new()
var se_plugin := ScheduleEditorPlugin.new()

var se_w: Window
var se: Control


func _enter_tree():
	# gizmos
	add_node_3d_gizmo_plugin(point_gizmo)
	add_inspector_plugin(door_jump_plugin)
	add_inspector_plugin(conversion)
	add_inspector_plugin(we_plugin)
	add_inspector_plugin(se_plugin)
	# autoload
	add_autoload_singleton("SkeleRealmsGlobal", "res://addons/skelerealms/scripts/sk_global.gd")
	add_autoload_singleton("CovenSystem", "res://addons/skelerealms/scripts/covens/coven_system.gd")
	add_autoload_singleton("GameInfo", "res://addons/skelerealms/scripts/system/game_info.gd")
	add_autoload_singleton("SaveSystem", "res://addons/skelerealms/scripts/system/save_system.gd")
	add_autoload_singleton("CrimeMaster", "res://addons/skelerealms/scripts/crime/crime_master.gd")
	add_autoload_singleton("DialogueHooks", "res://addons/skelerealms/scripts/system/dialogue_hooks.gd")
	add_autoload_singleton("DeviceNetwork", "res://addons/skelerealms/scripts/misc/device_network.gd")
	
	se_w = Window.new()
	se = ScheduleEditorPlugin.ScheduleEditor.instantiate()
	se_w.add_child(se)
	EditorInterface.get_base_control().add_child(se_w)
	se_w.hide()
	
	se_plugin.request_open.connect(func(events:Array[ScheduleEvent]) -> void:
		se.edit(events)
		se_w.popup_centered(Vector2i(1920, 1080))
		)


func _exit_tree():
	# gizmos
	remove_node_3d_gizmo_plugin(point_gizmo)
	remove_inspector_plugin(door_jump_plugin)
	remove_inspector_plugin(conversion)
	remove_inspector_plugin(we_plugin)
	remove_inspector_plugin(se_plugin)
	# autoload
	remove_autoload_singleton("SkeleRealmsGlobal")
	remove_autoload_singleton("CovenSystem")
	remove_autoload_singleton("GameInfo")
	remove_autoload_singleton("SaveSystem")
	remove_autoload_singleton("CrimeMaster")
	remove_autoload_singleton("DialogueHooks")
	remove_autoload_singleton("DeviceNetwork")
	
	se_w.queue_free()


func _enable_plugin() -> void:
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
	
	ProjectSettings.set_setting("skelerealms/worlds_path", "res://worlds")
	ProjectSettings.set_setting("skelerealms/entities_path", "res://entities")
	ProjectSettings.set_setting("skelerealms/covens_path", "res://covens")
	ProjectSettings.set_setting("skelerealms/doors_path", "res://doors")
	ProjectSettings.set_setting("skelerealms/networks_path", "res://networks")
	
	ProjectSettings.set_setting("skelerealms/entity_archetypes", PackedStringArray([
		"res://addons/skelerealms/npc_entity_template.tscn",
		"res://addons/skelerealms/item_entity_template.tscn"
	]))


func _disable_plugin() -> void:
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
	
	ProjectSettings.set_setting("skelerealms/entity_archetypes", null)
