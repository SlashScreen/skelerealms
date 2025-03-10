class_name InteractiveComponent
extends SKEntityComponent
## Component that allows an entity to be interacted with by players or other entities.
## Provides customizable interaction text and translation support.

## Emitted when this entity is interacted with by another entity
signal interacted(id:String)

## Whether this entity can currently be interacted with
@export var interactible:bool = true
## The verb to display in the interaction tooltip (e.g. "OPEN", "TALK", etc.)
@export var interact_verb:String = "INTERACT"
## Optional callback that returns a custom string for the interaction text
var translation_callback:Callable
## The translated name to display in interaction prompts
var interact_name:String:
	get:
		if not translation_callback.is_null():
			return translation_callback.call()
		else:
			return tr(parent_entity.name)


func _init() -> void:
	name = &"InteractiveComponent"


## Simulates the player interacting with this entity
## Shorthand for interact("Player")
func interact_by_player():
	interacted.emit("Player")
	print("Player interacted")


## Triggers an interaction with this entity from another entity
## [param refID] The reference ID of the entity initiating the interaction
func interact(refID:String):
	print("Trying to emit")
	interacted.emit(refID)
