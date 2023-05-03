class_name NPCComponent 
extends EntityComponent
## The brain for an NPC. Handles AI behavior, scheduling, combat, dialogue interactions.
## @tutorial(In-depth view of opinion system): https://github.com/SlashScreen/skelerealms/wiki/NPCs#opinions-and-how-the-npc-determines-its-opinions


const THREATENING_ENTITY_TYPES = [
	"NPCComponent",
	"PlayerComponent",
]

#* Export
## Base data for this NPC.
@export var data: NPCData
#* Public.
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
			print("entering combat")
			entered_combat.emit()
		elif not val and in_combat:
			print("leaving combat")
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
			if val and _puppet:
				_puppet.stop_nav()
			elif not val and _puppet:
				_puppet.continue_nav()
			_busy = val
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
## Opinions of entities 
var _opinions = {}


signal entered_combat
signal left_combat
signal start_saw_player
signal end_saw_player
signal chitchat_started(dialogue_node:String)
signal destination_reached
signal dialogue_with_npc_started(dialogue_node:String)
signal schedule_updated(ev:ScheduleEvent)
signal start_dialogue(dialogue_node:String)
signal warning(ref_id:String)
signal flee(ref_id:String)
signal heard_something(emitter:AudioEventEmitter)
signal perception_transition(what:StringName, transitioned_to:String, fsm:PerceptionFSM_Machine)
signal interacted(refID:String)
signal friendly_fire_response
signal draw_weapons
signal put_away_weapons
signal hit_by(who:String)
signal damaged_with_effect(effect:StringName)


#* ### OVERRIDES


func _init(d:NPCData) -> void:
	data = d
	name = "NPCComponent"
	var s:Schedule = Schedule.new()
	s.name = "Schedule"
	s.events = data.schedule
	add_child(s)
	_schedule = s
	
	# Set default player opinion
	_opinions[&"Player"] = d.default_player_opinion


func _ready():
	super._ready()
	
	# Initialize all AI Modules
	for module in data.modules:
		module.link(self)
		module._initialize()
	
	await parent_entity.instantiated # wait for entity to be ready to instantiate to ger siblings
	
	if not ($"../InteractiveComponent" as InteractiveComponent).interacted.is_connected(func(x:String): interacted.emit(x)):
		($"../InteractiveComponent" as InteractiveComponent).interacted.connect(func(x:String): interacted.emit(x))
	
	_nav_component = $"../NavigatorComponent" as NavigatorComponent
	_puppet_component = $"../PuppetSpawnerComponent" as PuppetSpawnerComponent
	_interactive_component = $"../InteractiveComponent" as InteractiveComponent
	_goap_component = $"../GOAPComponent" as GOAPComponent
	
	# sync nav agent
	_puppet_component.spawned_puppet.connect(func(x:Node): _puppet = x as NPCPuppet )
	_puppet_component.despawned_puppet.connect(func(): _puppet = null )
	
	# misc setup
	_interactive_component.interactible = data.interactive # TODO: Or instance override


func _on_enter_scene():
	_puppet_component.spawn(data.prefab)
	_sim_level = SimulationLevel.FULL


func _on_exit_scene():
	_puppet_component.despawn()
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


func _exit_tree() -> void:
	for m in data.modules:
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


#* ### PATHFINDING


## Calculate this NPC's path to a [NavPoint].
func set_destination(dest:NavPoint) -> void:
	# Recalculate path
	_path = _nav_component.calculate_path_to(dest)
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
				var e = SkeleRealmsGlobal.entity_manager.get_entity(p)
				if e.some():
					return not (e.unwrap as Entity).get_component("ItemComponent") == null
				return false
				)


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
			if (ev.unwrap() as ScheduleEvent).condition == null or (ev.unwrap() as ScheduleEvent).condition.evaluate(): 
				# if no condition, it passes. Otherwise, check if passes
				# If we find a schedule and it isn't the one we currently have, set it to the new event.
				_current_schedule_event = ev.unwrap()
				schedule_updated.emit(_current_schedule_event)
	else:
		# Else we have no schewdule for this time period
		_current_schedule_event = null
		schedule_updated.emit(null)


#* ### MISC


## Get a relationship this NPC has of [RelationshipType]. Pass in the type's key. Returns the relationship if found, none if none found.
func get_relationship_of_type(key:String) -> Option:
	var res = data.relationships.filter(func(r:Relationship): return r.relationship_type and r.relationship_type.relationship_key == key)
	if res.is_empty():
		return Option.none()
	return Option.from(res[0])


## Gets this NPC's relationship with someone by ref id. Returns the relationship if found, none if none found.
func get_relationship_with(ref_id:String) -> Option:
	var res = data.relationships.filter(func(r:Relationship): return r.relationship_type and r.other_person == ref_id)
	if res.is_empty():
		return Option.none()
	return Option.from(res[0])


## Determines the opinion of some entity. See the tutorial in the class docs for a more in-depth look at NPC opinions.
func determine_opinion_of(id:StringName) -> float:
	var e:Entity = SkeleRealmsGlobal.entity_manager.get_entity(id).unwrap()
	print(e)
	
	if not THREATENING_ENTITY_TYPES.any(func(x:String): return e.get_component(x).some()): # if it doesn't have any components that are marked as threatening, return neutral.
		return 0
	
	var e_cc = e.get_component("CovensComponent")
	var opinions = []
	var opinion_total = 0
	
	# calculate modifiers
	var covens_modifier = 2 if data.loyalty == 1 else 1 # if values covens, increase modifier
	var self_modifier = 2 if data.loyalty == 2 else 1 # ditto
	
	# if has other covens, compare against ours
	if e_cc.some():
		var covens = parent_entity.get_component("CovensComponent").unwrap().covens
		var coven_opinions_unfiltered = []
		var e_covens_component = e_cc.unwrap()
		print(e_covens_component.get_parent())
		
		# get all opinions
		for coven in covens:
			var c = CovenSystem.get_coven(coven)
			# get the other coven opinions
			coven_opinions_unfiltered.append_array(c.get_coven_opinions(e_covens_component.covens.keys())) # FIXME: Get this coven opinions on other 
		
		opinions.append_array(coven_opinions_unfiltered.filter(func(x:int): return not x == 0)) # filter out zeroes
		opinion_total += opinions.size() * covens_modifier # calculate total
	# if has an opinion of the player, take into acocunt
	if not _opinions[id] == 0:
		opinions.append(_opinions[id])
		opinion_total += self_modifier # avoid 1 * self_modifier because that's an identity function so we can just do self_modifier
	
	# Return weighted average
	return opinions.reduce(func(sum, next): return sum + next, 0) / opinion_total


## Current simulation level for an NPC.
enum SimulationLevel {
	FULL, # When the actor is in the scene.
	GRANULAR, # When the actor is outside of the scene. Will still follow a schedule and go from point to point, but will not walk around using the navmesh, interact with things in the world, or do anything that involves the puppet.
	NONE, ## When the actor is outside of the simulation distance. It will not do anything.
}
