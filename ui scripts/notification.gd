extends Label
class_name Notification
## Controls a notification sent to the player.

# TODO: set notification time
## How long it stays on the screen.
const notification_time = 10


func _ready():
	($Timer as Timer).timeout.connect(_vanish.bind())
	($Timer as Timer).start(notification_time)


func _vanish():
	queue_free()
