class_name ItemComponent 
extends EntityComponent
## Keeps track of item data

## The data blob this item has.
@export var data: ItemData
## What inventory this item is in.
@onready var contained_inventory: Option = Option.none()
## Whether this item is in inventory or not.
var in_inventory:bool: 
	get:
		return contained_inventory.some()
# TODO: Item functions


func _init() -> void:
	name = "EntityComponent"


func _ready() -> void:
	super._ready()
	await parent_entity.instantiated
	if not $"../InteractiveComponent".interacted.is_connected(interact.bind()):
		$"../InteractiveComponent".interacted.connect(interact.bind())


func _on_enter_scene():
	_spawn()


func _spawn():
	print("spawning %s" % parent_entity.name)
	$"../PuppetSpawnerComponent".spawn(data.prefab)


func _on_exit_scene():
	print("despawn")
	_despawn()


func _despawn():
	$"../PuppetSpawnerComponent".despawn()


func _process(delta):
	if in_inventory:
		parent_entity.position = (SkeleRealmsGlobal.entity_manager.get_entity(contained_inventory.unwrap() as String).unwrap() as Entity).position


## Move this to another inventory. Adds and removes the item from the inventories.
func move_to_inventory(refID:String):
	# remove from inventory if we are in one
	if contained_inventory.some():
		SkeleRealmsGlobal.entity_manager\
			.get_entity(contained_inventory.unwrap())\
			.unwrap()\
			.get_component("InventoryComponent")\
			.unwrap()\
			.remove_from_inventory(parent_entity.name)
	
	# add to new inventory
	SkeleRealmsGlobal.entity_manager\
		.get_entity(refID)\
		.unwrap()\
		.get_component("InventoryComponent")\
		.unwrap()\
		.add_to_inventory(parent_entity.name)
	
	contained_inventory = Option.from(refID)
	
	if in_inventory:
		_despawn()


## Drop this on the ground.
func drop():
	contained_inventory = Option.none()
	_spawn() # Should check if we are in scene, although nothing should drop in the Ether


## Interact with this item. Called from [InteractiveComponent].
func interact(interacted_refID):
	move_to_inventory(interacted_refID)


func save() -> Dictionary:
	return {
		"contained_inventory" = contained_inventory.unwrap() if contained_inventory.some() else ""
	}


func load_data(data:Dictionary):
	contained_inventory =  Option.none() if data["contained_inventory"] == "" else Option.from(data["contained_inventory"])
