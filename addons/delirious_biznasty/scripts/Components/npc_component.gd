class_name NPCComponent extends EntityComponent

const entity = preload("../entity_component.gd")
var puppet: NPCPuppet
@export var data: NPCData

#func _ready():
#	($"../InteractiveComponent" as InteractiveComponent).interacted.connect(interact.bind())

func _on_enter_scene():
	print("spawn")
	var n = data.prefab.instantiate()
	puppet = n as NPCPuppet
	(n as Node3D).set_position((get_parent() as Entity).position)
	add_child(n)

func _on_exit_scene():
	print("despawn")
	for n in get_children():
		remove_child(n)
	puppet = null

# TODO: Behaviour
func interact(refID:String):
	pass
