class_name ScheduleEvent
extends Node


## These are the different schedule events that can occupy a schedule.


## From what time?
@export var from:Timestamp
## To what time?
@export var to:Timestamp
## Anmy condition that needs be checked first.
@export var condition:ScheduleCondition
## Schedule priotity.
@export var priority:float


## Get the location this event is at.
func get_event_location() -> NavPoint:
	return null


## Wthether this entity is "at" the event.
func satisfied_at_location(e:SKEntity) -> bool:
	return true


## What to do when the event has begun.
func on_event_started() -> void:
	return


## What to do when the event has ended.
func on_event_ended() -> void:
	return
