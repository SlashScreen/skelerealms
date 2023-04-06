class_name PerceptionFSM_Aware_Visible
extends FSMState
## In this state, it is actively looking at the target.


var _npc:NPCComponent
var e:Entity


func _get_state_name() -> String:
	return "AwareVisible"


func on_ready() -> void:
	_npc = owner as NPCComponent


func update(delta:float) -> void:
	(state_machine as PerceptionFSM_Machine).last_seen_position = e.position
	(state_machine as PerceptionFSM_Machine).last_seen_world = e.world
	if (state_machine as PerceptionFSM_Machine).visibility == 0: # we need the player to be completely invisible to evade detection. We can't just vanish into the shadows
		state_machine.transition("AwareInvisible")


func enter(msg:Dictionary = {}) -> void:
	e = BizGlobal.entity_manager.get_entity((state_machine as PerceptionFSM_Machine).tracked).unwrap()
