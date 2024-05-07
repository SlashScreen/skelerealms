class_name NPCInstance
extends InstanceData
## An instance of [NPCData] in the world


@export var npc_data: NPCData
## Any items this NPC has in their inventory that will not be generated.
@export var unique_items: Array[ItemInstance] = []


func get_archetype_components() -> Array[SKEntityComponent]:
	var components:Array[SKEntityComponent] = []
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
	components.append(ViewDirectionComponent.new())
	components.append(EquipmentComponent.new())
	components.append(InventoryComponent.new(unique_items))
	if not _try_override_script(npc_data.custom_script) == null:
		components.append(ScriptComponent.new(npc_data.custom_script))
	
	return components
