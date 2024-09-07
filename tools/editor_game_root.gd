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


func _process(delta):
	_listen()


func _ask_for_data() -> void:
	sock.put_packet(PackedByteArray([1, 2, 3, 2, 1]))


func _listen() -> void:
	sock.poll()
	var state = sock.get_connection_status()
	if state == MultiplayerPeer.CONNECTION_CONNECTED:
		while sock.get_available_packet_count():
			_move_player.call_deferred(bytes_to_var(sock.get_packet()))
			sock.close()


func _move_player(data:Dictionary) -> void:
	for c:Node in get_children():
		if c is SKEntityManager:
			var tc:TeleportComponent = (c as SKEntityManager).get_entity(&"Player").get_component(&"TeleportComponent")
			tc.teleport(data["world"], data["pos"])
			GameInfo.start_game()
	set_process(false)
