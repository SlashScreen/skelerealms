class_name AIModule
extends Resource
## Base class for AI Packages for NPCs.
## Skelerealms uses 2 AI systems, each with different roles.
## The AI Package system determines what goals the NPC should attempt to achieve, and the GOAP AI system figures out how to achieve it.
## Override this to set custom behaviors by attaching to [NPCComponent]'s many signals.


var _npc:NPCComponent


## Link this module to the component.
func link(npc:NPCComponent) -> void:
	self._npc = npc


## Override this as a "_ready()" analogue.
func _initialize() -> void:
	pass


func _clean_up() -> void:
	return


func get_type() -> String:
	return "AIModule"


## Prints a rich text message to the console prepended with the entity name. Used for easier debugging. 
func printe(text:String) -> void:
	_npc.printe(text)
