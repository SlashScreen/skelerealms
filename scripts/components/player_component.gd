class_name PlayerComponent
extends SKEntityComponent
## Player component.


var _set_up:bool


func _init() -> void:
	name = "PlayerComponent"


func _ready():
	($"../TeleportComponent" as TeleportComponent).teleporting.connect(teleport.bind())
	(parent_entity.get_component("DamageableComponent") as DamageableComponent).damaged.connect(on_damage.bind())


func on_damage(info:DamageInfo) -> void:
	# TODO: Genericize, calculate buffs and debuffs
	(parent_entity.get_component("VitalsComponent") as VitalsComponent).change_health(-info.damage_effects[&"blunt"])


func _entity_ready() -> void:
	var ic:InventoryComponent = parent_entity.get_component("InventoryComponent")
	ic.added_to_inventory.connect(func(id): QuestEngine.instance.register_quest_event("item_get", {"filter":id}))
	ic.removed_from_inventory.connect(func(id): QuestEngine.instance.register_quest_event("item_get", {"filter":id}, true))


## Set the entity's position.
func set_entity_position(pos:Vector3):
	parent_entity.position = pos


func set_entity_rotation(q:Quaternion) -> void:
	parent_entity.rotation = q


func _process(delta):
	parent_entity.world = GameInfo.world
	
	if _set_up:
		return
	
	var pc = $"../PuppetSpawnerComponent".puppet
	
	if not pc == null:
		pc.update_position.connect(set_entity_position.bind())
		_set_up = true


## Teleport the player.
func teleport(world:String, pos:Vector3):
	print("teleporting player to %s : %s" % [world, pos])
	GameInfo.world = world # Set the game's world to destination world
	parent_entity.world = world # Set this entity world to the destination
	(%WorldLoader as WorldLoader).load_world(world) # Load world
	($"../PuppetSpawnerComponent" as PuppetSpawnerComponent).set_puppet_position(pos) # Set player puppet position
