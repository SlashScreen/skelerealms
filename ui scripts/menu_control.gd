class_name MenuController
extends Control
## Pause menu controller.


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	(%GameInfo as GameInfo).pause.connect(show.bind())
	(%GameInfo as GameInfo).unpause.connect(hide.bind())
