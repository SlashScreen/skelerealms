class_name ItemInstance
extends InstanceData
## A single instance of an [ItemData] in the world.

@export var item_data:ItemData
@export var item_owner:String
@export var contained_inventory:String
@export var rotation:Quaternion
# TODO: Set rotation, position, world

func get_archetype_components() -> Array[EntityComponent]:
	var components:Array[EntityComponent] = []
	# set up item component
	var item_component = ItemComponent.new()
	item_component.data = item_data
	item_component.contained_inventory = Option.wrap(contained_inventory)
	item_component.name = "ItemComponent" # be sure to name them
	# Add new components
	components.append(item_component)
	components.append(InteractiveComponent.new())
	components.append(PuppetSpawnerComponent.new())
	
	return components
