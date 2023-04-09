class_name NavNetwork
extends Resource
## A granular navigation network that allows agents to navigate outside of currently loaded scenes. 
## These are auto-converted to the K-D tree system on runtime, which is dumb.
## This whole thing is scuffed and may warrant a rewrite of some kind to be more efficient, but I need it to work 
## more than I need it to be efficient right now. 
## Could improve by having it turn itself into a K-D tree at build time, not runtime. 
#! This wretched thing could be a performance pain point.


@export var portals:Array[NetPortal] = []
@export var world:StringName
@export var _points:Array[NetPoint] = []


func add_point(pt:Vector3) -> void:
	_points.push_back(NetPoint.new(pt))
