class_name NavNetwork
extends Resource


class NetPoint:
	var point:Vector3
	var connections:Dictionary = {} # node : cost


	func connect_point(other:NetPoint, cost:float = 1) -> void:
		connections[other] = cost
		other.connections[self] = cost
	

	func _init(pt:Vector3) -> void:
		point = pt


var _points:Array[NavPoint] = []


# TODO: Allow for cross-world conenctions. Add portal object?
func add_point(pt:Vector3) -> void:
	_points.push_back(NetPoint.new(pt))
