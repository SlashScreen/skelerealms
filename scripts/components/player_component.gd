class_name PlayerComponent
extends SKEntityComponent
## Component that handles player-specific behavior and state management.
## Manages player teleportation, damage handling, and synchronization with the game world.
## Usage of this is optional. YOu can use your own if you'd like.

var _set_up:bool  ## Internal flag to track if the player's puppet connections are initialized


func _init() -> void:
	name = &"PlayerComponent"


## Connects signals for teleportation and damage handling
func _ready():
	($"../TeleportComponent" as TeleportComponent).teleporting.connect(teleport.bind())
	(parent_entity.get_component(&"DamageableComponent") as DamageableComponent).damaged.connect(on_damage.bind())


## Processes damage received by the player
## [param info] Information about the damage type and amount
func on_damage(info:DamageInfo) -> void:
	# TODO: Genericize, calculate buffs and debuffs
	(parent_entity.get_component(&"VitalsComponent") as VitalsComponent).change_health(-info.damage_effects[&"blunt"])


## Updates the player entity's position
## [param pos] The new world position
func set_entity_position(pos:Vector3):
	parent_entity.position = pos


## Updates the player entity's rotation
## [param q] The new rotation as a quaternion
func set_entity_rotation(q:Quaternion) -> void:
	parent_entity.quaternion = q


func _process(delta):
	if not parent_entity.world == GameInfo.world:
		parent_entity.world = GameInfo.world
	
	if _set_up:
		return
	
	var pc = $"../PuppetSpawnerComponent".puppet
	
	if not pc == null:
		pc.update_position.connect(set_entity_position.bind())
		_set_up = true


## Handles player teleportation between worlds
## [param world] The target world identifier
## [param pos] The target position in the new world
func teleport(world:String, pos:Vector3):
	print("teleporting player to %s : %s" % [world, pos])
	GameInfo.world = world  # Set the game's world to destination world
	parent_entity.world = world  # Set this entity world to the destination
	(%WorldLoader as WorldLoader).load_world(world)  # Load world
	parent_entity.get_component(&"PuppetSpawnerComponent").set_puppet_position(pos)  # Set player puppet position
