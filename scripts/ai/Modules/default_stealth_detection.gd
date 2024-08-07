extends AIModule


@export var view_dist:float = 30


func _update_fsm(data:Dictionary, delta:float) -> void:
	for ref_id:StringName in data:
		if has_node(NodePath(ref_id)):
			pass
		else:
			var fsm := FSM.new()
			fsm.name = ref_id
			add_child(fsm)


func in_view(vis:float, dist:float) -> bool:
	return dist <= view_dist * vis


class FSM:
	extends Node
	
	
	enum {
		UNAWARE,
		AWARE_VISIBLE,
		AWARE_INVISIBLE,
		WARY
	}
	
	
	const LOSE_TIMER := 120.0
	
	var state:int = UNAWARE
	var seek_timer:float = 0.0
	
	
	func update(data:Dictionary, delta:float, dist:float, in_view_cone:bool) -> void:
		var vis:float = data[&"visibility"]
		
		match state:
			UNAWARE, WARY:
				if in_view_cone:
					state = AWARE_VISIBLE
			AWARE_VISIBLE:
				if is_zero_approx(vis):
					state = AWARE_INVISIBLE
					seek_timer = LOSE_TIMER
			AWARE_INVISIBLE:
				if not is_zero_approx(vis):
					state = AWARE_VISIBLE
				else: 
					seek_timer -= delta
					if seek_timer <= 0.0:
						state = WARY
	
