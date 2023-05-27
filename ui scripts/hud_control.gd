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


const _time_string = "%s:  %02X:%02X"


func _ready():
	GameInfo.pause.connect(_on_pause.bind())
	GameInfo.unpause.connect(_on_unpause.bind())
	GameInfo.minute_incremented.connect(_set_timer_text.bind())
	_set_timer_text()


func _set_timer_text():
	timer_label.text = _time_string % [tr("TIME"), GameInfo.world_time[&"hour"], GameInfo.world_time[&"minute"]]


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
	hide()
	$Timer.paused = true

func _on_unpause():
	show()
	$Timer.paused = false
