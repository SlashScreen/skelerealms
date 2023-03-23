extends Control
class_name HudControl
## Controls the game hud.


## Root of the notifications.
@export var notification_root:VBoxContainer
## Notification prefab.
@export var notification:PackedScene
## Health bar.
@export var health_bar:ProgressBar
## Stamina bar.
@export var moxie_bar:ProgressBar
## Magica bar.
@export var will_bar:ProgressBar
## World time label.
@export var timer_label:Label


var _world_minutes:int = 0
var _world_hours:int = 0
const _time_string = "%s:  %02X:%02X"


func _ready():
	$Timer.timeout.connect(_on_timer_complete.bind())
	$Timer.one_shot = false
	$Timer.start(ProjectSettings.get_setting("biznasty/seconds_per_minute"))
	_set_timer_text()


func _on_timer_complete():
	_world_minutes += 1
	if _world_minutes > ProjectSettings.get_setting("biznasty/minutes_per_hour"):
		_world_minutes = 0
		_world_hours += 1
	if _world_hours > ProjectSettings.get_setting("biznasty/hours_per_day"):
		_world_hours = 0
	
	_set_timer_text()



func _set_timer_text():
	timer_label.text = _time_string % [tr("TIME"),_world_hours, _world_minutes]


## Spawn a notification with a label.
func spawn_notification(text:String):
	var n = notification.instantiate()
	(n as Notification).set_text(text)
	add_child(n)


## Set the health bar value.
func set_health(val:int): 
	health_bar.value = val


## Set the stamina bar value.
func set_stamina(val:int): 
	moxie_bar.value = val


## Set the willpower bar value.
func set_will(val:int): 
	will_bar.value = val


func _on_pause():
	$Timer.paused = true

func _on_unpause():
	$Timer.paused = false
