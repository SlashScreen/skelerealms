class_name NPCPuppet
extends CharacterBody3D
## Puppet "brain" for an NPC.


var eyes:EyesPerception
var npc_component:NPCComponent
var puppeteer:PuppetSpawnerComponent


## Called every frame to update the entity's position.
signal change_position(Vector3)

var movement_speed: float = 2.0
@onready var movement_target_position: Vector3 = position # No world because this agent only works in the scene.
var target_reached:bool:
	get:
		return navigation_agent.is_navigation_finished()

var movement_paused:bool = false

## The navigation agent.
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_actor_setup")
	change_position.connect((get_parent().get_parent() as Entity)._on_set_position.bind())
	eyes = $EyesPerception
	puppeteer = $"../../".get_component("PuppetSpawnerComponent").unwrap()
	npc_component = $"../../".get_component("NPCComponent").unwrap()
	if npc_component:
		print("Connecting percieved event")
		eyes.perceived.connect(npc_component.on_percieve_start.bind())
		eyes.not_perceived.connect(npc_component.on_percieve_end.bind())
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
	if npc_component:
		eyes.try_perception()

	if navigation_agent.is_navigation_finished():
		return
	
	if movement_paused:
		return
	
	var current_agent_position: Vector3 = global_transform.origin
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	set_velocity(new_velocity)
	move_and_slide()


func _process(delta) -> void:
	change_position.emit(position)
