class_name ChestInstance
extends InstanceData


@export var owner:String
@export var reset_time_minutes:int
@export var owner_id:StringName
var current_inventory:PackedStringArray


func get_archetype_components() -> Array[SKEntityComponent]:
	return [
		ChestComponent.new(),
		InventoryComponent.new(),
		]


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
