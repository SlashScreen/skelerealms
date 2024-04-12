class_name NPCPuppet
extends CharacterBody3D
## Puppet "brain" for an NPC.


@export var animator: AnimationController
@onready var movement_target_position: Vector3 = position # No world because this agent only works in the scene.
var eyes:EyesPerception
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
var hands_manager:HandsManager:
	get:
		if hands_manager == null:
			hands_manager = %HandsManager
		return hands_manager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_actor_setup")
	add_to_group("perception_target")
	change_position.connect((get_parent().get_parent() as Entity)._on_set_position.bind())
	eyes = $EyesPerception
	puppeteer = $"../../".get_component("PuppetSpawnerComponent")
	npc_component = $"../../".get_component("NPCComponent")
	view_dir = $"../../".get_component("ViewDirectionComponent")
	if npc_component:
		puppeteer.printe("Connecting percieved event")
		eyes.perceived.connect(npc_component.on_percieve_start.bind())
		eyes.not_perceived.connect(npc_component.on_percieve_end.bind())
		
		npc_component.entered_combat.connect(draw_weapons.bind())
		npc_component.left_combat.connect(lower_weapons.bind())
		
		if hands_manager:
			hands_manager.weapons_drawn = npc_component.in_combat
			for h in hands_manager.hands:
				if npc_component.in_combat:
					hands_manager.get_hand(h).show()
				else:
					hands_manager.get_hand(h).hide()
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

	if navigation_agent.is_navigation_finished() or movement_paused:
		if animator: animator.set_value(&"walk_speed", 0)
		return
	
	if animator: animator.set_value(&"walk_speed", movement_speed) # In-game, moves at a brisk pace
	
	var current_agent_position: Vector3 = global_transform.origin
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	var new_direction: Vector3 = next_path_position - current_agent_position # Calculate direction to point in
	if not new_direction.length() == 0:
		look_at(position + Vector3(new_direction.normalized().x, 0, new_direction.normalized().z))
	var new_velocity = (new_direction.normalized() * movement_speed) if animator == null \
						else (quaternion * -(animator.root_motion_callback.call() / delta))
	
	set_velocity(new_velocity)
	move_and_slide()


func _process(delta) -> void:
	change_position.emit(position)
	view_dir.view_rot = rotation


func draw_weapons() -> void:
	hands_manager.raise_weapons.emit()


func lower_weapons() -> void:
	puppeteer.printe("Lowering weapons.")
	hands_manager.lower_weapons.emit()
