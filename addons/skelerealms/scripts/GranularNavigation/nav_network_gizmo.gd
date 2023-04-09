class_name NavNetworkGizmo
extends EditorNode3DGizmoPlugin


const mat:Material = preload("res://addons/skelerealms/scripts/GranularNavigation/gizmo_mat.tres")


func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is NavigationNetwork3D


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()

	var net = gizmo.get_node_3d() as NavigationNetwork3D
	# Aggeregate lines?
	for pt in net.network._points:
		# draw spheres at points
		var t:Transform3D = Transform3D()
		t.origin = pt.point
		t.basis = t.basis.scaled(Vector3(0.3, 0.3, 0.3))
		gizmo.add_mesh(SphereMesh.new(), mat, t)
		# draw lines between all connections
		# TODO: Recurse
		for c in pt.connections:
			var pts = PackedVector3Array()
			pts.append(pt.point)
			pts.append(c.point)
			gizmo.add_lines(pts, mat)


func _get_gizmo_name() -> String:
	return "Navigation Network (Skelerealms)"
