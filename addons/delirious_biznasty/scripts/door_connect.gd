class_name DoorJumpPlugin
extends EditorInspectorPlugin

func _can_handle(object):
	return object is Door

func _parse_begin(obj:Object):
	var go_to_button:Button = Button.new()
	go_to_button.text = "Jump to door location"
	add_custom_control(go_to_button)

func _jump_to_door_location():
	pass
