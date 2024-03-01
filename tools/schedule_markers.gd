@tool
extends HBoxContainer


const HOUR_SEPARATION = 128


func _ready() -> void:
	for i in range(ProjectSettings.get_setting("skelerealms/hours_per_day")):
		var vb:VSeparator = VSeparator.new()
		var c:Control = Control.new()
		c.custom_minimum_size = Vector2(HOUR_SEPARATION, 0)
		add_child(vb)
		add_child(c)
