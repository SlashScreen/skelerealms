class_name EyesPerception
extends Node3D
## This handles seeing, and it attached to the head of the character.


## FOV is the field of view of the eyes, in degrees. The default value is 90 degrees.
@export var fov_h:float = 90
@export var fov_v:float = 90
@export var view_distance:float = 30

signal begin_perceiving(percieved:PerceptionData)
signal end_perceiving(percieved:PerceptionData)


func check_sees_collider(pt:CollisionShape3D):
	# 1) See if target in range
	# 2) See if direction to target within fovs
	# 3) Calculate light level
	# 4) Calculate percent of coverage
	pass

# no wait we need to keep updating on a thing? 
class PerceptionData:
	var object:Node
	var visibility:float
