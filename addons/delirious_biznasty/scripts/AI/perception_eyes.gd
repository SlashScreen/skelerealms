class_name EyesPerception
extends Node3D
## This handles seeing, and it attached to the head of the character.


## FOV is the field of view of the eyes, in degrees. The default value is 90 degrees.
@export var fov_h:float = 90
@export var fov_v:float = 90
@export var view_distance:float = 30
@export var light_level_threshold:float = 0.1

var light_probe:LightEstimation

signal begin_perceiving(percieved:PerceptionData)
signal end_perceiving(percieved:PerceptionData)


func check_sees_collider(pt:CollisionObject3D) -> PerceptionData :
	# 1) See if target in range
	if position.distance_to(pt.position) > view_distance:
		return null
	# 2) See if direction to target within fovs
	var direction_to = pt.position - position
	var angle_to = direction_to.dot(transform.basis.z)
	if angle_to < 1 - (fov_h / 2 / 180):
		return null
	# TODO: vertical fov using pitch, horizontal using yaw
	# 3) Raycast check
	var state = get_world_3d().direct_space_state
	var q = PhysicsRayQueryParameters3D.create(position, pt.position) # TODO: exclude all under owner
	var c = state.intersect_ray(q)
	if c: # if collider hit
		if c == pt or (c as Node).is_ancestor_of(pt): # if collider hit is this or ancestor
			return null
	# 4) Calculate light level
	var light_level = await light_probe.get_light_level_for_point(pt.position)
	if light_level < light_level_threshold:
		return null
	# 5) Calculate percent of coverage with AABBs <- TODO
	return PerceptionData.new(pt, light_level)


# no wait we need to keep updating on a thing? 
class PerceptionData:
	var object:Node
	var visibility:float
	
	func _init(obj:Node, vis:float) -> void:
		object = obj
		visibility = vis
