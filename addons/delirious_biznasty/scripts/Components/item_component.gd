class_name ItemComponent extends EntityComponent

@export var data: ItemData
var puppet:Node
var contained_inventory: Option
var in_inventory:bool: 
	get:
		return contained_inventory.some()
# TODO: Item functions

#func _ready():
#	($"../InteractiveComponent" as InteractiveComponent).interacted.connect(interact.bind())

func _is_in_inventory():
	return contained_inventory.some()

func _on_enter_scene():
	spawn()

func spawn():
	if not contained_inventory.some() : return
	
	print("spawn")
	var n = data.prefab.instantiate()
	(n as Node3D).set_position((get_parent() as Entity).position)
	puppet = n
	add_child(n)

func _on_exit_scene():
	print("despawn")
	despawn()

func despawn():
	for n in get_children():
		remove_child(n)
	puppet = null

func move_to_inventory(refID:String):
	contained_inventory = Option.from(refID)
	if not in_inventory:
		despawn()

func drop():
	contained_inventory = Option.none()
	spawn() # Should check if we are in scene, although nothing should drop in the Ether

func interact(refID):
	add_to_inventory(refID)
