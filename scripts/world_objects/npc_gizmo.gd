extends EditorNode3DGizmoPlugin


func _init():
	create_material("main", Color(1,0,0))
	create_handle_material("handles")


func _has_gizmo(node):
	return node is WorldNPC


func _redraw(gizmo:EditorNode3DGizmo):
	#TODO: This does not sync every frame
	gizmo.clear()
	
	var npc:WorldNPC = gizmo.get_node_3d()
	var mesh:Mesh = SphereMesh.new()
	if npc.instance:
		#shit, how do I set the world?...
		var prefab:Node = npc.instance.npc_data.prefab.instantiate()
		if npc.get_child_count() > 0:
			if not npc.get_child(0) == prefab:
				npc.remove_child(npc.get_child(0))
				npc.add_child(prefab)
				prefab.owner = npc
		else:
			npc.add_child(prefab)
			prefab.owner = npc
	else:
		if npc.get_child_count() > 0:
			npc.remove_child(npc.get_child(0))
	
	var tri_mesh = BoxMesh.new().create_trimesh_shape()
	
	#gizmo.add_mesh(mesh, get_material("main", gizmo))
	#gizmo.add_collision_triangles(tri_mesh)

func _get_gizmo_name() -> String:
	return "NPC item"
