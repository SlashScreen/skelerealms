class_name InteractiveObject
extends Node3D
## base class for objects in the world that don't need tracking, but can be interacted with, like a sign.
## See [Door] for an example implementation.


signal on_interact(id:String)

## Whether it can be interacted with.
@export var interactible:bool = true
## Verb to use when hovered over.
@export var interact_verb:String = "INTERACT"
## Name of the object.
@export var object_name:String = "THING"


func interact(id:String):
	on_interact.emit(id)
