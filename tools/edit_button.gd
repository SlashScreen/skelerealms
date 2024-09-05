@tool
extends Button


const EditorGameRoot = preload("res://addons/skelerealms/tools/editor_game_root.gd")


func _ready() -> void: 
	text = "Open Skelerealms World"
	pressed.connect(_on_press.bind())


func _on_press() -> void:
	var cam:Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
	EditorGameRoot.spawn_position = cam.position
	EditorGameRoot.spawn_world = EditorInterface.get_edited_scene_root().name
	
	var game_root_path:String = SkeleRealmsGlobal.config.game_root.resource_path
	EditorInterface.play_custom_scene(game_root_path)
