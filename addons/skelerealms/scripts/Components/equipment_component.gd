class_name EquipmentComponent
extends EntityComponent


var equipment_slot:Dictionary


func _init() -> void:
	name = "EquipmentComponent"


func _ready() -> void:
	super._ready()


func equip(item:String, slot:EquipmentSlots.Slots) -> void:
	# TODO: Check slot
	equipment_slot[slot] = item
