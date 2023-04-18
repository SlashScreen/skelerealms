class_name ItemPuppet
extends Node3D


var puppeteer:PuppetSpawnerComponent

signal change_position(Vector3)


func _ready():
	puppeteer = $"../../".get_component("PuppetSpawnerComponent").unwrap()
	change_position.connect((get_parent().get_parent() as Entity)._on_set_position.bind())


func _process(delta):
	change_position.emit(position)


func get_puppeteer() -> PuppetSpawnerComponent:
	return puppeteer
