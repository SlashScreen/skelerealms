@tool
class_name ChestComponent
extends SKEntityComponent


## Optionally refreshing inventories.


@onready var loot_table:SKLootTable = get_child(0)
@export_range(0, 100, 1, "or_greater") var reset_time_minutes:int ## How long it takes to refresh this chest, in in-game minutes. 0 will not refresh.
@export var owner_id:StringName
var looted_time:Timestamp


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if reset_time_minutes > 0:
		GameInfo.minute_incremented.connect(_check_should_restore.bind())
	# If none provided, just generate a dummy loot table that will do nothing.
	if loot_table == null:
		var nlt := SKLootTable.new()
		add_child(nlt)
		loot_table = nlt


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
	
	for id:PackedScene in res.items:
		var e:SKEntity = SKEntityManager.instance.add_entity(id)
		ic.add_to_inventory(e.name)
	ic.currencies = res.currencies


func on_generate() -> void:
	reroll()


func get_dependencies() -> Array[String]:
	return [
		"InventoryComponent",
	]
