@tool
class_name MarkerInstance
extends InstanceData


@export var rotation:Quaternion


func get_archetype_components() -> Array[SKEntityComponent]:
	return [MarkerComponent.new(rotation)]


func convert_to_scene() -> PackedScene:
	var ps := PackedScene.new()
	
	var e := SKEntity.new()
	e.name = ref_id
	InstanceData._transfer_properties(self, e)
	
	for c:SKEntityComponent in get_archetype_components():
		InstanceData._transfer_properties(self, c)
		e.add_child(c)
		c.owner = e
	
	ps.pack(e)
	
	return ps
