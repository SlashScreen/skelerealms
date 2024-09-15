@tool
extends Button


var sock:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var spawn_position:Vector3
var spawn_world:String
var sending := false


func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	text = "Open Skelerealms World"
	pressed.connect(_on_press.bind())


func _on_press() -> void:
	var cam:Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()

	OS.set_environment("world", EditorInterface.get_edited_scene_root().name)
	OS.set_environment("pos", var_to_str(cam.position))
	
	var game_root_path:String = SkeleRealmsGlobal.config.game_root.resource_path
	EditorInterface.play_custom_scene(game_root_path)
	OS.set_environment("world", "")
	OS.set_environment("pos", "")
