extends Node3D


static var spawn_position:Vector3
static var spawn_world:String

var sock:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var sent:bool


func _client_ready() -> void:
	_open_sock()


func _open_sock() -> void:
	if not sock.create_client("localhost", 8123) == OK:
		push_warning("Could not connect to Skelerealms play button.")


func _push_spawn_data() -> void:
	var data = {
		"pos":spawn_position,
		"world":spawn_world,
	}
	
	sock.send_text(JSON.stringify(data))


func _process(delta):
	_listen()


func _ask_for_data() -> void:
	sock.put_packet(PackedByteArray([1, 2, 3, 2, 1]))


func _listen() -> void:
	sock.poll()
	var state = sock.get_connection_status()
	if state == WebSocketPeer.STATE_OPEN:
		while sock.get_available_packet_count():
			_move_player(JSON.parse_string(sock.get_packet().get_string_from_utf8()))
			sock.close()
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = sock.get_close_code()
		var reason = sock.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false)


func _move_player(data:Dictionary) -> void:
	print("Got data: ", data)
