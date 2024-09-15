extends Node3D


static var spawn_position:Vector3
static var spawn_world:String


func _ready() -> void:
	var world:String = OS.get_environment("world")
	if world.is_empty():
		world = SkeleRealmsGlobal.config.default_world
	
	var p := str_to_var(OS.get_environment("pos"))
	var pos:Vector3 = p if p else SkeleRealmsGlobal.config.default_world_position
	
	_move_player(world, pos)


func _move_player(world:String, pos:Vector3) -> void:
	for c:Node in get_children():
		if c is SKEntityManager:
			var tc:TeleportComponent = (c as SKEntityManager).get_entity(&"Player").get_component(&"TeleportComponent")
			tc.teleport(world, pos)
			GameInfo.start_game()
