@tool
extends PanelContainer


const FILE_INHERIT = 1

@onready var option_button: OptionButton = $VBoxContainer/HBoxContainer/OptionButton
@onready var file_dialog: FileDialog = $FileDialog

var editing:SKWorldEntity


# life will be pain until this gets merged https://github.com/godotengine/godot/pull/90057


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var templates:PackedStringArray = ProjectSettings.get_setting("skelerealms/entity_archetypes")
	option_button.clear()
	for t:String in templates:
		option_button.add_item(t)


func edit(what:SKWorldEntity) -> void:
	editing = what


func _on_button_pressed() -> void:
	file_dialog.popup_centered()
	#_create_using_editor()


func _grab_uid(path:String) -> String:
	return ResourceUID.id_to_text(ResourceLoader.get_resource_uid(path))


func _generate_inherited_scene_id() -> String:
	return "1_%s" % SKIDGenerator.generate_id(5).to_lower()


func _format_scene(from:String, entity_name:String) -> String:
	var id:String = _generate_inherited_scene_id()
	var uid:String = ResourceUID.id_to_text(ResourceUID.create_id())
	return """
[gd_scene load_steps=2 format=3 uid=\"%s\"]

[ext_resource type=\"PackedScene\" uid=\"%s\" path=\"%s\" id=\"%s\"]

[node name=\"%s\" instance=ExtResource(\"%s\")]
""" % [
	uid,
	_grab_uid(from),
	from,
	id,
	entity_name,
	id
]


func _on_file_dialog_file_selected(path: String) -> void:
	_make_manually(path)
	#_create_using_instantiation(path)


func _make_manually(path:String) -> void:
	var p:String = option_button.get_item_text(option_button.selected)
	var contents:String = _format_scene(p, "test_entity")
	var fh := FileAccess.open(path, FileAccess.WRITE)
	fh.store_string(contents)
	fh.close()
	EditorInterface.get_resource_filesystem().scan()
	EditorInterface.get_resource_filesystem().update_file(path)
	EditorInterface.get_resource_previewer().queue_resource_preview(path, self, &"receive_thumbnail", null)
	editing.entity = ResourceLoader.load(path)


func _create_using_editor() -> void:
	EditorInterface.get_file_system_dock().navigate_to_path(option_button.get_item_text(option_button.selected))
	
	var popup:PopupMenu = EditorInterface.get_file_system_dock().get_children()\
		.filter(func(n:Node)->bool:return n is PopupMenu)\
		.filter(func(p:PopupMenu) -> bool: return p.item_count > 0)\
		.filter(func(p:PopupMenu) -> bool: return p.get_item_text(0) == "Open Scene")\
		[0]
	
	if popup:
		popup.id_pressed.emit(FILE_INHERIT)


func _create_using_instantiation(path:String) -> void:
	var p:String = option_button.get_item_text(option_button.selected)
	var new_scene:Node = (ResourceLoader.load(p) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_MAIN_INHERITED)
	new_scene.scene_file_path = p
	print(new_scene.scene_file_path)
	var new_ps := PackedScene.new()
	new_ps.pack(new_scene)
	ResourceSaver.save(new_ps, path)


func receive_thumbnail(_path:String, _preview:Texture2D, _thumbnail_preview:Texture2D, _userdata:Variant) -> void:
	return
