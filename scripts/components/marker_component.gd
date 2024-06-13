@tool
class_name MarkerComponent
extends SKEntityComponent
## Component tag for [WorldMarker]s.


var rotation:Quaternion


func _init(rot:Quaternion = Quaternion.IDENTITY) -> void:
	name = "MarkerComponent"
	rotation = rot


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super._ready()
	parent_entity.rotation = rotation


func get_world_entity_preview() -> Node:
	var sphere := MeshInstance3D.new()
	sphere.mesh = SphereMesh.new()
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.BLUE
	mat.albedo_color.a = 0.5
	
	sphere.set_surface_override_material(0, mat)
	return sphere
