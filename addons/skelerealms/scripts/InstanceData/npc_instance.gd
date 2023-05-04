class_name NPCInstance
extends InstanceData
## An instance of [NPCData] in the world


@export var npc_data: NPCData


func get_archetype_components() -> Array[EntityComponent]:
	var components:Array[EntityComponent] = []
	# Add new components
	components.append(NPCComponent.new(npc_data))
	components.append(InteractiveComponent.new())
	components.append(PuppetSpawnerComponent.new())
	components.append(TeleportComponent.new())
	components.append(GOAPComponent.new())
	components.append(SkillsComponent.new())
	components.append(AttributesComponent.new())
	components.append(VitalsComponent.new())
	components.append(SpellTargetComponent.new())
	components.append(CovensComponent.new(npc_data.covens))
	components.append(DamageableComponent.new())
	components.append(NavigatorComponent.new())
	if not _try_override_script(npc_data.custom_script) == null:
		components.append(ScriptComponent.new(npc_data.custom_script))
	
	return components
