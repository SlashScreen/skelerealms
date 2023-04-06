class_name PerceptionFSM_Aware_Invisible
extends FSMState
## In this state, the line of sight has been broken. THe NPC may look for the target here.


## The time it takes to lose track of something, in seconds
var lose_timer_max:float = 60
var _npc:NPCComponent
var lose_timer:float


func _get_state_name() -> String:
	return "AwareInvisible"


func ready() -> void:
	_npc = owner as NPCComponent


func enter(msg:Dictionary = {}) -> void:
	lose_timer = lose_timer_max


func update(delta:float) -> void:
	lose_timer -= delta # decrease timer
	if lose_timer <= 0:
		state_machine.transition("lost")
