@tool
class_name MarkerComponent
extends SKEntityComponent
## Component that represents a world marker with rotation information.
## Used to mark positions and orientations in the world, with editor visualization support.

var rotation:Quaternion  ## The rotation of the marker in world space


func _init(rot:Quaternion = Quaternion.IDENTITY) -> void:
	name = &"MarkerComponent"
	rotation = rot


## Applies the stored rotation to the parent entity
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super._ready()
	parent_entity.rotation = rotation


## Creates a visual representation of the marker for the editor. Returns a blue semi-transparent sphere.
func get_world_entity_preview() -> Node:
	var sphere := MeshInstance3D.new()
	sphere.mesh = SphereMesh.new()
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.BLUE
	mat.albedo_color.a = 0.5
	
	sphere.set_surface_override_material(0, mat)
	return sphere
