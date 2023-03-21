class_name ItemComponent extends EntityComponent

const entity = preload("../entity_component.gd")

@export var data: ItemData

func _on_enter_scene():
	print("spawn")
	add_child(data.prefab.instantiate())

func _on_exit_scene():
	print("despawn")
	for n in get_children():
		remove_child(n)
