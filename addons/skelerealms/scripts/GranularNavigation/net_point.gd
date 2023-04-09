## A single point in the network.
class_name NetPoint
extends Resource


@export var point:Vector3
@export var connections:Dictionary = {} # node : cost


func connect_point(other:NetPoint, cost:float = 1) -> void:
	connections[other] = cost
	other.connections[self] = cost
	

func _init(pt:Vector3) -> void:
	point = pt
