extends CharacterBody3D
class_name PlayerController
## Player controller.


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const PARENT_TREE_CLIMB = 10


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_sensitivity:float = ProjectSettings.get_setting("player/look_sensitivity")
var puppeteer:PuppetSpawnerComponent
@onready var camera:Camera3D = $Camera3D


## Called to update the entity
signal update_position(pos:Vector3)
signal update_rotation(rot:Quaternion)


func _ready():
	puppeteer = $"../../".get_component("PuppetSpawnerComponent").unwrap()
	update_position.connect((get_parent().get_parent() as Entity)._on_set_position.bind())
	update_rotation.connect((get_parent().get_parent() as Entity)._on_set_rotation.bind())


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
	update_rotation.emit(camera.quaternion)
	# Example implementation of using interaction.
	# If interact key pressed 
	if Input.is_action_just_released("interact"):
		print("Interact pressed")
		var collider = ($Camera3D/InteractionRay as RayCast3D).get_collider() as Node # Attempt raycast
		if collider == null: # if we didn't hit anything, return early
			return
			
		var interactive = SkeleRealmsGlobal.get_interactive_node(collider)
		if interactive:
			interactive.interact(&"Player")


func get_puppeteer() -> PuppetSpawnerComponent:
	return puppeteer
