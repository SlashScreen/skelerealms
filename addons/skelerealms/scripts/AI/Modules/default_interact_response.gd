class_name DefaultInteractResponseModule # oh god this is getting java like
extends AIModule


func _initialize() -> void:
	_npc.interacted.connect(on_interact.bind())


func on_interact(refID:String) -> void:
	_npc.start_dialogue.emit(_npc.data.start_dialogue_node)
	_npc._busy = true
