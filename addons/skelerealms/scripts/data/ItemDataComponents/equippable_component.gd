class_name EquippableDataComponent
extends ItemDataComponent

@export var valid_slots:Array[EquipmentSlots.Slots]


func get_type() -> String:
	return "EquippableDataComponent"
