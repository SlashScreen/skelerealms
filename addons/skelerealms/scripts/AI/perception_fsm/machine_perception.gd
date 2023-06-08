class_name PerceptionFSM_Machine
extends FSMMachine
## The NPC perpection tracking is a finite state machine for easily tweakable behavior.
## This is where the stealth mechanics come in- how the NPC processes seeing stuff. The ? -> ! pipeline in MGS games. I dunno. I'm tired. I hope you get it.
## The current state machine looks like this: [br]
## [codeblock]
## ┌───────┐                 ┌──────────────┐
## │Unaware│   ┌─────────────┤Lost track of │
## └───┬───┘   │             └──────────────┘
##     │       │                   ▲
##     │       │                   │
##     ▼       ▼                   │
## ┌────────────┐            ┌─────┴────────┐
## │AwareVisible├──────────► │AwareInvisible│
## └────────────┘ ◄──────────┴──────────────┘
## [/codeblock]


## RefID of tracked entity.
var tracked:String
## The current visibility of the entity. 0 means it is not visible.
var visibility:float
## The last known position of the entity.
var last_seen_position:Vector3
## The last known world of this entity.
var last_seen_world:String


func _init(tracked_obj:String, vis:float) -> void:
	tracked = tracked_obj
	visibility = vis


## Remove this FSM from the system.
func remove_fsm() -> void:
	(get_parent() as NPCComponent).perception_forget(tracked)
