@tool
extends EditorPlugin


const QuestWindow = preload("res://addons/journalgd/Editor/quest_editor_screen.tscn")
const icon:Texture2D = preload("res://addons/journalgd/icon.png")


var quest_panel_instance:Control


func _enter_tree() -> void:
	quest_panel_instance = QuestWindow.instantiate() # Instantiate editor
	get_editor_interface().get_editor_main_screen().add_child(quest_panel_instance) # Add to main screen
	_make_visible(false) #hide by default


func _exit_tree() -> void:
	if quest_panel_instance:
		quest_panel_instance.queue_free() # destroy panel


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "JournalGD Editor"


func _get_plugin_icon() -> Texture2D:
	return icon


func _make_visible(state:bool) -> void:
	if quest_panel_instance:
		quest_panel_instance.visible = state
