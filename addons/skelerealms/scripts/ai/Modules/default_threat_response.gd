class_name DefaultThreatResponseModule # oh god this is getting java like
extends AIModule


# How many levels weaker something needs to be to be considered "weaker".
const THREAT_LEVEL_WEAKER_INTERVAL = 1
# How many levels greater to be considered "stronger".
const THREAT_LEVEL_GREATER_INTERVAL = 1
# How many levels greater to be considered "significantly stronger".
const THREAT_LEVEL_MUCH_GREATER_INTERVAL = 5

@export_category("Combat info")
## Will this actor initiate combat? [br]
## Peaceful: Will not initiate combat. [br]
## Bluffing: Variant of peaceful, they will warn and try to act tough, but never attack. [br
## Aggressive: Will attack anything below the [member attack_threshold] on sight. [br]
## Frenzied: Will attack anything, ignoring opinion.
@export_enum("Peaceful", "Bluffing", "Aggressive", "Frenzied") var aggression:int = 2
## Agressive NPCs will attack any entity with an opinion below this threshold.
@export_range(-100, 100) var attack_threshold:int = -50
## Response to combat. [br]
## Coward: Flees from combat. [br]
## Cautious: Cautious: Will flee unless stronger than target. [br]
## Average: Will fight unless outmatched. [br]
## Brave: Will fight unless very outmatched. [br]
## Foolhardy: Will never flee.
@export_enum("Coward", "Cautious", "Average", "Brave", "Foolhardy") var confidence:int = 2
## Response to witnessing combat. [br]
## Helps Nobody: Does not help anybody. [br]
## Helps people: Helps people above [member assistance_threshold].
@export_enum("Helps nobody", "Helps people") var assistance:int = 1
## If [member assistance] is "Helps people", it will assist entities with an opinion above this threshold.
@export_range(-100, 100) var assistance_threshold:int = 0
## How NPCs behave when hit by friends. [br]
## Neutral: Aggro friends immediately when hit. [br]
## Friend: During combat, won't attack player unless hit a number of times in an amount of time. Outside of combat, it will aggro the friendly immediately. [br]
## Ally: During combat, will ignore all attacks from friend. Outside of combat, behaves in the same way is "Friend" in combat. [br]
@export_enum("Neutral", "Friend", "Ally") var friendly_fire_behavior:int = 1

@export var warn_radius:float = 20
@export var attack_radius:float = 8

## Thread for an NPC to keep watch when alerted
var vigilant_thread:Thread
## Set to true to stop [memer vigilant_thread]
var pull_out_of_thread = false


func _initialize() -> void:
	_npc.perception_transition.connect(_handle_perception_info.bind())
	_npc.hit_by.connect(func(who): _aggress(EntityManager.instance.get_entity(who).unwrap()))


func _handle_perception_info(what:StringName, transition:String, fsm:PerceptionFSM_Machine) -> void:
	var opinion = _npc.determine_opinion_of(what)
	print("----------")
	print("handling perception info")
	print("Opinion on %s: %s" % [what, opinion])
	var below_attack_threshold = (opinion <= attack_threshold) or aggression == 3 # will be below attack threshold by default if frenzied

	match transition:
		"AwareInvisible":
			if aggression == 0: # if peaceful
				return
			# if threat, seek last known position
			if below_attack_threshold:
				print("seek last known position")
				_npc.goap_memory["last_seen_position"] = NavPoint.new(fsm.last_seen_world, fsm.last_seen_position) # commit to memory
				_npc.add_objective({"enemy_sought" = true}, true, 10) # add goal to seek position
		"AwareVisible":
			if aggression == 0: # if peaceful
				return

			if below_attack_threshold: # if attack threshold or frenzied
				if not _npc.in_combat:
					print("start vigilance")
					var e = EntityManager.instance.get_entity(what).unwrap()

					# attack immediately if frenzied
					if aggression == 3:
						_begin_attack(e)
						return

					_enter_vigilant_stance()
					if vigilant_thread:
						pull_out_of_thread = true
						vigilant_thread.wait_to_finish()
					vigilant_thread = Thread.new()
					vigilant_thread.start(_stay_vigilant.bind(e))
				else:
					print("needs to attack")
		"Lost":
			# may be useless
			return
		"Unaware":
			if aggression == 0: # if peaceful
				return

			# if threat, do "huh?" behavior
			if below_attack_threshold:
				print("needs to investigate")
				# TODO: Stop, investigate
				return


## Will keep watch until the entity is out of range. TODO: Visibility?
func _stay_vigilant(e:Entity) -> void:
	# may need to change the order of this, im not sure where to put it yet
	if _npc.in_combat: # don't react if already in combat
		_add_enemy(e)
		return

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
		# if within ring and not player, attack
		if distance_to_e <= attack_radius ** 2 and not e.get_component("PlayerComponent").some():
			print("frenzied immediate attack")
			_begin_attack(e)
			return
		# if frenzied and within ring attack immediately
		if distance_to_e <= warn_radius ** 2 and aggression == 3:
			print("frenzied immediate attack")
			_begin_attack(e)
			return
		# if within warn ring
		if distance_to_e <= warn_radius ** 2 and distance_to_e > attack_radius ** 2:
			# if not already warned, warn and set warned
			if not warned:
				print("become warned")
				_warn(e)
				warned = true
		# if in attack distance, attack
		if distance_to_e <= attack_radius ** 2:
			print("in attack distance")
			_begin_attack(e)
			return


func _begin_attack(e:Entity) -> void:
	# figure out response to confrontation
	print("beginning attack")
	match aggression:
		0: # Peaceful
			print("peaceful response")
			return
		1: # Bluffing
			print("bluffing response")
			_flee(e)
		2, 3:
			# Add to goap memory
			print("aggressive/frenzied response")
			_npc.in_combat = true
			_add_enemy(e)
			# This will begin combat, because NPCs have a recurring goal where all enemies must be dead


func _add_enemy(e:Entity) -> void:
	if _npc.goap_memory.has("enemies"):
		if not _npc.goap_memory["enemies"].has(e.name):
			_npc.goap_memory["enemies"].append(e)
	else:
		_npc.goap_memory["enemies"] = [e.name]
		_npc._goap_component.interrupt() # interrupt current task if entering combat


func _warn(e:Entity) -> void:
	# Issue warning to entity
	print("warning!")
	_npc.warning.emit(e.name)


func _enter_normal_state() -> void:
	# undo vigilant stance
	print("exit vigilant stance")
	return


func _enter_vigilant_stance() -> void:
	# draw weapons, turn towards threat
	print("enter vigilant stance")


func _flee(e:Entity) -> void:
	# tell GOAP to flee from enemies
	print("flee")
	_npc.add_objective({"flee_from_enemies" : true}, true, 10)
	_npc.flee.emit(e.name)


## Response to being hit.
func _aggress(e:Entity) -> void:
	# "Coward", "Cautious", "Average", "Brave", "Foolhardy"
	# TODO: Friendly fire
	var threat = _determine_threat(e)
	match confidence:
		0: # Coward - flee
			_flee(e)
			return
		1: # Cautious - only attack if target weaker
			if threat == -1:
				_begin_attack(e)
				return
			else:
				_flee(e)
				return
		2: # Average - attack if evenly matched or stronger
			if threat <= 0:
				_begin_attack(e)
				return
			else:
				_flee(e)
				return
		3: # Brave - Fight unless significantly outmatched
			if threat <= 1:
				_begin_attack(e)
				return
			else:
				_flee(e)
				return
		4: # Foolhardy - always attack, no matter the threat
			_begin_attack(e)
			return


## Determines the threat level of another entity by conparing levels in a [SkillsComponent]. Returns: [br]
## -1: Weaker [br]
## 0: About the same or no skills component [br]
## 1: Stronger [br]
## 2: Significantly stronger [br]
## See [constant THREAT_LEVEL_WEAKER_INTERVAL], [constant THREAT_LEVEL_GREATER_INTERVAL], [constant THREAT_LEVEL_MUCH_GREATER_INTERVAL]
func _determine_threat(e:Entity) -> int:
	var e_sc = e.get_component("SkillsComponent")
	# if no skills component associated with the entity, default is 0
	if not e_sc.some():
		return 0

	var npc_level = _npc.parent_entity.get_component("SkillsComponent").unwrap().level
	var e_level = e_sc.unwrap().level
	var difference = e_level - npc_level # negative is weaker

	# Check if it's a bit weaker
	if difference < -THREAT_LEVEL_WEAKER_INTERVAL:
		return -1
	# Check for much greater
	if difference > THREAT_LEVEL_MUCH_GREATER_INTERVAL:
		return 2
	# Then check for a bit greater
	if difference > THREAT_LEVEL_GREATER_INTERVAL:
		return 1
	# Else about the same
	return 0


func _clean_up() -> void:
	if vigilant_thread:
		vigilant_thread.wait_to_finish()
