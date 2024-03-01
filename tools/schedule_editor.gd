@tool
extends PanelContainer

@onready var timeline:Control = $ScrollContainer/HBoxContainer
var scroll_value:int


func _process(_delta: float) -> void:
	scroll_value = timeline.position.x
