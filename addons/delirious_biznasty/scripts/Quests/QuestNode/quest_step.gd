class_name QuestStep
extends Node

var type:StepType = StepType.ALL
var is_final_step:bool = false
@export var next_steps:Dictionary = {}

var next_step:QuestStep:
	get:
		if type == StepType.ALL:
			return next_steps[0]
		for g in get_children().map(func(x): x as QuestGoal):
			if(g.evaluate(false)):
				return next_steps[g.key]
		return null


func evaluate(is_active_step:bool) -> bool:
	var results:Array[bool] = []
	for g in get_children().map(func(x): x as QuestGoal):
		results.append(g.evaluate() || g.optional) # if evaluate or optional
	if type == StepType.ALL:
		return results.all(func(x): x)
	else:
		return results.any(func(x): x)


## Register a goal event.
func register_event(key:String):
	for g in get_children().map(func(x): x as QuestGoal):
		g.attempt_register(key)


enum StepType {
	ALL,
	ANY,
	BRANCH,
}
