class_name MarkerComponent
extends EntityComponent
## Component tag for [WorldMarker]s.


var rotation:Quaternion


func _init(rot:Quaternion) -> void:
	name = "MarkerComponent"
	rotation = rot


func _ready() -> void:
	super._ready()
	parent_entity.rotation = rotation
