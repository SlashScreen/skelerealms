class_name MarkerComponent
extends EntityComponent
## Component tag for [WorldMarker]s.


func _init(rot:Quaternion) -> void:
	parent_entity.rotation = rot
