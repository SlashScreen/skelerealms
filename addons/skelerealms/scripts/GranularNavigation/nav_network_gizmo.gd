class_name NavNetworkGizmo
extends EditorNode3DGizmoPlugin


# TODO: Allow undo redo
# TODO: Add portals

const RAY_LENGTH = 500

var associations:Array[NetPoint] = []
var _plugin



func _init(plugin:EditorPlugin) -> void:
	create_handle_material("handles")
	create_material("gizmo_mat", Color(0, 0, 1, 1))
	_plugin = plugin


func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is NavigationNetwork3D


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	associations.clear()

	var handle_points = PackedVector3Array()
	var i = 0

	var net = gizmo.get_node_3d() as NavigationNetwork3D
	associations.resize(net.network._points.size())
	var handle_idx:Array = [] # styupid but it should work now

	# Aggeregate lines?
	for pt in net.network._points:
		handle_points.append(pt.point)
		# draw spheres at points
		var t:Transform3D = Transform3D()
		t.origin = pt.point
		t.basis = t.basis.scaled(Vector3(0.3, 0.3, 0.3))
		var mesh = SphereMesh.new()
		gizmo.add_mesh(mesh, get_material("gizmo_mat", gizmo), t)
		gizmo.add_collision_triangles(mesh)
		# draw lines between all connections
		associations[i] = pt
		handle_idx.append(i)
		# TODO: Recurse
		for c in pt.connections:
			var pts = PackedVector3Array()
			pts.append(pt.point)
			pts.append(c.point)
			gizmo.add_lines(pts, get_material("gizmo_mat", gizmo))
		
		i += 1
	
	gizmo.add_handles(handle_points, get_material("handles", gizmo), handle_idx)


func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2) -> void:
	var pt = associations[handle_id]
	var from = camera.project_ray_origin(screen_pos)
	var to = from + (camera.project_ray_normal(screen_pos) * RAY_LENGTH)
	var ray = PhysicsRayQueryParameters3D.create(from, to)
	await gizmo.get_node_3d().get_tree().physics_frame
	var hits = gizmo.get_node_3d().get_world_3d().direct_space_state.intersect_ray(ray)
	#print(handle_id)
	#print(hits)
	if hits:
		pt.point = hits["position"] as Vector3
		_redraw(gizmo) # TODO: Don't update the whole thing (?)


func _get_gizmo_name() -> String:
	return "Navigation Network (Skelerealms)"
