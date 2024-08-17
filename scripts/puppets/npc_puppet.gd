class_name NPCPuppet
extends CharacterBody3D
## Puppet "brain" for an NPC.


@onready var movement_target_position: Vector3 = position # No world because this agent only works in the scene.
## This is a stealth provider. See the "Sealth Provider" article i nthe documentation for details.
@export var eyes:Node 
var npc_component:NPCComponent
var puppeteer:PuppetSpawnerComponent
var view_dir:ViewDirectionComponent
var movement_speed: float = 1.0
var target_reached:bool:
	get:
		return navigation_agent.is_navigation_finished()

## Called every frame to update the entity's position.
signal change_position(Vector3)

var movement_paused:bool = false
## The navigation agent.
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_actor_setup")
	add_to_group("perception_target")
	change_position.connect((get_parent().get_parent() as SKEntity)._on_set_position.bind())
	puppeteer = $"../../".get_component("PuppetSpawnerComponent")
	npc_component = $"../../".get_component("NPCComponent")
	view_dir = $"../../".get_component("ViewDirectionComponent")
	if npc_component:
		puppeteer.printe("Connecting percieved event")
		
		npc_component.entered_combat.connect(draw_weapons.bind())
		npc_component.left_combat.connect(lower_weapons.bind())

	else:
		push_warning("NPC Puppet not a child of an entity with an NPCComponent. Perception turned off.")


func get_puppeteer() -> PuppetSpawnerComponent:
	return puppeteer


## Finds the closest point to this puppet, and jumps to it. 
## This is to avoid getting stuck in things that it may have phased into while navigating out-of-scene.
func snap_to_navmesh() -> void:
	position = NavigationServer3D.map_get_closest_point(NavigationServer3D.get_maps()[0], position)


## Set up navigation.
func _actor_setup()  -> void:
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	snap_to_navmesh() # snap to mesh
	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)


## Set the target for the NPC.
func set_movement_target(movement_target: Vector3) -> void:
	navigation_agent.set_target_position(movement_target)


func pause_nav() -> void:
	movement_paused = true


func continue_nav() -> void:
	movement_paused = false


func _physics_process(delta) -> void:
	npc_component.puppet_request_move.emit(self)


func _process(delta) -> void:
	change_position.emit(position)
	view_dir.view_rot = rotation


func draw_weapons() -> void:
	npc_component.puppet_request_raise_weapons.emit(self)


func lower_weapons() -> void:
	npc_component.puppet_request_lower_weapons.emit(self)
