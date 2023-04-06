class_name PerceptionFSM_Machine
extends FSMMachine


var tracked:String
var visibility:float
var last_seen_position:Vector3
var last_seen_world:String


func _init(tracked_obj:String, vis:float) -> void:
	tracked = tracked_obj
	visibility = vis



func remove_fsm() -> void:
	pass
