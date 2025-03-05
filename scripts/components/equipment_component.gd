class_name EquipmentComponent
extends SKEntityComponent
## Component that manages equipment slots and item equipping/unequipping.
## Handles validation of equipment slots and maintains equipment state.

var equipment_slot:Dictionary  ## Maps slot names to equipped item RefIDs

signal equipped(item:StringName, slot:StringName)  ## Emitted when an item is equipped to a slot
signal unequipped(item:StringName, slot:StringName)  ## Emitted when an item is removed from a slot


func _init() -> void:
	name = &"EquipmentComponent"


func _ready() -> void:
	super._ready()


## Attempts to equip an item to a specified slot. Returns true if successful.
## [param item] RefID of the item to equip
## [param slot] Name of the slot to equip to
## [param silent] Whether to suppress equipped signal
func equip(item:StringName, slot:StringName, silent:bool = false) -> bool:
	# Get component
	var e = SKEntityManager.instance.get_entity(item)
	if not e:
		return false
	# Get item component
	var ic = e.get_component(&"ItemComponent")
	if not ic:
		return false
	# Get equippable data component
	var ec = (ic as ItemComponent).get_component(&"EquippableDataComponent")
	if not ec:
		return false
	# Check slot validity
	if not (ec as EquippableDataComponent).valid_slots.has(slot):
		return false
	# Unequip if already in slot so we can put it in a new slot
	unequip_item(item)

	equipment_slot[slot] = item
	if not silent:
		equipped.emit(item, slot)
	return true


## Removes any item currently equipped in the specified slot
## [param slot] The slot to clear
## [param silent] Whether to suppress unequipped signal
func clear_slot(slot:StringName, silent:bool = false) -> void:
	if equipment_slot.has(slot):
		var to_unequip = equipment_slot[slot]
		equipment_slot[slot] = null
		if not silent:
			unequipped.emit(to_unequip, slot)


## Unequips a specific item from any slot it's equipped in
## [param item] RefID of the item to unequip
## [param silent] Whether to suppress unequipped signal
func unequip_item(item:StringName, silent:bool = false) -> void:
	for s in equipment_slot:
		if equipment_slot[s] == item:
			equipment_slot[s] = null
			if not silent:
				unequipped.emit(item, s)
			return


## Checks if a specific item is equipped in a specific slot. Returns true if the item is in the slot.
## [param item] RefID of the item to check
## [param slot] Name of the slot to check
func is_item_equipped(item:StringName, slot:StringName) -> bool:
	if not equipment_slot.has(slot):
		return false
	return equipment_slot[slot] == item


## Gets the item equipped in a slot. Returns Option containing the item RefID, or none if empty.
## [param slot] Name of the slot to check
func is_slot_occupied(slot:StringName) -> Option:
	if equipment_slot.has(slot):
		return Option.wrap(equipment_slot[slot])
	else:
		return Option.none()
