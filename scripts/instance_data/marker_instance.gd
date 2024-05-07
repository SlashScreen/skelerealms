class_name MarkerInstance
extends InstanceData


@export var rotation:Quaternion


func get_archetype_components() -> Array[SKEntityComponent]:
	return [MarkerComponent.new(rotation)]
