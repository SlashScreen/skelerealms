class_name InteractiveObject
extends Node3D
## Objects in the world that don't need tracking, but can be interacted with, like a sign.

signal on_interact(id:String)

func interact(id:String):
	on_interact.emit(id)
