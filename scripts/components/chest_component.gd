class_name ChestComponent
extends SKEntityComponent


## Optionally refreshing inventories.


@export var loot_table:SKLootTable
@export_range(0, 100, 1, "or_greater") var reset_time_minutes:int ## How long it takes to refresh this chest, in in-game minutes. 0 will not refresh.
var looted_time:Timestamp
var owner_id:StringName


func _init(oid:StringName = &"", lt:SKLootTable = null, rt:int = -1) -> void:
	owner_id = oid
	loot_table = lt
	reset_time_minutes = rt


func _ready() -> void:
	reroll()
	if reset_time_minutes > 0:
		GameInfo.minute_incremented.connect(_check_should_restore.bind())


func _check_should_restore() -> void:
	if not looted_time:
		return
	if parent_entity.in_scene or Timestamp.dict_to_minutes(Timestamp.build_from_world_timestamp().time_since(looted_time)) < reset_time_minutes: # will not refresh while in scene
		return
	clear()
	reroll()


func clear() -> void:
	var ic:InventoryComponent = parent_entity.get_component("InventoryComponent")
	for i:StringName in ic.inventory:
		SKEntityManager.instance.remove_entity(i)
	ic.inventory.clear() # Doing this instead of the remove item function since looping and removing stuff is bad and I don't need the signal
	ic.currencies.clear()


func reroll() -> void:
	var ic:InventoryComponent = parent_entity.get_component("InventoryComponent")
	var res: Dictionary = loot_table.resolve()
	
	for id:ItemData in res.items:
		var item: ItemInstance = ItemInstance.new()
		item.item_data = id
		item.contained_inventory = String(parent_entity.name)
		item.item_owner = owner_id
		item.ref_id = preload("res://addons/skelerealms/scripts/vendor/uuid.gd").v4()
		
		var e:SKEntity = SKEntityManager.instance.add_entity(item)
		ic.add_to_inventory(e.name)
	
	ic.currencies = res.currencies
