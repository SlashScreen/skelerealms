@tool

class_name QuestNode
extends Node
## This is an instance of a [Quest] within the scene.


## The quest data.
var qID:String
var complete:bool = false
var _active_step:QuestStep
var data:Dictionary:
	get:
		return{
			"active_step": _active_step.name,
			"steps": get_children().map(func(x): return x.name)
		}
var update_signal:Signal


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
			update_signal.emit(name, data)
			return
		_active_step = _active_step.next_step


func register_step_event(key:String, args:Dictionary = {}, undo:bool = false):
	for g in get_children():
		g.register_event(key, args, undo)


func is_step_complete(id:String):
	var st = find_child(id) as QuestStep
	if not st:
		return false
	return st.evaluate(false)


func save() -> Dictionary:
	var step_data = {}
	for s in get_children():
		step_data[s.name] = s.save()
	return {
		"complete": complete,
		"active_step": _active_step.name,
		"step_data": step_data
	}


func load_data(data:Dictionary) -> void:
	complete = data.complete
	_active_step = get_node(data.active_step)
	for s_name in data.step_data:
		get_node(s_name).load_data(data.step_data[s_name])
