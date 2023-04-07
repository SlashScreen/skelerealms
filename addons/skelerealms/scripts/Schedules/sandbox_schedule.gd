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
