class_name SpellProjectile
extends RigidBody3D
## A special script for projectiles: provides a callback when it hits an object.


## Callback when something is hit.
signal hit_target(target:Node3D)


func _ready():
	body_entered.connect(func(x:Node3D):
		hit_target.emit(x)
	)
