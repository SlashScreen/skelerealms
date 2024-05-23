class_name NPCComponent
extends SKEntityComponent
## The brain for an NPC. Handles AI behavior, scheduling, combat, dialogue interactions.
## The component itself is a blank slate, being comprised largely of state trackers and utility functions, and will likely do nothing without an [AIModule] to determine its behavior.
## It also has aobut a million signals that AI modules, the GOAP system, animation controllers, dialogue systems, etc. can hook into. Think of them as an API.
## @tutorial(In-depth look at the NPC system): https://github.com/SlashScreen/skelerealms/wiki/NPCs
## @tutorial(In-depth view of opinion system): https://github.com/SlashScreen/skelerealms/wiki/NPCs#opinions-and-how-the-npc-determines-its-opinions


@export_category("Flags")
## Whether this NPC is essential to the story, and them dying would screw things up.
@export var essential:bool = true
## Whether this NPC is a ghost.
@export var ghost:bool
## Whether this NPC can't take damage.
@export var invulnerable:bool
## Whether this NPC is unique.
@export var unique:bool = true
## Whether this NPC affects the stealth meter when it sees you.
@export var affects_stealth_meter:bool = true
## Whether you can interact with this NPC.
@export var interactive:bool = true
## NPC relationships.
@export var relationships:Array[Relationship]
@export_category("AI")
## Component types that the AI will looks for to determine threats. 
@export var threatening_enemy_types = [
	"NPCComponent",
	"PlayerComponent",
]
## Opinions of entities. StringName:float
@export var npc_opinions = {}
## Loyalty of this NPC. Determines weights of opinion calculations.
@export_enum("None", "Covens", "Self") var loyalty:int = 0
## How the opinion of something is calculated.
@export_enum("Minimum", "Maximum", "Average") var opinion_mode:int = 0

#* Public
var player_opinion:int
var visibility_threshold:float = 0.3
## Stores data of interest for GOAP to access.
var goap_memory:Dictionary = {}
#* Properties
var in_combat:bool:
	get:
		return in_combat
	set(val):
		if val and not in_combat: # these checks prevent spamming
			printe("entering combat")
			entered_combat.emit()
		elif not val and in_combat:
			printe("leaving combat")
			left_combat.emit()
		in_combat = val
var _current_target_point:NavPoint:
	set(val):
		_current_target_point = val
		if _puppet:
			_puppet.set_movement_target(val.position)
	get:
		return _current_target_point
## Whether this character is in dialogue or a cutscene or in combat. Will stop/continue the puppet's pathfinding if applicable (not in combat).
var _busy:bool:
		get:
			return _busy or in_combat # is also busy if in combat
		set(val):
			printe("Set busy to %s" % val)
			if val and _puppet:
				_puppet.pause_nav()
			elif not val and _puppet:
				_puppet.continue_nav()
			_busy = val
var ai_modules:Array[AIModule] = []
#* Private
## Navigator.
var _nav_component:NavigatorComponent
## Puppet manager component.
var _puppet_component:PuppetSpawnerComponent
## Interactive component.
var _interactive_component:InteractiveComponent
## Behavior planner.
var _goap_component:GOAPComponent
## The schedule event the NPC is following, if applicable.
var _current_schedule_event:ScheduleEvent
## Scheduler node.
var _schedule:Schedule
## Simulation level of the npc.
var _sim_level:SimulationLevel = SimulationLevel.FULL
## Indexes of the doors in the current path. THis is important to keeo track of due to the nature of doors going between worlds.
var _doors_in_path:Array[int] = []
## How close to a path marker the NPC must be to have reached it.
var _path_follow_end_distance:float = 1
## Off-world navigation walk speed.
var _walk_speed:float = 1
## Puppet root node.
var _puppet:NPCPuppet
## References to FSMs keeping track of entites it has seen. Pattern is refID:String : machine:[PerceptionFSM_Machine].
var _perception_memory:Dictionary = {}
## Target entity during combat.
var _combat_target:String
## Navigation path.
var _path:Array[NavPoint]



## Signal emitted when this NPC enters combat.
signal entered_combat
## Signal emitted when this NPC leaved combat.
signal left_combat
## Signal emitted when it starts to see the player.
signal start_saw_player
## Signal emitted when it stops seeing the player.
signal end_saw_player
## Signal emitted when it reaches its target destination.
signal destination_reached
## Signal emitted when its schedule has been updated.
signal schedule_updated(ev:ScheduleEvent)
## Signal emitted when this NPC enters dialogue.
signal start_dialogue
## Signal emitted when it warns an entity. Passes ref id of who it is warning.
signal warning(ref_id:String)
## Signal emitted when it wants to flee from an entity. Passes ref id of who it is warning.
signal flee(ref_id:String)
## Signal emitted when it hears an audio event.
signal heard_something(emitter:AudioEventEmitter)
## Signal emitted when a perception state changes.
signal perception_transition(what:StringName, transitioned_to:String, fsm:PerceptionFSM_Machine)
## Signal emitted when this NPC is interacted with.
signal interacted(refID:String)
## Signal emitted when this NPC reacts to being hit by a friendly entity.
signal friendly_fire_response
## Signal emitted when the NPC wants to draw weapons.
signal draw_weapons
## Signal emitted when the NPC wants to put away its weapons.
signal put_away_weapons
## Signal emitted when the NPC is hit by somebody.
signal hit_by(who:String)
## Signal emitted when the NPC is hit with a particular damage effect - blunt, piercing, magic, etc.
signal damaged_with_effect(effect:StringName)
## Signal emitted when the NPC is added to a conversation.
signal added_to_conversation
## Signal emitted when the NPC is removed from a conversation.
signal removed_from_conversation
## Signal emitted when a crime is witnessed
signal crime_witnessed 
signal updated(delta:float)
signal puppet_request_move(puppet:NPCPuppet)
signal puppet_request_raise_weapons(puppet:NPCPuppet)
signal puppet_request_lower_weapons(puppet:NPCPuppet)


## Shorthand to get an npc component for an entity by ID.
static func get_npc_component(id:StringName) -> NPCComponent:
	var eop = SKEntityManager.instance.get_entity(id)
	if not eop:
		return null
	var icop = eop.get_component("NPCComponent")
	if icop:
		return icop
	else:
		return null


#* ### OVERRIDES


func _ready():
	super._ready()
	
	# Initialize all AI Modules
	var modules:Array[AIModule] = []
	for module:Node in get_children():
		if not module is AIModule:
			continue
		modules.append(module)
	# FIXME: Parent entity can be instantiated called BEFORE this.


func _entity_ready() -> void:
	_nav_component = $"../NavigatorComponent" as NavigatorComponent
	# Puppet manager component.
	_puppet_component = $"../PuppetSpawnerComponent" as PuppetSpawnerComponent
	# Interactive component.
	_interactive_component = $"../InteractiveComponent" as InteractiveComponent
	# Behavior planner.
	_goap_component = $"../GOAPComponent" as GOAPComponent
	($"../InteractiveComponent" as InteractiveComponent).interacted.connect(func(x:String): interacted.emit(x))
	
	# sync nav agent
	_puppet_component.spawned_puppet.connect(func(x:Node):
		_puppet = x as NPCPuppet
		_goap_component._agent = (x as NPCPuppet).navigation_agent
		)
	_puppet_component.despawned_puppet.connect(func():
		_puppet = null
		_goap_component._agent = null
		)
	
	# misc setup
	_interactive_component.translation_callback = get_translated_name.bind()
	
	GameInfo.minute_incremented.connect(_calculate_new_schedule.bind())


func _on_enter_scene():
	_sim_level = SimulationLevel.FULL


func _on_exit_scene():
	_sim_level = SimulationLevel.GRANULAR


func _process(delta):
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

	updated.emit(delta)


func _exit_tree() -> void:
	for m in ai_modules:
		m._clean_up()


#* ### DIALOGUE AND INTERACTIVITY


## Make this NPC Leave dialogue.
func leave_dialogue() -> void:
	_busy = false


## Ask this NPC to interact with something.
func interact_with(refID:String) -> void:
	goap_memory["interact_target"] = refID
	add_objective ( # Add goal to interact with an object.
		{"interacted" : true},
		true,
		2
	)


func add_to_conversation() -> void:
	added_to_conversation.emit()


func remove_from_conversation() -> void:
	removed_from_conversation.emit()


#* ### PATHFINDING


## Calculate this NPC's path to a [NavPoint].
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


## Make the npc go to the next point in its path
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


## Gets the length of a slice of the path in meters. Doors are considered to be 0 distance, since they are different sides of the same object, at least theoretically.
func _get_path_length(slice:Array[NavPoint]) -> float:
	if slice.size() < 2: # if 0 or 1 length is 0
		return 0
	# else total everything
	var accum:float = 0
	for i in range(slice.size() - 1):
		if slice[i].world == slice[i + 1].world:
			accum += slice[i].position.distance_to(slice[i + 1].position)
	# maybe square root everything after, and use distance_to_squared?
	return accum


## Pop the next path value. Also shifts [member _doors_in_path] to match that.
func _pop_path() -> NavPoint:
	_doors_in_path = _doors_in_path\
						.map(func(x:int): return x-1)\
						.filter(func(x:int): return x >= 0) # shift doors forward and remove ines that have passed
	return _path.pop_front() # may be reversed, i dont remember


## Add a Goap objective.
func add_objective(goals:Dictionary, remove_after_satisfied:bool, priority:float):
	_goap_component.add_objective(goals, remove_after_satisfied, priority)


## Remove objectives that have a set of goals. Goals must match exactly.
func remove_objective_by_goals(goals:Dictionary) -> void:
	_goap_component.remove_objective_by_goals(goals)


#* ### PERCEPTION


## Callback for when percpetion begins
func on_percieve_start(info:EyesPerception.PerceptionData) -> void:
	if _perception_memory.has(info.object):
		# if we have it, then update the perception info
		_perception_memory[info.object].visibility = info.visibility
	else:
		# if we don't, add new fsm
		var fsm:PerceptionFSM_Machine = PerceptionFSM_Machine.new(info.object, info.visibility)
		add_child(fsm)
		fsm.transitioned.connect(func(x:String): perception_transition.emit(info.object, x, fsm))
		fsm.initial_state = "Unaware"
		fsm.setup([
			PerceptionFSM_Aware_Invisible.new(),
			PerceptionFSM_Aware_Visible.new(),
			PerceptionFSM_Lost.new(),
			PerceptionFSM_Unaware.new(),
		])
		_perception_memory[info.object] = fsm


# TODO: Special behavior for going through doors, since the "last seen position" would be at the door.
# Perhaps if on perception end and in different world, force it through?
#! What happpens when the puppet is despawned?
## Callback for when something leaves sightline.
func on_percieve_end(info:EyesPerception.PerceptionData) -> void:
	if _perception_memory.has(info.object):
		# if we have it, set perception to 0 (hidden)
		_perception_memory[info.object].visibility = 0


## Callback for when this npc hears a weird noise.
func on_hear_audio(emitter:AudioEventEmitter) -> void:
	heard_something.emit(emitter)


## Forget an entity from the perception memory.
func perception_forget(who:String) -> void:
	if not _perception_memory.has(who):
		return
	var n:Node = _perception_memory[who]
	_perception_memory.erase(who)
	n.queue_free()


## Get all items this entity remembers seeing.
func get_remembered_items() -> Array[String]:
	return _perception_memory.keys()\
			.filter(func(p:String):
				var e = SKEntityManager.instance.get_entity(p)
				if e.some():
					return not (e.unwrap as SKEntity).get_component("ItemComponent") == null
				return false
				)


func can_see_entity(id:StringName) -> bool:
	if not parent_entity.in_scene:
		return false
	if not _perception_memory.has(id):
		return false
	return (_perception_memory[id] as PerceptionFSM_Machine).state._get_state_name() == "AwareVisible"


#* ### SCHEDULE


## Ask this NPC to go to its schedule point.
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


## Get the current schedule for this NPC.
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


#* ### MISC


## Get a relationship this NPC has of [RelationshipType]. Pass in the type's key. Returns the relationship if found, none if none found.
func get_relationship_of_type(key:String) -> Option:
	var res = relationships.filter(func(r:Relationship): return r.relationship_type and r.relationship_type.relationship_key == key)
	if res.is_empty():
		return Option.none()
	return Option.from(res[0])


## Gets this NPC's relationship with someone by ref id. Returns the relationship if found, none if none found.
func get_relationship_with(ref_id:String) -> Option:
	var res = relationships.filter(func(r:Relationship): return r.relationship_type and r.other_person == ref_id)
	if res.is_empty():
		return Option.none()
	return Option.from(res[0])


## Determines the opinion of some entity. See the tutorial in the class docs for a more in-depth look at NPC opinions.
func determine_opinion_of(id:StringName) -> float:
	var e:SKEntity = SKEntityManager.instance.get_entity(id)

	if not threatening_enemy_types.any(func(x:String): return not e.get_component(x) == null): # if it doesn't have any components that are marked as threatening, return neutral.
		return 0

	var e_cc = e.get_component("CovensComponent")
	var opinions = []
	var opinion_total = 0

	# calculate modifiers
	var covens_modifier = 2 if loyalty == 1 else 1 # if values covens, increase modifier
	var self_modifier = 2 if loyalty == 2 else 1 # ditto

	# if has other covens, compare against ours
	if e_cc:
		var covens = parent_entity.get_component("CovensComponent").covens
		var covennpc_opinions_unfiltered = []
		var e_covens_component = e_cc

		# get all opinions
		for coven in covens:
			var c = CovenSystem.get_coven(coven)
			# get the other coven opinions
			covennpc_opinions_unfiltered.append_array(c.get_covennpc_opinions(e_covens_component.covens.keys())) # FIXME: Get this coven opinions on other
			# take crimes into account
			opinions.append(CrimeMaster.max_crime_severity(id, coven) * -10) # sing opinion by -10 for each severity point

		opinions.append_array(covennpc_opinions_unfiltered.filter(func(x:int): return not x == 0)) # filter out zeroes
		opinion_total += opinions.size() * covens_modifier # calculate total
	# if has an opinion of the player, take into account
	if npc_opinions.has(id) and not npc_opinions[id] == 0:
		opinions.append(npc_opinions[id])
		opinion_total += self_modifier # avoid 1 * self_modifier because that's an identity function so we can just do self_modifier
	print("Considering: ", opinions)
	# Return weighted average
	match opinion_mode:
		0:
			var o:Variant = opinions.min()
			return 0.0 if o == null else o
		1:
			var o:Variant = opinions.max()
			return 0.0 if o == null else o
		2:
			return opinions.reduce(func(sum, next): return sum + next, 0) / (1 if opinion_total == 0 else opinion_total)
		_:
			return 0.0


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


func get_translated_name() -> String:
	var t = tr(parent_entity.name)
	if t == parent_entity.name:
		return tr(parent_entity.form_id)
	else:
		return t


## Current simulation level for an NPC.
enum SimulationLevel {
	FULL, ## When the actor is in the scene.
	GRANULAR, ## When the actor is outside of the scene. Will still follow a schedule and go from point to point, but will not walk around using the navmesh, interact with things in the world, or do anything that involves the puppet.
	NONE, ## When the actor is outside of the simulation distance. It will not do anything.
}
