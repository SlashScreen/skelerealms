class_name NetworkGizmo
extends EditorNode3DGizmoPlugin


const RAY_LENGTH:float = 500

## Association of handle index to associated point.
var handle_associations:Array[NetworkPoint] = []
## The most recent selected point.
var last_modified:NetworkPoint:
	get:
		return last_modified
	set(val):
		# Prevent spam by checking if val is different
		if last_modified == val:
			return
		second_last_modified = last_modified # move value to the second last modified
		last_modified = val
## Second last point that was selected.
var second_last_modified:NetworkPoint

var _plugin:EditorPlugin


func _init() -> void:
	create_material("edge", Color(0, 1, 0)) # Edge color
	create_material("point_unselected", Color(0, 0, 1)) # Color for normal points
	create_material("point_select0", Color(1, 0, 0)) # Color for recently selected points
	create_material("point_select1", Color(1, 1, 0)) # Color for second most recently selected points
	create_handle_material("handles")


func _get_gizmo_name() -> String:
	return "Network"


func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is NetworkInstance


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()

	if gizmo.get_node_3d().network.points.size() == 0:
		return

	# For each node:
	var mesh = SphereMesh.new()

	# Handle stuff
	var handle_pts = PackedVector3Array()
	handle_associations.clear() # Clear the array
	handle_associations.resize(gizmo.get_node_3d().network.points.size()) # Set associations size so we can just set indexes
	var handle_idx:Array[int] = [] # We use these to assign indexes when adding the handles. Theoretically it would be fine without this but we want to be sure
	var idx:int = 0

	for n in gizmo.get_node_3d().network.points:
		# set transform
		var t = Transform3D()
		t = t.scaled(Vector3(0.1, 0.1, 0.1))
		t.origin = n.position
		# Draw node sphere and handle
		handle_pts.append(n.position)
		gizmo.add_mesh(CylinderMesh.new() if n is NetworkPortal else mesh, _get_material_for_point(n, gizmo), t)
		# Handle indexes
		handle_associations[idx] = n
		handle_idx.append(idx)
		idx += 1
	
	# Then for each edge:
	var pts = PackedVector3Array()
	for e in gizmo.get_node_3d().network.edges:
		# Add line points
		pts.append(e.point_a.position)
		pts.append(e.point_b.position)
	
	# Then draw lines
	gizmo.add_lines(pts, get_material("edge", gizmo))

	# Add handles
	gizmo.add_handles(handle_pts, get_material("handles", gizmo), handle_idx)


func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2) -> void:
	# get associated point
	var pt = handle_associations[handle_id]
	# Create ray
	var from = camera.project_ray_origin(screen_pos)
	var to = from + (camera.project_ray_normal(screen_pos) * RAY_LENGTH)
	var ray = PhysicsRayQueryParameters3D.create(from, to)
	# Wait to be able to get physics info
	await gizmo.get_node_3d().get_tree().physics_frame
	# Cast ray
	var hits = gizmo.get_node_3d().get_world_3d().direct_space_state.intersect_ray(ray)
	if hits:
		pt.position = hits["position"] as Vector3 # Set point position to handle
		last_modified = pt # set last modified
		_redraw(gizmo) # TODO: Don't update the whole thing (?)


func _commit_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, restore, cancel: bool) -> void:
	# print("Commit handle %s that has restore %s " % [handle_id, restore])
	# get associated point
	var pt = handle_associations[handle_id]
	# restore if cancel
	if cancel:
		#pt.position = restore
		return
	

	""" var ur = _plugin.get_undo_redo()
	ur.create_action("Move Network Point")
	ur.add_do_property(pt, "position", pt.position)
	ur.add_undo_property(pt, "position", restore)
	ur.commit_action() """


## Get the material for the point. This changed the material based on how recently it was selected.
func _get_material_for_point(pt:NetworkPoint, gizmo: EditorNode3DGizmo) -> Material:
	# If last modified
	if last_modified == pt:
		return get_material("point_select0", gizmo)
	# If second last modified
	if second_last_modified == pt:
		return get_material("point_select1", gizmo)
	# Else unselected
	return get_material("point_unselected", gizmo)
