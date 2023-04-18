extends CharacterBody3D
class_name PlayerController
## Player controller.


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const PARENT_TREE_CLIMB = 10


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_sensitivity:float = ProjectSettings.get_setting("player/look_sensitivity")
@onready var camera:Camera3D = $Camera3D


## Called to update the entity
signal update_position(pos:Vector3)


func _physics_process(delta):
	if GameInfo.paused:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)


func _process(_delta):
	update_position.emit(position)
	# Example implementation of using interaction.
	# If interact key pressed 
	if Input.is_action_just_released("interact"):
		print("Interact pressed")
		var collider = ($Camera3D/InteractionRay as RayCast3D).get_collider() as Node # Attempt raycast
		if collider == null: # if we didn't hit anything, return early
			return
		print("Collider not null")
		# Section 1: Check for InteractiveObject
		print("Section 1")
		var check_node:Node = collider
		for i in PARENT_TREE_CLIMB: # Try climbing tree to attempt to find the InteractiveObject
			# If the parent was null, break early
			if check_node == null:
				break
			print(check_node.name)
			if check_node is InteractiveObject: # Interact if interactive object
				(check_node as InteractiveObject).interact("Player")
				break
			check_node = check_node.get_parent()
		# Section 2: Entity
		print("Section 2")
		# Attempt to get an interactive component form the entity
		var ic = SkeleRealmsGlobal.get_entity_in_tree(collider).get_component("InteractiveComponent")
		if ic.some():
			ic.unwrap().interact("Player")
