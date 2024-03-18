class_name SKWorldObject
extends Node3D


var _neighbors:Array[SKWorldObject] = []


func _ready() -> void:
	_collect_neighbors()


func broadcast_message(msg:StringName, args:Array = []) -> void:
	for n:SKWorldObject in _neighbors:
		n.receive_message(msg, args)


func receive_message(_msg:StringName, _args:Array = []) -> void:
	return


func _collect_neighbors() -> void:
	_neighbors.clear()
	if get_parent() is SKWorldObject:
		_neighbors.append(get_parent())
	for c:Node in get_parent().get_children():
		if c == self:
			continue
		if c is SKWorldObject:
			_neighbors.append(c)
