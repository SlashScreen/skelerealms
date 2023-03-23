class_name NPCComponent 
extends EntityComponent
## The brain for an NPC.


## Base data for this NPC.
@export var data: NPCData

#func _ready():
#	($"../InteractiveComponent" as InteractiveComponent).interacted.connect(interact.bind())


func _on_enter_scene():
	$"../PuppetSpawnerComponent".spawn(data.prefab)



func _on_exit_scene():
	$"../PuppetSpawnerComponent".despawn()


# TODO: Behaviour
## Interact with this npc. See [InteractiveComponent].
func interact(refID:String):
	pass
