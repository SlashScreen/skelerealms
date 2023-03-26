class_name PlayerComponent
extends EntityComponent
## Player component.


var _set_up:bool

var health:float:
	get:
		return health
	set(val):
		update_health.emit(val)
		health = val # May cause a loop?
var moxie:float:
	get:
		return moxie
	set(val):
		update_moxie.emit(val)
		moxie = val # May cause a loop?
var will:float:
	get:
		return will
	set(val):
		update_will.emit(val)
		will = val # May cause a loop?


signal update_health(new_value:float)
signal update_moxie(new_value:float)
signal update_will(new_value:float)


func _ready():
	($"../TeleportComponent" as TeleportComponent).teleporting.connect(teleport.bind())
	var h = (%HUD as HudControl)
	# Shouldn't connect them here but im lazy
	update_health.connect(h.set_health.bind())
	update_moxie.connect(h.set_stamina.bind())
	update_will.connect(h.set_will.bind())
	# Set to initial values.
	update_health.emit(health)
	update_moxie.emit(moxie)
	update_will.emit(will)


## Set the entity's position.
func set_entity_position(pos:Vector3):
	parent_entity.position = pos


func _process(delta):
	if _set_up:
		return
	
	var pc = ($"../PuppetSpawnerComponent".puppet as PlayerController)
	
	if not pc == null:
		pc.update_position.connect(set_entity_position.bind())
		_set_up = true


## Teleport the player.
func teleport(world:String, pos:Vector3):
	(%GameInfo as GameInfo).world = world # Set the game's world to destination world
	parent_entity.world = world # Set this entity world to the destination
	(%WorldLoader as WorldLoader).load_world(world) # Load world
	($"../PuppetSpawnerComponent" as PuppetSpawnerComponent).set_puppet_position(pos) # Set player puppet position
