class_name PerceptionFSM_Lost
extends FSMState


const forget_timer_max:float = 600
var _npc:NPCComponent
var forget_timer:float = 0


func _get_state_name() -> String:
	return "Lost"


func on_ready() -> void:
	_npc = owner as NPCComponent


func update(delta:float) -> void:
	# if the thing is visible again, we are aware of it again.
	# if it is in state lost, this NPC will "recognize" it, and immediately remember it.
	if (state_machine as PerceptionFSM_Machine).visibility >= _npc.visibility_threshold:
		state_machine.transition("AwareVisible")
	
	forget_timer -= delta
	if forget_timer < 0:
		(state_machine as PerceptionFSM_Machine).remove_fsm()


func enter(msg:Dictionary) -> void:
	forget_timer = forget_timer_max
