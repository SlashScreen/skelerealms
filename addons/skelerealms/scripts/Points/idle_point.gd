class_name IdlePoint
extends Marker3D


@export var owning_entity:String

var is_occupied:bool:
	get:
		return is_occupied
	set(val):
		if val and not is_occupied:
			occupied.emit()
		elif not val and is_occupied:
			unoccupied.emit()
		is_occupied = val

signal occupied
signal unoccupied


func occupy() -> void:
	is_occupied = true
