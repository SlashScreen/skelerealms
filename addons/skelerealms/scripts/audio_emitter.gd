class_name AudioEventEmitter
extends AudioStreamPlayer3D # TODO: Allow any backend
## Used to emit sounds that should have an effect on other things, like alerting NPCs.


@export var ignore_self:bool = false


## Finds every node of group "audio_listener" in a radius of unit_size using a physics shape cast, and attempts to call method "heard_audio" on it, passing self as an argument.
func play_event():
	# TODO: Make it less physics based?
	play()
	var space_state = get_world_3d().direct_space_state # get space state
	# create query
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = SphereShape3D.new()
	# create query position
	var t = Transform3D()
	t.origin = position
	t.scaled(Vector3(unit_size, unit_size, unit_size)) # scale to match radius
	query.transform = t
	# make query
	var res = space_state.intersect_shape(query)
	# if ignoring self, filter out all nodes part of this tree
	if ignore_self:
		res = res.filter(func(x:Dictionary):
			return not (x["collider"] as Node).is_ancestor_of(self) and not (x["collider"] as Node).find_child(self.name)
		)
	res.filter(func(x:Node): return x.is_in_group("audio_listener"))
	# return results, where all colliders are selected from it.
	for n in  res.map(func(x:Dictionary): return x["collider"] as Node)\
			.filter(func(x:Node): return x.has_method("heard_audio")):
		n.heard_audio(self)
