class_name HitDetector
extends Area3D
## Hit detector used for melee weapons.


var active:bool ## Whether this should listen for collisions
var collision_callback:Callable ## A callable this should use to pass information back.


func _ready() -> void:
	body_entered.connect(func(body:Node3D) -> void:
		if active:
			collision_callback.call(body)
		)


func activate(cback:Callable) -> void:
	collision_callback = cback
	active = true


func deactivate() -> void:
	active = false
