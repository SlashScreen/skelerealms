class_name InteractiveObject
extends Node3D
## base class for objects in the world that don't need tracking, but can be interacted with, like a sign.
## See [Door] for an example implementation.


signal on_interact(id:String)


func interact(id:String):
	on_interact.emit(id)
