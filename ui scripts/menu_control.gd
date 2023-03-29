class_name MenuController
extends Control
## Pause menu controller.


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	GameInfo.pause.connect(show.bind())
	GameInfo.unpause.connect(hide.bind())
