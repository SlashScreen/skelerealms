class_name ChestInstance
extends InstanceData


@export var owner:String
@export var reset_time_minutes:int
@export var owner_id:StringName
var current_inventory:Array[String]


func get_archetype_components() -> Array[SKEntityComponent]:
	return [
		InventoryComponent.new(),
		]
