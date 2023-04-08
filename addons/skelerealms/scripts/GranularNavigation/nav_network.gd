class_name NavNetwork
extends Resource
## A granular navigation network that allows agents to navigate outside of currently loaded scenes. 
## These are auto-converted to the K-D tree system on runtime, which is dumb.
## This whole thing is scuffed and may warrant a rewrite of some kind to be more efficient, but I need it to work 
## more than I need it to be efficient right now. 
## Could improve by having it turn itself into a K-D tree at build time, not runtime. 
#! This wretched thing could be a performance pain point.


## A single point in the network.
class NetPoint:
	extends Resource
	var point:Vector3
	var connections:Dictionary = {} # node : cost


	func connect_point(other:NetPoint, cost:float = 1) -> void:
		connections[other] = cost
		other.connections[self] = cost
	

	func _init(pt:Vector3) -> void:
		point = pt


## This portal allows you to link this network to other [NavNetwork]s.
class NetPortal: # no earthly idea how im going to make this intuitive
	extends NetPoint

	@export var id:StringName
	@export var other_side:NetPortal
	@export var world:StringName


@export var portals:Array[NetPortal] = []
@export var world:StringName
var _points:Array[NetPoint] = []


func add_point(pt:Vector3) -> void:
	_points.push_back(NetPoint.new(pt))
