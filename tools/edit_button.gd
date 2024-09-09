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
	#spawn_position = cam.position
	#spawn_world = EditorInterface.get_edited_scene_root().name
	
	
	#_open_sock()
	OS.set_environment("world", EditorInterface.get_edited_scene_root().name)
	OS.set_environment("pos", var_to_str(cam.position))
	
	var game_root_path:String = SkeleRealmsGlobal.config.game_root.resource_path
	EditorInterface.play_custom_scene(game_root_path)
	OS.set_environment("world", "")
	OS.set_environment("pos", "")


func _serve() -> void:
	sock.poll()
	var state := sock.get_connection_status()
	if state == MultiplayerPeer.CONNECTION_CONNECTED:
		while sock.get_available_packet_count():
			if sock.get_packet() == PackedByteArray([1, 2, 3, 2, 1]):
				_push_spawn_data()
				sock.close()
				sending = false


func _open_sock() -> void:
	if not sock.create_server(8123) == OK:
		push_warning("Could not start Skelerealms play button service.")
	if sock.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_warning("Could not start Skelerealms play button service.")
		return
	sock.peer_connected.connect(func(id:int) -> void: 
		_push_spawn_data()
		)
	sending = true


func _push_spawn_data() -> void:
	var data = {
		"pos":spawn_position,
		"world":spawn_world,
	}
	if not sock.put_packet(var_to_bytes(data)) == OK:
		push_warning("Failed to send Skelerealms play button data.")


func _process(_delta) -> void:
	if sending:
		_serve()
