class_name WorldItem
extends InteractiveObject
## An item placed in the world, which syncs up with an entity.
## This will destroy itself on runtime; This is an editor tool.


@export var instance:ItemInstance


func _ready():
	var _e = EntityManager.instance.get_entity(instance.ref_id) # calling get_entity will cause the enity manager to start tracking this instance, if it isn't already.
	queue_free()
