class_name LightEstimation
extends Node3D

const interpolation_method:Image.Interpolation = Image.INTERPOLATE_BILINEAR
var svpt: SubViewport
var svpb: SubViewport
#@export var render_target: ViewportTexture


## Calculates a light level at a given point.
func get_light_level_for_point(point:Vector3) -> float:
	# Move the octahedron to point
	position = point
	# reset location
	await RenderingServer.frame_post_draw
	# camera render both sides
	var img:Image = svpt.get_texture().get_image()
	# resize to 1x1
	img.resize(1,1, interpolation_method)
	# return luminance
	var top = img.get_pixel(0,0).get_luminance()
	print(top)
	
	# Do the other thing for the other side 
	img = svpb.get_texture().get_image()
	img.resize(1,1, interpolation_method)
	var bottom = img.get_pixel(0,0).get_luminance()
	print(bottom)
	
	return (top + bottom) / 2 # average top and bottom


func _ready() -> void:
	svpt = $SViewportTop
	svpb = $SViewportBottom
	print(await get_light_level_for_point(Vector3()))
