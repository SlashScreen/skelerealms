class_name WorldItem
extends InteractiveObject
## An item placed in the world, which syncs up with an entity.
## This will destroy itself when loaded. This is an editor tool.

const uuid_gen = preload("../vendor/uuid.gd")

@export var ref_id:String = uuid_gen.v4()
@export var item_owner:String
@export var instance:ItemInstance

func _ready():
	queue_free()
