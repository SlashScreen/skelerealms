@tool
class_name AIModule
extends Node
## Base class for AI Packages for NPCs.
## Skelerealms uses 2 AI systems, each with different roles.
## The AI Package system determines what goals the NPC should attempt to achieve, and the GOAP AI system figures out how to achieve it.
## Override this to set custom behaviors by attaching to [NPCComponent]'s many signals.


@onready var _npc:NPCComponent = get_parent()


## Link this module to the component.
func link(npc:NPCComponent) -> void:
	self._npc = npc


## The "ready" function if you depend on the NPC's variables.
func initialize() -> void:
	pass


func _clean_up() -> void:
	return


func get_type() -> String:
	return "AIModule"


## Prints a rich text message to the console prepended with the entity name. Used for easier debugging. 
func printe(text:String) -> void:
	_npc.printe(text)
