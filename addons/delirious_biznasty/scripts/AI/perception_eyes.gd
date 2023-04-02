class_name EyesPerception
extends Node3D
## This handles seeing, and it attached to the head of the character.


## FOV is the field of view of the eyes, in degrees. The default value is 90 degrees.
@export var fov:float = 90
@export var view_distance:float = 30

signal begin_perceiving(percieved:String)
signal end_perceiving(percieved:String)
