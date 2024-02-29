@tool
extends Control


const RELATIONSHIP_EDITOR = preload("relationship_editor.tscn")
const COVEN_RANK_EDITOR = preload("coven_rank_data_editor.tscn")

@onready var add_module:Button = $NPC/panels/AIModule/VBoxContainer/New/Add
@onready var load_module_button:Button = $NPC/panels/AIModule/VBoxContainer/LoadModule
@onready var load_module_file:FileDialog = $NPC/panels/AIModule/VBoxContainer/LoadModule/FileDialog
@onready var module_list:ItemList = $NPC/panels/AIModule/VBoxContainer/ItemList
@onready var mod_class_selection:OptionButton = $NPC/panels/AIModule/VBoxContainer/New/ModuleSelection

@onready var goap_class_selection:OptionButton = $NPC/panels/GOAPModules/VBoxContainer/New/GoapSelection
@onready var add_goap:Button = $NPC/panels/GOAPModules/VBoxContainer/New/Add
@onready var load_goap_button:Button = $NPC/panels/GOAPModules/VBoxContainer/LoadGoap
@onready var load_goap_file:FileDialog = $NPC/panels/GOAPModules/VBoxContainer/LoadGoap/FileDialog
@onready var goap_list:ItemList = $NPC/panels/GOAPModules/VBoxContainer/ItemList

var prefab_path:String:
	set(val):
		prefab_path = val
		$Prefab.set_path_label(val)

var editing_data:NPCData


func refresh_class_list() -> void:
	mod_class_selection.clear()
	var inherited:PackedStringArray = ClassDB.get_inheriters_from_class(&"AIModule")
	for i:String in inherited:
		mod_class_selection.add_item(i)


func refresh_goap_list() -> void:
	goap_class_selection.clear()
	var inherited:PackedStringArray = ClassDB.get_inheriters_from_class(&"GOAPBehavior")
	for i:String in inherited:
		goap_class_selection.add_item(i)


func _ready() -> void:
	# Refresh
	refresh_class_list()
	refresh_goap_list()
	$Prefab.texture = null
	# Modules
	load_module_file.files_selected.connect(func(paths:PackedStringArray) -> void:
		for path:String in paths:
			add_module_to_list(load(path))
		update_ai_modules()
		)
	add_module.pressed.connect(func() -> void:
		var n:AIModule = ClassDB.instantiate(mod_class_selection.get_item_text(mod_class_selection.selected))
		add_module_to_list(n)
		)
	load_module_button.pressed.connect(load_module_file.popup_centered.bind())
	# Prefab
	$Prefab.prefab_set.connect(func(p:String) -> void: 
		prefab_path = p
		update_prefab()
		)
	# GOAP
	load_goap_file.files_selected.connect(func(paths:PackedStringArray) -> void:
		for path:String in paths:
			add_goap_to_list(load(path))
		update_goap_behaviors()
		)
	add_goap.pressed.connect(func() -> void:
		var n:GOAPBehavior = ClassDB.instantiate(goap_class_selection.get_item_text(goap_class_selection.selected))
		add_goap_to_list(n)
		)
	load_goap_button.pressed.connect(load_goap_file.popup_centered.bind())


func add_module_to_list(mod:AIModule) -> void:
	var i:int = module_list.add_item(mod.name)
	module_list.set_item_metadata(i, mod)


func add_goap_to_list(goap:GOAPBehavior) -> void:
	var i:int = goap_list.add_item(goap.name)
	goap_list.set_item_metadata(i, goap)


func update_ai_modules() -> void:
	var output:Array[AIModule] = []
	for i:int in range(goap_list.item_count):
		output.append(goap_list.get_item_metadata(i))
	editing_data.modules = output


func update_goap_behaviors() -> void:
	var output:Array[GOAPBehavior] = []
	for i:int in range(goap_list.item_count):
		output.append(goap_list.get_item_metadata(i))
	editing_data.goap_actions = output


func update_prefab() -> void:
	editing_data.prefab = load(prefab_path)
