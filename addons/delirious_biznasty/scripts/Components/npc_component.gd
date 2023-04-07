class_name NPCComponent 
extends EntityComponent
## The brain for an NPC.


## Base data for this NPC.
@export var data: NPCData

var player_opinion:int
var in_combat:bool:
	get:
		return in_combat
	set(val):
		if val and not in_combat: # these checks prevent spamming
			entered_combat.emit()
		elif not val and in_combat:
			left_combat.emit()
		in_combat = val
var _path:Array[NavPoint]
var _current_target_point:NavPoint: # TODO: make setting this update the nav agent
	set(val):
		_current_target_point = val
		if _puppet:
			_puppet.set_movement_target(val.position)
	get:
		return _current_target_point
var visibility_threshold:float = 0.3
## Stores data of interest for GOAP to access.
var goap_memory:Dictionary = {}
var _nav_component:NavigatorComponent
var _puppet_component:PuppetSpawnerComponent
var _interactive_component:InteractiveComponent
var _goap_component:GOAPComponent
var _current_schedule_event:ScheduleEvent
var _schedule:Schedule
var _sim_level:SimulationLevel = SimulationLevel.FULL
var _doors_in_path:Array[int] = []
var _path_follow_end_distance:float = 1
var _walk_speed:float = 1
var _puppet:NPCPuppet
var _perception_memory:Dictionary = {}


signal entered_combat
signal left_combat
signal start_saw_player
signal end_saw_player
signal chitchat_started(dialogue_node:String)
signal destination_reached
signal dialogue_with_npc_started(dialogue_node:String)
signal schedule_updated(ev:ScheduleEvent)
signal start_dialogue
signal warning


#* ### OVERRIDES


func _init(d:NPCData) -> void:
	data = d
	name = "NPCComponent"
	var s:Schedule = Schedule.new()
	s.name = "Schedule"
	s.events = data.schedule
	add_child(s)
	_schedule = s


func _ready():
	super._ready()
	
	await parent_entity.instantiated # wait for entity to be ready to instantiate to ger siblings
	
	if not ($"../InteractiveComponent" as InteractiveComponent).interacted.is_connected(interact.bind()):
		($"../InteractiveComponent" as InteractiveComponent).interacted.connect(interact.bind())
	
	_nav_component = $"../NavigatorComponent" as NavigatorComponent
	_puppet_component = $"../PuppetSpawnerComponent" as PuppetSpawnerComponent
	_interactive_component = $"../InteractiveComponent" as InteractiveComponent
	_goap_component = $"../GOAPComponent" as GOAPComponent
	
	# sync nav agent
	_puppet_component.spawned_puppet.connect(func(x:Node): _puppet = x as NPCPuppet )
	_puppet_component.despawned_puppet.connect(func(): _puppet = null )


func _on_enter_scene():
	_puppet_component.spawn(data.prefab)
	_sim_level = SimulationLevel.FULL


func _on_exit_scene():
	_puppet_component.despawn()
	_sim_level = SimulationLevel.GRANULAR


func _process(delta):
	#* Section 1: Path following
	# If in scene, use navmesh agent.
	if parent_entity.in_scene:
		if _puppet.target_reached: # If puppet reached target
			_next_point()
	else: # If not in scene, move between points.
		if parent_entity.position.distance_to(_current_target_point.position) < _path_follow_end_distance: # if reached point
			_next_point() # get next point
			parent_entity.world = _current_target_point.world # set world
		parent_entity.position = parent_entity.position.move_toward(_current_target_point.position, delta * _walk_speed) # move towards position


#* ### DIALOGUE AND INTERACTIVITY


# TODO:
## Interact with this npc. See [InteractiveComponent].
func interact(refID:String):
	pass


#* ### PATHFINDING


## Calculate this NPC's path to a [NavPoint].
func set_destination(dest:NavPoint):
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
		if _path[next_door].position.distance_to(parent_entity.position) < ProjectSettings.get_setting("biznasty/actor_fade_distance"): # TODO: fine tune these
			# if the next door is close enough, jsut go to it next because it will look awkward following the path
			# skip all until door
			# TODO: Interact with door?
			for i in range(next_door): # this will make the target point the door
				_current_target_point = _pop_path() # FIXME: WILL CAUSE RECALCULATION A LOT
			return
	else: # if we dont have doors (we can assume that the destination is in same world
		if _path.back().position.distance_to(parent_entity.position) < ProjectSettings.get_setting("biznasty/actor_fade_distance"): 
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
		fsm.transitioned.connect(func(x:String): handle_perception_transition(info.object, x))
		fsm.initial_state = "Unaware"
		fsm.setup([
			PerceptionFSM_Aware_Invisible.new(),
			PerceptionFSM_Aware_Visible.new(),
			PerceptionFSM_Lost.new(),
			PerceptionFSM_Unaware.new(),
		])


## Change behavior based on how the perception level of an object changes.
func handle_perception_transition(id:String, transition:String) -> void:
	# TODO: determine threat level and response
	match transition:
		"AwareInvisible":
			return
		"AwareVisible":
			return
		"Lost":
			return
		"Unaware":
			return


## Callback for when something leaves perception
func on_percieve_end(info:EyesPerception.PerceptionData) -> void:
	if _perception_memory.has(info.object):
		# if we have it, set perception to 0 (hidden)
		_perception_memory[info.object].visibility = 0


# TODO:
func on_hear_audio(emitter:AudioEventEmitter) -> void:
	# determine importance of sound
	# Add point of interest to memory
	# add task to investigate
	# Figure out like, whether it's unexpected
	pass


# TODO:
func determine_threat_level(what:String) -> void:
	# use covens, relationships, etc to determine threat level of something
	pass


# TODO:
func determine_threat_response() -> void:
	# using threat level and the npc's combat information, determine what it should do and add goals to reflect
	# (flee, fight, etc)
	pass


## Forget something from the perception memory.
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
				var e = BizGlobal.entity_manager.get_entity(p)
				if e.some():
					return not (e.unwrap as Entity).get_component("ItemComponent") == null
				return false
				)


#* ### SCHEDULE


# TODO:
func follow_schedule() -> void:
	# Resolve schedule
	# Go to the schedule point
	pass


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


## Current simulation level for an NPC.
enum SimulationLevel {
	FULL, # When the actor is in the scene.
	GRANULAR, # When the actor is outside of the scene. Will still follow a schedule and go from point to point, but will not walk around using the navmesh, interact with things in the world, or do anything that involves the puppet.
	NONE, ## When the actor is outside of the simulation distance. It will not do anything.
}
