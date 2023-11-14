class_name EquippableDataComponent
extends ItemDataComponent


@export var valid_slots:Array[EquipmentSlots.Slots]
@export var override_texture: Texture2D
@export var override_material: Material
@export var override_model: PackedScene


func get_type() -> String:
	return "EquippableDataComponent"
