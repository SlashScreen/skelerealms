@tool
class_name ChestComponent
extends SKEntityComponent
## Component that manages a container with resettable inventory and loot generation.
## Supports automatic loot table generation and timed inventory refresh.

@onready var loot_table:SKLootTable = get_child(0)  ## Reference to the loot table that determines container contents
@export_range(0, 100, 1, "or_greater") var reset_time_minutes:int  ## Time in game minutes before chest contents refresh (0 = never)
@export var owner_id:StringName  ## ID of the entity that owns this chest
var looted_time:Timestamp  ## Timestamp of when the chest was last looted


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if reset_time_minutes > 0:
		GameInfo.minute_incremented.connect(_check_should_restore.bind())
	# Create default empty loot table if none exists
	if loot_table == null:
		var nlt := SKLootTable.new()
		add_child(nlt)
		loot_table = nlt


## Checks if the chest should restore its contents based on time elapsed
func _check_should_restore() -> void:
	if not looted_time:
		return
	if parent_entity.in_scene or Timestamp.dict_to_minutes(Timestamp.build_from_world_timestamp().time_since(looted_time)) < reset_time_minutes:
		return
	clear()
	reroll()


## Removes all items and currency from the chest
func clear() -> void:
	var ic:InventoryComponent = parent_entity.get_component(&"InventoryComponent")
	for i:StringName in ic.inventory:
		SKEntityManager.instance.remove_entity(i)
	ic.inventory.clear() # Doing this instead of the remove item function since looping and removing stuff is bad and I don't need the signal
	ic.currencies.clear()


## Generates new contents for the chest using its loot table
func reroll() -> void:
	var ic:InventoryComponent = parent_entity.get_component(&"InventoryComponent")
	var res: Dictionary = loot_table.resolve()
	
	for id:PackedScene in res.items:
		var e:SKEntity = SKEntityManager.instance.add_entity(id)
		ic.add_to_inventory(e.name)
	for id:StringName in res.entities:
		ic.add_to_inventory(id)
	ic.currencies = res.currencies


## Initializes chest contents when the entity is first generated
func on_generate() -> void:
	reroll()


## Lists the components required by this component. Returns array of component names.
func get_dependencies() -> Array[String]:
	return [
		&"InventoryComponent",
	]
