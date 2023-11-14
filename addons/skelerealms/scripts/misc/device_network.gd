extends Node
## Singleton used for coordinating dungeon puzzle elements.


## Signal called when a device is updated. See [method update_device_state].
signal device_state_changed(device:StringName, value:Variant)


## Signal a device being updated. See [signal device_state_changed].
func update_device_state(device:StringName, value:Variant) -> void:
	device_state_changed.emit(device, value)
