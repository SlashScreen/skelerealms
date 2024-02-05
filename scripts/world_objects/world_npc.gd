class_name WorldNPC
extends InteractiveObject
## An npc placed in the world, which syncs up with an entity.
## This will destroy itself on runtime; This is an editor tool.


@export var instance:NPCInstance


func _ready():
	if visible:
		_spawn()
	else:
		visibility_changed.connect(func(s:bool) -> void: if s: _spawn())


func _spawn():
	var e = EntityManager.instance.get_entity(instance.ref_id) # calling get_entity will cause the enity manager to start tracking this instance, if it isn't already.
	queue_free()
