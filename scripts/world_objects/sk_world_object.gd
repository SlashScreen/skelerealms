class_name SKWorldObject
extends Node3D


## This is the base class for non-entity objects affected by Skelerealms concepts.
## This base class is needed to interact with the message broadcasting system used by [class StatusEffect]s - see [class EffectsObject].
## [b]Please Note:[/b] I am still not 100% sure about this design decision, and this system may change in the future.


## A list of nodes that will have messages broadcast to them.
var _neighbors:Array[SKWorldObject] = []


func _ready() -> void:
	_collect_neighbors()
	get_parent().child_order_changed.connect(_collect_neighbors.bind())


## Broadcast messages to siblings and parent of this node (if they are SKWorldObjects).
func broadcast_message(msg:StringName, args:Array = []) -> void:
	for n:SKWorldObject in _neighbors:
		n.receive_message(msg, args)


## Override this to handle receiving messages.
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
