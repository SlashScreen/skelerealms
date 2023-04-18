class_name DefaultThreatResponseModule # oh god this is getting java like
extends AIModule


@export var warn_radius:float = 20
@export var attack_radius:float = 8


func _initialize() -> void:
	_npc.perception_transition.connect(_handle_perception_info.bind())


func _handle_perception_info(what:StringName, transition:String) -> void:
	var opinion = _npc.determine_opinion_of(what)
	
	match transition:
		"AwareInvisible":
			# if threat, seek last known position
			return
		"AwareVisible":
			## if threat, warn, fight
			return
		"Lost":
			# may be useless
			return
		"Unaware":
			# if threat, do "huh?" behavior
			return
