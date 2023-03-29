extends Node
## holds Current game state.


## What world the player is in.
@export var world: String = "test world 1"


var paused:bool = false
var game_running:bool = true :
	get:
		return game_running
	set(val):
		if val:
			$Timer.paused = false
			game_running = val # does this call Set again?
		else:
			$Timer.paused = true
			game_running = val

var world_time:Dictionary = {
	"world_time" : 0,
	"minute" : 0,
	"hour" : 0,
	"day" : 0,
	"week" : 0,
	"month" : 0,
	"year" : 0,
}


signal pause
signal unpause
signal minute_incremented
signal hour_incremented
signal day_incremented
signal week_incremented
signal month_incremented
signal year_incremented


func _ready():
	name = "GameInfo"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var t = Timer.new()
	t.name = "Timer"
	add_child(t)
	
	$Timer.timeout.connect(_on_timer_complete.bind())
	$Timer.one_shot = false
	$Timer.start(1)
	$Timer.paused = not game_running


## Puase the game.
func pause_game():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	paused = true
	get_tree().paused = true
	$Timer.paused = true
	pause.emit()


## Unpause the game.
func unpause_game():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	paused = false
	get_tree().paused = false
	$Timer.paused = false
	unpause.emit()


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()


func toggle_pause():
	if paused:
		unpause_game()
	else:
		pause_game()


func _on_timer_complete():
	# Increment world time
	world_time["world_time"] += 1
	# Increment minute
	if world_time["world_time"] % ProjectSettings.get_setting("biznasty/seconds_per_minute") == 0:
		world_time["minutes"] += 1
		minute_incremented.emit()
	# Wrap minutes to hours
	if world_time["minutes"] > ProjectSettings.get_setting("biznasty/minutes_per_hour"):
		world_time["minutes"] = 0
		world_time["hours"] += 1
		hour_incremented.emit()
	# Wrap hours to days
	if world_time["hours"] > ProjectSettings.get_setting("biznasty/hours_per_day"):
		world_time["hours"] = 0
		world_time["day"] += 1
		day_incremented.emit()
	# Wrap days to weeks
	if world_time["day"] > ProjectSettings.get_setting("biznasty/days_per_week"):
		world_time["day"] = 0
		world_time["week"] += 1
		week_incremented.emit()
	# Wrap weeks to months
	if world_time["week"] > ProjectSettings.get_setting("biznasty/weeks_per_month"):
		world_time["week"] = 0
		world_time["month"] += 1
		month_incremented.emit()
	# Wrap months to years
	if world_time["month"] > ProjectSettings.get_setting("biznasty/months_per_year"):
		world_time["month"] = 0
		world_time["year"] += 1
		year_incremented.emit()


func save() -> Dictionary:
	return {
		"world" : world,
		"world_time" : world_time,
	}


func load_game(data:Dictionary):
	world = data["world"]
	world_time = data["world_time"]
