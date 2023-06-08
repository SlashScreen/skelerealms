class_name WorldNPC
extends InteractiveObject
## An npc placed in the world, which syncs up with an entity.
## This will destroy itself on runtime; This is an editor tool.


@export var instance:NPCInstance


func _ready():
	print("Attempting to spawn %s" % instance.ref_id)
	print("Can we spawn %s? %s" % [instance.ref_id, SkeleRealmsGlobal.entity_manager.get_entity(instance.ref_id).some()]) # calling get_entity will cause the enity manager to start tracking this instance, if it isn't already.
	queue_free()
