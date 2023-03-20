class_name MeshComponent extends EntityComponent

const entity = preload("../entity_component.gd")

@export var prefab: PackedScene

func _on_enter_scene():
	print("spawn")
	add_child(prefab.instantiate())

func _on_exit_scene():
	print("despawn")
	for n in get_children():
		remove_child(n)
