@tool
extends Node3D


static var spawn_position:Vector3
static var spawn_world:String


func spawn_default() -> void:
	if spawn_world.is_empty():
		spawn_world = SkeleRealmsGlobal.config.default_world
	
	# TODO: Get entity manager by type
	var tc:TeleportComponent = ($EntityManager as SKEntityManager).get_entity(&"Player").get_component(&"TeleportComponent")
	tc.teleport(spawn_world, spawn_position)
