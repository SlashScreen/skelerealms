class_name DefaultThreatResponseModule # oh god this is getting java like
extends AIModule


@export var warn_radius:float = 20
@export var attack_radius:float = 8

## Thread for an NPC to keep watch when alerted
var vigilant_thread:Thread
## Set to true to stop [memer vigilant_thread]
var pull_out_of_thread = false


func _initialize() -> void:
	_npc.perception_transition.connect(_handle_perception_info.bind())


func _handle_perception_info(what:StringName, transition:String, fsm:PerceptionFSM_Machine) -> void:
	var opinion = _npc.determine_opinion_of(what)
	print("Opinion on %s: %s" % [what, opinion])
	var below_attack_threshold = opinion <= _npc.data.attack_threshold
	
	match transition:
		"AwareInvisible":
			if _npc.data.aggression == 0: # if peaceful
				return
			# if threat, seek last known position
			if below_attack_threshold:
				_npc.goap_memory["last_seen_position"] = NavPoint.new(fsm.last_seen_world, fsm.last_seen_position) # commit to memory
				_npc.add_objective({"enemy_sought" = true}, true, 10) # add goal to seek position
		"AwareVisible":
			if _npc.data.aggression == 0: # if peaceful
				return
			
			if below_attack_threshold or _npc.data.aggression == 3: # if attack threshold or frenzied
				# TODO: Only if not already in a combat state
				var e = SkeleRealmsGlobal.entity_manager.get_entity(what).unwrap()
				_enter_vigilant_stance()
				vigilant_thread = Thread.new()
				vigilant_thread.start(_stay_vigilant.bind(e))
		"Lost":
			# may be useless
			return
		"Unaware":
			# if threat, do "huh?" behavior
			if below_attack_threshold:
				# TODO: Stop, investigate
				return


## Will keep watch until the entity is out of range. TODO: Visibility?
func _stay_vigilant(e:Entity) -> void: 
	var warned:bool = false
	
	while true:
		# check if out of world
		if not _npc.parent_entity.world == e.world:
			_enter_normal_state()
			return
		# leave thread early if need be
		if pull_out_of_thread:
			pull_out_of_thread = false
			return
		# range checks
		var distance_to_e = _npc.parent_entity.position.distance_squared_to(e.position)
		# check if out of range
		if distance_to_e > warn_radius ** 2:
			_enter_normal_state()
			return
		# if frenzied and within ring attack immediately
		if distance_to_e <= warn_radius ** 2 and _npc.data.aggression == 3:
			_begin_attack(e)
			return
		# if within warn ring
		if distance_to_e <= warn_radius ** 2 and distance_to_e > attack_radius ** 2:
			# if not already warned, warn and set warned
			if not warned:
				_warn(e)
				warned = true
		# if in attack distance, attack
		if distance_to_e <= attack_radius ** 2:
			_begin_attack(e)
			return


func _begin_attack(e:Entity) -> void:
	# figure out response to confrontation
	match _npc.data.aggression:
		0: # Peaceful
			return
		1: # Bluffing
			_flee()
		2, 3:
			# Add to goap memory
			if _npc.goap_memory.has("enemies"):
				# but only if not already in memory
				if not _npc.goap_memory["enemies"].has(e.name):
					_npc.goap_memory["enemies"].append(e)
			else:
				_npc.goap_memory["enemies"] = [e.name]
			# This will begin combat, because NPCs have a recurring goal where all enemies must be dead


func _warn(e:Entity) -> void:
	# Issue warning to entity
	_npc.warning.emit(e.name)


func _enter_normal_state() -> void:
	# undo vigilant stance
	return


func _enter_vigilant_stance() -> void:
	# draaw weapons, turn towards threat
	return


func _flee() -> void:
	# tell GOAP to flee from enemies
	_npc.add_objective({"flee_from_enemies" : true}, true, 10)


## Response to being hit.
func _aggress(e:Entity) -> void:
	# "Coward", "Cautious", "Average", "Brave", "Foolhardy"
	# TODO: Friendly fire
	var threat = _determine_threat(e)
	match _npc.data.confidence:
		0: # Coward - flee
			_flee()
			return
		1: # Cautious - only attack if target weaker
			if threat == -1:
				_begin_attack(e)
				return
			else:
				_flee()
				return
		2: # Average - attack if evenly matched or stronger
			if threat <= 0:
				_begin_attack(e)
				return
			else:
				_flee()
				return
		3: # Brave - Fight unless significantly outmatched
			if threat <= 1:
				_begin_attack(e)
				return
			else:
				_flee()
				return
		4: # Foolhardy - always attack, no matter the threat
			_begin_attack(e)
			return


## Determines the threat level of another entity. Returns: [br]
## -1: weaker [br]
## 0: about the same [br]
## 1: stronger [br]
## 2: significantly stronger
func _determine_threat(e:Entity) -> int:
	return 0


func _clean_up() -> void:
	vigilant_thread.wait_to_finish()
