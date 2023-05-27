class_name PlayerComponent
extends EntityComponent
## Player component.


var _set_up:bool


func _init() -> void:
	name = "PlayerComponent"


func _ready():
	($"../TeleportComponent" as TeleportComponent).teleporting.connect(teleport.bind())


## Set the entity's position.
func set_entity_position(pos:Vector3):
	parent_entity.position = pos


func set_entity_rotation(q:Quaternion) -> void:
	parent_entity.rotation = q


func _process(delta):
	if _set_up:
		return
	
	var pc = $"../PuppetSpawnerComponent".puppet
	
	if not pc == null:
		pc.update_position.connect(set_entity_position.bind())
		_set_up = true


## Teleport the player.
func teleport(world:String, pos:Vector3):
	(%GameInfo as GameInfo).world = world # Set the game's world to destination world
	parent_entity.world = world # Set this entity world to the destination
	(%WorldLoader as WorldLoader).load_world(world) # Load world
	($"../PuppetSpawnerComponent" as PuppetSpawnerComponent).set_puppet_position(pos) # Set player puppet position
