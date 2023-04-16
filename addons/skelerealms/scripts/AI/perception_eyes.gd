class_name EyesPerception
extends Node3D
## This handles seeing, and it attached to the head of the character.


const perception_interval:float = 0.25

## FOV is the field of view of the eyes, in degrees. The default value is 90 degrees.
@export var fov_h:float = 90
@export var fov_v:float = 90
@export var view_distance:float = 30
@export var light_level_threshold:float = 0.1

var light_probe:LightEstimation
var t:Timer


signal perceived(percieved:PerceptionData)
signal not_perceived(percieved:PerceptionData)


func _ready() -> void:
	t = Timer.new()
	add_child(t)
	t.start(perception_interval)
	t.timeout.connect(try_perception.bind())
	light_probe = $Probe


## Check if this can see a target
func check_sees_collider(pt:CollisionShape3D) -> PerceptionData :
	# 1) See if target in range
	if position.distance_to(pt.position) > view_distance:
		return PerceptionData.new(_find_ref_id(pt), 0)
	# 2) See if direction to target within fovs
	var direction_to = pt.global_position - global_position
	var angle_to = direction_to.dot(transform.basis.z)
	if angle_to < 1 - (fov_h / 2 / 180):
		return PerceptionData.new(_find_ref_id(pt), 0)
	# TODO: vertical fov using pitch, horizontal using yaw
	# 3) Raycast check
	await get_tree().physics_frame
	var state = get_world_3d().direct_space_state
	var q = PhysicsRayQueryParameters3D.create(global_position, pt.global_position)
	var c = state.intersect_ray(q)
	if c: # if collider hit
		if not (c["collider"] == pt or (c["collider"] as Node).is_ancestor_of(pt)): # if collider hit is this or ancestor
			return PerceptionData.new(_find_ref_id(pt), 0)
	# 4) Calculate light level
	var light_level = await light_probe.get_light_level_for_point(pt.position)
	if light_level < light_level_threshold:
		return null
	# 5) Calculate percent of coverage with AABBs <- TODO
	return PerceptionData.new(_find_ref_id(pt), light_level)


## Try looking at everything in range.
func try_perception() -> void:
	var perception_targets = get_tree()\
									.get_nodes_in_group("perception_target")\
									.filter(func(x:Node): return x is CollisionShape3D and (x as CollisionShape3D).position.distance_to(position) <= view_distance)
	# Loop through targets and get check info.
	for target in perception_targets:
		var res = await check_sees_collider(target)
		if res.visibility > 0: # If we see it, emit signal
			perceived.emit(res)
			# print("percieved %s" % res)
		else:
			not_perceived.emit(res)


func _find_ref_id(n:Node) -> String:
	var check:Node = n.get_parent()
	while check.get_parent():
		if check is Entity:
			return (check as Entity).name
		check = check.get_parent()
	return ""


# no wait we need to keep updating on a thing? 
class PerceptionData:
	var object:String
	var visibility:float
	
	func _init(obj:String, vis:float) -> void:
		object = obj
		visibility = vis
