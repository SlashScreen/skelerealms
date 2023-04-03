class_name LightEstimation
extends Node3D


var svp: SubViewport
var cam_parent:Node3D
#@export var render_target: ViewportTexture


## Calculates a light level at a given point.
func get_light_level_for_point(point:Vector3) -> float:
	# Move the octahedron to point
	position = point
	# reset location
	cam_parent.rotation = Vector3()
	await RenderingServer.frame_post_draw
	# camera render both sides
	var img:Image = svp.get_texture().get_image()
	# resize to 1x1
	img.resize(1,1, Image.INTERPOLATE_TRILINEAR)
	# return luminance
	var top = img.get_pixel(0,0).get_luminance()
	print(top)
	
	# Do the other thing for the other side 
	cam_parent.rotate_z(180) # flip camera 'round
	await RenderingServer.frame_post_draw
	img = svp.get_texture().get_image()
	img.resize(1,1, Image.INTERPOLATE_TRILINEAR)
	var bottom = img.get_pixel(0,0).get_luminance()
	print(bottom)
	
	return (top + bottom) / 2 # average top and bottom


func _ready() -> void:
	svp = $RenderWindow
	cam_parent = $RenderWindow/Node3D
	print(await get_light_level_for_point(Vector3()))
