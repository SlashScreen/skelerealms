class_name ItemComponent 
extends EntityComponent
## Keeps track of item data


const DROP_DISTANCE:float = 2

## The data blob this item has.
@export var data: ItemData
## What inventory this item is in.
@onready var contained_inventory: Option = Option.none()
## Whether this item is in inventory or not.
var in_inventory:bool: 
	get:
		return contained_inventory.some()
var quest_item:bool
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
		parent_entity.position = (SkeleRealmsGlobal.entity_manager.get_entity(contained_inventory.unwrap()).unwrap() as Entity).position
		parent_entity.world = (SkeleRealmsGlobal.entity_manager.get_entity(contained_inventory.unwrap()).unwrap() as Entity).world


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
	
	# drop if moved to inventory is empty
	if refID == "":
		drop()
		return
	
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
	var e:Entity = SkeleRealmsGlobal.entity_manager.get_entity(contained_inventory.unwrap()).unwrap()
	var drop_dir:Quaternion = e.rotation
	print(drop_dir.get_euler().normalized() * DROP_DISTANCE)
	# This whole bit is genericizing dropping the item in front of the player. It's meant to be used with the player, it should work with anything with a puppet. 
	
	# raycast in front of puppet if possible to do wall check
	var psc = e.get_component("PuppetSpawnerComponent")
	if e.in_scene and psc.some():
		print("has puppet component, in scene")
		if psc.unwrap().puppet:
			print("puppet exists")
			# construct raycast
			var from = parent_entity.position + Vector3(0, 1.5, 0)
			var to = parent_entity.position + Vector3(0, 1.5, 0) + (drop_dir.get_euler().normalized() * DROP_DISTANCE)
			var query = PhysicsRayQueryParameters3D.create(from, to, 0xFFFFFFFF, SkeleRealmsGlobal.get_child_rids(psc.unwrap().puppet))
			await get_tree().physics_frame
			var space = (psc.unwrap().puppet as Node3D).get_world_3d().direct_space_state
			
			var res = space.intersect_ray(query)
			if res.is_empty():
				# else spawn in front
				print("didn't hit anything")
				parent_entity.position = to
				contained_inventory = Option.none()
				_spawn() # Should check if we are in scene, although nothing should drop in the Ether
				return
			else:
				# if hit something, spawn at hit position
				print(res)
				parent_entity.position = res["position"] # TODO: Compensate for item size
				contained_inventory = Option.none()
				_spawn() # Should check if we are in scene, although nothing should drop in the Ether
				return
	
	parent_entity.position = parent_entity.position + Vector3(0, 1.5, 0)
	
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
	contained_inventory = Option.none() if data["contained_inventory"] == "" else Option.from(data["contained_inventory"])
