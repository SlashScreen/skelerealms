class_name Schedule
extends Node
## Keeps track of the schedule.
## Schedules are roughly analagous to Creation Kit's "packages", although limited to time slots.
## It is made up of [ScheduleEvent]s.
## To adjust NPC behavior under circumastances outside of keeping a schedule, see [GOAPComponent] and [ScheduleCondition].


@export var events:Array[ScheduleEvent]


func find_schedule_activity_for_current_time() -> Option:
	# Scan events
	for ev in events:
		# Compare timestamps
		if Timestamp.build_from_world_timestamp().is_in_between(ev.from, ev.to):
			# If we find one in the right timeframe, select it
			return Option.from(ev)
	# If we make it this far, we didn't find any, return none.
	return Option.none()
