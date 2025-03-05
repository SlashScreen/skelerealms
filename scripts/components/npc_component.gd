@tool
class_name NPCComponent
extends SKEntityComponent
## The brain for an NPC that handles AI behavior, scheduling, combat, and dialogue interactions.
## This component provides the base functionality for NPCs, including opinion systems, combat states, and AI hooks.
## Requires additional AI modules to define specific behaviors.
##
## For detailed information, see:
## [url]https://github.com/SlashScreen/skelerealms/wiki/NPCs[/url]
## [url]https://github.com/SlashScreen/skelerealms/wiki/NPCs#opinions-and-how-the-npc-determines-its-opinions[/url]

@export_category("Flags")
## Whether this NPC is essential to the story and cannot be permanently killed
@export var essential:bool = true
## Whether this NPC is a ghost and has special interaction rules
@export var ghost:bool
## Whether this NPC is immune to all forms of damage
@export var invulnerable:bool
## Whether this NPC is a unique character rather than a generic NPC
@export var unique:bool = true
## Whether this NPC contributes to the player's stealth detection
@export var affects_stealth_meter:bool = true
## Whether this NPC can be interacted with through dialogue or other means
@export var interactive:bool = true

@export_category("AI")
## Array of relationship definitions that determine how this NPC relates to others
@export var relationships:Array[Relationship]
## List of component types that this NPC will consider as potential threats
@export var threatening_enemy_types = [
	"NPCComponent",
	"PlayerComponent",
]
## Dictionary mapping entity IDs to opinion values
@export var npc_opinions = {}
## Determines how the NPC weighs different factors when calculating opinions
## [br]0: No loyalty - purely individual opinions
## [br]1: Coven loyalty - considers coven relationships
## [br]2: Self loyalty - prioritizes self-interest
@export_enum("None", "Covens", "Self") var loyalty:int = 0
## Method used to resolve multiple opinion values into a final opinion
## [br]0: Use lowest opinion value
## [br]1: Use highest opinion value
## [br]2: Take average of all opinions
@export_enum("Minimum", "Maximum", "Average") var opinion_mode:int = 0

## The NPC's current opinion of the player
var player_opinion:int
## Minimum visibility level required for the NPC to detect entities
var visibility_threshold:float = 0.3
## Memory storage used by the GOAP AI system to track world state
var goap_memory:Dictionary = {}

## Whether the NPC is currently in combat state
var in_combat:bool:
	get:
		return in_combat
	set(val):
		if val and not in_combat:
			printe("entering combat")
			entered_combat.emit()
		elif not val and in_combat:
			printe("leaving combat")
			left_combat.emit()
		in_combat = val

## Current navigation point the NPC is moving towards
var _current_target_point:NavPoint:
	set(val):
		_current_target_point = val
		if _puppet:
			_puppet.set_movement_target(val.position)
	get:
		return _current_target_point

## List of AI modules that control this NPC's behavior
var ai_modules:Array[AIModule] = []
## Dictionary storing information about entities the NPC has seen and their visibility status
var perception_memory:Dictionary = {}

## The NPC's navigation component for pathfinding
var _nav_component:NavigatorComponent
## Component that manages the NPC's physical representation in the world
var _puppet_component:PuppetSpawnerComponent
## Component that handles player interactions with this NPC
var _interactive_component:InteractiveComponent
## Component that handles GOAP-based AI planning
var _goap_component:GOAPComponent
## The current schedule event this NPC is following
var _current_schedule_event:ScheduleEvent
## The NPC's schedule of activities and behaviors
var _schedule:Schedule
## Current simulation detail level for this NPC
var _sim_level:SimulationLevel = SimulationLevel.FULL
## Indices of doors along the NPC's current path for cross-world navigation
var _doors_in_path:Array[int] = []
## Distance threshold for considering a path point reached
var _path_follow_end_distance:float = 1
## Movement speed when navigating between worlds
var _walk_speed:float = 1
## The NPC's physical puppet node in the world
var _puppet:NPCPuppet
## Reference ID of the current combat target
var _combat_target:String
## Current navigation path as array of points
var _path:Array[NavPoint]

## Whether the NPC is busy in dialogue/cutscene/combat
var _busy:bool:
	get:
		return _busy or in_combat
	set(val):
		printe("Set busy to %s" % val)
		if val and _puppet:
			_puppet.pause_nav()
		elif not val and _puppet:
			_puppet.continue_nav()
		_busy = val

## Emitted when the NPC enters combat state
signal entered_combat
## Emitted when the NPC leaves combat state
signal left_combat
## Emitted when the NPC first detects the player
signal start_saw_player
## Emitted when the NPC loses sight of the player
signal end_saw_player
## Emitted when the NPC reaches its current navigation target
signal destination_reached
## Emitted when the NPC's schedule is updated with a new event
signal schedule_updated(ev:ScheduleEvent)
## Emitted when the NPC enters a dialogue interaction
signal start_dialogue
## Emitted when the NPC's awareness of an entity changes (for stealth)
signal awareness_state_changed(ref_id:String, state:int)
## Emitted when the NPC decides to flee from an entity
signal flee(ref_id:String)
## Emitted when the NPC detects an audio event in the world
signal heard_something(emitter:AudioEventEmitter)
## Emitted when a player or other entity interacts with this NPC
signal interacted(refID:String)
## Emitted when the NPC is hit by a friendly entity
signal friendly_fire_response
## Emitted when the NPC should draw its weapons
signal draw_weapons
## Emitted when the NPC should sheathe its weapons
signal put_away_weapons
## Emitted when the NPC takes damage from an entity
signal hit_by(who:String)
## Emitted when the NPC takes a specific type of damage
signal damaged_with_effect(effect:StringName)
## Emitted when the NPC joins a conversation
signal added_to_conversation
## Emitted when the NPC leaves a conversation
signal removed_from_conversation
## Emitted when the NPC witnesses a crime being committed
signal crime_witnessed
## Emitted when the NPC updates its state
signal updated(delta:float)
## Emitted when the NPC's puppet requests to move
signal puppet_request_move(puppet:NPCPuppet)
## Emitted when the NPC's puppet requests to draw weapons
signal puppet_request_raise_weapons(puppet:NPCPuppet)
## Emitted when the NPC's puppet requests to sheathe weapons
signal puppet_request_lower_weapons(puppet:NPCPuppet)

## Returns the NPCComponent for an entity with the given ID, or null if not found
static func get_npc_component(id:StringName) -> NPCComponent:
	var eop = SKEntityManager.instance.get_entity(id)
	if not eop:
		return null
	var icop = eop.get_component("NPCComponent")
	if icop:
		return icop
	else:
		return null


#region perception


## Returns a dictionary of objects currently visible to this NPC through its puppet's vision system.
## Returns an empty dictionary if the NPC has no puppet or vision system.
func get_visible_objects() -> Dictionary:
	if _puppet == null:
		return {}
	if _puppet.eyes == null:
		return {}
	return _puppet.eyes.get_visible_objects()


#endregion perception

#region overrides


func _init() -> void:
	name = &"NPCComponent"


func _ready():
	if Engine.is_editor_hint():
		return 
	
	super._ready()
	
	# Initialize all AI Modules
	var modules:Array[AIModule] = []
	for module:Node in get_children():
		if not module is AIModule:
			continue
		modules.append(module)

	_nav_component = parent_entity.get_component("NavigatorComponent") as NavigatorComponent
	_puppet_component = parent_entity.get_component("PuppetSpawnerComponent") as PuppetSpawnerComponent
	_interactive_component = parent_entity.get_component("InteractiveComponent") as InteractiveComponent
	_goap_component = parent_entity.get_component("GOAPComponent") as GOAPComponent
	_interactive_component.interacted.connect(func(x:String): interacted.emit(x))
	
	# sync nav agent
	_puppet_component.spawned_puppet.connect(func(x:Node):
		_puppet = x as NPCPuppet
		_goap_component._agent = (x as NPCPuppet).navigation_agent
		)
	_puppet_component.despawned_puppet.connect(func():
		_puppet = null
		_goap_component._agent = null
		)
	# schedule
	var s := get_node_or_null("Schedule")
	if s:
		_schedule = s
	else:
		var n := Schedule.new()
		n.name = "Schedule"
		add_child(n)
		_schedule = n
	# misc setup
	_interactive_component.translation_callback = get_translated_name.bind()
	
	GameInfo.minute_incremented.connect(_calculate_new_schedule.bind())
	for a:AIModule in modules:
		a.initialize()


func _on_enter_scene():
	_sim_level = SimulationLevel.FULL


func _on_exit_scene():
	_sim_level = SimulationLevel.GRANULAR


func _process(delta):
	if Engine.is_editor_hint():
		return
	#* Section 1: Path following
	# If in scene, use navmesh agent.
	if _current_target_point:
		if parent_entity.in_scene:
			if _puppet.target_reached: # If puppet reached target
				_next_point()
		else: # If not in scene, move between points.
			if parent_entity.position.distance_to(_current_target_point.position) < _path_follow_end_distance: # if reached point
				_next_point() # get next point
				parent_entity.world = _current_target_point.world # set world
			parent_entity.position = parent_entity.position.move_toward(_current_target_point.position, delta * _walk_speed) # move towards position
	
	if _puppet:
		if _puppet.eyes:
			var d:Dictionary = _puppet.eyes.get_visible_objects()
			for obj:Object in d:
				if obj is not Node:
					continue
				var e:SKEntity = SkeleRealmsGlobal.get_entity_in_tree(obj)
				if not e:
					continue 
				
				if perception_memory.has(e.name):
					perception_memory[e.name][&"visibility"] = d[obj][&"visibility"]
					perception_memory[e.name][&"last_seen_position"] = d[obj][&"last_seen_position"]
				else:
					perception_memory[e.name] = {
						&"visibility": d[obj][&"visibility"],
						&"last_seen_position": d[obj][&"last_seen_position"],
					}
	
	updated.emit(delta)

## Returns a list of required component dependencies for this NPC
func get_dependencies() -> Array[String]:
	return [
		"InteractiveComponent",
		"PuppetSpawnerComponent",
		"NavigatorComponent",
		"GOAPComponent",
	]


func _exit_tree() -> void:
	for m in ai_modules:
		m._clean_up()

#endregion overrides

#region dialogue


## Makes the NPC exit from its current dialogue interaction
func leave_dialogue() -> void:
	_busy = false


## Requests the NPC to interact with an entity by its reference ID
## [param refID] The reference ID of the entity to interact with
func interact_with(refID:String) -> void:
	goap_memory["interact_target"] = refID
	add_objective ( # Add goal to interact with an object.
		{"interacted" : true},
		true,
		2
	)


## Signals that the NPC has joined a conversation
func add_to_conversation() -> void:
	added_to_conversation.emit()


## Signals that the NPC has left a conversation
func remove_from_conversation() -> void:
	removed_from_conversation.emit()


#endregion dialogue

#region pathfinding


## Calculates and sets a path for the NPC to follow to reach a destination
## [param dest] The navigation point to pathfind to
func set_destination(dest:NavPoint) -> void:
	# Recalculate path
	_path = _nav_component.calculate_path_to(dest)
	# if no path calculated, try to set it to the destination for the navigation master
	if parent_entity.in_scene and _path.size() == 0 and dest.world == parent_entity.world:
		_current_target_point = dest
		return
	# detect any doors
	for i in range(_path.size() - 1):
		if not _path[i].world == _path[i + 1].world: # if next world that isnt this world then it is a door
			_doors_in_path.append(i)
	# set current point
	_next_point()


## Advances the NPC to the next point in its calculated path
## Handles special cases for in-scene vs out-of-scene movement and door transitions
func _next_point() -> void:
	# return early if the path has no elements
	if _path.size() == 0:
		return

	if not parent_entity.in_scene: # if we arent in scene, we follow the path exactly
		_current_target_point = _pop_path()
		return

	# we do this rigamarole because it will look weird if an NPC follows the granular path exactly
	if _doors_in_path.size() > 0: # if we have doors
		var next_door:int = _doors_in_path[0] # get next door
		if _path[next_door].position.distance_to(parent_entity.position) < ProjectSettings.get_setting("skelerealms/actor_fade_distance"): # TODO: fine tune these
			# if the next door is close enough, jsut go to it next because it will look awkward following the path
			# skip all until door
			# TODO: Interact with door?
			for i in range(next_door): # this will make the target point the door
				_current_target_point = _pop_path()
			return
	else: # if we dont have doors (we can assume that the destination is in same world
		if _path.back().position.distance_to(parent_entity.position) < ProjectSettings.get_setting("skelerealms/actor_fade_distance"):
			# if the last point is close enough, skip all until until last
			_current_target_point = _path.back()
			# clear path
			_path.clear()
			_doors_in_path.clear()
			return


## Calculates the total length of a path segment in meters
## Doors are treated as having zero distance since they connect the same space
## [param slice] Array of navigation points to measure
## Returns: The total path length in meters
func _get_path_length(slice:Array[NavPoint]) -> float:
	if slice.size() < 2: # if 0 or 1 length is 0
		return 0
	# else total everything
	var accum:float = 0
	for i in range(slice.size() - 1):
		if slice[i].world == slice[i + 1].world:
			accum += slice[i].position.distance_to(slice[i + 1].position)
	return accum


## Removes and returns the next point in the path, updating door indices
## Returns: The next navigation point in the path
func _pop_path() -> NavPoint:
	_doors_in_path = _doors_in_path\
						.map(func(x:int): return x-1)\
						.filter(func(x:int): return x >= 0)
	return _path.pop_front()


## Adds a new objective for the NPC's GOAP planner
## [param goals] Dictionary of world states that define the objective
## [param remove_after_satisfied] Whether to remove the objective once completed
## [param priority] Priority level of this objective (higher = more important)
func add_objective(goals:Dictionary, remove_after_satisfied:bool, priority:float):
	_goap_component.add_objective(goals, remove_after_satisfied, priority)


## Removes objectives that exactly match the given goal states
## [param goals] Dictionary of goal states to match against
func remove_objective_by_goals(goals:Dictionary) -> void:
	_goap_component.remove_objective_by_goals(goals)


#endregion pathfinding

#region schedule


## Directs the NPC to move to its current schedule location
## Will not recalculate if already at the correct location
func go_to_schedule_point() -> void:
	# Resolve schedule
	_calculate_new_schedule()

	# Don't recalculate if we are already at point
	if _current_schedule_event.satisfied_at_location(parent_entity):
		return

	# Go to the schedule point
	var loc = _current_schedule_event.get_event_location()
	if loc:
		_current_target_point = loc


## Updates the NPC's current schedule based on game time
## Only processes if the NPC is being simulated
func _calculate_new_schedule() -> void:
	# Don't do this if we are not being simulated.
	if _sim_level == SimulationLevel.NONE:
		return

	var ev = _schedule.find_schedule_activity_for_current_time() # Scan schedule
	if ev.some():
		if not ev.unwrap() == _current_schedule_event:
			if _current_schedule_event:
				_current_schedule_event.on_event_ended()

			_current_schedule_event = ev.unwrap()

			if _current_schedule_event.has_method("attach_npc"):
				_current_schedule_event.attach_npc(self)
			_current_schedule_event.on_event_started()
			schedule_updated.emit(_current_schedule_event)
	else:
		# Else we have no schewdule for this time period
		_current_schedule_event = null
		schedule_updated.emit(null)


#endregion schedule 

#region misc


## Finds a relationship of the specified type in this NPC's relationships
## [param key] The relationship type key to search for
## Returns: Option containing the relationship if found, none if not found
func get_relationship_of_type(key:String) -> Option:
	var res = relationships.filter(func(r:Relationship): return r.relationship_type and r.relationship_type.relationship_key == key)
	if res.is_empty():
		return Option.none()
	return Option.from(res[0])


## Finds this NPC's relationship with another entity
## [param ref_id] The reference ID of the other entity
## Returns: Option containing the relationship if found, none if not found
func get_relationship_with(ref_id:String) -> Option:
	var res = relationships.filter(func(r:Relationship): return r.relationship_type and r.other_person == ref_id)
	if res.is_empty():
		return Option.none()
	return Option.from(res[0])


## Calculates this NPC's opinion of another entity based on various factors
## Takes into account:
## - Coven relationships and crimes
## - Personal opinions
## - Loyalty settings
## [param id] The reference ID of the entity to evaluate
## Returns: A float representing the opinion (-100 to 100)
func determine_opinion_of(id:StringName) -> float:
	var e:SKEntity = SKEntityManager.instance.get_entity(id)

	if not threatening_enemy_types.any(func(x:String): return not e.get_component(x) == null):
		return 0

	var e_cc = e.get_component("CovensComponent")
	var opinions = []
	var opinion_total = 0

	# calculate modifiers
	var covens_modifier = 2 if loyalty == 1 else 1
	var self_modifier = 2 if loyalty == 2 else 1

	# if has other covens, compare against ours
	if e_cc:
		var covens = parent_entity.get_component("CovensComponent").covens
		var covennpc_opinions_unfiltered = []
		var e_covens_component = e_cc

		# get all opinions
		for coven in covens:
			var c = CovenSystem.get_coven(coven)
			covennpc_opinions_unfiltered.append_array(c.get_covennpc_opinions(e_covens_component.covens.keys()))
			opinions.append(CrimeMaster.max_crime_severity(id, coven) * -10)

		opinions.append_array(covennpc_opinions_unfiltered.filter(func(x:int): return not x == 0))
		opinion_total += opinions.size() * covens_modifier
	# if has an opinion of the player, take into account
	if npc_opinions.has(id) and not npc_opinions[id] == 0:
		opinions.append(npc_opinions[id])
		opinion_total += self_modifier

	# Return weighted average based on opinion mode
	match opinion_mode:
		0: # Minimum
			var o:Variant = opinions.min()
			return 0.0 if o == null else o
		1: # Maximum
			var o:Variant = opinions.max()
			return 0.0 if o == null else o
		2: # Average
			return opinions.reduce(func(sum, next): return sum + next, 0) / (1 if opinion_total == 0 else opinion_total)
		_:
			return 0.0


## Gathers debug information about the NPC's current state
## Returns: A formatted string containing current values of important variables
func gather_debug_info() -> String:
	return """
[b]NPCComponent[/b]
	Visibility threshold: %s
	In combat: %s
	Busy: %s
	GOAP Memory: %s
	Current Target Point: %s
	Path: %s
	Simulation Level: %s
""" % [
	visibility_threshold,
	in_combat,
	_busy,
	goap_memory,
	_current_target_point,
	_path,
	_sim_level
]


## Gets the translated name of this NPC
## First tries to translate the entity name, then falls back to form_id translation
## Returns: The translated name string
func get_translated_name() -> String:
	var t = tr(parent_entity.name)
	if t == parent_entity.name:
		if parent_entity.form_id.is_empty():
			return parent_entity.name
		else:
			return tr(parent_entity.form_id)
	else:
		return t

#endregion misc

## Defines the different simulation detail levels for NPCs based on their distance from the player
enum SimulationLevel {
	## NPC is in the active scene - full AI, physics, and animation
	FULL,
	## NPC is outside the active scene but within simulation range - simplified movement and behavior
	GRANULAR,
	## NPC is outside simulation range - completely inactive
	NONE,
}
