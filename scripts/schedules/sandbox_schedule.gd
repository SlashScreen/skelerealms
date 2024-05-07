class_name SandboxSchedule
extends ScheduleEvent
## A "Sandbox" procedure is a term borrowed from Creation Kit games. This is essentially letting the NPC mill about with nothing more important to do.


## Influences how long an NPC will do an activity for. Represents the midpoint of a random range time duration in seconds.
@export var energy:float
@export var can_swim:bool = false
@export var can_sit:bool = true
@export var can_eat:bool = true
@export var can_sleep:bool = true
## Whether this entity can engage in conversdation while idling.
@export var can_engage_conversation:bool = true
@export var use_idle_points:bool = true
@export_category("Location")
## Whether this NPC must be at a certain location to idle. For example: town square, inn.
@export var be_at_location:bool = true
@export var location_position:Vector3
@export var location_world:String
@export var target_radius:float = 25
var _npc:NPCComponent


func get_event_location() -> NavPoint:
	# Idle points found from goap action 
	return NavPoint.new(location_world, location_position)


func satisfied_at_location(e:SKEntity) -> bool:
	# if we dont need to be at location, return true by default
	if not be_at_location:
		return true
	# if world not the same
	if not e.world == location_world:
		return false	
	# if too far away
	if e.position.distance_to(location_position) > target_radius:
		return false
	# else, we passed
	return true


func on_event_started() -> void:
	_npc.add_objective({"perform_idle_point":true}, false, 0)
	_npc.goap_memory["sandbox_schedule"] = self


func on_event_ended() -> void:
	_npc.remove_objective_by_goals({"perform_idle_point":true})
	_npc.goap_memory.erase("sandbox_schedule")


func attach_npc(n:NPCComponent) -> void:
	_npc = n
