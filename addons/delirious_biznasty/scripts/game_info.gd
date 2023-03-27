class_name GameInfo 
extends Node
## holds Current game state.


## What world the player is in.
@export var world: String


var paused:bool = false


signal pause
signal unpause


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	process_mode = Node.PROCESS_MODE_ALWAYS
	BizGlobal.game_info = self


## Puase the game.
func pause_game():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	paused = true
	get_tree().paused = true
	pause.emit()


## Unpause the game.
func unpause_game():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	paused = false
	get_tree().paused = false
	unpause.emit()


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()


func toggle_pause():
	if paused:
		unpause_game()
	else:
		pause_game()
