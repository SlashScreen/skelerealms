class_name NPCSpawnPoint
extends Node3D


const UUID = preload("../vendor/uuid.gd")
## This is used for one-shot spawners; the unique ID of the spawner will be stored in here if it
## spawned its NPC. This is a hash set.
static var spawn_tracker: Dictionary # TODO: Save this
@export var templates: Array[NPCTemplateOption]
@export_enum("One Shot", "Every Time", "Must Be Triggered") var mode:int


func _ready() -> void:
	match mode:
		0:
			if not spawn_tracker.has(generate_id()):
				spawn()
		1:
			spawn()


func spawn() -> void:
	# set up entity
	var t = resolve_templates()
	if t == null:
		return
	
	var npci = NPCInstance.new()
	npci.npc_data = t
	npci.world = GameInfo.world
	npci.position = position
	var uuid:String = UUID.v4()
	npci.ref_id = uuid
	
	# add that shiz
	spawn_tracker[generate_id()] = true
	var e = EntityManager.instance.add_entity(npci)
	e.rotation = quaternion
	e.generated = true
	
	# resolve loot table
	if t.loot_table:
		for i in t.loot_table.resolve_table_to_instances():
			var ie = EntityManager.instance.add_entity(i) # Add entity
			(e.get_component("ItemComponent") as ItemComponent).contained_inventory = e.name # set contained inventory


func reset_spawner() -> void:
	spawn_tracker.erase(generate_id())


## Get a deterministic ID for this spawner.
func generate_id() -> int:
	return get_path().hash()


## Roll and select a template
func resolve_templates() -> NPCData:
	if templates.size() == 0:
		push_warning("No templates to spawn from.")
		return null
	
	while true:
		for t in templates:
			var res = t.resolve()
			if res:
				return t.template
	return null
