class_name AnimationController
extends Node

## This is a basic abstraction layer for animations. Use of this is purely optional.
## Place this node just under a puppet node, and connect various other nodes meant to control different aspects of animation somewhere beneath it in the tree,
## And have them subscribe to the signals here to receive animation events from the puppet.


signal value_set(key:StringName, value:Variant)
signal triggered(key:StringName)
signal swapped(now_true:StringName, now_false:StringName)


var root_motion_callback:Callable = func(): return Vector3(0,0,0)
var root_rotation_callback:Callable = func(): return Vector3(0,0,0)
var root_scale_callback:Callable = func(): return Vector3(0,0,0)


func set_value(key:StringName, value:Variant) -> void:
	value_set.emit(key, value)


func trigger(key:StringName) -> void:
	triggered.emit(key)


func swap(now_true:StringName, now_false:StringName) -> void:
	swapped.emit(now_true, now_false)


## Use this to find the controller in the tree.
static func get_animator(n: Node) -> AnimationController:
	if n.get_parent() == null:
		return null
	
	for x in n.get_parent().get_children():
		if x is AnimationController:
			return x
	
	return get_animator(n.get_parent())
