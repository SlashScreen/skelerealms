@tool
extends Button


var sock:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var spawn_position:Vector3
var spawn_world:String


func _ready() -> void: 
	text = "Open Skelerealms World"
	pressed.connect(_on_press.bind())
	_open_sock()


func _on_press() -> void:
	var cam:Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
	spawn_position = cam.position
	spawn_world = EditorInterface.get_edited_scene_root().name
	
	var game_root_path:String = SkeleRealmsGlobal.config.game_root.resource_path
	EditorInterface.play_custom_scene(game_root_path)


func _serve() -> void:
	sock.poll()
	var state := sock.get_connection_status()
	if state == MultiplayerPeer.CONNECTION_CONNECTED:
		while sock.get_available_packet_count():
			if sock.get_packet() == PackedByteArray([1, 2, 3, 2, 1]):
				_push_spawn_data()
	elif state == MultiplayerPeer.CONNECTION_CONNECTING:
		# Keep polling to achieve proper close.
		pass
	elif state == MultiplayerPeer.CONNECTION_DISCONNECTED:
		var code = sock.get_close_code()
		var reason = sock.get_close_reason()
		#print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])


func _open_sock() -> void:
	if not sock.create_server(8123) == OK:
		push_warning("Could not start Skelerealms play button service.")
	if sock.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_warning("Could not start Skelerealms play button service.")
		return
	sock.peer_connected.connect(func(id:int) -> void: 
		_push_spawn_data()
		)


func _push_spawn_data() -> void:
	var data = {
		"pos":spawn_position,
		"world":spawn_world,
	}
	if not sock.put_packet(var_to_bytes(data)) == OK:
		push_warning("Failed to send Skelerealms play button data.")


func _process(delta):
	_serve()
