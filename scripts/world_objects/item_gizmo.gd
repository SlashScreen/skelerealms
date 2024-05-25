extends EditorNode3DGizmoPlugin


func _init():
	create_material("main", Color(1,0,0))
	create_handle_material("handles")


func _has_gizmo(node):
	return node is WorldItem


func _redraw(gizmo:EditorNode3DGizmo):
	#TODO: This doe s not sync every frame
	gizmo.clear()
	
	var item:WorldItem = gizmo.get_node_3d()
	var mesh:Mesh = SphereMesh.new()
	if item.instance:
		#shit, how do I set the world?...
		var prefab:Node = item.instance.item_data.prefab.instantiate()
		if item.get_child_count() > 0:
			if not item.get_child(0) == prefab:
				item.remove_child(item.get_child(0))
				item.add_child(prefab)
				prefab.owner = item
		else:
			item.add_child(prefab)
			prefab.owner = item
	else:
		if item.get_child_count() > 0:
			item.remove_child(item.get_child(0))
	
	var tri_mesh = BoxMesh.new().create_trimesh_shape()
	
	#gizmo.add_mesh(mesh, get_material("main", gizmo))
	#gizmo.add_collision_triangles(tri_mesh)


func _get_gizmo_name() -> String:
	return "World item"
