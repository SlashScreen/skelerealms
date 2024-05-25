@tool
class_name ItemInstance
extends InstanceData
## A single instance of an [ItemData] in the world.


@export var item_data:ItemData
@export var item_owner:String
@export var contained_inventory:String
@export var rotation:Quaternion = Quaternion.IDENTITY
@export var quest_item:bool = false


func get_archetype_components() -> Array[SKEntityComponent]:
	var components:Array[SKEntityComponent] = []
	# set up item component
	var item_component = ItemComponent.new()
	item_component.contained_inventory = contained_inventory
	item_component.name = "ItemComponent" # be sure to name them
	item_component.quest_item = quest_item
	item_component.item_owner = item_owner
	# Add new components
	components.append(item_component)
	components.append(InteractiveComponent.new())
	components.append(PuppetSpawnerComponent.new())
	if not _try_override_script(item_data.custom_script) == null:
		components.append(ScriptComponent.new(item_data.custom_script))
	
	return components



func convert_to_scene() -> PackedScene:
	var ps := PackedScene.new()
	
	var e := SKEntity.new()
	e.name = item_data.id
	InstanceData._transfer_properties(self, e)
	
	for c:SKEntityComponent in get_archetype_components():
		#InstanceData._transfer_properties(item_data, c)
		#InstanceData._transfer_properties(self, c)
		e.add_child(c)
		c.owner = e
		if c is PuppetSpawnerComponent:
			var p := item_data.prefab.instantiate()
			c.add_child(p)
			p.owner = e
	
	ps.pack(e)
	
	return ps
