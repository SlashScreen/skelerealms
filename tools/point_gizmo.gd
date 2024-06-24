extends EditorNode3DGizmoPlugin


func _get_gizmo_name() -> String:
	return "SKR Point Gizmos"


func _init() -> void:
	create_material("wm", Color(0,0,1))
	create_material("npc", Color(1,0,1))
	create_material("idle", Color(0,1,1))
	create_handle_material("handles")


func _has_gizmo(for_node_3d) -> bool:
	match for_node_3d.get_script():
		NPCSpawnPoint, IdlePoint:
			return true
		_:
			return false


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var mesh = SphereMesh.new()
	mesh.radius = 0.5
	gizmo.add_mesh(mesh, get_material(get_mat_for_node(gizmo.get_node_3d()), gizmo))


func get_mat_for_node(n:Node) -> String:
	match n.get_script():
		WorldMarker:
			return "wm"
		NPCSpawnPoint:
			return "npc"
		IdlePoint:
			return "idle"
		_:
			return ""
