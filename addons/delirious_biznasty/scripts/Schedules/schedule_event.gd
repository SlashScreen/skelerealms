class_name ScheduleEvent
extends Resource


@export var name:String
## From what time?
@export var from:Timestamp
## To what time?
@export var to:Timestamp
@export var condition:ScheduleCondition
@export var can_swim:bool = false
@export var can_sit:bool = true
@export var can_eat:bool = true
@export var can_sleep:bool = true
