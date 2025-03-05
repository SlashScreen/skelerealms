class_name ViewDirectionComponent
extends SKEntityComponent
## Component that tracks an entity's view direction independently of its rotation.
## Useful for NPCs and players to maintain a separate facing direction from their movement (like head rotation), as well as tracking the player's view direction.

var view_rot:Vector3 = Vector3.FORWARD  ## The direction the entity is looking, defaults to forward


func _init() -> void:
	name = &"ViewDirectionComponent"
