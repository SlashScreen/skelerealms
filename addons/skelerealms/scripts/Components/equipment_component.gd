class_name EquipmentComponent
extends EntityComponent


var equipment_slot:Dictionary

signal equipped(item:StringName, slot:EquipmentSlots.Slots)
signal unequipped(item:StringName, slot:EquipmentSlots.Slots)


func _init() -> void:
	name = "EquipmentComponent"


func _ready() -> void:
	super._ready()


func equip(item:StringName, slot:EquipmentSlots.Slots) -> bool:
	# Get component
	var e = SkeleRealmsGlobal.entity_manager.get_entity(item)
	if not e.some():
		return false
	# Get item component
	var ic = e.unwrap().get_component("ItemComponent")
	if not ic.some():
		return false
	# Get equippable data component
	var ec = (ic.unwrap() as ItemComponent).data.get_component("EquippableDataComponent")
	if not ec.some():
		return false
	# Check slot validity
	if not (ec.unwrap() as EquippableDataComponent).valid_slots.has(slot):
		return false
	# Unequip if already in slot so we ca nput it in a new slot
	unequip_item(item)
	
	equipment_slot[slot] = item
	equipped.emit(item, slot)
	return true


## Unequip anything in a slot.
func clear_slot(slot:EquipmentSlots.Slots) -> void:
	if equipment_slot[slot]:
		unequipped.emit(equipment_slot[slot], slot)
		equipment_slot[slot] = null


## Unequip a specific item, no matter what slot it's in.
func unequip_item(item:StringName) -> void:
	for s in equipment_slot:
		if equipment_slot[s] == item:
			unequipped.emit(item, s)
			equipment_slot[s] = null
			return


func is_item_equipped(item:StringName, slot:EquipmentSlots.Slots) -> bool:
	if not equipment_slot.has(slot):
		return false
	return equipment_slot[slot] == item
