extends EntityComponent
class_name InteractiveComponent

signal interacted(id:String)

@export var interactible:bool = true
@export var interact_text:String

func interact_by_player():
	interacted.emit("Player")

func interact(refID:String):
	interacted.emit(refID)
