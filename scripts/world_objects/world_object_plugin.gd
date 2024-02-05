class_name WorldObjectPlugin
extends EditorInspectorPlugin


func _can_handle(object):
	return object is WorldNPC or object is WorldItem or object is WorldMarker or object is Chest


func _parse_begin(object):
	var sync_position:Button = Button.new()
	sync_position.text = "Sync position"
	sync_position.pressed.connect(func(): _sync_position(object))
	add_custom_control(sync_position)


func _sync_position(object):
	object.instance.position = (object as Node3D).global_position
	object.instance.world = EditorInterface.get_edited_scene_root().name
	if not object.instance.get("rotation") == null:
		object.instance. rotation = (object as Node3D).quaternion
