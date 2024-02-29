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

var editing_data:NPCInstance
var win:Window


func refresh_class_list() -> void:
	mod_class_selection.clear()
	var inherited:Array = SKToolPlugin.find_classes_that_inherit(&"AIModule")
	for d:Dictionary in inherited:
		mod_class_selection.add_item(d.class)
		mod_class_selection.set_item_metadata(mod_class_selection.item_count - 1, d.path)


func refresh_goap_list() -> void:
	goap_class_selection.clear()
	var inherited:Array = SKToolPlugin.find_classes_that_inherit(&"GOAPBehavior")
	for d:Dictionary in inherited:
		goap_class_selection.add_item(d.class)
		goap_class_selection.set_item_metadata(goap_class_selection.item_count - 1, d.path)


func _ready() -> void:
	# Refresh
	refresh_class_list()
	refresh_goap_list()
	$Prefab.clear()
	# Modules
	load_module_file.files_selected.connect(func(paths:PackedStringArray) -> void:
		for path:String in paths:
			add_module_to_list(load(path))
		update_ai_modules()
		)
	add_module.pressed.connect(func() -> void:
		if mod_class_selection.get_item_text(mod_class_selection.selected) == "":
			return
		var n:AIModule = load(mod_class_selection.get_selected_metadata()).new()
		add_module_to_list(n)
		update_ai_modules()
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
		if goap_class_selection.get_item_text(goap_class_selection.selected) == "":
			return
		var n:GOAPBehavior = load(goap_class_selection.get_selected_metadata()).new()
		add_goap_to_list(n)
		update_goap_behaviors()
		)
	load_goap_button.pressed.connect(load_goap_file.popup_centered.bind())


func edit(o: NPCInstance, w:Window) -> void:
	await ready
	editing_data = o
	w.title = o.ref_id
	win = w
	_load_res()


func _load_res() -> void:
	%RefID.text = editing_data.ref_id
	for g:GOAPBehavior in editing_data.npc_data.goap_actions:
		add_goap_to_list(g)
	for a:AIModule in editing_data.npc_data.modules:
		add_module_to_list(a)
	# Flags
	# i hate my life
	%Essential.button_pressed = editing_data.npc_data.essential
	%Essential.toggled.connect(func(s:bool) -> void: editing_data.npc_data.essential = s)
	%Ghost.button_pressed = editing_data.npc_data.ghost
	%Ghost.toggled.connect(func(s:bool) -> void: editing_data.npc_data.ghost = s)
	%Invulnerable.button_pressed = editing_data.npc_data.invulnerable
	%Invulnerable.toggled.connect(func(s:bool) -> void: editing_data.npc_data.invulnerable = s)
	%Unique.button_pressed = editing_data.npc_data.unique
	%Unique.toggled.connect(func(s:bool) -> void: editing_data.npc_data.unique = s)
	%StealthMeter.button_pressed = editing_data.npc_data.affects_stealth_meter
	%StealthMeter.toggled.connect(func(s:bool) -> void: editing_data.npc_data.affects_stealth_meter = s)
	%Interactive.button_pressed = editing_data.npc_data.interactive
	%Interactive.toggled.connect(func(s:bool) -> void: editing_data.npc_data.interactive = s)
	# Relationships
	%DefaultOpinion.value = editing_data.npc_data.default_player_opinion
	%DefaultOpinion.value_changed.connect(func(v:float)->void: editing_data.npc_data.default_player_opinion = roundi(v))
	# TODO: Load relationships to list


func add_module_to_list(mod:AIModule) -> void:
	var i:int = module_list.add_item(mod.get_type())
	module_list.set_item_metadata(i, mod)


func add_goap_to_list(goap:GOAPBehavior) -> void:
	var i:int = goap_list.add_item(goap.id)
	goap_list.set_item_metadata(i, goap)


func update_ai_modules() -> void:
	var output:Array[AIModule] = []
	for i:int in range(goap_list.item_count):
		output.append(goap_list.get_item_metadata(i))
	editing_data.npc_data.modules = output


func update_goap_behaviors() -> void:
	var output:Array[GOAPBehavior] = []
	for i:int in range(goap_list.item_count):
		output.append(goap_list.get_item_metadata(i))
	editing_data.npc_data.goap_actions = output


func update_prefab() -> void:
	editing_data.prefab = load(prefab_path)


func _on_ref_id_text_submitted(new_text: String) -> void:
	editing_data.ref_id = new_text
	win.title = new_text
