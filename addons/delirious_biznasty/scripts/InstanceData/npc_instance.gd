class_name NPCInstance
extends InstanceData
## An instance of [NPCData] in the world


@export var npc_data: NPCData


func get_archetype_components() -> Array[EntityComponent]:
	var components:Array[EntityComponent] = []
	# set up item component
	var npc_component = NPCComponent.new()
	npc_component.data = npc_data
	npc_component.name = "NPCComponent" # be sure to name them
	# Add new components
	components.append(npc_component)
	components.append(InteractiveComponent.new())
	components.append(PuppetSpawnerComponent.new())
	
	return components
