class_name ItemComponent extends EntityComponent

const entity = preload("../entity_component.gd")

@export var data: ItemData

func _on_enter_scene():
	print("spawn")
	var n = data.prefab.instantiate()
	(n as Node3D).set_position((get_parent() as Entity).position)
	add_child(n)

func _on_exit_scene():
	print("despawn")
	for n in get_children():
		remove_child(n)
