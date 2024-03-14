class_name SKToolPlugin
extends EditorInspectorPlugin


const EDITORS:Dictionary = {
	&"NpcInstance": preload("npc_instance_inspector.tscn"),
	&"ItemInstance": preload("item_instance_inspector.tscn"),
	&"NpcData": preload("npc_data_inspector.tscn"),
	&"ItemData": preload("item_data_inspector.tscn"),
	&"Coven": preload("coven_editor.tscn"),
	&"LootTable": preload("loot_table_inspector.tscn")
}
static var instance:SKToolPlugin


func _init() -> void:
	instance = self


func _can_handle(object: Object) -> bool:
	return object is InstanceData\
		or object is RefData\
		or object is Coven\
		or object is SKLootTable


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
		n.edit(object)
	elif object is NPCData:
		var n:Node = EDITORS.NpcData.instantiate()
		w.add_child(n)
		n.edit(object)
	elif object is ItemInstance:
		var n:Node = EDITORS.ItemInstance.instantiate()
		w.add_child(n)
		n.edit(object)
	elif object is ItemData:
		var n:Node = EDITORS.ItemData.instantiate()
		w.add_child(n)
		n.edit(object)
	elif object is Coven:
		var n:Node = EDITORS.Coven.instantiate()
		w.add_child(n)
		n.edit(object)
	elif object is ChestInstance:
		#open_loot_inspector((object as ChestInstance).loot_table)
		return
	elif object is SKLootTable:
		open_loot_inspector((object as SKLootTable).items)
		return
	else:
		return
	EditorInterface.get_base_control().add_child(w)
	w.close_requested.connect(w.queue_free.bind())
	w.show()


static func find_classes_that_inherit(what:StringName) -> Array:
	return ProjectSettings.get_global_class_list()\
		.filter(func(d:Dictionary)->bool: return d.base == what)


func open_loot_inspector(i:Array[SKLootTableItem]) -> void:
	var w:Window = Window.new()
	w.position = EditorInterface.get_base_control().size / 2 - (EditorInterface.get_base_control().size / 4)
	w.min_size = EditorInterface.get_base_control().size / 2
	
	var e:Node = EDITORS.LootTable.instantiate()
	w.add_child(e)
	e.edit(null, i)
	
	EditorInterface.get_base_control().add_child(w)
	w.close_requested.connect(w.queue_free.bind())
	w.show()
