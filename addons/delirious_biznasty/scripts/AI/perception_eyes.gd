class_name EyesPerception
extends Node3D
## This handles seeing, and it attached to the head of the character.


## FOV is the field of view of the eyes, in degrees. The default value is 90 degrees.
@export var fov_h:float = 90
@export var fov_v:float = 90
@export var view_distance:float = 30

signal begin_perceiving(percieved:PerceptionData)
signal end_perceiving(percieved:PerceptionData)


func check_sees_collider(pt:CollisionShape3D) -> bool :
	# 1) See if target in range
	if position.distance_to(pt.position) > view_distance:
		return false
	# 2) See if direction to target within fovs
	var direction_to = pt.position - position
	var angle_to = direction_to.dot(transform.basis.z)
	if angle_to < 1 - (fov_h / 2 / 180):
		return false
	# TODO: vertical fov using pitch, horizontal using yaw
	# 3) Raycast check
	# 4) Calculate light level
	# 5) Calculate percent of coverage with AABBs
	return true

# no wait we need to keep updating on a thing? 
class PerceptionData:
	var object:Node
	var visibility:float
