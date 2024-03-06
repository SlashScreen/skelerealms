class_name SKToolPlugin
extends EditorInspectorPlugin


const EDITORS:Dictionary = {
	&"NpcInstance": preload("npc_instance_inspector.tscn"),
	&"ItemInstance": preload("item_instance_inspector.tscn"),
	&"NpcData": preload("npc_data_inspector.tscn"),
	&"ItemData": preload("item_data_inspector.tscn"),
}


func _can_handle(object: Object) -> bool:
	return object is InstanceData\
		or object is Coven


func _parse_begin(object: Object) -> void:
	var b:Button = Button.new()
	b.text = "Open Advanced Editor"
	b.pressed.connect(_open_window.bind(object))
	add_custom_control(b)


func _open_window(object: Object) -> void:
	var w:Window = Window.new()
	w.position = EditorInterface.get_base_control().size / 2 - (EditorInterface.get_base_control().size / 4)
	w.min_size = EditorInterface.get_base_control().size / 2
	if object is NPCInstance:
		var n:Node = EDITORS.NpcInstance.instantiate()
		w.add_child(n)
		n.edit(object, w)
	EditorInterface.get_base_control().add_child(w)
	w.close_requested.connect(w.queue_free.bind())
	w.show()


static func find_classes_that_inherit(what:StringName) -> Array:
	return ProjectSettings.get_global_class_list()\
		.filter(func(d:Dictionary)->bool: return d.base == what)
