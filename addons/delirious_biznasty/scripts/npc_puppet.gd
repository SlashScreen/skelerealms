class_name NPCPuppet
extends CharacterBody3D
## Puppet "brain" for an NPC.

## Called every frame to update the entity's position.
signal change_position(Vector3)

var movement_speed: float = 2.0
var movement_target_position: Vector3 = Vector3(-3.0,0.0,2.0)

## The navigation agent.
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("_actor_setup")
	change_position.connect((get_parent().get_parent() as Entity)._on_set_position.bind())


## Set up navigation.
func _actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)


## Set the target for the NPC.
func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_transform.origin
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	set_velocity(new_velocity)
	move_and_slide()
	
func _process(delta):
	change_position.emit(position)
