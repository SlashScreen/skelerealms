class_name DeviceEmitter
extends Node


@export var device_name:StringName


func emit_state(state:Variant) -> void:
	DeviceNetwork.update_device_state(device_name, state)
