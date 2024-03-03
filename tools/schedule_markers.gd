@tool
extends HBoxContainer


const HOUR_SEPARATION = 256
const H_LINE_WIDTH = 6
const HH_LINE_WIDTH = 2


@onready var hpd:int = ProjectSettings.get_setting("skelerealms/hours_per_day")
var default_font:Font
var default_font_size:int


func _ready() -> void:
	custom_minimum_size = Vector2((hpd + 1) * HOUR_SEPARATION, 0)
	default_font = ThemeDB.fallback_font
	default_font_size = ThemeDB.fallback_font_size


func _draw() -> void:
	draw_hour_lines()
	draw_half_hour_lines()


func draw_hour_lines() -> void:
	var arr:PackedVector2Array = PackedVector2Array()
	arr.resize((hpd + 1) * 2)
	for i in range(hpd + 1):
		var x:int = HOUR_SEPARATION * i
		arr[i * 2] = Vector2(x, 0)
		arr[i * 2 + 1] = Vector2(x, size.y)
		draw_string(default_font, Vector2(x + 5, size.y - default_font_size - 5), "%dh" % i)
	draw_multiline(arr, Color.DARK_SLATE_GRAY, H_LINE_WIDTH)


func draw_half_hour_lines() -> void:
	var arr:PackedVector2Array = PackedVector2Array()
	arr.resize((hpd + 1) * 2)
	for i in range(hpd + 1):
		var x:int = (HOUR_SEPARATION * i) + (HOUR_SEPARATION / 2)
		arr[i * 2] = Vector2(x, 0)
		arr[i * 2 + 1] = Vector2(x, size.y)
	draw_multiline(arr, Color.hex(0x55_55_55), HH_LINE_WIDTH)
