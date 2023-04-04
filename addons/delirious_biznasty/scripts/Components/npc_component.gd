class_name NPCComponent 
extends EntityComponent
## The brain for an NPC.


## Base data for this NPC.
@export var data: NPCData

var player_opinion:int
var in_combat:bool

var _path:Array[NavPoint]
var _current_target_point:NavPoint
var _nav_component:NavigatorComponent
var _puppet_component:PuppetSpawnerComponent
var _interactive_component:InteractiveComponent
var _goap_component:GOAPComponent
var _current_schedule_event:ScheduleEvent
var _schedule:Schedule
var _sim_level:SimulationLevel = SimulationLevel.FULL


signal entered_combat
signal left_combat
signal start_saw_player
signal end_saw_player
signal chitchat_started(dialogue_node:String)
signal destination_reached
signal dialogue_with_npc_started(dialogue_node:String)
signal schedule_updated(ev:ScheduleEvent)


func _ready():
	super._ready()
	
	await parent_entity.instantiated # wait for entity to be ready to instantiate
	
	if not ($"../InteractiveComponent" as InteractiveComponent).interacted.is_connected(interact.bind()):
		($"../InteractiveComponent" as InteractiveComponent).interacted.connect(interact.bind())
	# create a schedule if ther isnt one
	if not find_child("Schedule"):
		var s:Schedule = Schedule.new()
		s.name = "Schedule"
		s.events = data.schedule
		add_child(s)
		_schedule = s
	else:
		_schedule = get_node("Schedule")
		_schedule.events = data.schedule


func _on_enter_scene():
	$"../PuppetSpawnerComponent".spawn(data.prefab)
	_sim_level = SimulationLevel.FULL


func _on_exit_scene():
	$"../PuppetSpawnerComponent".despawn()
	_sim_level = SimulationLevel.GRANULAR

# TODO: All of this

func _process(delta):
	# Path following
	# If in scene, use navmesh agent
	# If not in scene, lerp between points.
	pass


## Interact with this npc. See [InteractiveComponent].
func interact(refID:String):
	pass


# TODO: Average covens and player opinion
func determine_opinion(refID:String) -> int:
	return 0


## Calculate this NPC's path to a [NavPoint].
func set_destination(dest:NavPoint):
	# Recalculate path
	_path = _nav_component.calculate_path_to(dest)


func add_objective(goals:Dictionary, remove_after_satisfied:bool, priority:float):
	_goap_component.add_objective(goals, remove_after_satisfied, priority)


func on_percieve(ref_id:String):
	pass


func follow_schedule():
	# Go to the schedule point
	pass


func _calculate_new_schedule():
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


## Current simulation level for an NPC.
enum SimulationLevel {
	FULL, # When the actor is in the scene.
	GRANULAR, # When the actor is outside of the scene. Will still follow a schedule and go from point to point, but will not walk around using the navmesh, interact with things in the world, or do anything that involves the puppet.
	NONE, ## When the actor is outside of the simulation distance. It will not do anything.
}
