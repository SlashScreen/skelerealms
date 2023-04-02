class_name ChestInstance
extends InstanceData


@export var owner:String
@export var loot_table:LootTable
@export var reset_time:Timestamp
var current_inventory:Array[String]


func get_archetype_components() -> Array[EntityComponent]:
	var inv:InventoryComponent = InventoryComponent.new()
	inv.snails = loot_table.resolve_snails() # generate snails
	var instances = loot_table.resolve_table_to_instances()
	for i in instances:
		# item instances will automatically sync with this world and position
		i.contained_inventory = ref_id # set contained inventory to this, since it's in the chest
		i.item_owner = owner # add owner, if applicable
		inv.inventory.append(i.ref_id) # add to inventory
		BizGlobal.entity_manager.add_entity(i) # add the item to the world
	return [inv]
