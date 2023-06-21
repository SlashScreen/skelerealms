class_name ScheduleEvent
extends Resource


@export var name:String
## From what time?
@export var from:Timestamp
## To what time?
@export var to:Timestamp
@export var condition:ScheduleCondition
@export var priority:float


## Get the location this event is at
func get_event_location() -> NavPoint:
	return null


func satisfied_at_location(e:Entity) -> bool:
	return true

func on_event_started() -> void:
	return


func on_event_ended() -> void:
	return
