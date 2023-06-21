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


func _ready() -> void:
	add_to_group("idle_points")


func occupy(who:String) -> void:
	is_occupied = true
	owning_entity = who


func unoccupy() -> void:
	is_occupied = false
