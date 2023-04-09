class_name NavNetworkGizmo
extends EditorNode3DGizmoPlugin


func _init() -> void:
	create_handle_material("handles")
	create_material("gizmo_mat", Color(0, 0, 1, 1))


func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is NavigationNetwork3D


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var handle_points = PackedVector3Array()

	var net = gizmo.get_node_3d() as NavigationNetwork3D
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
		# TODO: Recurse
		for c in pt.connections:
			var pts = PackedVector3Array()
			pts.append(pt.point)
			pts.append(c.point)
			gizmo.add_lines(pts, get_material("gizmo_mat", gizmo))
	
	gizmo.add_handles(handle_points, get_material("handles", gizmo), [])


func _get_gizmo_name() -> String:
	return "Navigation Network (Skelerealms)"
