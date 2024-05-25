class_name NPCTemplateOption
extends Resource


@export var template:PackedScene
@export_range(0, 1) var chance:float = 1


func resolve() -> bool:
	return randf() <= chance
