class_name InteractiveComponent
extends EntityComponent
## Handles interactions on an entity

## Emitted when this entity is interacted with.
signal interacted(id:String)

## Whether it can be interacted with.
@export var interactible:bool = true
## What tooltip to display when the cursor hovers over this. The RefID is used as the object name.
@export var interact_verb:String = "INTERACT"
## A callback (that returns String) that allows you to get a custom string for interact text rather than
## using the RefID.
## For example: If you dynamically created an NPC (eg. spawning is a Spider enemy), you could instead grab
## a translated version of your handmade NPCData's ID rather than trying to translate a randomly generated
## RefID.
var translation_callback:Callable
## Gets the translated RefID, or, if applicable, whatever is returned by [member translation_callback]
var interact_name:String:
	get:
		if not translation_callback.is_null():
			return translation_callback.call()
		else:
			return tr(parent_entity.name)


func _init() -> void:
	name = "InteractiveComponent"

## Interact with this as the player.
## Shorthand for [codeblock] interact("Player") [/codeblock].
func interact_by_player():
	interacted.emit("Player")

## Interact with this entity. Pass in the refID of the interactor.
func interact(refID:String):
	interacted.emit(refID)
