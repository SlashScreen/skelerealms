class_name SystemMenu
extends Control
## The game system menu.


func _on_quit_button_button_up():
	get_tree().quit()


func _on_save_button_pressed():
	SaveSystem.save()
