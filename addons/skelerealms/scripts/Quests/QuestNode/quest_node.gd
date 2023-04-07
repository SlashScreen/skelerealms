class_name QuestNode
extends Node
## This is an instance of a [Quest] within the scene.


## The quest data.
var _q_data:Quest
var qID:String
var complete:bool = false
@onready var _active_step:QuestStep = get_child(0)


signal quest_complete(qID:String)
signal quest_updated(qID:String)


# Might be useless
## Evaluate whether the quest is complete or not.
func evaluate() -> bool:
	if complete: # if we are already complete, skip this
		return true
	
	var results:Array[bool] = []
	for g in get_children().map(func(x): x as QuestStep):
		results.append(g.evaluate(g == _active_step)) # pass in whether this is the active step, important for goals later on.
	return results.all(func(x): x)


func update():
	if complete:
		return
	if _active_step.evaluate(true): #if active step is true, move to the next one
		if _active_step.is_final_step:
			complete = true
			quest_complete.emit(qID)
			return
		_active_step = _active_step.next_step


func register_step_event(key:String):
	for g in get_children().map(func(x): x as QuestStep):
		g.register_event(key)
	update()


func is_step_complete(id:String):
	var st = find_child(id) as QuestStep
	if not st:
		return false
	return st.evaluate(false)
	
