class_name ContinuityCondition
extends ScheduleCondition

@export var flag:String
@export var value:float

func evaluate() -> bool:
	# return false if doesn't have flag
	if not GameInfo.continuity_flags.has(flag):
		return false
	# return false if values don't match up
	if not GameInfo.continuity_flags[flag] == value:
		return false
	# else return true
	return true
