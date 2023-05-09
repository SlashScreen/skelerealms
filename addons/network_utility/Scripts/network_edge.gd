class_name NetworkEdge
extends Resource


@export var point_a:NetworkPoint
@export var point_b:NetworkPoint
@export var cost:float = 1
@export var bidirectional:bool = true


func _init(a:NetworkPoint = null, b:NetworkPoint = null, cost:float = 1, bidirectional:bool = true) -> void:
	self.point_a = a
	self.point_b = b
	self.cost = cost
	self.bidirectional = bidirectional
