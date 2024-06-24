class_name Schedule
extends Node


## Keeps track of the schedule.
## Schedules are roughly analagous to Creation Kit's "AI packages", although limited to time slots.
## It is made up of [ScheduleEvent]s.
## To adjust NPC behavior under circumastances outside of keeping a schedule, see [GOAPComponent] and [ScheduleCondition].


@onready var events:Array[ScheduleEvent] = get_children()


func find_schedule_activity_for_current_time() -> Option:
	# Scan events
	var valid_events = events.filter(func(ev:ScheduleEvent): return Timestamp.build_from_world_timestamp().is_in_between(ev.from, ev.to)) # get those that are in the time space
	valid_events.sort_custom(func(a:ScheduleEvent, b:ScheduleEvent): return a.priority > b.priority ) # sort descending by priority
	# find first one that is valid
	for ev in valid_events:
		if (ev as ScheduleEvent).condition == null or (ev as ScheduleEvent).condition.evaluate():
			return Option.from(ev)
	# If we make it this far, we didn't find any, return none.
	return Option.none()
