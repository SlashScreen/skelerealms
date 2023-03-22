class_name ItemComponent extends EntityComponent

const entity = preload("../entity_component.gd")

@export var data: ItemData
var puppet:Node
# TODO: Item functions

#func _ready():
#	($"../InteractiveComponent" as InteractiveComponent).interacted.connect(interact.bind())

func _on_enter_scene():
	print("spawn")
	var n = data.prefab.instantiate()
	(n as Node3D).set_position((get_parent() as Entity).position)
	puppet = n
	add_child(n)

func _on_exit_scene():
	print("despawn")
	for n in get_children():
		remove_child(n)
	puppet = null

func interact(refID):
	pass
