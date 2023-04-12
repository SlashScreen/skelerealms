class_name DefaultThreatResponseModule # oh god this is getting java like
extends AIModule


func _initialize() -> void:
	_npc.perception_transition.connect(_handle_perception_info.bind())


func _handle_perception_info(what:StringName, transition:String) -> void:
	match transition:
		"AwareInvisible":
			# if threat, seek last known position
			return
		"AwareVisible":
			## if threat, wark, fight
			return
		"Lost":
			# may be useless
			return
		"Unaware":
			# if threat, do "huh?" behavior
			return
