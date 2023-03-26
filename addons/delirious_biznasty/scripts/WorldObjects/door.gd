class_name Door
extends InteractiveObject
## Example implementation of an interactive object.
## Interacting with this teleports the interactor.


# TODO: Door instead of position. Hm how though
@export var dest_world:String
@export var dest_pos:Vector3
@export var open_verb:String = "OPEN"


func _ready():
	on_interact.connect(_handle_teleport_request.bind())


# You could also override #interact, instead of binding to signal.
func _handle_teleport_request(id:String):
	var teleportee = BizGlobal.entity_manager.get_entity(id) # get an entity
	if teleportee.some(): # if there is a valid object
		var tc = (teleportee.unwrap() as Entity).get_component("TeleportComponent")  # Try to get a teleport component
		if tc.some():
			(tc.unwrap() as TeleportComponent).teleport(dest_world, dest_pos)
