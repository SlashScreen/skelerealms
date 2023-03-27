class_name InteractiveComponent
extends EntityComponent
## Handles interactions on an entity

## Emitted when this entity is interacted with.
signal interacted(id:String)

## Whether it can be interacted with.
@export var interactible:bool = true
## What tooltip to display when the cursor hovers over this.
@export var interact_text:String

func _ready():
	name = "InteractiveComponent"

## Interact with this as the player.
## Shorthand for [codeblock] interact("Player") [/codeblock].
func interact_by_player():
	interacted.emit("Player")

## Interact with this entity. Pass in the refID of the interactor.
func interact(refID:String):
	interacted.emit(refID)
