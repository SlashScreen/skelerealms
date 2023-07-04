class_name PerceptionEars
extends CollisionShape3D
## Add to something to make it be able to hear.
## Isn't an [EntityComponent], so can be added to anything.
## Be sure to add a shape.


## Called when it hears something.
signal heard_something(emitter:AudioEventEmitter)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("audio_listener")


func hear_audio(emitter:AudioEventEmitter):
	heard_something.emit(emitter)
