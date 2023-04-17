class_name DefaultThreatResponseModule # oh god this is getting java like
extends AIModule


@export var warn_radius:float = 20
@export var attack_radius:float = 8


func _initialize() -> void:
	_npc.perception_transition.connect(_handle_perception_info.bind())


func _handle_perception_info(what:StringName, transition:String) -> void:
	var threat = determine_threat_level(what)
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


## Determines the threat level of an entity, from 0 being harmless to 100 being like, Ganondorf.
func determine_threat_level(what:String) -> int:
	var e:Entity = SkeleRealmsGlobal.entity_manager.get_entity(what).unwrap()
	if not e.get_component("NPCComponent").some(): # if it's not an NPC, it's harmless.
		# TODO: make it not tied to NPCComponent?
		return 0
	
	#var cc = e.get_component("CovensComponent")
	
	# using threat level and the npc's combat information, determine what it should do and add goals to reflect
	# (flee, fight, etc)
	return 0
