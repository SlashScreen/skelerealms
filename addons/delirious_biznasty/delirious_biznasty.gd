@tool
extends EditorPlugin

var dock:Control

func _enter_tree():
	# Initialization of the plugin goes here.
	dock = preload("res://addons/delirious_biznasty/scripts/Quests/quest_editor_screen.tscn").instantiate()
	add_control_to_bottom_panel(dock, "Quest Editor")
	


func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.free()
