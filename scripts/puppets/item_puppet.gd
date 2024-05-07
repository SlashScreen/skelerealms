class_name ItemPuppet
extends RigidBody3D


## The puppeteer of this item.
var puppeteer:PuppetSpawnerComponent
## When this is true, the puppet will not sync its position with the puppeteer.
## This is intended to be used for when an item is in an NPCs hand.
## This will turn on by default if the node at "../../" relative to this one is not an entity, although this may change in the future.
## When true, all [CollisionShape3D]s beneath in the heirarchy will be turned off to prevent collisions with whoever is holding it. 
var inactive:bool:
	get:
		return inactive
	set(val):
		inactive = val
		set_collision_state(self, not val)

signal change_position(Vector3)
signal change_rotation(Quaternion)


func _ready():
	if not $"../../" is SKEntity: # TODO: Less brute force method
		inactive = true
		return
	
	puppeteer = $"../../".get_component("PuppetSpawnerComponent")
	change_position.connect((get_parent().get_parent() as SKEntity)._on_set_position.bind())
	change_rotation.connect((get_parent().get_parent() as SKEntity)._on_set_rotation.bind())


func _process(delta):
	if not inactive:
		change_position.emit(position)
		change_rotation.emit(quaternion)


func get_puppeteer() -> PuppetSpawnerComponent:
	if inactive:
		return null
	return puppeteer


func set_collision_state(n:Node, state:bool) -> void:
	if n is CollisionShape3D and not n.get_parent() is HitDetector:
		(n as CollisionShape3D).disabled = not state
	for c in n.get_children():
		set_collision_state(c, state)
