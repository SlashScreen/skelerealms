class_name ItemComponent 
extends EntityComponent
## Keeps track of item data

## The data blob this item has.
@export var data: ItemData
var puppet:Node
## What inventory this item is in.
@onready var contained_inventory: Option = Option.none()
## Whether this item is in inventory or not.
var in_inventory:bool: 
	get:
		return contained_inventory.some()
# TODO: Item functions

#func _ready():
#	($"../InteractiveComponent" as InteractiveComponent).interacted.connect(interact.bind())

func _on_enter_scene():
	_spawn()


func _spawn():
	if contained_inventory.some() : return
	
	print("spawn")
	var n = data.prefab.instantiate()
	(n as Node3D).set_position((get_parent() as Entity).position)
	puppet = n
	add_child(n)


func _on_exit_scene():
	print("despawn")
	_despawn()


func _despawn():
	for n in get_children():
		remove_child(n)
	puppet = null


func _process(delta):
	if in_inventory:
		parent_entity.position = ((%EntityManager as EntityManager).get_entity(contained_inventory.unwrap() as String).unwrap() as Entity).position


## Move this to another inventory.
func move_to_inventory(refID:String):
	contained_inventory = Option.from(refID)
	if not in_inventory:
		_despawn()


## Drop this on the ground.
func drop():
	contained_inventory = Option.none()
	_spawn() # Should check if we are in scene, although nothing should drop in the Ether


## Interact with this item. Called from [InteractiveComponent].
func interact(refID):
	move_to_inventory(refID)
